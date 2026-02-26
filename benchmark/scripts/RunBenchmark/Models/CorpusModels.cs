// ============================================================================
// CorpusModels.cs — Data models for corpus files and runtime state
// ============================================================================
// Traces To:  runner-design-spec.md §6, §8, §9
// Purpose:    Deserialization targets for questions.json, checkpoint.json,
//             archive manifest, and the runtime data structures that flow
//             between components during execution.
// ============================================================================

using System.Text.Json.Serialization;

namespace RunBenchmark.Models;

// ============================================================================
// Questions corpus — deserialized from questions.json
// ============================================================================

/// <summary>
/// A single site entry in questions.json. Contains the site's domain and
/// all questions associated with it.
/// </summary>
public sealed record SiteQuestions
{
    [JsonPropertyName("site_id")]
    public required string SiteId { get; init; }

    [JsonPropertyName("domain")]
    public required string Domain { get; init; }

    [JsonPropertyName("questions")]
    public required IReadOnlyList<Question> Questions { get; init; }
}

/// <summary>
/// A single benchmark question with its source URLs and metadata.
/// </summary>
public sealed record Question
{
    [JsonPropertyName("question_id")]
    public required string QuestionId { get; init; }

    [JsonPropertyName("text")]
    public required string Text { get; init; }

    /// <summary>
    /// Question complexity category: "single-fact", "multi-section-synthesis",
    /// "conceptual-relationship", "procedural", or "temporal".
    /// </summary>
    [JsonPropertyName("complexity")]
    public required string Complexity { get; init; }

    /// <summary>
    /// llms.txt section names that contain the answer to this question.
    /// Used by Content Assembler to identify which sections to include.
    /// </summary>
    [JsonPropertyName("source_sections")]
    public required IReadOnlyList<string> SourceSections { get; init; }

    /// <summary>
    /// URLs to the content pages that answer this question.
    /// These are keys into the archive manifest.
    /// </summary>
    [JsonPropertyName("source_urls")]
    public required IReadOnlyList<string> SourceUrls { get; init; }
}

// ============================================================================
// Checkpoint — persisted to checkpoint.json for resume support
// ============================================================================

/// <summary>
/// Checkpoint state persisted to disk after each completed (model, question) pair.
/// Enables resume after interruption per design spec §8.
/// </summary>
public sealed class CheckpointState
{
    [JsonPropertyName("config_version")]
    public string ConfigVersion { get; set; } = "";

    [JsonPropertyName("started_at")]
    public string StartedAt { get; set; } = "";

    [JsonPropertyName("last_updated_at")]
    public string LastUpdatedAt { get; set; } = "";

    [JsonPropertyName("current_model_index")]
    public int CurrentModelIndex { get; set; }

    /// <summary>
    /// Map of model_id → list of completed question_ids.
    /// A question is only added here after BOTH conditions complete.
    /// </summary>
    [JsonPropertyName("completed")]
    public Dictionary<string, List<string>> Completed { get; set; } = new();

    /// <summary>Check whether a (model, question) pair has been completed.</summary>
    public bool IsCompleted(string modelId, string questionId)
    {
        return Completed.TryGetValue(modelId, out var questions)
               && questions.Contains(questionId);
    }

    /// <summary>Mark a (model, question) pair as completed.</summary>
    public void MarkCompleted(string modelId, string questionId)
    {
        if (!Completed.TryGetValue(modelId, out var questions))
        {
            questions = new List<string>();
            Completed[modelId] = questions;
        }
        if (!questions.Contains(questionId))
        {
            questions.Add(questionId);
        }
        LastUpdatedAt = DateTime.UtcNow.ToString("o");
    }
}

// ============================================================================
// Archive manifest — deserialized from archive/manifest.json
// ============================================================================

/// <summary>
/// Root of the archive manifest file. Maps URLs to fetch results.
/// </summary>
public sealed record ArchiveManifest
{
    [JsonPropertyName("fetched_at")]
    public string? FetchedAt { get; init; }

    [JsonPropertyName("entries")]
    public required IReadOnlyList<ArchiveEntry> Entries { get; init; }
}

/// <summary>
/// A single entry in the archive manifest, recording the fetch result
/// for one URL.
/// </summary>
public sealed record ArchiveEntry
{
    [JsonPropertyName("site_id")]
    public required string SiteId { get; init; }

    [JsonPropertyName("url")]
    public required string Url { get; init; }

    [JsonPropertyName("fetch_status")]
    public required string FetchStatus { get; init; }

    /// <summary>
    /// Relative path to the archived HTML file within archive/html/.
    /// Null if fetch failed.
    /// </summary>
    [JsonPropertyName("html_path")]
    public string? HtmlPath { get; init; }

