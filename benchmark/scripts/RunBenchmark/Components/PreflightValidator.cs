// ============================================================================
// PreflightValidator.cs — Comprehensive pre-run checks
// ============================================================================
// Traces To:  runner-design-spec.md §4.2 (Validate Phase)
// Purpose:    Runs 10 checks before any inference begins. Returns a pass/fail
//             result with a list of issues. Fatal check failures abort the run;
//             warnings are logged but do not prevent execution.
//
// Philosophy: Catch problems early — before 3 hours of small-model inference
//             discovers that the archive is missing pages for Site S015.
// ============================================================================

using System.Text.Json;
using Microsoft.Extensions.Logging;
using RunBenchmark.Models;

namespace RunBenchmark.Components;

/// <summary>
/// Result of a single pre-flight check.
/// </summary>
public sealed record ValidationResult(
    string CheckId,
    string Description,
    bool Passed,
    bool IsFatal,
    string? Details = null);

/// <summary>
/// Runs the 10 pre-flight validation checks from design spec §4.2.
/// </summary>
public sealed class PreflightValidator
{
    private readonly BenchmarkConfig _config;
    private readonly InferenceClient _inferenceClient;
    private readonly ILogger _logger;

    public PreflightValidator(
        BenchmarkConfig config,
        InferenceClient inferenceClient,
        ILogger logger)
    {
        _config = config;
        _inferenceClient = inferenceClient;
        _logger = logger;
    }

    /// <summary>
    /// Runs all pre-flight checks and returns the results.
    /// </summary>
    /// <returns>
    /// Ordered list of validation results. Check <see cref="ValidationResult.Passed"/>
    /// and <see cref="ValidationResult.IsFatal"/> to determine whether to proceed.
    /// </returns>
    public async Task<List<ValidationResult>> RunAllChecksAsync(
        CancellationToken cancellationToken = default)
    {
        var results = new List<ValidationResult>();

        _logger.LogInformation("Running pre-flight validation...");

        // V-1: Config file parses without error
        //      (Already passed if we got here — ConfigLoader would have thrown)
        results.Add(new ValidationResult("V-1", "Config file parses without error",
            Passed: true, IsFatal: true));

        // V-2: All paths resolve to existing files/directories
        results.Add(CheckPaths());

        // V-3: questions.json schema valid
        results.Add(CheckQuestionsSchema());

        // V-4: Archive manifest exists and all source URLs have entries
        results.Add(CheckArchiveManifest());

        // V-5: Archive entries with SUCCESS have non-empty content files
        results.Add(CheckArchiveFiles());

        // V-6: Inference endpoint responds to health check
        results.Add(await CheckEndpointHealthAsync(cancellationToken));

        // V-7: All models available at the endpoint
        results.Add(await CheckModelsAvailableAsync(cancellationToken));

        // V-8: Checkpoint version matches (if resuming)
        results.Add(CheckCheckpointVersion());

        // V-9: Checkpoint/CSV cross-validation (if resuming)
        results.Add(CheckCheckpointCsvConsistency());

        // V-10: Disk space estimate
        results.Add(CheckDiskSpace());

        // Report summary
        var fatal = results.Count(r => !r.Passed && r.IsFatal);
        var warnings = results.Count(r => !r.Passed && !r.IsFatal);
        var passed = results.Count(r => r.Passed);

        _logger.LogInformation(
            "Pre-flight validation complete: {Passed} passed, {Fatal} fatal, {Warnings} warnings.",
            passed, fatal, warnings);

        foreach (var r in results.Where(r => !r.Passed))
        {
            if (r.IsFatal)
                _logger.LogError("[FATAL] {CheckId}: {Description} — {Details}",
                    r.CheckId, r.Description, r.Details);
            else
                _logger.LogWarning("[WARN] {CheckId}: {Description} — {Details}",
                    r.CheckId, r.Description, r.Details);
        }

        return results;
    }

    // ========================================================================
    // Individual checks
    // ========================================================================

    /// <summary>V-2: All paths in config.paths resolve to existing files/dirs.</summary>
    private ValidationResult CheckPaths()
    {
        var missing = new List<string>();

        CheckFileExists(_config.Paths.Questions, "questions", missing);
        CheckFileExists(_config.Paths.GoldAnswers, "gold_answers", missing);
        CheckFileExists(_config.Paths.SiteList, "site_list", missing);
        CheckFileExists(_config.Paths.ScoringRubric, "scoring_rubric", missing);
        CheckDirExists(_config.Paths.ArchiveDir, "archive_dir", missing);

        // Note: results_dir, raw_data_csv, checkpoint_file may not exist yet
        // (they're created by the runner). We only check input paths.

        if (missing.Count > 0)
        {
            return new ValidationResult("V-2",
                "All input paths resolve to existing files/directories",
                Passed: false, IsFatal: true,
                Details: $"Missing: {string.Join(", ", missing)}");
        }

        return new ValidationResult("V-2",
            "All input paths resolve to existing files/directories",
            Passed: true, IsFatal: true);
    }

