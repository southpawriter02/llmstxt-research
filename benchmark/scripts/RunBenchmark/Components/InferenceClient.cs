// ============================================================================
// InferenceClient.cs — Thin HTTP wrapper for Ollama/LM Studio inference API
// ============================================================================
// Traces To:  runner-design-spec.md §7.5 (Inference Request), §7.6 (Timeout/Error)
// Purpose:    Sends chat completion requests to the configured inference
//             endpoint and returns structured results. Handles timeouts,
//             connection failures, HTTP errors, and malformed responses.
//
// No retry policy: At temperature 0 with a fixed seed, retrying the same
//                  prompt produces the same result (or the same failure).
//                  The only exception is connection-refused, where a brief
//                  wait may resolve a transient loading issue (§7.6).
//
// Request format: OpenAI-compatible /v1/chat/completions (§7.5).
//                 Both Ollama and LM Studio support this format.
// ============================================================================

using System.Diagnostics;
using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Logging;
using RunBenchmark.Models;

namespace RunBenchmark.Components;

/// <summary>
/// Sends inference requests to the local Ollama or LM Studio endpoint.
/// Returns structured <see cref="InferenceResult"/> objects that the
/// Orchestrator uses to populate CSV rows.
/// </summary>
public sealed class InferenceClient
{
    private readonly HttpClient _httpClient;
    private readonly string _endpointUrl;
    private readonly int _timeoutSeconds;
    private readonly ILogger _logger;

    /// <summary>
    /// Tracks consecutive connection failures for the endpoint-down detection
    /// logic in design spec §10.1. After 3 consecutive failures across
    /// different questions, the runner pauses and prompts the operator.
    /// </summary>
    private int _consecutiveConnectionFailures;

    /// <summary>Maximum consecutive connection failures before pausing.</summary>
    private const int MaxConsecutiveFailuresBeforePause = 3;

    /// <summary>
    /// Creates a new InferenceClient.
    /// </summary>
    /// <param name="httpClient">Pre-configured HttpClient (from HttpClientFactory).</param>
    /// <param name="endpointUrl">Full URL to the chat completions endpoint.</param>
    /// <param name="timeoutSeconds">Per-request timeout in seconds.</param>
    /// <param name="logger">Logger for diagnostic output.</param>
    public InferenceClient(
        HttpClient httpClient,
        string endpointUrl,
        int timeoutSeconds,
        ILogger logger)
    {
        _httpClient = httpClient;
        _endpointUrl = endpointUrl;
        _timeoutSeconds = timeoutSeconds;
        _logger = logger;
    }

