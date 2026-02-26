// ============================================================================
// Program.cs — CLI Entry Point for the benchmark data collection runner
// ============================================================================
// Traces To:  runner-design-spec.md §11 (CLI Interface), §3.2 (Component Responsibilities)
// Purpose:    Parses command-line arguments, selects the execution phase,
//             instantiates all components, and hands off to the Orchestrator.
//             This is the only component that knows about the console — all
//             other components are testable without I/O.
//
// Exit codes (§11.2):
//   0   = Phase completed successfully
//   1   = Pre-flight validation failed (Fatal check)
//   2   = Inference endpoint unreachable
//   3   = Unrecoverable internal error
//   4   = Disk full or I/O error
//   130 = Interrupted by operator (Ctrl+C)
//
// Usage:
//   run-benchmark [phase] [options]
//
//   Phases:
//     validate    Run pre-flight validation only
//     run         Run the inference loop (assumes archive exists)
//     all         Run validate → run in sequence (default)
//
//   Options:
//     --config <path>         Path to benchmark-config.json
//     --resume                Resume from checkpoint (default if checkpoint exists)
//     --no-resume             Start fresh, ignoring existing checkpoint
//     --force-rerun <model>   Re-run a specific model even if checkpointed
//     --dry-run               Run validation + assembly but skip inference
//     --verbose               Enable Debug-level logging
//     --log-file <path>       Override log file path
// ============================================================================

using System.Text.Json;
using Microsoft.Extensions.Logging;
using RunBenchmark.Components;
using RunBenchmark.Models;

namespace RunBenchmark;

/// <summary>
/// CLI entry point. Parses arguments, wires components, manages lifecycle.
/// </summary>
public static class Program
{
    /// <summary>Cancellation token source for Ctrl+C handling (§11.3).</summary>
    private static readonly CancellationTokenSource Cts = new();

    /// <summary>Reference to checkpoint manager for Ctrl+C flush.</summary>
    private static CheckpointManager? _checkpointManager;

    /// <summary>Reference to result writer for Ctrl+C flush.</summary>
    private static ResultWriter? _resultWriter;