    /// <summary>V-3: questions.json schema valid.</summary>
    private ValidationResult CheckQuestionsSchema()
    {
        try
        {
            var json = File.ReadAllText(_config.Paths.Questions);
            var sites = JsonSerializer.Deserialize<List<SiteQuestions>>(json);

            if (sites is null || sites.Count == 0)
            {
                return new ValidationResult("V-3", "questions.json schema valid",
                    Passed: false, IsFatal: true,
                    Details: "questions.json is empty or deserialized to null.");
            }

            // Check for unique question IDs
            var allQuestionIds = new HashSet<string>();
            var duplicates = new List<string>();

            foreach (var site in sites)
            {
                foreach (var q in site.Questions)
                {
                    if (string.IsNullOrEmpty(q.QuestionId))
                    {
                        return new ValidationResult("V-3", "questions.json schema valid",
                            Passed: false, IsFatal: true,
                            Details: $"Question in site {site.SiteId} has empty question_id.");
                    }

                    if (!allQuestionIds.Add(q.QuestionId))
                        duplicates.Add(q.QuestionId);

                    if (q.SourceUrls.Count == 0)
                    {
                        return new ValidationResult("V-3", "questions.json schema valid",
                            Passed: false, IsFatal: true,
                            Details: $"Question {q.QuestionId} has empty source_urls array.");
                    }
                }
            }

            if (duplicates.Count > 0)
            {
                return new ValidationResult("V-3", "questions.json schema valid",
                    Passed: false, IsFatal: true,
                    Details: $"Duplicate question IDs: {string.Join(", ", duplicates)}");
            }

            _logger.LogDebug("questions.json: {SiteCount} sites, {QuestionCount} questions.",
                sites.Count, allQuestionIds.Count);

            return new ValidationResult("V-3", "questions.json schema valid",
                Passed: true, IsFatal: true);
        }
        catch (Exception ex) when (ex is JsonException or IOException)
        {
            return new ValidationResult("V-3", "questions.json schema valid",
                Passed: false, IsFatal: true,
                Details: ex.Message);
        }
    }

    /// <summary>V-4: Archive manifest exists and covers all source URLs.</summary>
    private ValidationResult CheckArchiveManifest()
    {
        if (!File.Exists(_config.Paths.ArchiveManifest))
        {
            return new ValidationResult("V-4",
                "Archive manifest exists and covers all source URLs",
                Passed: false, IsFatal: true,
                Details: $"Manifest not found: {_config.Paths.ArchiveManifest}");
        }

        try
        {
            var manifestJson = File.ReadAllText(_config.Paths.ArchiveManifest);
            var manifest = JsonSerializer.Deserialize<ArchiveManifest>(manifestJson);

            if (manifest?.Entries is null)
            {
                return new ValidationResult("V-4",
                    "Archive manifest exists and covers all source URLs",
                    Passed: false, IsFatal: true,
                    Details: "Manifest entries are null.");
            }

            // Build a set of all URLs in the manifest
            var manifestUrls = new HashSet<string>(
                manifest.Entries.Select(e => e.Url),
                StringComparer.OrdinalIgnoreCase);

            // Check all source_urls from questions.json
            var questionsJson = File.ReadAllText(_config.Paths.Questions);
            var sites = JsonSerializer.Deserialize<List<SiteQuestions>>(questionsJson)!;
            var missingUrls = new List<string>();

            foreach (var site in sites)
            {
                foreach (var q in site.Questions)
                {
                    foreach (var url in q.SourceUrls)
                    {
                        if (!manifestUrls.Contains(url))
                            missingUrls.Add($"{q.QuestionId}: {url}");
                    }
                }
            }

            if (missingUrls.Count > 0)
            {
                return new ValidationResult("V-4",
                    "Archive manifest exists and covers all source URLs",
                    Passed: false, IsFatal: true,
                    Details: $"{missingUrls.Count} source URLs missing from manifest. " +
                             $"First 5: {string.Join("; ", missingUrls.Take(5))}");
            }

            return new ValidationResult("V-4",
                "Archive manifest exists and covers all source URLs",
                Passed: true, IsFatal: true);
        }
        catch (Exception ex) when (ex is JsonException or IOException)
        {
            return new ValidationResult("V-4",
                "Archive manifest exists and covers all source URLs",
                Passed: false, IsFatal: true,
                Details: ex.Message);
        }
    }

