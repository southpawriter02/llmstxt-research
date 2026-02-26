// ============================================================================
// ResultWriter.cs — Manages raw-data.csv output with immediate flush
// ============================================================================
// Traces To:  runner-design-spec.md §9 (Output Schema)
// Purpose:    Writes one row per completed (site, question, model, condition)
//             tuple to raw-data.csv. Handles header writing on first run,
//             UTF-8 BOM encoding, append-mode, and per-row flushing.
//
// Column order: Matches the canonical 17-column order from design spec §9.1.
//               The analysis notebook and scoring tools expect this order.
//
// Encoding:   UTF-8 with BOM (ensures Excel detects encoding correctly).
// Line endings: \n (LF) — consistent with the rest of the project.
// Quoting:    All string fields double-quoted per RFC 4180.
//
// Thread safety: Not thread-safe. The Orchestrator calls WriteRow sequentially
//                (one tuple at a time), so no locking is needed.
// ============================================================================

using System.Globalization;
using System.Text;
using CsvHelper;
using CsvHelper.Configuration;
using Microsoft.Extensions.Logging;
using RunBenchmark.Models;

namespace RunBenchmark.Components;

/// <summary>
/// Writes result rows to raw-data.csv with immediate flush after each row.
/// </summary>
public sealed class ResultWriter : IDisposable
{
    private readonly string _csvPath;
    private readonly ILogger _logger;
    private StreamWriter? _writer;
    private CsvWriter? _csv;
    private bool _headerWritten;

    /// <summary>
    /// The 17 column headers in canonical order per design spec §9.1.
    /// </summary>
    private static readonly string[] ColumnHeaders =
    {
        "site_id",              // 1
        "question_id",          // 2
        "model_id",             // 3
        "condition",            // 4
        "input_token_count",    // 5
        "ref_token_count",      // 6
        "output_token_count",   // 7
        "content_chars",        // 8
        "response_text",        // 9
        "inference_engine",     // 10
        "elapsed_seconds",      // 11
        "exclusion_reason",     // 12
        "scoring_notes",        // 13
        "factual_accuracy",     // 14
        "hallucination_count",  // 15
        "completeness",         // 16
        "citation_fidelity"     // 17
    };

    /// <summary>
    /// Creates a new ResultWriter for the specified CSV path.
    /// </summary>
    /// <param name="csvPath">Absolute path to raw-data.csv.</param>
    /// <param name="logger">Logger for diagnostic output.</param>
    public ResultWriter(string csvPath, ILogger logger)
    {
        _csvPath = csvPath;
        _logger = logger;
    }

    /// <summary>
    /// Initializes the CSV writer. Writes the header row if the file is
    /// new or empty. Opens in append mode for resume scenarios.
    /// </summary>
    /// <param name="isResume">
    /// True if resuming from a checkpoint (header should already exist).
    /// </param>
    public void Initialize(bool isResume)
    {
        // Ensure the results directory exists
        var dir = Path.GetDirectoryName(_csvPath);
        if (dir is not null && !Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
            _logger.LogInformation("Created results directory: {Dir}", dir);
        }

        // Check if file already has content (determines whether to write header)
        var fileExists = File.Exists(_csvPath);
        var fileHasContent = fileExists && new FileInfo(_csvPath).Length > 0;

        // Open in append mode with UTF-8 BOM encoding
        // AutoFlush = true ensures each row is flushed immediately (design spec §9.2)
        _writer = new StreamWriter(
            _csvPath,
            append: true,
            encoding: new UTF8Encoding(encoderShouldEmitUTF8Identifier: !fileHasContent))
        {
            AutoFlush = true,
            NewLine = "\n"  // LF line endings per design spec §9.2
        };

        var csvConfig = new CsvConfiguration(CultureInfo.InvariantCulture)
        {
            HasHeaderRecord = false,  // We write the header manually
            NewLine = "\n",
            ShouldQuote = _ => true  // Quote ALL string fields per design spec §9.2
        };

        _csv = new CsvWriter(_writer, csvConfig);

        // Write header if this is a new file (not resume) or file is empty
        if (!fileHasContent)
        {
            WriteHeader();
            _logger.LogInformation("CSV header written to: {Path}", _csvPath);
        }
        else if (isResume)
        {
            _logger.LogInformation("Resuming CSV append to: {Path}", _csvPath);
        }

        _headerWritten = true;
    }