    public static async Task<int> Main(string[] args)
    {
        // ----------------------------------------------------------------
        // 1. Register Ctrl+C handler (§11.3)
        // ----------------------------------------------------------------
        Console.CancelKeyPress += OnCancelKeyPress;

        // ----------------------------------------------------------------
        // 2. Parse command-line arguments
        // ----------------------------------------------------------------
        var options = ParseArguments(args);

        // ----------------------------------------------------------------
        // 3. Configure logging (§10.2)
        // ----------------------------------------------------------------
        using var loggerFactory = LoggerFactory.Create(builder =>
        {
            builder.AddConsole(opts =>
            {
                opts.TimestampFormat = "HH:mm:ss ";
            });

            builder.SetMinimumLevel(options.Verbose
                ? LogLevel.Debug
                : LogLevel.Information);

            // File logging would be added here via a file logging provider
            // For now, console logging is sufficient; file logging can be added
            // via Serilog or a simple file logger if needed.
        });

        var logger = loggerFactory.CreateLogger("RunBenchmark");

        try
        {
            // ----------------------------------------------------------------
            // 4. Load configuration (§5)
            // ----------------------------------------------------------------
            logger.LogInformation("═══════════════════════════════════════════════════════════════");
            logger.LogInformation("  Context Collapse Mitigation Benchmark — Data Collection Runner");
            logger.LogInformation("═══════════════════════════════════════════════════════════════");
            logger.LogInformation("");

            var config = ConfigLoader.Load(options.ConfigPath, logger);

            // ----------------------------------------------------------------
            // 5. Create shared components
            // ----------------------------------------------------------------
            using var httpClient = new HttpClient();
            httpClient.Timeout = TimeSpan.FromSeconds(config.InferenceEndpoint.RequestTimeoutSeconds + 30);

            var inferenceClient = new InferenceClient(
                httpClient,
                config.InferenceEndpoint.FullUrl,
                config.InferenceEndpoint.RequestTimeoutSeconds,
                logger);

            // ----------------------------------------------------------------
            // 6. Run the requested phase
            // ----------------------------------------------------------------
            switch (options.Phase)
            {
                case ExecutionPhase.Archive:
                    logger.LogWarning(
                        "Archive phase is not yet implemented in the runner. " +
                        "Content archival is currently a manual pre-processing step. " +
                        "See methodology.md §2.1 for the archival protocol.");
                    return 0;

                case ExecutionPhase.Validate:
                    return await RunValidatePhaseAsync(config, inferenceClient, logger, Cts.Token);

                case ExecutionPhase.Run:
                    return await RunInferencePhaseAsync(
                        config, inferenceClient, options, logger, Cts.Token);

                case ExecutionPhase.All:
                default:
                    // Validate first
                    var validateResult = await RunValidatePhaseAsync(
                        config, inferenceClient, logger, Cts.Token);
                    if (validateResult != 0)
                        return validateResult;

                    // Then run inference
                    return await RunInferencePhaseAsync(
                        config, inferenceClient, options, logger, Cts.Token);
            }
        }
        catch (ConfigurationException ex)
        {
            logger.LogError("Configuration error: {Message}", ex.Message);
            return 1;
        }
        catch (OperationCanceledException)
        {
            logger.LogInformation("Run interrupted by operator (Ctrl+C). Exiting cleanly.");
            return 130;
        }
        catch (IOException ex) when (ex.Message.Contains("disk full", StringComparison.OrdinalIgnoreCase) ||
                                     ex.Message.Contains("no space", StringComparison.OrdinalIgnoreCase))
        {
            logger.LogError("Disk full or I/O error: {Message}", ex.Message);
            return 4;
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unrecoverable internal error: {Message}", ex.Message);
            return 3;
        }
    }

    // ========================================================================
    // Phase runners
    // ========================================================================

    /// <summary>Runs the pre-flight validation phase (design spec §4.2).</summary>
    private static async Task<int> RunValidatePhaseAsync(
        BenchmarkConfig config,
        InferenceClient inferenceClient,
        ILogger logger,
        CancellationToken cancellationToken)
    {
        logger.LogInformation("--- Phase: Pre-flight Validation ---");

        var validator = new PreflightValidator(config, inferenceClient, logger);
        var results = await validator.RunAllChecksAsync(cancellationToken);

        var fatalFailures = results.Where(r => !r.Passed && r.IsFatal).ToList();

        if (fatalFailures.Count > 0)
        {
            logger.LogError(
                "{Count} fatal validation failure(s). Cannot proceed with inference.",
                fatalFailures.Count);
            return 1;
        }

        logger.LogInformation("Pre-flight validation passed (all fatal checks OK).");
        return 0;
    }