    /// <summary>V-5: SUCCESS entries have non-empty content files.</summary>
    private ValidationResult CheckArchiveFiles()
    {
        try
        {
            if (!File.Exists(_config.Paths.ArchiveManifest))
            {
                return new ValidationResult("V-5",
                    "Archive content files exist and are non-empty",
                    Passed: false, IsFatal: true,
                    Details: "Cannot check — manifest not found.");
            }

            var manifestJson = File.ReadAllText(_config.Paths.ArchiveManifest);
            var manifest = JsonSerializer.Deserialize<ArchiveManifest>(manifestJson)!;
            var archiveDir = _config.Paths.ArchiveDir;
            var missingFiles = new List<string>();

            foreach (var entry in manifest.Entries.Where(e => e.IsSuccess))
            {
                // Check HTML file
                if (entry.HtmlPath is not null)
                {
                    var htmlFullPath = Path.Combine(archiveDir, entry.HtmlPath);
                    if (!File.Exists(htmlFullPath) || new FileInfo(htmlFullPath).Length == 0)
                        missingFiles.Add($"HTML: {entry.HtmlPath}");
                }

                // Check Markdown file
                if (entry.MarkdownPath is not null)
                {
                    var mdFullPath = Path.Combine(archiveDir, entry.MarkdownPath);
                    if (!File.Exists(mdFullPath) || new FileInfo(mdFullPath).Length == 0)
                        missingFiles.Add($"MD: {entry.MarkdownPath}");
                }
            }

            if (missingFiles.Count > 0)
            {
                return new ValidationResult("V-5",
                    "Archive content files exist and are non-empty",
                    Passed: false, IsFatal: true,
                    Details: $"{missingFiles.Count} missing/empty files. " +
                             $"First 5: {string.Join("; ", missingFiles.Take(5))}");
            }

            return new ValidationResult("V-5",
                "Archive content files exist and are non-empty",
                Passed: true, IsFatal: true);
        }
        catch (Exception ex)
        {
            return new ValidationResult("V-5",
                "Archive content files exist and are non-empty",
                Passed: false, IsFatal: true,
                Details: ex.Message);
        }
    }

    /// <summary>V-6: Inference endpoint responds to health check.</summary>
    private async Task<ValidationResult> CheckEndpointHealthAsync(
        CancellationToken cancellationToken)
    {
        var healthy = await _inferenceClient.CheckHealthAsync(cancellationToken);

        return new ValidationResult("V-6",
            "Inference endpoint responds to health check",
            Passed: healthy, IsFatal: true,
            Details: healthy ? null : $"Endpoint at {_config.InferenceEndpoint.FullUrl} unreachable.");
    }

    /// <summary>V-7: All models available at the endpoint.</summary>
    private async Task<ValidationResult> CheckModelsAvailableAsync(
        CancellationToken cancellationToken)
    {
        var available = await _inferenceClient.GetAvailableModelsAsync(cancellationToken);

        if (available.Count == 0)
        {
            return new ValidationResult("V-7",
                "All models available at endpoint",
                Passed: true, IsFatal: false,
                Details: "Could not retrieve model list (may not be supported). " +
                         "Models will be verified at runtime.");
        }

        var missing = _config.Models
            .Where(m => !available.Any(a =>
                a.Equals(m.OllamaTag, StringComparison.OrdinalIgnoreCase) ||
                a.StartsWith(m.OllamaTag.Split(':')[0], StringComparison.OrdinalIgnoreCase)))
            .Select(m => m.OllamaTag)
            .ToList();

        if (missing.Count > 0)
        {
            return new ValidationResult("V-7",
                "All models available at endpoint",
                Passed: false, IsFatal: false,  // Warning, not fatal (§4.2)
                Details: $"Missing models: {string.Join(", ", missing)}. " +
                         "Pull them with 'ollama pull' before running.");
        }

        return new ValidationResult("V-7",
            "All models available at endpoint",
            Passed: true, IsFatal: false);
    }

