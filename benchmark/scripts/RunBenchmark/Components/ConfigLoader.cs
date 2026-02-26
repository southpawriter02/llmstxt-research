// ============================================================================
// ConfigLoader.cs — Reads, validates, and resolves benchmark-config.json
// ============================================================================
// Traces To:  runner-design-spec.md §5 (Configuration Loading)
// Purpose:    Single entry point for loading the benchmark configuration.
//             Deserializes JSON → strongly-typed BenchmarkConfig, resolves
//             all relative paths against the config file's directory, and
//             validates required fields before returning an immutable config.
//
// Validation: See §5.2 for the complete rule set. If any rule fails, this
//             component throws a ConfigurationException with a descriptive
//             message — the CLI entry point catches it and reports to the
//             operator.
// ============================================================================

using System.Text.Json;
using Microsoft.Extensions.Logging;
using RunBenchmark.Models;

namespace RunBenchmark.Components;

/// <summary>
/// Loads and validates benchmark-config.json. Returns an immutable
/// <see cref="BenchmarkConfig"/> that all other components receive as a
/// constructor dependency.
/// </summary>
public static class ConfigLoader
{
    // JSON deserialization options — case-insensitive to tolerate minor
    // casing differences, but PropertyNameCaseInsensitive is false by default
    // since we use explicit [JsonPropertyName] attributes everywhere.
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = false,
        ReadCommentHandling = JsonCommentHandling.Skip,
        AllowTrailingCommas = true
    };

    /// <summary>
    /// Loads the benchmark configuration from the specified file path.
    /// </summary>
    /// <param name="configFilePath">
    /// Absolute or relative path to benchmark-config.json.
    /// All paths inside the config are resolved relative to this file's directory.
    /// </param>
    /// <param name="logger">Logger for diagnostic output during loading.</param>
    /// <returns>A validated, path-resolved, immutable <see cref="BenchmarkConfig"/>.</returns>
    /// <exception cref="ConfigurationException">
    /// Thrown when the config file cannot be read, parsed, or fails validation.
    /// The exception message is human-readable and includes the specific rule that failed.
    /// </exception>
    public static BenchmarkConfig Load(string configFilePath, ILogger logger)
    {
        // --- Step 1: Read the raw JSON ---
        var absolutePath = Path.GetFullPath(configFilePath);
        logger.LogInformation("Loading config from: {Path}", absolutePath);

        if (!File.Exists(absolutePath))
        {
            throw new ConfigurationException(
                $"Config file not found: {absolutePath}");
        }

        string json;
        try
        {
            json = File.ReadAllText(absolutePath);
        }
        catch (Exception ex) when (ex is IOException or UnauthorizedAccessException)
        {
            throw new ConfigurationException(
                $"Cannot read config file: {absolutePath} — {ex.Message}", ex);
        }

        // --- Step 2: Deserialize ---
        BenchmarkConfig config;
        try
        {
            config = JsonSerializer.Deserialize<BenchmarkConfig>(json, JsonOptions)
                     ?? throw new ConfigurationException("Config file deserialized to null.");
        }
        catch (JsonException ex)
        {
            throw new ConfigurationException(
                $"Config JSON parse error: {ex.Message}", ex);
        }

        // --- Step 3: Validate (design spec §5.2) ---
        Validate(config);

        // --- Step 4: Resolve relative paths (design spec §5.1) ---
        var configDir = Path.GetDirectoryName(absolutePath)
                        ?? throw new ConfigurationException(
                            $"Cannot determine directory of config file: {absolutePath}");

        config = ResolveRelativePaths(config, configDir);

        logger.LogInformation(
            "Config loaded: version={Version}, models={ModelCount}, engine={Engine}",
            config.Version, config.Models.Count, config.InferenceEndpoint.Engine);

        return config;
    }

    // ========================================================================
    // Validation — design spec §5.2
    // ========================================================================

    /// <summary>
    /// Applies all validation rules defined in design spec §5.2.
    /// Throws <see cref="ConfigurationException"/> on the first failure.
    /// </summary>
    private static void Validate(BenchmarkConfig config)
    {
        // Rule: Version present
        if (string.IsNullOrWhiteSpace(config.Version))
            throw new ConfigurationException("config.version is required and cannot be empty.");

        // Rule: Models non-empty
        if (config.Models.Count == 0)
            throw new ConfigurationException("config.models array must have ≥1 entry.");

        // Rule: Model IDs unique
        var modelIds = new HashSet<string>();
        foreach (var m in config.Models)
        {
            if (!modelIds.Add(m.ModelId))
                throw new ConfigurationException($"Duplicate model_id: \"{m.ModelId}\".");
        }

        // Rule: Inference parameters in range
        var ip = config.InferenceParameters;
        if (ip.Temperature < 0.0 || ip.Temperature > 2.0)
            throw new ConfigurationException(
                $"temperature must be in [0.0, 2.0], got {ip.Temperature}.");
        if (ip.Seed <= 0)
            throw new ConfigurationException(
                $"seed must be > 0, got {ip.Seed}.");
        if (ip.NumPredict <= 0)
            throw new ConfigurationException(
                $"num_predict must be > 0, got {ip.NumPredict}.");
        if (ip.NumCtxOverhead <= 0)
            throw new ConfigurationException(
                $"num_ctx_overhead must be > 0, got {ip.NumCtxOverhead}.");

        // Rule: Paths non-empty
        var paths = config.Paths;
        ValidatePathField(paths.Questions, "paths.questions");
        ValidatePathField(paths.GoldAnswers, "paths.gold_answers");
        ValidatePathField(paths.SiteList, "paths.site_list");
        ValidatePathField(paths.ScoringRubric, "paths.scoring_rubric");
        ValidatePathField(paths.ArchiveDir, "paths.archive_dir");
        ValidatePathField(paths.ArchiveManifest, "paths.archive_manifest");
        ValidatePathField(paths.ResultsDir, "paths.results_dir");
        ValidatePathField(paths.RawDataCsv, "paths.raw_data_csv");
        ValidatePathField(paths.CheckpointFile, "paths.checkpoint_file");

        // Rule: Prompt template has placeholders
        if (!config.PromptTemplate.UserPrompt.Contains("{assembled_content}"))
            throw new ConfigurationException(
                "prompt_template.user_prompt must contain {assembled_content} placeholder.");
        if (!config.PromptTemplate.UserPrompt.Contains("{question_text}"))
            throw new ConfigurationException(
                "prompt_template.user_prompt must contain {question_text} placeholder.");

        // Rule: Conditions valid — must be exactly ["A", "B"]
        var conditions = config.RunProtocol.ConditionOrderPerQuestion;
        if (conditions.Count != 2 ||
            !conditions[0].Equals("A", StringComparison.Ordinal) ||
            !conditions[1].Equals("B", StringComparison.Ordinal))
        {
            throw new ConfigurationException(
                "run_protocol.condition_order_per_question must be exactly [\"A\", \"B\"].");
        }

        // Rule: Engine is a valid value
        var engine = config.InferenceEndpoint.Engine;
        if (engine != "ollama" && engine != "lm_studio")
        {
            throw new ConfigurationException(
                $"inference_endpoint.engine must be \"ollama\" or \"lm_studio\", got \"{engine}\".");
        }
    }

    /// <summary>Validates that a path field is non-null and non-empty.</summary>
    private static void ValidatePathField(string value, string fieldName)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new ConfigurationException($"{fieldName} is required and cannot be empty.");
    }

    // ========================================================================
    // Path resolution — design spec §5.1
    // ========================================================================

    /// <summary>
    /// Resolves all relative paths in the config to absolute paths by combining
    /// them with the config file's parent directory. Returns a new config with
    /// resolved paths (the original is unchanged — immutability preserved).
    /// </summary>
    private static BenchmarkConfig ResolveRelativePaths(BenchmarkConfig config, string configDir)
    {
        // Helper that resolves a single relative path against configDir
        string Resolve(string relativePath) =>
            Path.GetFullPath(Path.Combine(configDir, relativePath));

        // Create a new PathsConfig with all paths resolved to absolute
        var resolvedPaths = new PathsConfig
        {
            Questions = Resolve(config.Paths.Questions),
            GoldAnswers = Resolve(config.Paths.GoldAnswers),
            SiteList = Resolve(config.Paths.SiteList),
            ScoringRubric = Resolve(config.Paths.ScoringRubric),
            ArchiveDir = Resolve(config.Paths.ArchiveDir),
            ArchiveManifest = Resolve(config.Paths.ArchiveManifest),
            ResultsDir = Resolve(config.Paths.ResultsDir),
            RawDataCsv = Resolve(config.Paths.RawDataCsv),
            CheckpointFile = Resolve(config.Paths.CheckpointFile)
        };

        // Return a copy of the config with the resolved paths
        return config with { Paths = resolvedPaths };
    }
}

/// <summary>
/// Exception thrown when config loading or validation fails.
/// The message is always human-readable and includes the specific issue.
/// </summary>
public class ConfigurationException : Exception
{
    public ConfigurationException(string message) : base(message) { }
    public ConfigurationException(string message, Exception inner) : base(message, inner) { }
}
