// ============================================================================
// Orchestrator.cs — The main execution loop
// ============================================================================
// Traces To:  runner-design-spec.md §7 (Inference Loop)
// Purpose:    Iterates models → questions → conditions per the run protocol.
//             Delegates to Content Assembler, Inference Client, Result Writer,
//             and Checkpoint Manager. This is the only component that
//             coordinates the others — no component talks to another directly.
//
// Loop structure (§7.1):
//   FOR each model (sequential):
//     Load model + warmup
//     FOR each question (file order):
//       Check checkpoint → skip if done
//       Assemble content for both conditions
//       FOR each condition in ["A", "B"]:
//         Send inference → write result
//       Update checkpoint
//
// Qwen 3 handling: Appends /no_think to user message (§7.4).
// Truncation detection: Flags TRUNCATED_AT_512 in scoring_notes (§7.5).
// ============================================================================

using System.Diagnostics;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using RunBenchmark.Models;

namespace RunBenchmark.Components;

/// <summary>
/// The main execution loop that coordinates all components to process
/// the full experimental matrix.
/// </summary>
public sealed class Orchestrator
{
    private readonly BenchmarkConfig _config;
    private readonly ContentAssembler _contentAssembler;
    private readonly InferenceClient _inferenceClient;
    private readonly ResultWriter _resultWriter;
    private readonly CheckpointManager _checkpointManager;
    private readonly ArchiveManifest _manifest;
    private readonly List<SiteQuestions> _allSites;
    private readonly ILogger _logger;

    /// <summary>Progress reporting interval (every N questions).</summary>
    private const int ProgressReportInterval = 10;

    public Orchestrator(
        BenchmarkConfig config,
        ContentAssembler contentAssembler,
        InferenceClient inferenceClient,
        ResultWriter resultWriter,
        CheckpointManager checkpointManager,
        ArchiveManifest manifest,
        List<SiteQuestions> allSites,
        ILogger logger)
    {
        _config = config;
        _contentAssembler = contentAssembler;
        _inferenceClient = inferenceClient;
        _resultWriter = resultWriter;
        _checkpointManager = checkpointManager;
        _manifest = manifest;
        _allSites = allSites;
        _logger = logger;
    }