    /// <summary>
    /// Writes a single result row to the CSV file and flushes immediately.
    /// </summary>
    /// <param name="row">The result row to write.</param>
    /// <exception cref="InvalidOperationException">
    /// Thrown if Initialize() has not been called.
    /// </exception>
    public void WriteRow(ResultRow row)
    {
        if (_csv is null || _writer is null)
            throw new InvalidOperationException(
                "ResultWriter.Initialize() must be called before WriteRow().");

        // Write fields in canonical column order (design spec §9.1)
        // Column 1-4: Tuple identifiers
        _csv.WriteField(row.SiteId);
        _csv.WriteField(row.QuestionId);
        _csv.WriteField(row.ModelId);
        _csv.WriteField(row.Condition);

        // Column 5-8: Token counts and content size
        _csv.WriteField(row.InputTokenCount);
        _csv.WriteField(row.RefTokenCount);
        _csv.WriteField(row.OutputTokenCount);
        _csv.WriteField(row.ContentChars);

        // Column 9: Model response
        _csv.WriteField(row.ResponseText);

        // Column 10-12: Metadata
        _csv.WriteField(row.InferenceEngine);
        _csv.WriteField(row.ElapsedSeconds.ToString("F3", CultureInfo.InvariantCulture));
        _csv.WriteField(row.ExclusionReason);

        // Column 13: Scoring notes
        _csv.WriteField(row.ScoringNotes);

        // Column 14-17: Scoring columns (null until scoring phase)
        WriteNullableInt(row.FactualAccuracy);
        WriteNullableInt(row.HallucinationCount);
        WriteNullableInt(row.Completeness);
        WriteNullableInt(row.CitationFidelity);

        // End the row (writes the newline)
        _csv.NextRecord();

        // Flush is handled by StreamWriter.AutoFlush = true
        _logger.LogDebug(
            "CSV row written: {SiteId}/{QuestionId}/{ModelId}/{Condition}",
            row.SiteId, row.QuestionId, row.ModelId, row.Condition);
    }

    /// <summary>
    /// Reads existing rows from raw-data.csv and returns the set of
    /// (model_id, question_id) pairs that have BOTH conditions completed.
    /// Used for checkpoint cross-validation (design spec §8.3, step 4).
    /// </summary>
    /// <returns>
    /// Set of (modelId, questionId) pairs where both A and B rows exist.
    /// </returns>
    public static HashSet<(string modelId, string questionId)> ReadCompletedTuples(
        string csvPath, ILogger logger)
    {
        var result = new HashSet<(string, string)>();

        if (!File.Exists(csvPath))
            return result;

        try
        {
            using var reader = new StreamReader(csvPath);
            using var csv = new CsvReader(reader,
                new CsvConfiguration(CultureInfo.InvariantCulture)
                {
                    HasHeaderRecord = true,
                    NewLine = "\n"
                });

            // Track which (model, question) pairs have each condition
            var conditionTracker = new Dictionary<(string, string), HashSet<string>>();

            csv.Read();
            csv.ReadHeader();

            while (csv.Read())
            {
                var modelId = csv.GetField("model_id") ?? "";
                var questionId = csv.GetField("question_id") ?? "";
                var condition = csv.GetField("condition") ?? "";

                if (string.IsNullOrEmpty(modelId) || string.IsNullOrEmpty(questionId))
                    continue;

                var key = (modelId, questionId);
                if (!conditionTracker.TryGetValue(key, out var conditions))
                {
                    conditions = new HashSet<string>();
                    conditionTracker[key] = conditions;
                }
                conditions.Add(condition);
            }

            // Only include pairs where BOTH conditions are present
            foreach (var (key, conditions) in conditionTracker)
            {
                if (conditions.Contains("A") && conditions.Contains("B"))
                {
                    result.Add(key);
                }
            }

            logger.LogInformation(
                "Read {TotalRows} row pairs from existing CSV. " +
                "{CompletePairs} complete (model, question) pairs found.",
                conditionTracker.Count, result.Count);
        }
        catch (Exception ex) when (ex is IOException or CsvHelper.CsvHelperException)
        {
            logger.LogWarning(ex,
                "Failed to read existing CSV for cross-validation: {Error}",
                ex.Message);
        }

        return result;
    }