    /// <summary>
    /// Sends a single inference request and returns the result.
    /// </summary>
    /// <param name="modelTag">Ollama model tag (e.g., "llama3.3:8b-instruct-q8_0").</param>
    /// <param name="systemPrompt">System message content.</param>
    /// <param name="userMessage">User message content (assembled prompt).</param>
    /// <param name="parameters">Inference parameters from config.</param>
    /// <param name="numCtx">Computed context window size for this request.</param>
    /// <param name="cancellationToken">Cancellation token for graceful shutdown.</param>
    /// <returns>
    /// An <see cref="InferenceResult"/> containing the response text, token count,
    /// elapsed time, and any error reason.
    /// </returns>
    public async Task<InferenceResult> SendAsync(
        string modelTag,
        string systemPrompt,
        string userMessage,
        InferenceParametersConfig parameters,
        int numCtx,
        CancellationToken cancellationToken = default)
    {
        // Build the request body per design spec §7.5 (OpenAI-compatible format)
        var requestBody = new ChatCompletionRequest
        {
            Model = modelTag,
            Messages = new[]
            {
                new ChatMessage { Role = "system", Content = systemPrompt },
                new ChatMessage { Role = "user", Content = userMessage }
            },
            Temperature = parameters.Temperature,
            Seed = parameters.Seed,
            TopP = parameters.TopP,
            TopK = parameters.TopK,
            RepeatPenalty = parameters.RepeatPenalty,
            MaxTokens = parameters.NumPredict,
            Options = new RequestOptions { NumCtx = numCtx }
        };

        _logger.LogDebug(
            "Sending inference request: model={Model}, num_ctx={NumCtx}, " +
            "prompt_length={PromptLen}",
            modelTag, numCtx, userMessage.Length);

        var stopwatch = Stopwatch.StartNew();

        try
        {
            // Create a per-request timeout via a linked CancellationTokenSource
            using var timeoutCts = new CancellationTokenSource(
                TimeSpan.FromSeconds(_timeoutSeconds));
            using var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(
                cancellationToken, timeoutCts.Token);

            var response = await _httpClient.PostAsJsonAsync(
                _endpointUrl,
                requestBody,
                linkedCts.Token);

            stopwatch.Stop();

            // Reset consecutive failure counter on any response (even errors)
            _consecutiveConnectionFailures = 0;

            // Handle HTTP error codes (§7.6)
            if (!response.IsSuccessStatusCode)
            {
                var statusCode = (int)response.StatusCode;
                var body = await response.Content.ReadAsStringAsync(cancellationToken);
                _logger.LogError(
                    "HTTP {StatusCode} from inference endpoint. Body: {Body}",
                    statusCode, body.Length > 500 ? body[..500] + "..." : body);

                return new InferenceResult
                {
                    ErrorReason = $"HTTP_{statusCode}",
                    ElapsedSeconds = stopwatch.Elapsed.TotalSeconds
                };
            }

            // Parse the response
            var responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            return ParseResponse(responseJson, stopwatch.Elapsed.TotalSeconds);
        }
        catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
        {
            // Graceful shutdown requested — propagate the cancellation
            stopwatch.Stop();
            _logger.LogInformation("Inference request cancelled (shutdown requested).");
            throw;
        }
        catch (OperationCanceledException)
        {
            // Timeout (not user cancellation)
            stopwatch.Stop();
            _logger.LogError(
                "Inference request timed out after {Seconds}s for model {Model}.",
                _timeoutSeconds, modelTag);

            return new InferenceResult
            {
                ErrorReason = "TIMEOUT",
                ElapsedSeconds = stopwatch.Elapsed.TotalSeconds
            };
        }
        catch (HttpRequestException ex)
        {
            // Connection failure (§7.6: connection refused)
            stopwatch.Stop();
            _consecutiveConnectionFailures++;

            _logger.LogError(ex,
                "Connection failure #{Count} to inference endpoint: {Error}",
                _consecutiveConnectionFailures, ex.Message);

            // First connection failure for a model: wait 30s and retry once (§7.6)
            if (_consecutiveConnectionFailures == 1)
            {
                _logger.LogWarning(
                    "Waiting 30 seconds before retry (model may be loading)...");
                await Task.Delay(TimeSpan.FromSeconds(30), cancellationToken);

                // Recursive retry (only once — the counter is now 1, not 0)
                return await SendAsync(
                    modelTag, systemPrompt, userMessage,
                    parameters, numCtx, cancellationToken);
            }

            return new InferenceResult
            {
                ErrorReason = "CONNECTION_REFUSED",
                ElapsedSeconds = stopwatch.Elapsed.TotalSeconds
            };
        }
    }

    /// <summary>
    /// Sends a lightweight warm-up prompt (design spec §7.3).
    /// Logs timing for diagnostics. Returns the result so the Orchestrator
    /// can detect model-not-loaded conditions for LM Studio (§7.2).
    /// </summary>
    public async Task<InferenceResult> SendWarmupAsync(
        string modelTag,
        InferenceParametersConfig parameters,
        CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();

        var result = await SendAsync(
            modelTag,
            "You are a helpful assistant.",
            "Respond with OK.",
            parameters,
            numCtx: 512,  // Minimal context for warmup
            cancellationToken);

        stopwatch.Stop();

        if (result.IsSuccess)
        {
            _logger.LogDebug(
                "Warmup response from {Model}: {Response} ({Elapsed:F1}s)",
                modelTag, result.ResponseText?.Trim(), stopwatch.Elapsed.TotalSeconds);
        }
        else
        {
            _logger.LogWarning(
                "Warmup failed for {Model}: {Error} ({Elapsed:F1}s)",
                modelTag, result.ErrorReason, stopwatch.Elapsed.TotalSeconds);
        }

        return result;
    }