    /// <summary>
    /// Relative path to the archived Markdown file within archive/markdown/.
    /// Null if fetch failed or no Markdown equivalent exists.
    /// </summary>
    [JsonPropertyName("markdown_path")]
    public string? MarkdownPath { get; init; }

    /// <summary>
    /// The llms.txt section this URL belongs to (for Condition B assembly).
    /// </summary>
    [JsonPropertyName("llmstxt_section")]
    public string? LlmsTxtSection { get; init; }

    [JsonPropertyName("error_message")]
    public string? ErrorMessage { get; init; }

    /// <summary>Whether this entry was successfully fetched.</summary>
    [JsonIgnore]
    public bool IsSuccess => FetchStatus.Equals("SUCCESS", StringComparison.OrdinalIgnoreCase);
}

// ============================================================================
// Runtime data structures — flow between components during execution
// ============================================================================

/// <summary>
/// The assembled content for a single condition, produced by the Content Assembler
/// and consumed by the Orchestrator.
/// </summary>
public sealed record AssembledContent
{
    /// <summary>The condition this content is for: "A" or "B".</summary>
    public required string Condition { get; init; }

    /// <summary>
    /// The fully-assembled user message with content inserted into the prompt template.
    /// Null if the condition is entirely excluded.
    /// </summary>
    public string? AssembledPrompt { get; init; }

    /// <summary>
    /// Character count of the content block (before prompt template insertion).
    /// Stored in raw-data.csv as content_chars.
    /// </summary>
    public int ContentChars { get; init; }

    /// <summary>
    /// Input token count using the model family's tokenizer.
    /// 0 if tokenizer lookup not available (pre-computed tokens not found).
    /// </summary>
    public int InputTokenCount { get; init; }

    /// <summary>
    /// Input token count using the Llama 3 reference tokenizer.
    /// 0 if tokenizer lookup not available.
    /// </summary>
    public int RefTokenCount { get; init; }

    /// <summary>
    /// Computed num_ctx value for the API request.
    /// Formula: min(model.MaxContextLength, InputTokenCount + NumPredict + NumCtxOverhead).
    /// </summary>
    public int ComputedNumCtx { get; init; }

    /// <summary>
    /// If non-null, this condition is excluded and this is the reason code
    /// (e.g., "JS_ONLY", "HTTP_404", "ARCHIVE_MISSING").
    /// </summary>
    public string? ExclusionReason { get; init; }

    /// <summary>Notes about partial assembly (some source URLs failed).</summary>
    public string? ScoringNotes { get; init; }

    /// <summary>Whether this condition has usable assembled content.</summary>
    [System.Text.Json.Serialization.JsonIgnore]
    public bool IsExcluded => ExclusionReason is not null;
}

/// <summary>
/// Result of a single inference call, returned by the Inference Client.
/// </summary>
public sealed record InferenceResult
{
    /// <summary>The model's full response text. Null if the call failed.</summary>
    public string? ResponseText { get; init; }

    /// <summary>Output token count from the API response's usage field.</summary>
    public int OutputTokenCount { get; init; }

    /// <summary>Wall-clock time for the inference request in seconds.</summary>
    public double ElapsedSeconds { get; init; }

    /// <summary>
    /// If non-null, the inference call failed and this is the reason code
    /// (e.g., "TIMEOUT", "HTTP_500", "MALFORMED_RESPONSE", "EMPTY_RESPONSE").
    /// </summary>
    public string? ErrorReason { get; init; }

    /// <summary>Whether the inference call succeeded.</summary>
    [System.Text.Json.Serialization.JsonIgnore]
    public bool IsSuccess => ErrorReason is null && ResponseText is not null;
}

/// <summary>
/// A single row in raw-data.csv. This is the canonical output record
/// that the Result Writer serializes. Column order matches design spec §9.1.
/// </summary>
public sealed record ResultRow
{
    // -- Column 1-4: Tuple identifiers --
    public required string SiteId { get; init; }
    public required string QuestionId { get; init; }
    public required string ModelId { get; init; }
    public required string Condition { get; init; }

    // -- Column 5-8: Token counts and content size --
    public int InputTokenCount { get; init; }
    public int RefTokenCount { get; init; }
    public int OutputTokenCount { get; init; }
    public int ContentChars { get; init; }

    // -- Column 9: Model response --
    public string ResponseText { get; init; } = "";

    // -- Column 10-12: Metadata --
    public required string InferenceEngine { get; init; }
    public double ElapsedSeconds { get; init; }
    public string ExclusionReason { get; init; } = "";

    // -- Column 13: Scoring notes (runner writes TRUNCATED_AT_512 if applicable) --
    public string ScoringNotes { get; init; } = "";

    // -- Column 14-17: Scoring columns (null until scoring phase) --
    public int? FactualAccuracy { get; init; }
    public int? HallucinationCount { get; init; }
    public int? Completeness { get; init; }
    public int? CitationFidelity { get; init; }
}
