# benchmark-config.json Schema Documentation

> **Traces To:** Story 4.2, Task 4.2.3
> **Created:** 2026-02-26
> **Last Updated:** 2026-02-26
> **Consumed By:** `run-benchmark.cs` (data collection runner)
> **Authoritative Source:** `benchmark/methodology.md` (§2, §4)

---

This document defines every field in `benchmark-config.json`, its type, constraints, and the methodology section that governs its value. The config file is the machine-readable contract between the methodology specification and the data collection runner — every parameter the runner needs is either in this file or derivable from it at runtime.

**Immutability rule:** Once data collection begins, this file must not be modified. If a value needs to change mid-run (e.g., an Ollama tag is wrong), the run must be restarted from scratch with the corrected config and a fresh `raw-data.csv`. The `methodology_commit` field records the git commit hash of the methodology document this config was generated from, providing an audit trail.

---

## Top-Level Metadata

| Field | Type | Required | Description | Methodology Reference |
|-------|------|----------|-------------|-----------------------|
| `$schema` | String | No | Path to a JSON Schema file for IDE validation. Not used by the runner. | — |
| `_comment` | String | No | Human-readable description. Ignored by the runner. Present at multiple levels throughout the file. | — |
| `version` | String | Yes | Semantic version of the config format (e.g., `"1.0.0"`). Allows the runner to detect incompatible config files from different study versions. | — |
| `created` | String | Yes | ISO 8601 date when this config was authored. | — |
| `methodology_commit` | String | Yes | Git commit hash of `methodology.md` at the time this config was finalized. Set to `null` during drafting; must be populated before data collection. | — |

---

## `inference_endpoint`

Settings for the local inference server (Ollama or LM Studio).

