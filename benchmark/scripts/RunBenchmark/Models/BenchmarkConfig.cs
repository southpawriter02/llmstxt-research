// ============================================================================
// BenchmarkConfig.cs — Strongly-typed configuration model
// ============================================================================
// Traces To:  runner-design-spec.md §5, benchmark-config-schema.md
// Purpose:    Deserialization target for benchmark-config.json. Once loaded
//             and validated by ConfigLoader, this object is frozen (all
//             properties are init-only) and passed to every component as
//             a constructor dependency.
//
// Immutability: All properties use { get; init; } (C# 9+ init-only setters).
//               Collections are IReadOnlyList<T>. This prevents accidental
//               mutation during a multi-day run and makes the config safe to
//               pass without defensive copying.
// ============================================================================

using System.Text.Json.Serialization;

namespace RunBenchmark.Models;

/// <summary>
/// Root configuration object deserialized from benchmark-config.json.
/// Every field the runner needs is either in this object or derivable
/// from it at runtime.
/// </summary>
public sealed record BenchmarkConfig
{
    /// <summary>Semantic version of the config format (e.g., "1.0.0").</summary>
    [JsonPropertyName("version")]
    public required string Version { get; init; }

    /// <summary>ISO 8601 date when this config was authored.</summary>
    [JsonPropertyName("created")]
    public required string Created { get; init; }

    /// <summary>
    /// Git commit hash of methodology.md at the time this config was finalized.
    /// Null during drafting; must be populated before data collection.
    /// </summary>
    [JsonPropertyName("methodology_commit")]
    public string? MethodologyCommit { get; init; }

    /// <summary>Local inference server configuration (Ollama or LM Studio).</summary>
    [JsonPropertyName("inference_endpoint")]
    public required InferenceEndpointConfig InferenceEndpoint { get; init; }

    /// <summary>Global inference parameters applied to every model.</summary>
    [JsonPropertyName("inference_parameters")]
    public required InferenceParametersConfig InferenceParameters { get; init; }

    /// <summary>Standardized prompt structure from methodology §2.4.</summary>
    [JsonPropertyName("prompt_template")]
    public required PromptTemplateConfig PromptTemplate { get; init; }

    /// <summary>
    /// Ordered array of model definitions. Processed in array order.
    /// </summary>
    [JsonPropertyName("models")]
    public required IReadOnlyList<ModelConfig> Models { get; init; }

    /// <summary>Content extraction and preprocessing settings.</summary>
    [JsonPropertyName("extraction")]
    public required ExtractionConfig Extraction { get; init; }

    /// <summary>
    /// Filesystem paths to input and output files. All relative to the config
    /// file's directory — resolved to absolute paths by ConfigLoader at load time.
    /// </summary>
    [JsonPropertyName("paths")]
    public required PathsConfig Paths { get; init; }

    /// <summary>Run ordering and checkpoint strategy.</summary>
    [JsonPropertyName("run_protocol")]
    public required RunProtocolConfig RunProtocol { get; init; }

    /// <summary>Content archival phase settings.</summary>
    [JsonPropertyName("archive_protocol")]
    public required ArchiveProtocolConfig ArchiveProtocol { get; init; }
}

// ============================================================================
// Sub-configuration records — one per JSON section
// ============================================================================

/// <summary>
/// Settings for the local inference server (Ollama or LM Studio).
/// See benchmark-config-schema.md §inference_endpoint.
/// </summary>
public sealed record InferenceEndpointConfig
{
    [JsonPropertyName("base_url")]
    public required string BaseUrl { get; init; }

    [JsonPropertyName("api_path")]
    public required string ApiPath { get; init; }

    /// <summary>
    /// Which inference engine is running. Valid: "ollama" or "lm_studio".
    /// Recorded in raw-data.csv for reproducibility.
    /// </summary>
    [JsonPropertyName("engine")]
    public required string Engine { get; init; }