    /// <summary>
    /// Checks whether the inference endpoint is reachable by sending a health check.
    /// Used during pre-flight validation (design spec §4.2, V-6).
    /// </summary>
    /// <returns>True if the endpoint responds, false otherwise.</returns>
    public async Task<bool> CheckHealthAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            // Try Ollama's tags endpoint (also works for basic connectivity)
            var baseUrl = _endpointUrl.Contains("/v1/")
                ? _endpointUrl[.._endpointUrl.IndexOf("/v1/")] + "/api/tags"
                : _endpointUrl;

            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(10));
            using var linked = CancellationTokenSource.CreateLinkedTokenSource(
                cancellationToken, cts.Token);

            var response = await _httpClient.GetAsync(baseUrl, linked.Token);
            return response.IsSuccessStatusCode;
        }
        catch
        {
            return false;
        }
    }

    /// <summary>
    /// Gets the list of available models from Ollama (for pre-flight V-7).
    /// Returns an empty list if the endpoint doesn't support model listing.
    /// </summary>
    public async Task<List<string>> GetAvailableModelsAsync(
        CancellationToken cancellationToken = default)
    {
        try
        {
            var baseUrl = _endpointUrl.Contains("/v1/")
                ? _endpointUrl[.._endpointUrl.IndexOf("/v1/")] + "/api/tags"
                : _endpointUrl;

            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(10));
            using var linked = CancellationTokenSource.CreateLinkedTokenSource(
                cancellationToken, cts.Token);

            var response = await _httpClient.GetStringAsync(baseUrl, linked.Token);
            using var doc = JsonDocument.Parse(response);

            var models = new List<string>();
            if (doc.RootElement.TryGetProperty("models", out var modelsArray))
            {
                foreach (var model in modelsArray.EnumerateArray())
                {
                    if (model.TryGetProperty("name", out var name))
                    {
                        models.Add(name.GetString() ?? "");
                    }
                }
            }
            return models;
        }
        catch
        {
            return new List<string>();
        }
    }

    /// <summary>
    /// Whether the endpoint appears to be completely down (3+ consecutive failures).
    /// The Orchestrator checks this to decide whether to pause and prompt the operator.
    /// </summary>
    public bool IsEndpointDown => _consecutiveConnectionFailures >= MaxConsecutiveFailuresBeforePause;

    /// <summary>Resets the consecutive failure counter (e.g., after operator intervention).</summary>
    public void ResetFailureCounter() => _consecutiveConnectionFailures = 0;

    // ========================================================================
    // Response parsing
    // ========================================================================

    /// <summary>
    /// Parses an OpenAI-compatible chat completion response (§7.5).
    /// </summary>
    private InferenceResult ParseResponse(string json, double elapsedSeconds)
    {
        try
        {
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            // Extract response text from choices[0].message.content
            string? responseText = null;
            if (root.TryGetProperty("choices", out var choices) &&
                choices.GetArrayLength() > 0)
            {
                var firstChoice = choices[0];
                if (firstChoice.TryGetProperty("message", out var message) &&
                    message.TryGetProperty("content", out var content))
                {
                    responseText = content.GetString();
                }
            }

            // Extract output token count from usage.completion_tokens
            int outputTokens = 0;
            if (root.TryGetProperty("usage", out var usage) &&
                usage.TryGetProperty("completion_tokens", out var completionTokens))
            {
                outputTokens = completionTokens.GetInt32();
            }

            // Handle empty response (§7.6)
            if (string.IsNullOrEmpty(responseText))
            {
                _logger.LogError("Empty response text from inference endpoint.");
                return new InferenceResult
                {
                    ErrorReason = "EMPTY_RESPONSE",
                    ElapsedSeconds = elapsedSeconds
                };
            }

            return new InferenceResult
            {
                ResponseText = responseText,
                OutputTokenCount = outputTokens,
                ElapsedSeconds = elapsedSeconds
            };
        }
        catch (JsonException ex)
        {
            _logger.LogError(ex,
                "Malformed JSON response from inference endpoint: {Error}",
                ex.Message);
            _logger.LogDebug("Raw response: {Json}",
                json.Length > 2000 ? json[..2000] + "..." : json);

            return new InferenceResult
            {
                ErrorReason = "MALFORMED_RESPONSE",
                ElapsedSeconds = elapsedSeconds
            };
        }
    }
}

// ============================================================================
// Request/Response DTOs for the OpenAI-compatible chat completions API
// ============================================================================

/// <summary>
/// OpenAI-compatible chat completion request body.
/// See design spec §7.5 for the exact format.
/// </summary>
internal sealed class ChatCompletionRequest
{
    [JsonPropertyName("model")]
    public required string Model { get; init; }

    [JsonPropertyName("messages")]
    public required ChatMessage[] Messages { get; init; }

    [JsonPropertyName("temperature")]
    public double Temperature { get; init; }

    [JsonPropertyName("seed")]
    public int Seed { get; init; }

    [JsonPropertyName("top_p")]
    public double TopP { get; init; }

    [JsonPropertyName("top_k")]
    public int TopK { get; init; }

    [JsonPropertyName("repeat_penalty")]
    public double RepeatPenalty { get; init; }

    [JsonPropertyName("max_tokens")]
    public int MaxTokens { get; init; }

    [JsonPropertyName("options")]
    public RequestOptions? Options { get; init; }
}

/// <summary>Chat message with role and content.</summary>
internal sealed class ChatMessage
{
    [JsonPropertyName("role")]
    public required string Role { get; init; }

    [JsonPropertyName("content")]
    public required string Content { get; init; }
}

/// <summary>
/// Ollama-specific options passed in the request body.
/// LM Studio ignores these, which is fine.
/// </summary>
internal sealed class RequestOptions
{
    [JsonPropertyName("num_ctx")]
    public int NumCtx { get; init; }
}