    /// <summary>
    /// Executes the full inference loop across all models and questions.
    /// </summary>
    /// <param name="cancellationToken">
    /// Cancellation token for graceful shutdown (Ctrl+C).
    /// </param>
    /// <returns>
    /// Exit code: 0 = success, 2 = endpoint unreachable, 3 = internal error.
    /// </returns>
    public async Task<int> RunAsync(CancellationToken cancellationToken = default)
    {
        // Flatten all questions into a single ordered list (file order per §7.1)
        var allQuestions = _allSites
            .SelectMany(s => s.Questions.Select(q => (s.SiteId, Question: q)))
            .ToList();

        var totalQuestions = allQuestions.Count;
        var totalModels = _config.Models.Count;

        _logger.LogInformation(
            "Starting inference loop: {ModelCount} models × {QuestionCount} questions " +
            "× 2 conditions = {TupleCount} total tuples.",
            totalModels, totalQuestions, totalModels * totalQuestions * 2);

        // ----------------------------------------------------------------
        // Outer loop: Models (sequential, one at a time)
        // ----------------------------------------------------------------
        for (int modelIndex = 0; modelIndex < totalModels; modelIndex++)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var model = _config.Models[modelIndex];
            _checkpointManager.SetCurrentModelIndex(modelIndex);

            _logger.LogInformation(
                "═══════════════════════════════════════════════════════════════");
            _logger.LogInformation(
                "Starting model {Index}/{Total}: {ModelId} ({Tag})",
                modelIndex + 1, totalModels, model.ModelId, model.OllamaTag);
            _logger.LogInformation(
                "═══════════════════════════════════════════════════════════════");

            var modelStopwatch = Stopwatch.StartNew();
            var modelSuccessCount = 0;
            var modelExclusionCount = 0;
            var modelSkippedCount = 0;

            // --- Model loading + warmup (§7.2, §7.3) ---
            await WarmUpModelAsync(model, cancellationToken);

            // Log Qwen 3 thinking mode suppression (§7.4)
            if (model.IsQwen3)
            {
                _logger.LogInformation(
                    "Qwen 3 thinking mode suppressed via /no_think for model {ModelId}.",
                    model.ModelId);
            }

            // ----------------------------------------------------------------
            // Middle loop: Questions (file order)
            // ----------------------------------------------------------------
            for (int qIndex = 0; qIndex < allQuestions.Count; qIndex++)
            {
                cancellationToken.ThrowIfCancellationRequested();

                var (siteId, question) = allQuestions[qIndex];

                // Check checkpoint: skip if already complete (§7.1)
                if (_checkpointManager.IsCompleted(model.ModelId, question.QuestionId))
                {
                    modelSkippedCount++;
                    _logger.LogDebug(
                        "Skipping {ModelId}/{QuestionId} (already checkpointed).",
                        model.ModelId, question.QuestionId);
                    continue;
                }

                // Assemble content for both conditions
                var conditionResults = new List<(string condition, AssembledContent assembled)>();

                foreach (var condition in _config.RunProtocol.ConditionOrderPerQuestion)
                {
                    var assembled = _contentAssembler.AssembleCondition(
                        siteId, question, model, condition, _manifest);
                    conditionResults.Add((condition, assembled));
                }

                // ----------------------------------------------------------------
                // Inner loop: Conditions ["A", "B"]
                // ----------------------------------------------------------------
                foreach (var (condition, assembled) in conditionResults)
                {
                    cancellationToken.ThrowIfCancellationRequested();

                    if (assembled.IsExcluded)
                    {
                        // Write exclusion row (§6.5)
                        WriteExclusionRow(siteId, question, model, assembled);
                        modelExclusionCount++;
                        continue;
                    }

                    // Send inference request (§7.5)
                    var userMessage = assembled.AssembledPrompt!;

                    // Qwen 3 /no_think suppression (§7.4)
                    if (model.IsQwen3)
                    {
                        userMessage += "\n\n/no_think";
                    }

                    var result = await _inferenceClient.SendAsync(
                        model.OllamaTag,
                        _config.PromptTemplate.SystemPrompt,
                        userMessage,
                        _config.InferenceParameters,
                        assembled.ComputedNumCtx,
                        cancellationToken);

                    // Write result row
                    WriteResultRow(siteId, question, model, assembled, result);

                    if (result.IsSuccess)
                        modelSuccessCount++;
                    else
                        modelExclusionCount++;
                }

                // Update checkpoint after both conditions complete (§8.1)
                _checkpointManager.MarkCompleted(model.ModelId, question.QuestionId);

                // Progress reporting (§10.2)
                var completedForModel = qIndex + 1 - modelSkippedCount;
                if (completedForModel > 0 && completedForModel % ProgressReportInterval == 0)
                {
                    var elapsed = modelStopwatch.Elapsed;
                    var avgPerQuestion = elapsed.TotalSeconds / completedForModel;
                    var remaining = (totalQuestions - qIndex - 1) * avgPerQuestion;

                    _logger.LogInformation(
                        "Progress [{ModelId}]: {Completed}/{Total} questions, " +
                        "{Success} success, {Excluded} excluded. " +
                        "Elapsed: {Elapsed:hh\\:mm\\:ss}, ETA: {ETA:hh\\:mm\\:ss}",
                        model.ModelId,
                        qIndex + 1, totalQuestions,
                        modelSuccessCount, modelExclusionCount,
                        elapsed,
                        TimeSpan.FromSeconds(remaining));
                }

                // Check if endpoint is down (§10.1)
                if (_inferenceClient.IsEndpointDown)
                {
                    _logger.LogError(
                        "Inference endpoint appears to be down (3+ consecutive failures). " +
                        "Pausing for operator intervention.");

                    // Flush checkpoint before pausing
                    _checkpointManager.Flush();

                    Console.WriteLine();
                    Console.WriteLine("=== INFERENCE ENDPOINT DOWN ===");
                    Console.WriteLine("The endpoint has failed 3+ consecutive requests.");
                    Console.WriteLine("Check that Ollama/LM Studio is running.");
                    Console.WriteLine("Press Enter to retry, or Ctrl+C to exit gracefully.");
                    Console.ReadLine();

                    _inferenceClient.ResetFailureCounter();
                }
            }

            // Model completion summary (§7.1)
            modelStopwatch.Stop();
            _logger.LogInformation(
                "Model {ModelId} complete. " +
                "Success: {Success}, Excluded: {Excluded}, Skipped: {Skipped}. " +
                "Total time: {Elapsed:hh\\:mm\\:ss}.",
                model.ModelId,
                modelSuccessCount, modelExclusionCount, modelSkippedCount,
                modelStopwatch.Elapsed);
        }

        _logger.LogInformation(
            "═══════════════════════════════════════════════════════════════");
        _logger.LogInformation("Inference loop complete. All models processed.");
        _logger.LogInformation(
            "═══════════════════════════════════════════════════════════════");

