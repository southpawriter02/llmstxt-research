// ============================================================================
// CheckpointManager.cs — Tracks progress and enables resume after interruption
// ============================================================================
// Traces To:  runner-design-spec.md §8 (Checkpoint and Resume)
// Purpose:    Reads checkpoint.json on startup to determine which tuples are
//             already complete, and writes an updated checkpoint after each
//             question (both conditions) is finished.
//
// Granularity: Per-question (both conditions must complete). A question_id
//              is only added to the checkpoint after BOTH Condition A and B
//              have been processed and written to raw-data.csv.
//
// Atomic write: checkpoint.json.tmp → checkpoint.json rename prevents
//               half-written files on crash. See §8.2.
//
// Cross-validation: On resume, the checkpoint is verified against raw-data.csv.
//                   If the checkpoint is ahead of the CSV (claims completion but
//                   CSV rows are missing), the runner logs a warning. See §8.3.
// ============================================================================

using System.Text.Json;
using Microsoft.Extensions.Logging;
using RunBenchmark.Models;

namespace RunBenchmark.Components;

/// <summary>
/// Manages the checkpoint file for resume support. The checkpoint records
/// which (model, question) pairs have been fully completed.
/// </summary>
public sealed class CheckpointManager
{
    private readonly string _checkpointPath;
    private readonly string _configVersion;
    private readonly ILogger _logger;

    /// <summary>In-memory checkpoint state, updated after each question.</summary>
    private CheckpointState _state;

    /// <summary>JSON serializer options for pretty-printing checkpoint files.</summary>
    private static readonly JsonSerializerOptions WriteOptions = new()
    {
        WriteIndented = true
    };

    /// <summary>
    /// Creates a new CheckpointManager.
    /// </summary>
    /// <param name="checkpointPath">Absolute path to checkpoint.json.</param>
    /// <param name="configVersion">Config version string for compatibility checking.</param>
    /// <param name="logger">Logger for diagnostic output.</param>
    public CheckpointManager(string checkpointPath, string configVersion, ILogger logger)
    {
        _checkpointPath = checkpointPath;
        _configVersion = configVersion;
        _logger = logger;
        _state = new CheckpointState
        {
            ConfigVersion = configVersion,
            StartedAt = DateTime.UtcNow.ToString("o"),
            LastUpdatedAt = DateTime.UtcNow.ToString("o")
        };
    }

    /// <summary>
    /// Attempts to load an existing checkpoint from disk.
    /// Returns true if a valid checkpoint was loaded, false if starting fresh.
    /// </summary>
    /// <remarks>
    /// Resume protocol (§8.3):
    /// 1. Read and deserialize checkpoint.json.
    /// 2. Verify config_version matches. If not, warn but continue (operator decides).
    /// 3. Build completed set for skip logic during inference loop.
    /// </remarks>
    public bool TryLoadExisting()
    {
        if (!File.Exists(_checkpointPath))
        {
            _logger.LogInformation("No existing checkpoint found. Starting fresh.");
            return false;
        }

        try
        {
            var json = File.ReadAllText(_checkpointPath);
            var loaded = JsonSerializer.Deserialize<CheckpointState>(json);

            if (loaded is null)
            {
                _logger.LogWarning("Checkpoint file deserialized to null. Starting fresh.");
                return false;
            }

            // Version compatibility check (§8.3 step 2)
            if (loaded.ConfigVersion != _configVersion)
            {
                _logger.LogWarning(
                    "Checkpoint config_version mismatch: checkpoint={CheckpointVersion}, " +
                    "current={CurrentVersion}. Proceeding with caution — skipped tuples may " +
                    "not match the current config.",
                    loaded.ConfigVersion, _configVersion);
            }

            _state = loaded;

            // Count total completed tuples for the log summary
            var totalCompleted = _state.Completed.Values.Sum(q => q.Count);
            _logger.LogInformation(
                "Loaded checkpoint: {ModelCount} models, {TupleCount} completed question(s). " +
                "Started at {StartedAt}, last updated {LastUpdated}.",
                _state.Completed.Count, totalCompleted,
                _state.StartedAt, _state.LastUpdatedAt);

            return totalCompleted > 0;
        }
        catch (Exception ex) when (ex is JsonException or IOException)
        {
            _logger.LogWarning(ex,
                "Failed to load checkpoint file. Starting fresh. Error: {Error}",
                ex.Message);
            return false;
        }
    }

