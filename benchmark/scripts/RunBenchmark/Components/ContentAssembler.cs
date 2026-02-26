// ============================================================================
// ContentAssembler.cs — Builds prompts for Condition A and Condition B
// ============================================================================
// Traces To:  runner-design-spec.md §6 (Content Assembly Pipeline)
// Purpose:    Given a (site, question, model) triple, produces assembled
//             prompts for both experimental conditions:
//
//             Condition A: HTML readability extraction via SmartReader (§6.2)
//             Condition B: llms.txt Markdown with preprocessing + XML wrapping (§6.3)
//
//             Also computes token counts (§6.4) and handles exclusions (§6.5).
//
// The Content Assembler is the most complex component because it implements
// two distinct extraction pipelines and handles the per-question scoping logic
// that determines which archived pages are included in each prompt.
//
// LlmsTxtKit integration: Uses LlmsDocumentParser for parsing llms.txt files
// to determine section membership and XML wrapping structure. The XML format
// uses <project>/<section_name>/<doc> structure per methodology §2.3.
// ============================================================================

using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using LlmsTxtKit.Core.Parsing;
using Microsoft.Extensions.Logging;
using RunBenchmark.Models;
using SmartReader;

namespace RunBenchmark.Components;

/// <summary>
/// Interface for llms.txt parsing, allowing LlmsTxtKit or a fallback
/// implementation to be swapped without changing the Content Assembler.
/// See design spec §2.3.
/// </summary>
public interface ILlmsTxtParser
{
    /// <summary>
    /// Parses an llms.txt file and returns the structured document.
    /// </summary>
    LlmsDocument Parse(string content);

    /// <summary>
    /// Finds which section a given URL belongs to in the parsed document.
    /// Returns null if the URL is not found in any section.
    /// </summary>
    LlmsSection? FindSectionForUrl(LlmsDocument document, string url);
}

/// <summary>
/// Default ILlmsTxtParser implementation using LlmsTxtKit.Core.
/// </summary>
public sealed class LlmsTxtKitParser : ILlmsTxtParser
{
    public LlmsDocument Parse(string content) =>
        LlmsDocumentParser.Parse(content);

    public LlmsSection? FindSectionForUrl(LlmsDocument document, string url)
    {
        // Normalize URL for comparison (remove trailing slash, lowercase)
        var normalizedUrl = NormalizeUrl(url);

        foreach (var section in document.Sections)
        {
            foreach (var entry in section.Entries)
            {
                if (NormalizeUrl(entry.Url.ToString()) == normalizedUrl)
                    return section;
            }
        }
        return null;
    }

    private static string NormalizeUrl(string url)
    {
        return url.TrimEnd('/').ToLowerInvariant();
    }
}

/// <summary>
/// Pre-computed token counts loaded from token-counts.json (if available).
/// See design spec §12.1 — token counts are pre-computed by a Python script
/// to avoid runtime Python dependencies.
/// </summary>
public sealed class TokenCountLookup
{
    /// <summary>
    /// Key: (siteId, questionId, condition, family) → token count.
    /// </summary>
    private readonly Dictionary<string, int> _counts = new();

    /// <summary>
    /// Reference token counts (Llama 3 tokenizer).
    /// Key: (siteId, questionId, condition) → token count.
    /// </summary>
    private readonly Dictionary<string, int> _refCounts = new();

    /// <summary>Whether any token counts were loaded.</summary>
    public bool IsLoaded => _counts.Count > 0;