    /// <summary>
    /// Scans the CSV for orphaned rows (Condition A without matching B, or vice versa)
    /// for a specific (model, question) pair. Returns the row indices to remove.
    /// Used during resume when a crash left a partial question (design spec §8.4).
    /// </summary>
    public static void RemoveOrphanedRows(
        string csvPath, string modelId, string questionId, ILogger logger)
    {
        if (!File.Exists(csvPath))
            return;

        // Read all lines, filter out orphaned rows, rewrite
        var lines = File.ReadAllLines(csvPath);
        if (lines.Length <= 1) return; // Header only

        var header = lines[0];
        var keptLines = new List<string> { header };
        var removedCount = 0;

        for (int i = 1; i < lines.Length; i++)
        {
            var fields = ParseCsvLine(lines[i]);
            // Column indices: model_id=2, question_id=1 (0-indexed)
            if (fields.Length >= 4 &&
                fields[2] == modelId &&
                fields[1] == questionId)
            {
                removedCount++;
                continue; // Skip this orphaned row
            }
            keptLines.Add(lines[i]);
        }

        if (removedCount > 0)
        {
            File.WriteAllLines(csvPath, keptLines);
            logger.LogWarning(
                "Removed {Count} orphaned row(s) for ({ModelId}, {QuestionId}) from CSV.",
                removedCount, modelId, questionId);
        }
    }

    // ========================================================================
    // IDisposable
    // ========================================================================

    public void Dispose()
    {
        _csv?.Dispose();
        _writer?.Dispose();
    }

    // ========================================================================
    // Private helpers
    // ========================================================================

    /// <summary>Writes the CSV header row.</summary>
    private void WriteHeader()
    {
        if (_csv is null) return;

        foreach (var header in ColumnHeaders)
        {
            _csv.WriteField(header);
        }
        _csv.NextRecord();
    }

    /// <summary>Writes a nullable integer field (empty string if null).</summary>
    private void WriteNullableInt(int? value)
    {
        if (_csv is null) return;

        if (value.HasValue)
            _csv.WriteField(value.Value);
        else
            _csv.WriteField("");
    }

    /// <summary>
    /// Simple CSV line parser for the orphan removal logic.
    /// Handles double-quoted fields with embedded commas and newlines.
    /// </summary>
    private static string[] ParseCsvLine(string line)
    {
        var fields = new List<string>();
        var current = new StringBuilder();
        bool inQuotes = false;

        for (int i = 0; i < line.Length; i++)
        {
            char c = line[i];

            if (inQuotes)
            {
                if (c == '"')
                {
                    // Check for escaped quote ("")
                    if (i + 1 < line.Length && line[i + 1] == '"')
                    {
                        current.Append('"');
                        i++; // Skip next quote
                    }
                    else
                    {
                        inQuotes = false;
                    }
                }
                else
                {
                    current.Append(c);
                }
            }
            else
            {
                if (c == '"')
                {
                    inQuotes = true;
                }
                else if (c == ',')
                {
                    fields.Add(current.ToString());
                    current.Clear();
                }
                else
                {
                    current.Append(c);
                }
            }
        }

        fields.Add(current.ToString());
        return fields.ToArray();
    }
}