| Field | Type | Required | Default | Description | Methodology Reference |
|-------|------|----------|---------|-------------|-----------------------|
| `base_url` | String (URL) | Yes | `"http://localhost:11434"` | Base URL of the inference engine's HTTP API. Ollama default is port 11434; LM Studio uses a configurable port. | §4.1 |
| `api_path` | String | Yes | `"/v1/chat/completions"` | The API endpoint path appended to `base_url`. Both Ollama and LM Studio expose an OpenAI-compatible chat completions endpoint at this path. | §4.1 |
| `engine` | Enum | Yes | `"ollama"` | Which inference engine is running. Valid values: `"ollama"`, `"lm_studio"`. Recorded in `raw-data.csv` for reproducibility. The runner may use this to send engine-specific parameters (e.g., Ollama's `/api/generate` for model loading). | §4.1 |
| `request_timeout_seconds` | Integer | Yes | `300` | Maximum wait time (in seconds) for a single inference request before the runner considers it timed out. 300 seconds (5 minutes) is generous — even the largest model at the longest input should respond within 2-3 minutes on the Mac Studio. | §4.7 |
| `warmup_prompt_count` | Integer | Yes | `3` | Number of throwaway prompts sent to each newly loaded model before recording data. These prompts stabilize inference speed by warming up the KV cache and memory subsystem. Warmup responses are discarded. | §4.7 |

---

## `inference_parameters`

Global inference parameters applied to every model. These map directly to the Ollama/LM Studio API request body.

| Field | Type | Required | Value | Description | Methodology Reference |
|-------|------|----------|-------|-------------|-----------------------|
| `temperature` | Float | Yes | `0.0` | Greedy decoding. Highest-probability token selected at each step. Eliminates sampling variance. | §4.6 |
| `seed` | Integer | Yes | `42` | Fixed random seed for deterministic output. Provides reproducibility even if the backend has minor floating-point nondeterminism. | §4.6 |
| `top_p` | Float | Yes | `1.0` | Nucleus sampling disabled. At temperature 0, sampling is not invoked, but `top_p = 1.0` ensures no inadvertent filtering. | §4.6 |
| `top_k` | Integer | Yes | `0` | Top-k filtering disabled. Value of 0 means no filtering (all tokens considered). | §4.6 |
| `repeat_penalty` | Float | Yes | `1.0` | Repetition penalty disabled. A value of 1.0 applies no penalty. Enabled penalties can suppress correct repeated terminology. | §4.6 |
| `num_predict` | Integer | Yes | `512` | Maximum output tokens. Generous ceiling for factual answers (gold-standard answers average ~60 tokens). Responses exceeding this are truncated and flagged in `scoring_notes`. | §4.6 |
| `num_ctx_overhead` | Integer | Yes | `128` | Overhead tokens added to `input_token_count + num_predict` when computing the dynamic `num_ctx` per-run. Covers the system prompt, formatting tokens, and safety margin. The actual `num_ctx` sent to the API is: `min(model.max_context_length, input_token_count + num_predict + num_ctx_overhead)`. | §4.6 |

**Note on `num_ctx`:** The `num_ctx` value is not in this config because it is computed dynamically per-run by the runner. The formula is defined in §4.6 and uses `num_predict` and `num_ctx_overhead` from this section plus `input_token_count` (known only at runtime) and `max_context_length` from the model entry.

---

## `prompt_template`

The standardized prompt structure from §2.4. Both conditions use this identical template; only the `{assembled_content}` differs.

| Field | Type | Required | Description | Methodology Reference |
|-------|------|----------|-------------|-----------------------|
| `system_prompt` | String | Yes | The system message sent as the `system` role in the chat completions request. Contains no condition-specific language. | §2.4 |
| `user_prompt` | String | Yes | The user message template. Contains two placeholders: `{assembled_content}` (replaced with the condition's content block) and `{question_text}` (replaced with the question from `questions.json`). Newlines are represented as `\n` in JSON. | §2.4 |

**Runtime behavior:** The runner constructs the API request as a two-message conversation: one `system` message (from `system_prompt`) and one `user` message (from `user_prompt` with placeholders substituted). No assistant prefill or additional messages are included.

---

## `models[]`

An ordered array of model definitions. The runner processes models in array order (sequential, one at a time). Each model entry contains everything the runner needs to load and query that model.

| Field | Type | Required | Description | Methodology Reference |
|-------|------|----------|-------------|-----------------------|
| `model_id` | String | Yes | Unique identifier for this model in the benchmark. Format: `{family}-{size}-q8_0`. This value appears in `raw-data.csv` and all analysis outputs. | §4.3, §4.5 |
| `family` | String | Yes | Model family identifier. One of: `"llama"`, `"qwen3"`, `"gemma3"`, `"mistral"`. Used for tokenizer selection (§2.6) and subgroup analysis. | §4.2 |
| `parameters_b` | Integer | Yes | Parameter count in billions (e.g., `8`, `70`, `123`). Used for capability-tier assignment and the effect-size-vs-model-size analysis (§6.6). | §4.3 |
| `tier` | Enum | Yes | Capability tier assignment. One of: `"small"`, `"medium"`, `"large"`. Determines subgroup membership for H4 analysis. | §4.3 |
| `ollama_tag` | String | Yes | The exact Ollama model tag used to pull/load this model (e.g., `"llama3.3:8b-instruct-q8_0"`). If using LM Studio, this field is informational — the runner uses the model file path instead. **Must be verified against `ollama list` before data collection.** | §4.3 |
| `max_context_length` | Integer | Yes | Maximum supported context window in tokens. Used in the dynamic `num_ctx` calculation. Most models listed here support 128K (131072) tokens, but the actual usable window may be lower depending on available memory. | §4.6 |
| `quantization` | String | Yes | Quantization level. Fixed to `"Q8_0"` for all models in this study. Recorded in `raw-data.csv` alongside `model_id`. | §4.5 |
| `is_reference_tokenizer_family` | Boolean | Yes | `true` if this model's family provides the reference tokenizer for cross-model comparisons (§2.6). Only the Llama family is `true`. This flag tells the runner that `ref_token_count` equals `input_token_count` for this family's models. | §2.6 |
| `notes` | String | No | Human-readable notes. Not used by the runner. | — |

**Array ordering:** Models are listed in the order defined in §4.3 (Llama → Qwen 3 → Gemma 3 → Mistral, smallest to largest within each family). The runner processes them in this order but the ordering has no statistical significance — it only affects which model checkpoints first if the run is interrupted.

---

## `extraction`

Settings governing content extraction and preprocessing for both conditions.

| Field | Type | Required | Description | Methodology Reference |
|-------|------|----------|-------------|-----------------------|
| `html_extractor` | String | Yes | The extraction library used for Condition A. Value: `"SmartReader"`. Documented for reproducibility — if a different extractor were substituted, it would change the study's results. | §2.2 |
| `min_content_length_chars` | Integer | Yes | Minimum character count for extracted content to be considered valid. If SmartReader output is shorter than this, the extraction is treated as a failure and the tuple is excluded per §2.5. Value: `50`. | §2.5 |

### `extraction.markdown_preprocessing`

Preprocessing steps applied to Condition B Markdown content before XML wrapping.

| Field | Type | Required | Description | Methodology Reference |
|-------|------|----------|-------------|-----------------------|
| `strip_html_comments` | Boolean | Yes | Remove `<!-- ... -->` HTML comments from Markdown source. Matches reference implementation behavior. | §2.3 |
| `strip_base64_images` | Boolean | Yes | Remove inline base64-encoded images (`data:image/...` URIs). These are large, non-textual, and not useful for the model. | §2.3 |
| `max_consecutive_blank_lines` | Integer | Yes | Collapse runs of blank lines exceeding this count down to this count. Prevents whitespace bloat in poorly formatted Markdown. Value: `2`. | §2.3 |
| `normalize_line_endings` | String | Yes | Target line ending format. Value: `"LF"` (Unix-style `\n`). Ensures consistent tokenization regardless of source file line endings. | §2.3 |

---

## `paths`

Filesystem paths to input and output files. All paths are **relative to the config file's directory** (`benchmark/scripts/`). The runner resolves them at startup using the config file's location as the base.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `questions` | String | Yes | Path to the question corpus JSON file. |
| `gold_answers` | String | Yes | Path to the gold-standard answers JSON file. |
| `site_list` | String | Yes | Path to the site corpus CSV file. |
| `scoring_rubric` | String | Yes | Path to the scoring rubric Markdown file. Informational — the runner does not parse it, but it is included for completeness. |
| `archive_dir` | String | Yes | Path to the root of the content archive directory (§2.1). Contains `html/` and `markdown/` subdirectories. |
| `archive_manifest` | String | Yes | Path to the archive manifest JSON file within the archive directory. |
| `results_dir` | String | Yes | Path to the results output directory. Created by the runner if it does not exist. |
| `raw_data_csv` | String | Yes | Path to the output CSV file where all experimental results are written. |
| `checkpoint_file` | String | Yes | Path to the checkpoint JSON file. Written by the runner after each completed (model, question) pair. Read on startup to enable resume (Decision 3A). |

---

## `run_protocol`

Settings that control how the runner iterates through the experimental matrix.

| Field | Type | Required | Description | Methodology Reference |
|-------|------|----------|-------------|-----------------------|
| `model_order` | String | Yes | How models are processed. Value: `"sequential"` (one model loaded at a time, all questions run before loading the next). | §4.7 |
| `condition_order_per_question` | Array[String] | Yes | The order in which conditions are run for each question within a model's run. Value: `["A", "B"]`. Both conditions are run back-to-back for the same question before moving to the next question. | §4.7 |
| `checkpoint_granularity` | String | Yes | What constitutes a checkpointable unit. Value: `"per_question"` — the checkpoint is updated after both conditions for a question are complete. This is the finest useful granularity since a question's paired comparison requires both conditions. | §4.7 |
| `resume_from_checkpoint` | Boolean | Yes | Whether the runner should check for an existing checkpoint file on startup and skip already-completed work. Value: `true`. | §4.7 (Decision 3A) |

### `run_protocol.conditions`

Descriptive metadata for each experimental condition. Not used by the runner for logic — the runner identifies conditions by their `"A"`/`"B"` keys — but included for documentation completeness.

| Field | Type | Description |
|-------|------|-------------|
| `label` | String | Short human-readable label for the condition. |
| `description` | String | Longer description with methodology section reference. |

---

## `archive_protocol`

Settings for the content archival phase (§2.1), which runs as a separate step before inference begins.

| Field | Type | Required | Description | Methodology Reference |
|-------|------|----------|-------------|-----------------------|
| `fetch_timeout_seconds` | Integer | Yes | Maximum wait time for a single HTTP fetch during archiving. Value: `30`. Shorter than inference timeout because page fetches should be fast. | §2.1 |
| `user_agent` | String | Yes | The `User-Agent` header sent with all HTTP requests during archiving. Identifies the benchmark as academic research. Should be updated with the actual repository URL before running. | §2.1 |
| `respect_robots_txt` | Boolean | Yes | Whether the archiver checks `robots.txt` before fetching. Value: `true`. Sites that disallow crawling will be logged as fetch failures. | §2.1 |
| `rate_limit_ms` | Integer | Yes | Minimum milliseconds between consecutive HTTP requests to the same domain. Value: `1000` (1 second). Prevents overwhelming documentation servers. | §2.1 |

---

## Checkpoint File Format (Referenced by `paths.checkpoint_file`)

The checkpoint file is not part of the config — it is written by the runner at runtime. Its schema is documented here for completeness since the config references it.

```json
{
  "config_version": "1.0.0",
  "started_at": "2026-03-15T10:30:00Z",
  "last_updated_at": "2026-03-15T14:22:33Z",
  "current_model_index": 2,
  "completed_tuples": [
    {
      "model_id": "llama-3.3-8b-q8_0",
      "question_id": "S001-Q01",
      "conditions_completed": ["A", "B"]
    }
  ]
}
```

The runner reads this file on startup (if `resume_from_checkpoint` is `true`), identifies which tuples are already recorded in `raw-data.csv`, and skips them. The checkpoint file is advisory — the runner also validates against `raw-data.csv` directly to handle cases where the checkpoint is stale or corrupted.

---

## raw-data.csv Column Reference (Output File)

For completeness, these are the columns the runner writes to `raw-data.csv`. The column names are defined in the scoring rubric (§11) and methodology (§2.6, §4.5, §4.7). The config does not define these columns — the runner does — but they are documented here because understanding the output helps understand what the config controls.

| Column | Type | Source | Description |
|--------|------|--------|-------------|
| `site_id` | String | `questions.json` | Site identifier (e.g., `S001`) |
| `question_id` | String | `questions.json` | Question identifier (e.g., `S001-Q01`) |
| `model_id` | String | Config `models[].model_id` | Model identifier including quantization (e.g., `llama-3.3-8b-q8_0`) |
| `condition` | Enum | Runner | `A` or `B` |
| `input_token_count` | Integer | Runner (tokenizer) | Input tokens using the model family's tokenizer |
| `ref_token_count` | Integer | Runner (tokenizer) | Input tokens using the Llama 3 reference tokenizer |
| `output_token_count` | Integer | Runner (API response) | Output tokens of the model's response |
| `content_chars` | Integer | Runner | Character count of assembled content |
| `response_text` | String | Runner (API response) | The model's full response text |
| `inference_engine` | String | Config `inference_endpoint.engine` | Which engine served this run |
| `elapsed_seconds` | Float | Runner | Wall-clock time for the inference request |
| `exclusion_reason` | String | Runner | If excluded, the reason code (e.g., `HTTP_404`, `JS_ONLY`). Empty if not excluded. |
| `scoring_notes` | String | Scorer | Free-text notes added during scoring. Empty until scoring phase. |
| `factual_accuracy` | Integer | Scorer | 0–3 ordinal score. Null until scoring phase. |
| `hallucination_count` | Integer | Scorer | Count of hallucinated claims. Null until scoring phase. |
| `completeness` | Integer | Scorer | 0 or 1 binary. Null until scoring phase. |
| `citation_fidelity` | Integer | Scorer | 0–2 ordinal or null if N/A. Null until scoring phase. |