        return 0;
    }

    // ========================================================================
    // Model loading and warmup (§7.2, §7.3)
    // ========================================================================

    /// <summary>
    /// Warms up a model by sending throwaway prompts (§7.3).
    /// Also serves as the trigger for Ollama to load the model (§7.2).
    /// For LM Studio, detects model-not-loaded errors and prompts the operator (§7.2).
    /// </summary>
    private async Task WarmUpModelAsync(ModelConfig model, CancellationToken cancellationToken)
    {
        var warmupCount = _config.InferenceEndpoint.WarmupPromptCount;
        _logger.LogInformation(
            "Warming up model {ModelId} ({WarmupCount} prompts)...",
            model.ModelId, warmupCount);

        var warmupStopwatch = Stopwatch.StartNew();

        for (int i = 0; i < warmupCount; i++)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var result = await _inferenceClient.SendWarmupAsync(
                model.OllamaTag,
                _config.InferenceParameters,
                cancellationToken);

            // LM Studio interactive pause (§7.2):
            // If the warmup fails and we're using LM Studio, the model may not
            // be loaded. Prompt the operator to load it manually.
            if (result is not null && !result.IsSuccess &&
                _config.InferenceEndpoint.Engine == "lm_studio" &&
                (result.ErrorReason?.Contains("404") == true ||
                 result.ErrorReason?.Contains("not found") == true ||
                 result.ErrorReason == "CONNECTION_REFUSED"))
            {
                _logger.LogWarning(
                    "Model {OllamaTag} does not appear to be loaded in LM Studio.",
                    model.OllamaTag);

                Console.WriteLine();
                Console.WriteLine($"=== LM STUDIO: MODEL NOT LOADED ===");
                Console.WriteLine($"Model {model.OllamaTag} is not loaded in LM Studio.");
                Console.WriteLine("Load it now and press Enter to continue, or type 'skip' to skip this model.");
                Console.Write("> ");
                var input = Console.ReadLine()?.Trim();

                if (input?.Equals("skip", StringComparison.OrdinalIgnoreCase) == true)
                {
                    _logger.LogInformation("Operator chose to skip model {ModelId}.", model.ModelId);
                    return;
                }

                // Retry the warmup prompt after operator loads the model
                i--; // Redo this warmup prompt
                continue;
            }
        }

        warmupStopwatch.Stop();
        _logger.LogInformation(
            "Warmup complete for {ModelId} in {Elapsed:F1}s " +
            "(avg {Avg:F1}s per prompt, includes any model loading time).",
            model.ModelId,
            warmupStopwatch.Elapsed.TotalSeconds,
            warmupStopwatch.Elapsed.TotalSeconds / warmupCount);
    }

    // ========================================================================
    // Result row writing
    // ========================================================================

    /// <summary>
    /// Writes a successful inference result to raw-data.csv.
    /// Detects truncation and writes TRUNCATED_AT_512 to scoring_notes (§7.5).
    /// </summary>
    private void WriteResultRow(
        string siteId,
        Question question,
        ModelConfig model,
        AssembledContent assembled,
        InferenceResult result)
    {
        // Truncation detection (§7.5)
        var scoringNotes = assembled.ScoringNotes ?? "";
        if (result.IsSuccess &&
            result.OutputTokenCount >= _config.InferenceParameters.NumPredict)
        {
            var truncationFlag = "TRUNCATED_AT_512";
            scoringNotes = string.IsNullOrEmpty(scoringNotes)
                ? truncationFlag
                : $"{scoringNotes}; {truncationFlag}";
        }

        // Build exclusion reason from inference error (if any)
        var exclusionReason = result.ErrorReason ?? assembled.ExclusionReason ?? "";

        _resultWriter.WriteRow(new ResultRow
        {
            SiteId = siteId,
            QuestionId = question.QuestionId,
            ModelId = model.ModelId,
            Condition = assembled.Condition,
            InputTokenCount = assembled.InputTokenCount,
            RefTokenCount = assembled.RefTokenCount,
            OutputTokenCount = result.OutputTokenCount,
            ContentChars = assembled.ContentChars,
            ResponseText = result.ResponseText ?? "",
            InferenceEngine = _config.InferenceEndpoint.Engine,
            ElapsedSeconds = result.ElapsedSeconds,
            ExclusionReason = exclusionReason,
            ScoringNotes = scoringNotes,
            // Scoring columns null until scoring phase
            FactualAccuracy = null,
            HallucinationCount = null,
            Completeness = null,
            CitationFidelity = null
        });

        _logger.LogDebug(
            "Result: {SiteId}/{QuestionId}/{ModelId}/{Condition} — " +
            "{Status} ({Elapsed:F1}s, {OutputTokens} tokens)",
            siteId, question.QuestionId, model.ModelId, assembled.Condition,
            result.IsSuccess ? "SUCCESS" : result.ErrorReason,
            result.ElapsedSeconds, result.OutputTokenCount);
    }

    /// <summary>
    /// Writes an exclusion row for a condition that was excluded during content assembly.
    /// </summary>
    private void WriteExclusionRow(
        string siteId,
        Question question,
        ModelConfig model,
        AssembledContent assembled)
    {
        _resultWriter.WriteRow(new ResultRow
        {
            SiteId = siteId,
            QuestionId = question.QuestionId,
            ModelId = model.ModelId,
            Condition = assembled.Condition,
            InputTokenCount = 0,
            RefTokenCount = 0,
            OutputTokenCount = 0,
            ContentChars = 0,
            ResponseText = "",
            InferenceEngine = _config.InferenceEndpoint.Engine,
            ElapsedSeconds = 0,
            ExclusionReason = assembled.ExclusionReason ?? "UNKNOWN",
            ScoringNotes = assembled.ScoringNotes ?? "",
            FactualAccuracy = null,
            HallucinationCount = null,
            Completeness = null,
            CitationFidelity = null
        });

        _logger.LogWarning(
            "Excluded: {SiteId}/{QuestionId}/{ModelId}/{Condition} — {Reason}",
            siteId, question.QuestionId, model.ModelId, assembled.Condition,
            assembled.ExclusionReason);
    }
}