    /// <summary>
    /// Loads token counts from a JSON lookup file.
    /// File format: array of objects with siteId, questionId, condition, family, tokenCount, refTokenCount.
    /// </summary>
    public static TokenCountLookup LoadFromFile(string path, ILogger logger)
    {
        var lookup = new TokenCountLookup();

        if (!File.Exists(path))
        {
            logger.LogWarning(
                "Token count lookup file not found: {Path}. " +
                "Token counts will be recorded as 0. " +
                "Run scripts/precompute-token-counts.py to generate.",
                path);
            return lookup;
        }

        try
        {
            var json = File.ReadAllText(path);
            using var doc = JsonDocument.Parse(json);

            foreach (var entry in doc.RootElement.EnumerateArray())
            {
                var siteId = entry.GetProperty("site_id").GetString() ?? "";
                var questionId = entry.GetProperty("question_id").GetString() ?? "";
                var condition = entry.GetProperty("condition").GetString() ?? "";
                var family = entry.GetProperty("family").GetString() ?? "";
                var tokenCount = entry.GetProperty("token_count").GetInt32();
                var refTokenCount = entry.GetProperty("ref_token_count").GetInt32();

                var key = $"{siteId}|{questionId}|{condition}|{family}";
                lookup._counts[key] = tokenCount;

                var refKey = $"{siteId}|{questionId}|{condition}";
                lookup._refCounts[refKey] = refTokenCount;
            }

            logger.LogInformation("Loaded {Count} token count entries from {Path}.",
                lookup._counts.Count, path);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex,
                "Failed to load token counts from {Path}: {Error}",
                path, ex.Message);
        }

        return lookup;
    }

    /// <summary>Gets the token count for a specific (site, question, condition, family).</summary>
    public int GetTokenCount(string siteId, string questionId, string condition, string family)
    {
        var key = $"{siteId}|{questionId}|{condition}|{family}";
        return _counts.GetValueOrDefault(key, 0);
    }

    /// <summary>Gets the reference token count for a specific (site, question, condition).</summary>
    public int GetRefTokenCount(string siteId, string questionId, string condition)
    {
        var key = $"{siteId}|{questionId}|{condition}";
        return _refCounts.GetValueOrDefault(key, 0);
    }
}

/// <summary>
/// Assembles content for both experimental conditions given a
/// (site, question, model) triple.
/// </summary>
public sealed class ContentAssembler
{
    private readonly BenchmarkConfig _config;
    private readonly ILlmsTxtParser _parser;
    private readonly TokenCountLookup _tokenLookup;
    private readonly ILogger _logger;

    // -- Compiled regex patterns for Markdown preprocessing (§6.3) --

    /// <summary>Strips HTML comments: &lt;!-- ... --&gt;</summary>
    private static readonly Regex HtmlCommentRegex = new(
        @"<!--[\s\S]*?-->",
        RegexOptions.Compiled);

    /// <summary>Strips base64 images: ![...](data:image/...)</summary>
    private static readonly Regex Base64ImageRegex = new(
        @"!\[[^\]]*\]\(data:image/[^)]+\)",
        RegexOptions.Compiled);

    /// <summary>Collapses runs of &gt;2 consecutive blank lines to 2.</summary>
    private static readonly Regex ExcessBlankLinesRegex = new(
        @"\n{4,}",
        RegexOptions.Compiled);

    /// <summary>
    /// Cache of parsed llms.txt documents, keyed by site_id.
    /// Parsed once per site, reused across all questions for that site.
    /// </summary>
    private readonly Dictionary<string, LlmsDocument?> _llmsTxtCache = new();

    public ContentAssembler(
        BenchmarkConfig config,
        ILlmsTxtParser parser,
        TokenCountLookup tokenLookup,
        ILogger logger)
    {
        _config = config;
        _parser = parser;
        _tokenLookup = tokenLookup;
        _logger = logger;
    }