    /// <summary>
    /// Checks whether a (model, question) pair has already been completed.
    /// Used by the Orchestrator to skip already-processed tuples on resume.
    /// </summary>
    public bool IsCompleted(string modelId, string questionId)
    {
        return _state.IsCompleted(modelId, questionId);
    }

    /// <summary>
    /// Marks a (model, question) pair as completed and atomically writes
    /// the updated checkpoint to disk.
    /// </summary>
    /// <remarks>
    /// Atomic write protocol (§8.2):
    /// 1. Update in-memory state.
    /// 2. Serialize to JSON.
    /// 3. Write to checkpoint.json.tmp.
    /// 4. Atomically rename .tmp → .json.
    /// </remarks>
    public void MarkCompleted(string modelId, string questionId)
    {
        _state.MarkCompleted(modelId, questionId);
        WriteToDisk();

        _logger.LogDebug(
            "Checkpoint updated: ({ModelId}, {QuestionId}) marked complete.",
            modelId, questionId);
    }

    /// <summary>
    /// Updates the current model index in the checkpoint (for informational purposes).
    /// </summary>
    public void SetCurrentModelIndex(int index)
    {
        _state.CurrentModelIndex = index;
    }

    /// <summary>
    /// Forces a checkpoint write to disk. Called during graceful shutdown (Ctrl+C).
    /// </summary>
    public void Flush()
    {
        WriteToDisk();
        _logger.LogInformation("Checkpoint flushed to disk.");
    }

    /// <summary>
    /// Gets the count of completed questions for a specific model.
    /// Used for progress reporting.
    /// </summary>
    public int GetCompletedCount(string modelId)
    {
        return _state.Completed.TryGetValue(modelId, out var questions)
            ? questions.Count
            : 0;
    }

    /// <summary>
    /// Cross-validates the checkpoint against rows found in raw-data.csv.
    /// Returns a list of warnings for any discrepancies.
    /// See design spec §8.3, step 4.
    /// </summary>
    /// <param name="csvTuples">
    /// Set of (modelId, questionId) pairs found in the existing raw-data.csv.
    /// Each pair should appear if both conditions A and B have rows.
    /// </param>
    public List<string> CrossValidate(HashSet<(string modelId, string questionId)> csvTuples)
    {
        var warnings = new List<string>();

        foreach (var (modelId, questionIds) in _state.Completed)
        {
            foreach (var qid in questionIds)
            {
                if (!csvTuples.Contains((modelId, qid)))
                {
                    warnings.Add(
                        $"Checkpoint claims ({modelId}, {qid}) is complete, " +
                        "but no matching rows found in raw-data.csv. " +
                        "The checkpoint may be ahead of the CSV (crash between CSV write and checkpoint update).");
                }
            }
        }

        // Also check for CSV rows not in checkpoint (§8.4: normal, rebuild checkpoint)
        foreach (var (modelId, qid) in csvTuples)
        {
            if (!_state.IsCompleted(modelId, qid))
            {
                _logger.LogInformation(
                    "CSV has rows for ({ModelId}, {QuestionId}) not in checkpoint. " +
                    "Rebuilding checkpoint entry from CSV data.",
                    modelId, qid);
                _state.MarkCompleted(modelId, qid);
            }
        }

        return warnings;
    }

    /// <summary>
    /// Removes a specific model from the completed set, enabling re-run.
    /// Used by --force-rerun CLI flag (design spec §8.4).
    /// </summary>
    public void RemoveModel(string modelId)
    {
        if (_state.Completed.Remove(modelId))
        {
            _logger.LogInformation("Removed model {ModelId} from checkpoint for re-run.", modelId);
            WriteToDisk();
        }
    }

    // ========================================================================
    // Private helpers
    // ========================================================================

    /// <summary>
    /// Atomically writes the checkpoint to disk via temp-file-then-rename.
    /// </summary>
    private void WriteToDisk()
    {
        var json = JsonSerializer.Serialize(_state, WriteOptions);
        var tempPath = _checkpointPath + ".tmp";

        // Write to temp file first
        File.WriteAllText(tempPath, json);

        // Atomic rename (on same filesystem, File.Move with overwrite is atomic on macOS/Linux)
        File.Move(tempPath, _checkpointPath, overwrite: true);
    }
}