    /// <summary>
    /// Maximum wait time (seconds) for a single inference request.
    /// Default: 300 (5 minutes). See methodology §4.7.
    /// </summary>
    [JsonPropertyName("request_timeout_seconds")]
    public required int RequestTimeoutSeconds { get; init; }

    /// <summary>
    /// Number of throwaway prompts sent to each newly-loaded model
    /// before recording data. Stabilizes inference speed. See methodology §4.7.
    /// </summary>
    [JsonPropertyName("warmup_prompt_count")]
    public required int WarmupPromptCount { get; init; }

    /// <summary>Computed full URL: BaseUrl + ApiPath.</summary>
    [JsonIgnore]
    public string FullUrl => BaseUrl.TrimEnd('/') + ApiPath;
}

/// <summary>
/// Global inference parameters from methodology §4.6. Identical for all models.
/// Maps directly to the Ollama/LM Studio API request body.
/// </summary>
public sealed record InferenceParametersConfig
{
    [JsonPropertyName("temperature")]
    public required double Temperature { get; init; }

    [JsonPropertyName("seed")]
    public required int Seed { get; init; }

    [JsonPropertyName("top_p")]
    public required double TopP { get; init; }

    [JsonPropertyName("top_k")]
    public required int TopK { get; init; }

    [JsonPropertyName("repeat_penalty")]
    public required double RepeatPenalty { get; init; }

    /// <summary>Maximum output tokens. Default: 512. See methodology §4.6.</summary>
    [JsonPropertyName("num_predict")]
    public required int NumPredict { get; init; }

    /// <summary>
    /// Overhead tokens added to input_token_count + num_predict when computing
    /// the dynamic num_ctx. Covers system prompt, formatting, safety margin.
    /// See benchmark-config-schema.md §inference_parameters.
    /// </summary>
    [JsonPropertyName("num_ctx_overhead")]
    public required int NumCtxOverhead { get; init; }
}

/// <summary>
/// Standardized prompt structure from methodology §2.4.
/// Placeholders: {assembled_content} and {question_text}.
/// </summary>
public sealed record PromptTemplateConfig
{
    [JsonPropertyName("system_prompt")]
    public required string SystemPrompt { get; init; }

    [JsonPropertyName("user_prompt")]
    public required string UserPrompt { get; init; }
}

/// <summary>
/// A single model definition from the config's models[] array.
/// See benchmark-config-schema.md §models[].
/// </summary>
public sealed record ModelConfig
{
    /// <summary>
    /// Unique identifier for this model in the benchmark.
    /// Format: {family}-{size}-q8_0. Appears in raw-data.csv.
    /// </summary>
    [JsonPropertyName("model_id")]
    public required string ModelId { get; init; }

    /// <summary>
    /// Model family: "llama", "qwen3", "gemma3", or "mistral".
    /// Used for tokenizer selection (methodology §2.6) and subgroup analysis.
    /// </summary>
    [JsonPropertyName("family")]
    public required string Family { get; init; }

    /// <summary>Parameter count in billions (e.g., 8, 70, 123).</summary>
    [JsonPropertyName("parameters_b")]
    public required int ParametersB { get; init; }

    /// <summary>
    /// Capability tier: "small", "medium", or "large".
    /// Determines subgroup membership for H4 analysis.
    /// </summary>
    [JsonPropertyName("tier")]
    public required string Tier { get; init; }

    /// <summary>
    /// Exact Ollama model tag for pulling/loading (e.g., "llama3.3:8b-instruct-q8_0").
    /// Must be verified against 'ollama list' before data collection.
    /// </summary>
    [JsonPropertyName("ollama_tag")]
    public required string OllamaTag { get; init; }

    /// <summary>
    /// Maximum supported context window in tokens. Used in dynamic num_ctx calculation.
    /// </summary>
    [JsonPropertyName("max_context_length")]
    public required int MaxContextLength { get; init; }

    /// <summary>Quantization level. Fixed to "Q8_0" for this study.</summary>
    [JsonPropertyName("quantization")]
    public required string Quantization { get; init; }