    /// <summary>Runs the inference phase (design spec §7).</summary>
    private static async Task<int> RunInferencePhaseAsync(
        BenchmarkConfig config,
        InferenceClient inferenceClient,
        CliOptions options,
        ILogger logger,
        CancellationToken cancellationToken)
    {
        logger.LogInformation("--- Phase: Inference Loop ---");

        // Load corpus data
        logger.LogInformation("Loading corpus data...");

        var questionsJson = await File.ReadAllTextAsync(config.Paths.Questions, cancellationToken);
        var allSites = JsonSerializer.Deserialize<List<SiteQuestions>>(questionsJson)
                       ?? throw new ConfigurationException("Failed to deserialize questions.json.");

        var totalQuestions = allSites.Sum(s => s.Questions.Count);
        logger.LogInformation("Loaded {SiteCount} sites with {QuestionCount} questions.",
            allSites.Count, totalQuestions);

        // Load archive manifest
        var manifestJson = await File.ReadAllTextAsync(config.Paths.ArchiveManifest, cancellationToken);
        var manifest = JsonSerializer.Deserialize<ArchiveManifest>(manifestJson)
                       ?? throw new ConfigurationException("Failed to deserialize archive manifest.");
        logger.LogInformation("Loaded archive manifest with {EntryCount} entries.",
            manifest.Entries.Count);

        // Initialize checkpoint manager (§8)
        _checkpointManager = new CheckpointManager(
            config.Paths.CheckpointFile,
            config.Version,
            logger);

        bool isResume = false;
        if (options.NoResume)
        {
            logger.LogInformation("--no-resume: Starting fresh (ignoring checkpoint).");
        }
        else
        {
            isResume = _checkpointManager.TryLoadExisting();

            if (isResume)
            {
                // Cross-validate checkpoint against CSV (§8.3)
                var csvTuples = ResultWriter.ReadCompletedTuples(config.Paths.RawDataCsv, logger);
                var warnings = _checkpointManager.CrossValidate(csvTuples);

                foreach (var warning in warnings)
                    logger.LogWarning("Checkpoint cross-validation: {Warning}", warning);
            }
        }

        // Handle --force-rerun
        if (options.ForceRerunModel is not null)
        {
            _checkpointManager.RemoveModel(options.ForceRerunModel);
        }

        // Initialize result writer (§9)
        _resultWriter = new ResultWriter(config.Paths.RawDataCsv, logger);
        _resultWriter.Initialize(isResume);

        // Load token count lookup (§12.1)
        var tokenLookupPath = Path.Combine(
            config.Paths.ArchiveDir, "token-counts.json");
        var tokenLookup = TokenCountLookup.LoadFromFile(tokenLookupPath, logger);

        // Initialize content assembler (§6)
        var parser = new LlmsTxtKitParser();
        var contentAssembler = new ContentAssembler(config, parser, tokenLookup, logger);

        // Create orchestrator (§7)
        var orchestrator = new Orchestrator(
            config,
            contentAssembler,
            inferenceClient,
            _resultWriter,
            _checkpointManager,
            manifest,
            allSites,
            logger);

        // Dry-run mode: log what would happen, don't actually run inference
        if (options.DryRun)
        {
            logger.LogInformation(
                "DRY RUN: Would process {Models} models × {Questions} questions × 2 conditions " +
                "= {Total} tuples. No inference calls will be made.",
                config.Models.Count, totalQuestions,
                config.Models.Count * totalQuestions * 2);
            return 0;
        }

        // Run the inference loop
        var result = await orchestrator.RunAsync(cancellationToken);

        // Clean up
        _resultWriter.Dispose();
        _checkpointManager.Flush();

        return result;
    }

    // ========================================================================
    // Ctrl+C handling (§11.3)
    // ========================================================================

    /// <summary>
    /// Handles Ctrl+C by requesting cancellation and flushing state.
    /// Per §11.3:
    /// 1. Set cancellation flag.
    /// 2. Wait for current in-flight request to complete.
    /// 3. Write checkpoint.
    /// 4. Flush and close CSV.
    /// 5. Exit with code 130.
    /// </summary>
    private static void OnCancelKeyPress(object? sender, ConsoleCancelEventArgs e)
    {
        // Prevent immediate termination — let the run loop finish gracefully
        e.Cancel = true;

        Console.WriteLine();
        Console.WriteLine("Ctrl+C received. Finishing current request and saving state...");

        // Signal cancellation to all async operations
        Cts.Cancel();

        // Flush checkpoint and CSV
        try
        {
            _checkpointManager?.Flush();
            _resultWriter?.Dispose();
        }
        catch
        {
            // Best-effort flush during shutdown
        }
    }

    // ========================================================================
    // Argument parsing (§11.1)
    // ========================================================================