    /// <summary>V-8: Checkpoint version matches current config.</summary>
    private ValidationResult CheckCheckpointVersion()
    {
        if (!File.Exists(_config.Paths.CheckpointFile))
        {
            return new ValidationResult("V-8",
                "Checkpoint version matches current config",
                Passed: true, IsFatal: false,
                Details: "No checkpoint file (fresh run).");
        }

        try
        {
            var json = File.ReadAllText(_config.Paths.CheckpointFile);
            var checkpoint = JsonSerializer.Deserialize<CheckpointState>(json);

            if (checkpoint?.ConfigVersion != _config.Version)
            {
                return new ValidationResult("V-8",
                    "Checkpoint version matches current config",
                    Passed: false, IsFatal: false,
                    Details: $"Checkpoint version '{checkpoint?.ConfigVersion}' " +
                             $"doesn't match config version '{_config.Version}'.");
            }

            return new ValidationResult("V-8",
                "Checkpoint version matches current config",
                Passed: true, IsFatal: false);
        }
        catch (Exception ex)
        {
            return new ValidationResult("V-8",
                "Checkpoint version matches current config",
                Passed: false, IsFatal: false,
                Details: ex.Message);
        }
    }

    /// <summary>V-9: Checkpoint/CSV cross-validation.</summary>
    private ValidationResult CheckCheckpointCsvConsistency()
    {
        if (!File.Exists(_config.Paths.CheckpointFile) ||
            !File.Exists(_config.Paths.RawDataCsv))
        {
            return new ValidationResult("V-9",
                "Checkpoint/CSV consistency",
                Passed: true, IsFatal: false,
                Details: "No checkpoint or CSV to cross-validate.");
        }

        try
        {
            var csvTuples = ResultWriter.ReadCompletedTuples(
                _config.Paths.RawDataCsv, _logger);

            var checkpointJson = File.ReadAllText(_config.Paths.CheckpointFile);
            var checkpoint = JsonSerializer.Deserialize<CheckpointState>(checkpointJson);

            if (checkpoint is null)
            {
                return new ValidationResult("V-9",
                    "Checkpoint/CSV consistency",
                    Passed: false, IsFatal: false,
                    Details: "Checkpoint deserialized to null.");
            }

            // Count checkpoint entries missing from CSV
            var missingInCsv = 0;
            foreach (var (modelId, questionIds) in checkpoint.Completed)
            {
                foreach (var qid in questionIds)
                {
                    if (!csvTuples.Contains((modelId, qid)))
                        missingInCsv++;
                }
            }

            if (missingInCsv > 0)
            {
                return new ValidationResult("V-9",
                    "Checkpoint/CSV consistency",
                    Passed: false, IsFatal: false,
                    Details: $"{missingInCsv} checkpoint entries missing from CSV. " +
                             "Checkpoint may be ahead of CSV data.");
            }

            return new ValidationResult("V-9",
                "Checkpoint/CSV consistency",
                Passed: true, IsFatal: false);
        }
        catch (Exception ex)
        {
            return new ValidationResult("V-9",
                "Checkpoint/CSV consistency",
                Passed: false, IsFatal: false,
                Details: ex.Message);
        }
    }

    /// <summary>V-10: Disk space estimate.</summary>
    private ValidationResult CheckDiskSpace()
    {
        try
        {
            var resultsDir = _config.Paths.ResultsDir;
            if (!Directory.Exists(resultsDir))
            {
                // Create results directory — it's an output path
                Directory.CreateDirectory(resultsDir);
            }

            var driveInfo = new DriveInfo(Path.GetPathRoot(resultsDir) ?? "/");
            var freeGb = driveInfo.AvailableFreeSpace / (1024.0 * 1024 * 1024);

            // Estimated CSV size: ~50-100 MB (conservative)
            if (freeGb < 1.0)
            {
                return new ValidationResult("V-10",
                    "Sufficient disk space",
                    Passed: false, IsFatal: false,
                    Details: $"Only {freeGb:F1} GB free. Recommend ≥1 GB for results.");
            }

            return new ValidationResult("V-10",
                "Sufficient disk space",
                Passed: true, IsFatal: false,
                Details: $"{freeGb:F1} GB free.");
        }
        catch
        {
            // DriveInfo may not work on all platforms — non-fatal
            return new ValidationResult("V-10",
                "Sufficient disk space",
                Passed: true, IsFatal: false,
                Details: "Could not check disk space (platform limitation).");
        }
    }

    // ========================================================================
    // Helpers
    // ========================================================================

    private static void CheckFileExists(string path, string name, List<string> missing)
    {
        if (!File.Exists(path))
            missing.Add($"{name}: {path}");
    }

    private static void CheckDirExists(string path, string name, List<string> missing)
    {
        if (!Directory.Exists(path))
            missing.Add($"{name}: {path}");
    }
}