    /// <summary>
    /// True if this model's family provides the reference tokenizer for
    /// cross-model comparisons (methodology §2.6). Only Llama is true.
    /// </summary>
    [JsonPropertyName("is_reference_tokenizer_family")]
    public required bool IsReferenceTokenizerFamily { get; init; }

    /// <summary>Human-readable notes. Not used by the runner.</summary>
    [JsonPropertyName("notes")]
    public string? Notes { get; init; }

    /// <summary>Whether this model is from the Qwen 3 family (needs /no_think suppression).</summary>
    [JsonIgnore]
    public bool IsQwen3 => Family.Equals("qwen3", StringComparison.OrdinalIgnoreCase);
}

/// <summary>Content extraction and preprocessing settings.</summary>
public sealed record ExtractionConfig
{
    [JsonPropertyName("html_extractor")]
    public required string HtmlExtractor { get; init; }

    /// <summary>
    /// Minimum character count for extracted content to be considered valid.
    /// Below this threshold → exclusion with reason JS_ONLY.
    /// </summary>
    [JsonPropertyName("min_content_length_chars")]
    public required int MinContentLengthChars { get; init; }

    [JsonPropertyName("markdown_preprocessing")]
    public required MarkdownPreprocessingConfig MarkdownPreprocessing { get; init; }
}

/// <summary>
/// Preprocessing steps applied to Condition B Markdown content
/// before XML wrapping. See methodology §2.3.
/// </summary>
public sealed record MarkdownPreprocessingConfig
{
    [JsonPropertyName("strip_html_comments")]
    public required bool StripHtmlComments { get; init; }

    [JsonPropertyName("strip_base64_images")]
    public required bool StripBase64Images { get; init; }

    [JsonPropertyName("max_consecutive_blank_lines")]
    public required int MaxConsecutiveBlankLines { get; init; }

    [JsonPropertyName("normalize_line_endings")]
    public required string NormalizeLineEndings { get; init; }
}

/// <summary>
/// Filesystem paths to input and output files.
/// All paths stored here are ABSOLUTE — resolved from relative paths by ConfigLoader.
/// </summary>
public sealed record PathsConfig
{
    [JsonPropertyName("questions")]
    public required string Questions { get; init; }

    [JsonPropertyName("gold_answers")]
    public required string GoldAnswers { get; init; }

    [JsonPropertyName("site_list")]
    public required string SiteList { get; init; }

    [JsonPropertyName("scoring_rubric")]
    public required string ScoringRubric { get; init; }

    [JsonPropertyName("archive_dir")]
    public required string ArchiveDir { get; init; }

    [JsonPropertyName("archive_manifest")]
    public required string ArchiveManifest { get; init; }

    [JsonPropertyName("results_dir")]
    public required string ResultsDir { get; init; }

    [JsonPropertyName("raw_data_csv")]
    public required string RawDataCsv { get; init; }

    [JsonPropertyName("checkpoint_file")]
    public required string CheckpointFile { get; init; }
}

/// <summary>Run ordering and checkpoint strategy.</summary>
public sealed record RunProtocolConfig
{
    [JsonPropertyName("model_order")]
    public required string ModelOrder { get; init; }

    [JsonPropertyName("condition_order_per_question")]
    public required IReadOnlyList<string> ConditionOrderPerQuestion { get; init; }

    [JsonPropertyName("checkpoint_granularity")]
    public required string CheckpointGranularity { get; init; }

    [JsonPropertyName("resume_from_checkpoint")]
    public required bool ResumeFromCheckpoint { get; init; }
}

/// <summary>Content archiving settings from methodology §2.1.</summary>
public sealed record ArchiveProtocolConfig
{
    [JsonPropertyName("fetch_timeout_seconds")]
    public required int FetchTimeoutSeconds { get; init; }

    [JsonPropertyName("user_agent")]
    public required string UserAgent { get; init; }

    [JsonPropertyName("respect_robots_txt")]
    public required bool RespectRobotsTxt { get; init; }

    [JsonPropertyName("rate_limit_ms")]
    public required int RateLimitMs { get; init; }
}