    /// <summary>
    /// Parses CLI arguments into a structured options object.
    /// </summary>
    private static CliOptions ParseArguments(string[] args)
    {
        var options = new CliOptions();
        int i = 0;

        // First non-option argument is the phase
        if (args.Length > 0 && !args[0].StartsWith("--"))
        {
            options.Phase = args[0].ToLowerInvariant() switch
            {
                "archive" => ExecutionPhase.Archive,
                "validate" => ExecutionPhase.Validate,
                "run" => ExecutionPhase.Run,
                "all" => ExecutionPhase.All,
                _ => throw new ConfigurationException(
                    $"Unknown phase: \"{args[0]}\". Valid phases: archive, validate, run, all.")
            };
            i = 1;
        }

        // Parse options
        for (; i < args.Length; i++)
        {
            switch (args[i])
            {
                case "--config":
                    if (i + 1 >= args.Length)
                        throw new ConfigurationException("--config requires a path argument.");
                    options.ConfigPath = args[++i];
                    break;

                case "--resume":
                    options.NoResume = false;
                    break;

                case "--no-resume":
                    options.NoResume = true;
                    break;

                case "--force-rerun":
                    if (i + 1 >= args.Length)
                        throw new ConfigurationException("--force-rerun requires a model_id argument.");
                    options.ForceRerunModel = args[++i];
                    break;

                case "--dry-run":
                    options.DryRun = true;
                    break;

                case "--verbose":
                    options.Verbose = true;
                    break;

                case "--log-file":
                    if (i + 1 >= args.Length)
                        throw new ConfigurationException("--log-file requires a path argument.");
                    options.LogFile = args[++i];
                    break;

                case "--help":
                case "-h":
                    PrintUsage();
                    Environment.Exit(0);
                    break;

                default:
                    throw new ConfigurationException(
                        $"Unknown option: \"{args[i]}\". Use --help for usage.");
            }
        }

        return options;
    }

    /// <summary>Prints CLI usage information.</summary>
    private static void PrintUsage()
    {
        Console.WriteLine(@"
Context Collapse Mitigation Benchmark — Data Collection Runner

Usage: run-benchmark [phase] [options]

Phases:
  archive     Run the content archival phase only (not yet implemented)
  validate    Run pre-flight validation only
  run         Run the inference loop only (assumes archive exists)
  all         Run archive → validate → run in sequence (default)

Options:
  --config <path>         Path to benchmark-config.json
                          (default: ./benchmark-config.json)
  --resume                Resume from checkpoint (default if checkpoint exists)
  --no-resume             Start fresh, ignoring any existing checkpoint
  --force-rerun <model>   Re-run a specific model even if checkpointed
  --dry-run               Run validation and assembly but skip inference
  --verbose               Enable Debug-level logging
  --log-file <path>       Override log file path
  --help, -h              Show this help message

Exit Codes:
  0   Phase completed successfully
  1   Pre-flight validation failed
  2   Inference endpoint unreachable
  3   Unrecoverable internal error
  4   Disk full or I/O error
  130 Interrupted by operator (Ctrl+C)

Examples:
  run-benchmark all --config ./benchmark-config.json
  run-benchmark validate --verbose
  run-benchmark run --no-resume
  run-benchmark run --force-rerun llama-3.3-8b-q8_0 --verbose
");
    }
}

/// <summary>Execution phase selection.</summary>
public enum ExecutionPhase
{
    /// <summary>Run archive → validate → run in sequence (default).</summary>
    All,

    /// <summary>Run the content archival phase only (not yet implemented).</summary>
    Archive,

    /// <summary>Run pre-flight validation only.</summary>
    Validate,

    /// <summary>Run the inference loop only.</summary>
    Run
}

/// <summary>Parsed CLI options.</summary>
public sealed class CliOptions
{
    public ExecutionPhase Phase { get; set; } = ExecutionPhase.All;
    public string ConfigPath { get; set; } = "./benchmark-config.json";
    public bool NoResume { get; set; } = false;
    public string? ForceRerunModel { get; set; }
    public bool DryRun { get; set; }
    public bool Verbose { get; set; }
    public string? LogFile { get; set; }
}