    /// <summary>
    /// Assembles content for a single condition.
    /// </summary>
    /// <param name="siteId">The site identifier.</param>
    /// <param name="question">The question to answer.</param>
    /// <param name="model">The model configuration (for tokenizer selection).</param>
    /// <param name="condition">The condition: "A" or "B".</param>
    /// <param name="manifest">The archive manifest for looking up content paths.</param>
    /// <returns>An <see cref="AssembledContent"/> with the prompt or exclusion info.</returns>
    public AssembledContent AssembleCondition(
        string siteId,
        Question question,
        ModelConfig model,
        string condition,
        ArchiveManifest manifest)
    {
        try
        {
            if (condition == "A")
                return AssembleConditionA(siteId, question, model, manifest);
            else
                return AssembleConditionB(siteId, question, model, manifest);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex,
                "Content assembly failed for {SiteId}/{QuestionId}/Condition {Condition}: {Error}",
                siteId, question.QuestionId, condition, ex.Message);

            return new AssembledContent
            {
                Condition = condition,
                ExclusionReason = "ASSEMBLY_ERROR",
                ScoringNotes = $"Assembly error: {ex.Message}"
            };
        }
    }

    // ========================================================================
    // Condition A: SmartReader HTML extraction (§6.2)
    // ========================================================================

    /// <summary>
    /// Assembles Condition A content by running SmartReader on archived HTML.
    /// </summary>
    private AssembledContent AssembleConditionA(
        string siteId,
        Question question,
        ModelConfig model,
        ArchiveManifest manifest)
    {
        var extractedTexts = new List<string>();
        var failedUrls = new List<string>();
        var archiveDir = _config.Paths.ArchiveDir;

        foreach (var sourceUrl in question.SourceUrls)
        {
            // Look up the archive entry for this URL
            var entry = manifest.Entries.FirstOrDefault(e =>
                e.Url.Equals(sourceUrl, StringComparison.OrdinalIgnoreCase) ||
                e.Url.TrimEnd('/').Equals(sourceUrl.TrimEnd('/'), StringComparison.OrdinalIgnoreCase));

            if (entry is null || !entry.IsSuccess || entry.HtmlPath is null)
            {
                var reason = entry is null ? "not in manifest"
                    : !entry.IsSuccess ? $"fetch failed: {entry.FetchStatus}"
                    : "no HTML path";
                _logger.LogWarning(
                    "Condition A: Skipping URL {Url} for {QuestionId} ({Reason}).",
                    sourceUrl, question.QuestionId, reason);
                failedUrls.Add(sourceUrl);
                continue;
            }

            // Read the archived HTML
            var htmlPath = Path.Combine(archiveDir, entry.HtmlPath);
            if (!File.Exists(htmlPath))
            {
                _logger.LogWarning("Condition A: HTML file missing: {Path}", htmlPath);
                failedUrls.Add(sourceUrl);
                continue;
            }

            var html = File.ReadAllText(htmlPath);

            // Run SmartReader extraction (§6.2)
            try
            {
                var article = Reader.ParseArticle(sourceUrl, html);

                if (article?.IsReadable != true ||
                    string.IsNullOrWhiteSpace(article.TextContent))
                {
                    _logger.LogWarning(
                        "Condition A: SmartReader returned non-readable for {Url}.",
                        sourceUrl);
                    failedUrls.Add(sourceUrl);
                    continue;
                }

                var text = article.TextContent.Trim();

                // Check minimum content length threshold (§6.2, step 3)
                if (text.Length < _config.Extraction.MinContentLengthChars)
                {
                    _logger.LogWarning(
                        "Condition A: Extracted text below threshold ({Length} < {Min}) for {Url}. " +
                        "Excluding as JS_ONLY.",
                        text.Length, _config.Extraction.MinContentLengthChars, sourceUrl);
                    failedUrls.Add(sourceUrl);
                    continue;
                }

                extractedTexts.Add(text);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Condition A: SmartReader exception for {Url}: {Error}",
                    sourceUrl, ex.Message);
                failedUrls.Add(sourceUrl);
            }
        }

        // Handle exclusion scenarios (§6.5)
        if (extractedTexts.Count == 0)
        {
            return new AssembledContent
            {
                Condition = "A",
                ExclusionReason = "JS_ONLY",
                ScoringNotes = $"All {question.SourceUrls.Count} source URLs failed extraction."
            };
        }

        // Concatenate with separator (§6.2, step 5)
        var assembledContent = string.Join("\n\n---\n\n", extractedTexts);

        // Build the full prompt using the template
        var userPrompt = _config.PromptTemplate.UserPrompt
            .Replace("{assembled_content}", assembledContent)
            .Replace("{question_text}", question.Text);

        // Compute token counts (§6.4)
        var inputTokenCount = _tokenLookup.GetTokenCount(
            siteId, question.QuestionId, "A", model.Family);
        var refTokenCount = _tokenLookup.GetRefTokenCount(
            siteId, question.QuestionId, "A");

        // Compute dynamic num_ctx (§6.4)
        var numCtx = ComputeNumCtx(inputTokenCount, model);

        // Build scoring notes for partial assembly
        string? scoringNotes = failedUrls.Count > 0
            ? $"Partial assembly: {failedUrls.Count}/{question.SourceUrls.Count} URLs failed."
            : null;

        return new AssembledContent
        {
            Condition = "A",
            AssembledPrompt = userPrompt,
            ContentChars = assembledContent.Length,
            InputTokenCount = inputTokenCount,
            RefTokenCount = refTokenCount,
            ComputedNumCtx = numCtx,
            ScoringNotes = scoringNotes
        };
    }

    // ========================================================================
    // Condition B: Markdown preprocessing + XML wrapping (§6.3)
    // ========================================================================

    /// <summary>
    /// Assembles Condition B content by preprocessing Markdown and wrapping
    /// in the XML context structure.
    /// </summary>
    private AssembledContent AssembleConditionB(
        string siteId,
        Question question,
        ModelConfig model,
        ArchiveManifest manifest)
    {
        var archiveDir = _config.Paths.ArchiveDir;
        var failedUrls = new List<string>();

        // Step 1: Parse the site's llms.txt to get section structure
        var llmsDoc = GetOrParseLlmsTxt(siteId, manifest);

        // Step 2: For each source URL, read and preprocess the Markdown
        var docEntries = new List<(string sectionName, string title, string url, string content)>();

        foreach (var sourceUrl in question.SourceUrls)
        {
            var entry = manifest.Entries.FirstOrDefault(e =>
                e.Url.Equals(sourceUrl, StringComparison.OrdinalIgnoreCase) ||
                e.Url.TrimEnd('/').Equals(sourceUrl.TrimEnd('/'), StringComparison.OrdinalIgnoreCase));

            if (entry is null || !entry.IsSuccess || entry.MarkdownPath is null)
            {
                _logger.LogWarning(
                    "Condition B: Skipping URL {Url} for {QuestionId} (no Markdown).",
                    sourceUrl, question.QuestionId);
                failedUrls.Add(sourceUrl);
                continue;
            }

            var mdPath = Path.Combine(archiveDir, entry.MarkdownPath);
            if (!File.Exists(mdPath))
            {
                _logger.LogWarning("Condition B: Markdown file missing: {Path}", mdPath);
                failedUrls.Add(sourceUrl);
                continue;
            }

            var rawMarkdown = File.ReadAllText(mdPath);

            // Apply preprocessing (§6.3)
            var preprocessed = PreprocessMarkdown(rawMarkdown);

            // Determine which section this URL belongs to
            var sectionName = entry.LlmsTxtSection ?? "Unknown";
            if (llmsDoc is not null)
            {
                var section = _parser.FindSectionForUrl(llmsDoc, sourceUrl);
                if (section is not null)
                    sectionName = section.Name;
            }

            // Get the title from the llms.txt entry or from the URL
            var title = GetDocTitle(llmsDoc, sourceUrl) ?? sourceUrl;

            docEntries.Add((sectionName, title, sourceUrl, preprocessed));
        }

        // Handle exclusion (§6.5)
        if (docEntries.Count == 0)
        {
            return new AssembledContent
            {
                Condition = "B",
                ExclusionReason = "MARKDOWN_MISSING",
                ScoringNotes = $"All {question.SourceUrls.Count} source URLs have no Markdown."
            };
        }

        // Step 3: Wrap in XML context structure (§6.3)
        var xmlContent = BuildXmlContext(siteId, llmsDoc, docEntries);

        // Build the full prompt
        var userPrompt = _config.PromptTemplate.UserPrompt
            .Replace("{assembled_content}", xmlContent)
            .Replace("{question_text}", question.Text);

        // Compute token counts
        var inputTokenCount = _tokenLookup.GetTokenCount(
            siteId, question.QuestionId, "B", model.Family);
        var refTokenCount = _tokenLookup.GetRefTokenCount(
            siteId, question.QuestionId, "B");

        var numCtx = ComputeNumCtx(inputTokenCount, model);

        string? scoringNotes = failedUrls.Count > 0
            ? $"Partial assembly: {failedUrls.Count}/{question.SourceUrls.Count} URLs failed."
            : null;

        return new AssembledContent
        {
            Condition = "B",
            AssembledPrompt = userPrompt,
            ContentChars = xmlContent.Length,
            InputTokenCount = inputTokenCount,
            RefTokenCount = refTokenCount,
            ComputedNumCtx = numCtx,
            ScoringNotes = scoringNotes
        };
    }

    // ========================================================================
    // Markdown preprocessing (§6.3)
    // ========================================================================

    /// <summary>
    /// Applies the four preprocessing steps from config.extraction.markdown_preprocessing.
    /// </summary>
    private string PreprocessMarkdown(string raw)
    {
        var result = raw;
        var pp = _config.Extraction.MarkdownPreprocessing;

        // 1. Strip HTML comments
        if (pp.StripHtmlComments)
            result = HtmlCommentRegex.Replace(result, "");

        // 2. Strip base64 images
        if (pp.StripBase64Images)
            result = Base64ImageRegex.Replace(result, "");

        // 3. Normalize line endings (do this before blank line collapsing)
        if (pp.NormalizeLineEndings == "LF")
        {
            result = result.Replace("\r\n", "\n").Replace("\r", "\n");
        }

        // 4. Normalize blank lines (collapse >N consecutive to N)
        if (pp.MaxConsecutiveBlankLines > 0)
        {
            // A "blank line" is a line containing only whitespace.
            // N consecutive blank lines = N+1 newlines in a row.
            // We want to allow at most MaxConsecutiveBlankLines blank lines,
            // which means MaxConsecutiveBlankLines+1 newlines.
            var maxNewlines = pp.MaxConsecutiveBlankLines + 1;
            var replacement = new string('\n', maxNewlines);
            result = ExcessBlankLinesRegex.Replace(result, replacement);
        }

        return result.Trim();
    }

    // ========================================================================
    // XML context building (§6.3)
    // ========================================================================

    /// <summary>
    /// Builds the XML context structure per methodology §2.3:
    /// &lt;project title="..." summary="..."&gt;
    ///   &lt;section_name&gt;
    ///     &lt;doc title="..." url="..."&gt;
    ///       {preprocessed_markdown}
    ///     &lt;/doc&gt;
    ///   &lt;/section_name&gt;
    /// &lt;/project&gt;
    /// </summary>
    private string BuildXmlContext(
        string siteId,
        LlmsDocument? llmsDoc,
        List<(string sectionName, string title, string url, string content)> docs)
    {
        var sb = new StringBuilder();

        // Project wrapper with title and summary from llms.txt
        var projectTitle = EscapeXml(llmsDoc?.Title ?? siteId);
        var projectSummary = EscapeXml(llmsDoc?.Summary ?? "");

        sb.AppendLine($"<project title=\"{projectTitle}\" summary=\"{projectSummary}\">");

        // Group docs by section name to create section elements
        var sections = docs.GroupBy(d => d.sectionName);

        foreach (var section in sections)
        {
            // Use the section name as the XML element name, sanitized for XML
            var sectionTag = SanitizeXmlTag(section.Key);
            sb.AppendLine($"  <{sectionTag}>");

            foreach (var (_, title, url, content) in section)
            {
                sb.AppendLine($"    <doc title=\"{EscapeXml(title)}\" url=\"{EscapeXml(url)}\">");
                sb.AppendLine(content);
                sb.AppendLine("    </doc>");
            }

            sb.AppendLine($"  </{sectionTag}>");
        }

        sb.Append("</project>");

        return sb.ToString();
    }

    // ========================================================================
    // llms.txt parsing and caching
    // ========================================================================

    /// <summary>
    /// Gets or parses the llms.txt document for a site. Cached per site_id.
    /// </summary>
    private LlmsDocument? GetOrParseLlmsTxt(string siteId, ArchiveManifest manifest)
    {
        if (_llmsTxtCache.TryGetValue(siteId, out var cached))
            return cached;

        // Look for the llms.txt file in the archive
        // The llms.txt URL is typically the site's llms.txt endpoint
        var llmsTxtEntry = manifest.Entries.FirstOrDefault(e =>
            e.SiteId == siteId &&
            e.Url.EndsWith("/llms.txt", StringComparison.OrdinalIgnoreCase) &&
            e.IsSuccess &&
            e.MarkdownPath is not null);

        if (llmsTxtEntry is null)
        {
            _logger.LogWarning(
                "No llms.txt archive entry found for site {SiteId}. " +
                "Condition B XML wrapping will use fallback section names.",
                siteId);
            _llmsTxtCache[siteId] = null;
            return null;
        }

        var mdPath = Path.Combine(_config.Paths.ArchiveDir, llmsTxtEntry.MarkdownPath!);
        if (!File.Exists(mdPath))
        {
            _logger.LogWarning("llms.txt file missing from archive: {Path}", mdPath);
            _llmsTxtCache[siteId] = null;
            return null;
        }

        try
        {
            var content = File.ReadAllText(mdPath);
            var document = _parser.Parse(content);
            _llmsTxtCache[siteId] = document;

            _logger.LogDebug(
                "Parsed llms.txt for {SiteId}: title=\"{Title}\", sections={Sections}",
                siteId, document.Title, document.Sections.Count);

            return document;
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex,
                "Failed to parse llms.txt for {SiteId}: {Error}",
                siteId, ex.Message);
            _llmsTxtCache[siteId] = null;
            return null;
        }
    }

    /// <summary>
    /// Gets the title of a document from the llms.txt entries by matching URL.
    /// </summary>
    private static string? GetDocTitle(LlmsDocument? llmsDoc, string url)
    {
        if (llmsDoc is null) return null;

        var normalizedUrl = url.TrimEnd('/').ToLowerInvariant();

        foreach (var section in llmsDoc.Sections)
        {
            foreach (var entry in section.Entries)
            {
                if (entry.Url.ToString().TrimEnd('/').ToLowerInvariant() == normalizedUrl)
                    return entry.Title;
            }
        }
        return null;
    }

    // ========================================================================
    // Token count and num_ctx computation (§6.4)
    // ========================================================================

    /// <summary>
    /// Computes the dynamic num_ctx per design spec §6.4:
    /// min(model.MaxContextLength, inputTokenCount + numPredict + numCtxOverhead)
    /// </summary>
    private int ComputeNumCtx(int inputTokenCount, ModelConfig model)
    {
        var ip = _config.InferenceParameters;
        var computed = inputTokenCount + ip.NumPredict + ip.NumCtxOverhead;
        return Math.Min(model.MaxContextLength, computed);
    }

    // ========================================================================
    // XML helpers
    // ========================================================================

    /// <summary>Escapes a string for use in XML attribute values.</summary>
    private static string EscapeXml(string value)
    {
        return value
            .Replace("&", "&amp;")
            .Replace("\"", "&quot;")
            .Replace("<", "&lt;")
            .Replace(">", "&gt;")
            .Replace("'", "&apos;");
    }

    /// <summary>
    /// Sanitizes a string for use as an XML element name.
    /// Replaces spaces and special characters with underscores.
    /// </summary>
    private static string SanitizeXmlTag(string name)
    {
        // Replace spaces with underscores, remove non-alphanumeric except underscore/hyphen
        var sanitized = Regex.Replace(name, @"[^a-zA-Z0-9_\-]", "_");

        // XML element names can't start with a digit
        if (sanitized.Length > 0 && char.IsDigit(sanitized[0]))
            sanitized = "_" + sanitized;

        return string.IsNullOrEmpty(sanitized) ? "unknown" : sanitized;
    }
}
