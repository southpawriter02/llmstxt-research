# Data Collection Runner — Design Specification

**Status:** 🔶 Draft
**Created:** 2026-02-26
**Last Updated:** 2026-02-26
**Traces To:** Story 4.3 (Data Collection Infrastructure), Tasks 4.3.1–4.3.5
**Depends On:** `methodology.md` (§2, §4), `scripts/benchmark-config.json`, `scripts/benchmark-config-schema.md`
**Implements:** Phase 1 of the two-phase experimental architecture (see `PROPOSAL.md`)

---

> This document specifies the architecture-level design for `run-benchmark`, the C# console application that orchestrates the benchmark's data collection phase. It defines what the runner does, how its components interact, and how it handles the operational realities of a 21–53 hour experimental run across 10 models and 5,720 inference tuples.
>
> This spec describes *components and responsibilities* — not class hierarchies or method signatures. Implementation details are deferred to coding time, where IDE tooling and compiler feedback guide the specifics. The spec's job is to ensure the implementer understands what to build and why, without prescribing how every line of code should look.
>
> For the *what* and *why* of each parameter, see `methodology.md`. For the machine-readable parameter values, see `benchmark-config.json`. This document covers the *how*.

---

## 1. Overview and Scope

The data collection runner is a C# console application that executes Phase 1 of the benchmark study. It takes the frozen corpus (sites, questions, gold-standard answers), the pre-built content archive, and the benchmark configuration as inputs, then produces `raw-data.csv` — the complete experimental dataset — as output.

### 1.1 What the Runner Does

The runner orchestrates five operations in sequence:

1. **Pre-flight validation** — Verifies that all inputs exist, the configuration is valid, the inference endpoint is reachable, and the archive is complete.
2. **Content assembly** — For each (site, question) pair, assembles the content input for both Condition A (HTML readability extraction) and Condition B (llms.txt Markdown with XML wrapping) from the pre-built archive.
3. **Inference submission** — Sends each assembled prompt to the local inference endpoint (Ollama or LM Studio) and captures the response.
4. **Result recording** — Writes each (site, question, model, condition) tuple's results to `raw-data.csv` incrementally.
5. **Checkpoint management** — Maintains a checkpoint file that tracks progress and enables resume after interruption.

### 1.2 What the Runner Does Not Do

The runner is deliberately scoped to data collection only. It does **not**:

- **Score responses.** Scoring is a human activity performed after data collection, under the blinding protocol defined in `scoring-rubric.md` §7. The runner writes empty scoring columns (`factual_accuracy`, `hallucination_count`, `completeness`, `citation_fidelity`) that the scorer fills in later.
- **Perform statistical analysis.** Analysis is Phase 2, implemented in `results/analysis.ipynb` (Python/Jupyter). The runner's output is the notebook's input.
- **Fetch content from live sites.** All content comes from the pre-built archive (`benchmark/archive/`). The archival phase is a separate operation (see §4.1) that runs before any inference begins.
- **Manage model downloads.** The runner assumes models are already pulled into Ollama or loaded in LM Studio. It does not invoke `ollama pull` or manage GGUF files.
- **Tokenize content.** Tokenization is a pre-computation step that runs during content assembly (see §6.4), not during inference. The runner computes token counts using the appropriate tokenizer for each model family and records them alongside the assembled content.

### 1.3 Two-Phase Architecture Context

The runner exists within a deliberate architectural split (documented in `PROPOSAL.md`):

- **Phase 1 (this runner):** C#/.NET, requires Mac Studio hardware, depends on LlmsTxtKit and local inference engines. Produces `raw-data.csv`. Documented for reproducibility but not trivially replicable on arbitrary hardware.
- **Phase 2 (analysis notebook):** Python/Jupyter, zero .NET dependencies, runs on Colab or any Python environment. Reads `raw-data.csv` and produces all figures, tables, and statistical tests.

The runner is the instrument; the notebook is the analysis. They share a single contract: the `raw-data.csv` column schema defined in `benchmark-config-schema.md` §raw-data.csv and `scoring-rubric.md` §11.

---

## 2. Dependencies and Prerequisites

### 2.1 Build-Time Dependencies

These are required to compile the runner. All are available as NuGet packages.

| Package | Purpose | Methodology Reference |
|---------|---------|----------------------|
| **SmartReader** | HTML readability extraction for Condition A content | §2.2 |
| **System.Text.Json** | JSON parsing for config, questions, gold-answers, manifest, checkpoint | — |
| **CsvHelper** (or equivalent) | CSV writing for `raw-data.csv` with proper quoting and encoding | — |
| **LlmsTxtKit** | llms.txt parsing, section identification, and XML context assembly for Condition B | §2.3 |
| **Microsoft.Extensions.Logging** | Structured logging for long-running operations | §10 |
| **Microsoft.Extensions.Http** | `HttpClient` factory for inference API calls | §4.1 |

**Target framework:** .NET 8.0 or later (LTS). The runner is a console application (`<OutputType>Exe</OutputType>`), not a library.

### 2.2 Runtime Dependencies

These must be available on the host machine when the runner executes.

| Dependency | Purpose | Verification |
|------------|---------|-------------|
| **Ollama** (or LM Studio) | Local inference engine serving the models | Runner checks endpoint health at startup (§4.2) |
| **Pre-pulled models** | All 10 models from the config's `models[]` array, already downloaded | Runner verifies model availability via Ollama API at startup |
| **Pre-built archive** | `benchmark/archive/` populated by the archival phase | Runner validates manifest completeness at startup (§4.2) |
| **Corpus files** | `questions.json`, `gold-answers.json`, `site-list.csv` in their expected locations | Runner validates file existence and schema at startup |

### 2.3 LlmsTxtKit Dependency — Current State

The runner depends on LlmsTxtKit for two capabilities:

1. **llms.txt parsing** — Reading a site's llms.txt file, identifying sections and linked pages, and mapping Markdown URLs to their parent sections. This is needed to assemble the XML context structure for Condition B (§2.3).
2. **XML context assembly** — Wrapping Markdown content in the `<project>/<section>/<doc>` structure that replicates the reference implementation's `create_ctx()` output format.

**Important:** LlmsTxtKit's `llmstxt_compare` tool is listed as a dependency in the project blueprint (Story 4.3) and `PROPOSAL.md`, but the runner's actual needs are more specific. It needs the *parsing* and *context assembly* capabilities, not necessarily the full `llmstxt_compare` comparison workflow. If `llmstxt_compare` is not yet available when implementation begins, the runner can be built against LlmsTxtKit's lower-level parsing APIs (the `LlmsTxtDocument` model and context generator) and integrated with `llmstxt_compare` later.

**Fallback option:** If LlmsTxtKit is not available at all, the runner can implement a minimal llms.txt parser inline (the reference implementation's parser is ~20 lines of Python; a C# equivalent is feasible). This is not the preferred approach — it duplicates logic that belongs in LlmsTxtKit — but it removes the hard dependency if scheduling requires it.

A fallback implementation must support:
- Parsing an llms.txt file into sections (H2-only splitting per methodology §2.3).
- Identifying linked pages within each section (dash-prefixed entries).
- Extracting the site title (H1) and summary (blockquote) from the header.
- Filtering Optional sections (exclude by default unless explicitly required).
- Generating the `<project>/<section>/<doc>` XML context structure.

The runner should code against an **interface** (e.g., `ILlmsTxtParser`) that both LlmsTxtKit and any fallback implementation satisfy. This allows swapping implementations without changing the Content Assembler. The fallback, if built, must be tested against the reference implementation's output for at least 5 corpus sites to verify behavioral equivalence. Any inline implementation must be documented as technical debt and replaced when LlmsTxtKit is ready.

---

## 3. Component Architecture

The runner is organized into six components, each with a single responsibility. Components communicate through well-defined data structures — they do not share mutable state or call each other's internals.

### 3.1 Component Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                          CLI Entry Point                            │
│  Parses arguments, selects execution phase, wires components        │
└────────────┬───────────────────────────────────────┬────────────────┘
             │                                       │
             ▼                                       ▼
┌────────────────────────┐              ┌────────────────────────────┐
│   Config Loader        │              │   Pre-flight Validator     │
│                        │              │                            │
│ • Reads & validates    │──────────▶   │ • Checks files exist       │
│   benchmark-config.json│  config      │ • Validates archive        │
│ • Resolves relative    │  object      │ • Pings inference endpoint │
│   paths                │              │ • Verifies models available│
│ • Produces typed       │              │ • Reports go/no-go         │
│   config object        │              └────────────────────────────┘
└────────────┬───────────┘
             │ config
             ▼
┌────────────────────────────────────────────────────────────────────┐
│                        Orchestrator                                 │
│                                                                     │
│  The main loop. Iterates models → questions → conditions.           │
│  Delegates to Content Assembler and Inference Client.               │
│  Writes results via Result Writer. Updates Checkpoint Manager.      │
│                                                                     │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │ Content Assembler │  │ Inference Client  │  │ Result Writer    │  │
│  │                   │  │                   │  │                  │  │
│  │ • Reads archive   │  │ • Sends prompts   │  │ • Appends to     │  │
│  │ • Assembles A & B │  │   to Ollama/LMS   │  │   raw-data.csv   │  │
│  │ • Applies prompt  │  │ • Captures response│  │ • Writes header  │  │
│  │   template        │  │ • Measures timing  │  │   on first run   │  │
│  │ • Computes tokens │  │ • Handles timeouts │  │ • Flush per row  │  │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  │
│                                                                     │
│  ┌──────────────────┐                                               │
│  │Checkpoint Manager │                                              │
│  │                   │                                              │
│  │ • Reads checkpoint│                                              │
│  │   on startup      │                                              │
│  │ • Writes after    │                                              │
│  │   each question   │                                              │
│  │ • Determines skip │                                              │
│  │   set for resume  │                                              │
│  └──────────────────┘                                               │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Component Responsibilities

**CLI Entry Point** — Parses command-line arguments, determines which execution phase to run (archive, validate, run, or all), instantiates components, and hands off to the Orchestrator. This is the only component that knows about the console — all other components are testable without I/O.

**Config Loader** — Reads `benchmark-config.json`, deserializes it into a strongly-typed configuration object, resolves all relative paths against the config file's directory, and validates that required fields are present and well-formed. Returns a frozen (immutable) configuration object that other components receive as a constructor dependency.

**Pre-flight Validator** — Runs a comprehensive set of checks before any inference begins. Returns a pass/fail result with a list of issues. If any check fails, the runner exits with a non-zero exit code and a human-readable error report. This component exists to catch problems early — before 3 hours of small-model inference discovers that the archive is missing pages for Site S015.

**Orchestrator** — The main execution loop. Iterates through models (outer loop), questions (middle loop), and conditions (inner loop) per the run protocol in `benchmark-config.json`. For each tuple, it calls the Content Assembler to build the prompt, the Inference Client to get a response, and the Result Writer to record the outcome. It consults the Checkpoint Manager to skip already-completed tuples on resume.

**Content Assembler** — Given a (site, question, condition) triple and the config, produces an assembled prompt string ready for the inference API. For Condition A, it reads the archived HTML, runs SmartReader extraction, and inserts the result into the prompt template. For Condition B, it reads the archived Markdown, applies preprocessing (strip HTML comments, strip base64, normalize whitespace), wraps it in the XML context structure, and inserts the result into the prompt template. Also computes and returns token counts (per-model-family and reference) for the assembled content.

**Inference Client** — A thin HTTP client wrapper that sends a chat completion request to the configured inference endpoint and returns a structured response object (response text, output token count, elapsed time, and any error). Handles timeouts, connection failures, and HTTP error codes. Does not retry — a failed inference is logged and the tuple is recorded with an exclusion reason.

**Result Writer** — Manages the `raw-data.csv` output file. Writes the CSV header on first run (when the file doesn't exist or is empty), and appends one row per completed tuple. Flushes after every write to ensure data is persisted even if the process crashes. Uses proper CSV encoding (UTF-8 BOM, double-quoted string fields, LF line endings).

**Checkpoint Manager** — Reads `checkpoint.json` on startup to determine which tuples are already complete, and writes an updated checkpoint after each question (both conditions for that question) is finished. The checkpoint is the runner's insurance policy against interruption — a 53-hour run that crashes at hour 40 should resume from hour 40, not from scratch.

### 3.3 Data Flow

The components interact through a linear data pipeline with no circular dependencies:

```
benchmark-config.json ──▶ Config Loader ──▶ Config Object
                                               │
corpus files ──────────────────────────────────▶│
archive files ─────────────────────────────────▶│
                                               │
                                               ▼
                                          Orchestrator
                                               │
                          ┌────────────────────┼────────────────────┐
                          ▼                    ▼                    ▼
                   Content Assembler    Inference Client     Result Writer
                          │                    │                    │
                          │                    │                    ▼
                          │                    │              raw-data.csv
                          │                    │
                          ▼                    ▼
                   Assembled Prompt ──▶  API Request ──▶ Response
```

**Key invariant:** The Orchestrator is the only component that coordinates the others. The Content Assembler never talks to the Inference Client directly. The Result Writer never reads the checkpoint. This keeps each component independently testable.

---

## 4. Execution Phases

The runner supports three execution phases that can be invoked independently or in sequence. Each phase has explicit entry conditions and produces specific outputs.

### 4.1 Archive Phase

**Purpose:** Fetch all required content from live sites and store it in the immutable archive.

**Entry conditions:**
- `benchmark-config.json` loaded and validated.
- `questions.json` loaded (needed to determine which URLs to fetch per site).
- `site-list.csv` loaded (needed for llms.txt URLs and HTML-to-Markdown URL mappings).
- Network access available.

**Behavior:**
1. For each site in `site-list.csv`, identify all unique URLs from `questions.json` `source_urls` arrays.
2. For each URL, fetch both the HTML page (for Condition A) and the corresponding llms.txt-linked Markdown page (for Condition B).
3. Save raw fetched content to `archive/html/{site_id}/{url_hash}.html` and `archive/markdown/{site_id}/{url_hash}.md`.
4. Record each fetch result in `archive/manifest.json` per the schema in methodology §2.1.
5. Respect `archive_protocol` settings: timeout, user-agent, robots.txt, rate limiting.

**Output:** A populated `benchmark/archive/` directory with `manifest.json` and all fetched content files.

**Immutability:** Once the archive phase completes, the archive directory is treated as read-only by all subsequent phases. No subsequent operation modifies archived content.

**Note on LlmsTxtKit integration:** The archive phase needs LlmsTxtKit (or a fallback parser) to determine the HTML-to-Markdown URL mapping for each site. This mapping answers the question: "For this HTML documentation URL, which llms.txt-linked Markdown page covers the same content?" The mapping comes from parsing the site's llms.txt file and matching linked page URLs to the `source_urls` in `questions.json`.

### 4.2 Validate Phase (Pre-flight)

**Purpose:** Confirm that everything needed for the inference run exists and is valid before committing to a multi-day execution.

**Entry conditions:**
- `benchmark-config.json` loaded.

**Checks performed:**

| # | Check | Failure Severity | Rationale |
|---|-------|-----------------|-----------|
| V-1 | Config file parses without error | Fatal | Cannot proceed without valid configuration |
| V-2 | All paths in `config.paths` resolve to existing files/directories | Fatal | Missing inputs mean incomplete results |
| V-3 | `questions.json` schema valid (all required fields present, question IDs unique) | Fatal | Malformed questions break the entire pipeline |
| V-4 | `archive/manifest.json` exists and every `source_url` in `questions.json` has a corresponding archive entry | Fatal | Missing archive entries mean missing content pairs |
| V-5 | Archive entries with `fetch_status: SUCCESS` have non-empty content files at the expected paths | Fatal | Manifest says success but file is missing = data corruption |
| V-6 | Inference endpoint responds to a health check (e.g., `GET /v1/models` or Ollama's `GET /api/tags`) | Fatal | Endpoint unreachable means zero inference can happen |
| V-7 | All models in `config.models[]` are available at the endpoint (listed in Ollama's tag list or LM Studio's model directory) | Warning | A missing model can be pulled later; warn but don't block |
| V-8 | If resuming: `checkpoint.json` exists and its `config_version` matches the current config version | Warning | Stale checkpoint may skip wrong tuples; warn and offer to start fresh |
| V-9 | If resuming: every tuple listed in `checkpoint.json` has a corresponding row in `raw-data.csv` | Warning | Checkpoint/CSV mismatch suggests data corruption; warn |
| V-10 | Disk space estimate: `results/` directory has sufficient space for the expected CSV size (~50-100 MB) | Warning | Informational; prevents mid-run disk full errors |

**Output:** A validation report printed to the console. If any Fatal check fails, the runner exits with a non-zero code. Warnings are logged but do not prevent execution.

### 4.3 Run Phase (Inference Loop)

**Purpose:** Execute all inference tuples and record results.

**Entry conditions:**
- All Validate phase checks pass (or are explicitly overridden via CLI flag).
- The archive exists and is complete.
- The inference endpoint is running with at least the first model in the array available.

**Behavior:** See §7 (Inference Loop) for the detailed execution flow.

**Output:** `raw-data.csv` populated with one row per completed (site, question, model, condition) tuple. `checkpoint.json` updated after each question.

---

## 5. Configuration Loading

### 5.1 Loading and Deserialization

The Config Loader reads `benchmark-config.json` from a path specified via CLI argument (or a default relative to the executable). It deserializes the JSON into a strongly-typed C# object graph using `System.Text.Json`. The deserialized object is then frozen — all properties are read-only after construction.

**Path resolution:** All paths in the `config.paths` section are relative to the config file's parent directory. The Config Loader resolves them to absolute paths at load time by combining `Path.GetDirectoryName(configFilePath)` with each relative path. The resolved absolute paths are stored in the config object, so no other component needs to know the resolution strategy.

### 5.2 Validation Rules

After deserialization, the Config Loader applies the following validation rules before returning the config object. If any rule fails, the loader throws with a descriptive error message.

| Rule | Check |
|------|-------|
| Version present | `config.version` is not null or empty |
| Models non-empty | `config.models` array has ≥1 entry |
| Model IDs unique | No duplicate `model_id` values in the array |
| Inference parameters in range | `temperature` ∈ [0.0, 2.0], `seed` > 0, `num_predict` > 0, `num_ctx_overhead` > 0 |
| Paths non-empty | Every field in `config.paths` is a non-empty string |
| Prompt template has placeholders | `user_prompt` contains both `{assembled_content}` and `{question_text}` |
| Conditions valid | `condition_order_per_question` contains exactly `["A", "B"]` |

### 5.3 Config Object Immutability

The config object is constructed once and never modified. All properties use `{ get; init; }` accessors (C# 9+ init-only setters). Collections are exposed as `IReadOnlyList<T>`. This prevents accidental mutation during the run and makes the config safe to pass to any component without defensive copying.

---

## 6. Content Assembly Pipeline

The Content Assembler is the most complex component because it implements two distinct extraction pipelines (one per condition) and handles the per-question scoping logic that determines which archived pages are included in each prompt.

### 6.1 Assembly Flow

For a given (site, question, model) triple, the Content Assembler produces two assembled prompts — one for Condition A and one for Condition B. The flow is:

```
Input: (site_id, question, model_config)
  │
  ├──▶ Look up question.source_urls
  │
  ├──▶ For each source_url:
  │     ├──▶ Look up archive manifest entry
  │     ├──▶ If entry.fetch_status != SUCCESS → skip this URL, note exclusion
  │     └──▶ Read archived content file
  │
  ├──▶ Condition A path:
  │     ├──▶ For each HTML file: run SmartReader extraction
  │     ├──▶ If extracted text < 50 chars → skip, note exclusion (JS_ONLY)
  │     ├──▶ Concatenate extracted texts with "---" separator
  │     └──▶ Insert into prompt template as {assembled_content}
  │
  ├──▶ Condition B path:
  │     ├──▶ For each Markdown file: apply preprocessing
  │     │     ├──▶ Strip HTML comments
  │     │     ├──▶ Strip base64 images
  │     │     ├──▶ Normalize whitespace (max 2 blank lines, LF endings)
  │     │     └──▶ Done
  │     ├──▶ Wrap in XML context structure:
  │     │     <project title="..." summary="...">
  │     │       <section_name>
  │     │         <doc title="..." url="...">
  │     │           {preprocessed_markdown}
  │     │         </doc>
  │     │       </section_name>
  │     │     </project>
  │     └──▶ Insert into prompt template as {assembled_content}
  │
  └──▶ Return: (prompt_A, prompt_B, token_counts, exclusion_info)
```

### 6.2 Condition A: SmartReader Extraction

SmartReader takes raw HTML and returns extracted text. The Content Assembler:

1. Loads the raw HTML from `archive/html/{site_id}/{url_hash}.html`.
2. Passes it to SmartReader's `Reader` class.
3. Checks that the extracted text content meets the minimum length threshold (50 characters per `config.extraction.min_content_length_chars`).
4. If the extraction fails or is below threshold, records the URL as excluded with reason `JS_ONLY` and skips it.
5. For multi-URL questions, concatenates successful extractions in `source_urls` order, separated by `\n\n---\n\n`.

**SmartReader configuration:** Use default SmartReader settings. Do not disable any heuristics or override the content detection algorithm. The goal is a representative readability extraction, not an optimized one.

### 6.3 Condition B: Markdown Preprocessing and XML Wrapping

The Markdown path has two stages: preprocessing (cleaning) and wrapping (structure).

**Preprocessing** applies the four transformations defined in `config.extraction.markdown_preprocessing`:

1. **Strip HTML comments:** Remove all `<!-- ... -->` blocks (regex: `<!--[\s\S]*?-->`).
2. **Strip base64 images:** Remove all `data:image/...` URI occurrences, including any surrounding Markdown image syntax (`![...](data:image/...)`).
3. **Normalize blank lines:** Collapse runs of >2 consecutive blank lines down to 2.
4. **Normalize line endings:** Replace `\r\n` and `\r` with `\n`.

**XML wrapping** produces the `<project>/<section>/<doc>` structure per methodology §2.3. This requires knowing which llms.txt section each source URL belongs to — information obtained by parsing the site's llms.txt file (via LlmsTxtKit or the fallback parser). The site's title and summary come from the llms.txt file's H1 heading and blockquote, respectively.

**Optional section handling:** Per methodology §2.3, Optional sections are excluded by default unless a question's `source_urls` explicitly reference content from an Optional section. The Content Assembler checks each source URL against the llms.txt section map and includes Optional sections only when required by the question.

### 6.4 Tokenization

After assembling the content for each condition (but before inserting into the prompt template), the Content Assembler computes token counts:

| Count | Method | Stored As |
|-------|--------|-----------|
| `input_token_count` | Tokenize the full assembled prompt (system + user message) using the model family's tokenizer | `raw-data.csv` column |
| `ref_token_count` | Tokenize the full assembled prompt using the Llama 3 reference tokenizer | `raw-data.csv` column |
| `content_chars` | `assembled_content.Length` (character count of the content block only, before prompt template insertion) | `raw-data.csv` column |

**Tokenizer integration:** The tokenizer question is an open implementation detail (see §12). Options include: calling Python tokenizers via subprocess, using a .NET port of a BPE tokenizer, or using Ollama's `/api/tokenize` endpoint (if available). The design spec does not prescribe the implementation — only that per-model-family and reference token counts must be computed and recorded.

**`num_ctx` calculation:** The Content Assembler also computes the dynamic `num_ctx` value for each run:

```
num_ctx = min(model.max_context_length, input_token_count + config.num_predict + config.num_ctx_overhead)
```

This value is passed to the Inference Client for inclusion in the API request.

### 6.5 Exclusion Handling

When content assembly fails for one or both conditions, the Content Assembler returns exclusion information rather than throwing an exception. The Orchestrator uses this information to decide whether to proceed:

| Scenario | Handling |
|----------|----------|
| All source URLs failed for Condition A | Record tuple with `exclusion_reason`, skip inference for Condition A |
| All source URLs failed for Condition B | Record tuple with `exclusion_reason`, skip inference for Condition B |
| All source URLs failed for both conditions | Record both tuples with exclusion reasons, skip inference entirely |
| Some source URLs failed, others succeeded | Proceed with available content; note partial assembly in `scoring_notes` |

Exclusions are never silent. Every excluded tuple appears in `raw-data.csv` with an empty `response_text` and a populated `exclusion_reason`.

---

## 7. Inference Loop

The Orchestrator's inference loop is the core execution path. It implements the run protocol defined in `benchmark-config.json` and methodology §4.7.

### 7.1 Loop Structure

```
FOR each model in config.models (sequential):
  │
  ├──▶ Load model into inference engine
  │     (Ollama: POST /api/pull or verify already loaded)
  │     (Wait for model to be ready)
  │
  ├──▶ Run warm-up prompts (config.warmup_prompt_count)
  │     (Discard responses, log timing for diagnostics)
  │
  ├──▶ FOR each question in questions.json (in file order):
  │     │
  │     ├──▶ Check checkpoint: if (model, question) already complete → skip
  │     │
  │     ├──▶ Assemble content for both conditions
  │     │     (Content Assembler returns prompt_A, prompt_B, tokens, exclusions)
  │     │
  │     ├──▶ FOR each condition in ["A", "B"]:
  │     │     │
  │     │     ├──▶ If excluded → write exclusion row to CSV, continue
  │     │     │
  │     │     ├──▶ Send prompt to Inference Client
  │     │     │     (Include: model tag, system prompt, user message,
  │     │     │      inference parameters, computed num_ctx)
  │     │     │
  │     │     ├──▶ Receive response (or error/timeout)
  │     │     │
  │     │     └──▶ Write result row to CSV via Result Writer
  │     │
  │     └──▶ Update checkpoint: mark (model, question) as complete
  │
  └──▶ Log model completion summary (total time, success/fail counts)
```

### 7.2 Model Loading

Before processing any questions for a model, the Orchestrator ensures the model is loaded and ready to serve inference requests. The approach depends on the inference engine:

**Ollama:** Send a lightweight request (e.g., a single-token prompt) to verify the model is loaded. If the model is not loaded, Ollama automatically loads it on first request — but the first request will be slow (model loading time). The warm-up prompts (§7.3) serve as the loading trigger.

**LM Studio:** LM Studio requires explicit model loading through its UI or API. The runner cannot programmatically load models in LM Studio. If using LM Studio, the operator must manually load each model before its turn. When the runner detects a "model not found" error from LM Studio, it logs a warning with the expected model tag, pauses execution, and prompts the operator: `"Model {ollama_tag} not loaded in LM Studio. Load it now and press Enter to continue, or type 'skip' to skip this model."` This interactive pause avoids aborting the entire run for an operator-resolvable issue. Alternatively, the operator can pre-load all 10 models before starting the run.

### 7.3 Warm-Up Protocol

After model loading, the runner sends `config.inference_endpoint.warmup_prompt_count` (default: 3) throwaway prompts. These prompts are short, generic, and not recorded in `raw-data.csv`. Their purpose is to:

1. Trigger model loading if not already loaded (Ollama lazy-loads on first request).
2. Warm the KV cache and memory subsystem.
3. Stabilize inference timing (the first few inferences after loading are typically slower).

The warm-up prompt can be as simple as `"Respond with OK."` — it does not need to resemble the benchmark's actual prompts.

### 7.4 Qwen 3 Thinking Mode Suppression

Per methodology §4.6, Qwen 3 models must have thinking mode disabled. The Orchestrator handles this by injecting `/no_think` into the user message for any model where `config.models[].family == "qwen3"`. This is a runner-level behavior, not a config-level one — the config defines global parameters only, and model-specific behaviors like thinking mode suppression are handled in runner code.

**Recommended implementation:** Append `/no_think` to the end of the user message content (after the question text). This approach is documented in Qwen 3's official usage guide, works across both Ollama and LM Studio, and does not require engine-specific API parameters. The modified user message for Qwen 3 models becomes:

```
Content:
{assembled_content}

Question: {question_text}

/no_think
```

The runner logs `"Qwen 3 thinking mode suppressed via /no_think for model {model_id}"` at `Information` level when processing the first question for any Qwen 3 model. The `/no_think` suffix is **not** included in the `content_chars` or token count calculations — it is appended by the Orchestrator after the Content Assembler returns, and the token overhead is negligible (2-3 tokens).

### 7.5 Inference Request

Each inference call is a single HTTP POST to the configured endpoint (`config.inference_endpoint.base_url + config.inference_endpoint.api_path`) with the following request body (OpenAI-compatible format):

```json
{
  "model": "{ollama_tag}",
  "messages": [
    { "role": "system", "content": "{system_prompt}" },
    { "role": "user", "content": "{assembled_user_prompt}" }
  ],
  "temperature": 0.0,
  "seed": 42,
  "top_p": 1.0,
  "top_k": 0,
  "repeat_penalty": 1.0,
  "max_tokens": 512,
  "options": {
    "num_ctx": "{computed_num_ctx}"
  }
}
```

**Response parsing:** The runner extracts:
- `response_text` from `choices[0].message.content`.
- `output_token_count` from `usage.completion_tokens` (or by counting tokens in the response if the API doesn't report usage).
- `elapsed_seconds` measured client-side from request send to response complete.

**Truncation detection:** If `output_token_count` equals `num_predict` (512), the response likely hit the generation ceiling. The runner writes `"TRUNCATED_AT_512"` to the `scoring_notes` column for that row, flagging it for the scorer's attention per methodology §4.6. This is the one case where the runner writes a non-empty `scoring_notes` value — the scorer appends to it during scoring rather than overwriting.

### 7.6 Timeout and Error Handling

The Inference Client applies `config.inference_endpoint.request_timeout_seconds` (default: 300s) as the HTTP request timeout. If the request times out or returns an error:

| Error Type | Detection | Handling |
|------------|-----------|----------|
| HTTP timeout | `HttpClient` timeout exception | Record tuple with `exclusion_reason: TIMEOUT`. Do not retry. Move to next condition/question. |
| HTTP 4xx/5xx | HTTP response status code | Record with `exclusion_reason: HTTP_{code}`. Do not retry. |
| Connection refused | Socket exception | Log error. If this is the first request for a model, it may indicate the model isn't loaded. Wait 30 seconds and retry once. If still failing, abort the current model and move to the next. |
| Malformed response | JSON parsing failure | Record with `exclusion_reason: MALFORMED_RESPONSE`. Log the raw response body for debugging. |
| Empty response | Response text is null or empty | Record with `exclusion_reason: EMPTY_RESPONSE`. |

**No automatic retry policy.** At temperature 0 with a fixed seed, retrying the same prompt produces the same result (or the same failure). The only exception is the connection-refused case, where a brief wait may resolve a transient loading issue.

---

## 8. Checkpoint and Resume

### 8.1 Checkpoint File Structure

The checkpoint file (`checkpoint.json`) records which (model, question) pairs have been fully completed — meaning both Condition A and Condition B have been processed (whether successfully or excluded) and written to `raw-data.csv`.

```json
{
  "config_version": "1.0.0",
  "started_at": "2026-03-15T10:30:00Z",
  "last_updated_at": "2026-03-15T14:22:33Z",
  "current_model_index": 2,
  "completed": {
    "llama-3.3-8b-q8_0": ["S001-Q01", "S001-Q02", "...all 286..."],
    "llama-3.3-70b-q8_0": ["S001-Q01", "S001-Q02", "...partial..."]
  }
}
```

**Granularity:** The checkpoint is updated after **each question** (both conditions complete), not after each individual condition. This ensures that paired comparisons are always complete — you never have a Condition A result without the corresponding Condition B.

### 8.2 Write Protocol

After the Orchestrator finishes both conditions for a (model, question) pair:

1. Add the question_id to the model's completed list in the in-memory checkpoint state.
2. Update `last_updated_at`.
3. Serialize the checkpoint to JSON.
4. Write to a temporary file (`checkpoint.json.tmp`).
5. Atomically rename `checkpoint.json.tmp` → `checkpoint.json`.

The atomic rename prevents a half-written checkpoint file if the process crashes during the write. On Windows, `File.Replace()` provides this; on macOS/Linux, `File.Move()` with overwrite is atomic on the same filesystem.

### 8.3 Resume Protocol

On startup, if `config.run_protocol.resume_from_checkpoint` is `true` and `checkpoint.json` exists:

1. Read and deserialize the checkpoint.
2. Verify `config_version` matches the current config. If not, warn and ask the operator whether to continue or start fresh.
3. Build a `HashSet<(string model_id, string question_id)>` of completed tuples.
4. **Cross-validate against `raw-data.csv`:** Scan the CSV and verify that every tuple listed in the checkpoint actually has corresponding rows. If the checkpoint claims completion but the CSV is missing rows, log a warning — the checkpoint is ahead of the data, which suggests a crash between CSV write and checkpoint update.
5. During the inference loop, skip any (model, question) pair found in the completed set.

### 8.4 Edge Cases

| Scenario | Handling |
|----------|----------|
| Checkpoint exists but `raw-data.csv` doesn't | Treat as corrupted. Log warning, start fresh (ignore checkpoint). |
| `raw-data.csv` has rows not in checkpoint | Normal — this means the process crashed after writing CSV rows but before updating the checkpoint. The CSV is the source of truth. Rebuild the checkpoint from the CSV. |
| Checkpoint lists a model not in the current config | Ignore those entries. The config may have changed (e.g., a model was removed). |
| Condition A written but Condition B not yet attempted (crash mid-question) | The checkpoint was not updated (it updates only after both conditions). On resume, the runner finds no checkpoint entry for this (model, question) pair. It re-runs both conditions. The duplicate Condition A row in `raw-data.csv` is detected during CSV cross-validation (two rows for the same tuple). The runner deletes the orphaned Condition A row before re-running. |
| Operator wants to re-run a completed model | Provide a CLI flag (`--force-rerun <model_id>`) that removes that model from the checkpoint's completed set before starting. |

---

## 9. Output Schema

### 9.1 raw-data.csv

The runner writes one row per (site, question, model, condition) tuple. The complete column schema is defined in `benchmark-config-schema.md` §raw-data.csv. The runner is responsible for the following columns:

Columns are written in the order shown below. This order is the canonical column order for `raw-data.csv` — the analysis notebook and scoring tools expect it.

| # | Column | Written By | When |
|---|--------|-----------|------|
| 1 | `site_id` | Runner | At write time, from `questions.json` |
| 2 | `question_id` | Runner | At write time, from `questions.json` |
| 3 | `model_id` | Runner | At write time, from `config.models[]` |
| 4 | `condition` | Runner | At write time (`A` or `B`) |
| 5 | `input_token_count` | Runner | Computed during content assembly |
| 6 | `ref_token_count` | Runner | Computed during content assembly |
| 7 | `output_token_count` | Runner | From inference API response |
| 8 | `content_chars` | Runner | Computed during content assembly |
| 9 | `response_text` | Runner | From inference API response (empty if excluded) |
| 10 | `inference_engine` | Runner | From `config.inference_endpoint.engine` |
| 11 | `elapsed_seconds` | Runner | Measured client-side |
| 12 | `exclusion_reason` | Runner | Empty string if not excluded; reason code if excluded |
| 13 | `scoring_notes` | Runner/Scorer | Runner writes truncation flags (§7.5); scorer appends during scoring phase |
| 14 | `factual_accuracy` | Scorer | Null until scoring phase |
| 15 | `hallucination_count` | Scorer | Null until scoring phase |
| 16 | `completeness` | Scorer | Null until scoring phase |
| 17 | `citation_fidelity` | Scorer | Null until scoring phase |

### 9.2 Write Behavior

- **Encoding:** UTF-8 with BOM. BOM ensures Excel and other tools detect the encoding correctly.
- **Line endings:** `\n` (LF). Consistent with the rest of the project.
- **Quoting:** All string fields are double-quoted. Fields containing quotes use doubled-quote escaping (`""` inside `""`).
- **Header:** Written once, when the file is created or is empty. On resume, the header is not re-written.
- **Append mode:** The file is opened in append mode for writes. Each row is flushed immediately after writing. This means that even if the process crashes, all previously written rows are intact.
- **No in-memory buffering of results.** Each row is written as soon as the inference completes. The runner does not accumulate results in memory and batch-write them.

### 9.3 Scoring Columns

The four scoring columns (`factual_accuracy`, `hallucination_count`, `completeness`, `citation_fidelity`) are written as null by the runner. They exist in the CSV from the start so that the scoring phase can populate them in-place (or via a separate scoring tool that reads and rewrites the CSV). The analysis notebook expects these columns to be populated before it runs.

**`scoring_notes` exception:** Unlike the four scoring columns, `scoring_notes` may be non-empty at write time. The runner writes `"TRUNCATED_AT_512"` if the response hit the `num_predict` ceiling (see §7.5), and notes partial content assembly if some source URLs failed (see §6.5). The scorer appends to this field rather than overwriting, preserving any runner-generated flags.

---

## 10. Error Handling and Logging

### 10.1 Error Philosophy

The runner is designed to **survive and continue** rather than fail-fast. A 40-hour run that aborts on one bad page wastes 40 hours. The runner logs the error, records an exclusion, and moves on. The only conditions that cause the runner to stop are:

- **Pre-flight validation failures** (Fatal checks in §4.2). These are caught before any inference begins.
- **Inference endpoint completely unreachable** (not just one failed request, but the endpoint is down). After 3 consecutive connection failures across different questions, the runner pauses and prompts the operator.
- **Disk full** — cannot write to `raw-data.csv`. The runner catches the IOException and exits cleanly with a clear error message.
- **Unrecoverable internal error** (null reference, out of memory, etc.). The runner logs the exception, writes the current checkpoint, and exits. The operator can resume after diagnosing the issue.

Everything else — HTTP errors, timeouts, malformed responses, extraction failures, missing archive entries — is logged and recorded as an exclusion.

### 10.2 Logging Strategy

The runner uses `Microsoft.Extensions.Logging` with structured logging. Log output goes to both the console (for operator monitoring) and a log file (`results/run-benchmark.log`).

**Log levels:**

| Level | Used For | Examples |
|-------|----------|---------|
| `Information` | Normal progress milestones | "Starting model llama-3.3-8b-q8_0 (1/10)", "Question S001-Q01 complete (A: 2.3s, B: 1.8s)" |
| `Warning` | Non-fatal issues that the operator should know about | "Archive entry missing for URL X, excluding tuple", "Checkpoint version mismatch" |
| `Error` | Failed operations that result in exclusions | "Inference timeout for S015-Q03 Condition A (300s)", "SmartReader returned empty text for URL X" |
| `Debug` | Verbose diagnostic information | Full request/response JSON, token counts, computed `num_ctx` values |

**Known exclusion pattern — S032 (UBC):** Site S032 (students.ubc.ca) renders content via JavaScript only. All Condition A extractions for this site will be excluded with reason `JS_ONLY`. This is expected and documented in methodology §2.5. Condition B may still succeed if the llms.txt-linked pages are static Markdown files. The operator should not interpret these exclusions as errors.

**Progress reporting:** The runner logs a progress summary every N questions (configurable, default every 10 questions) showing:
- Elapsed time since model start
- Questions completed / total
- Success / exclusion counts for current model
- Estimated time remaining for current model (based on average time per question)

### 10.3 Structured Error Context

Every logged error includes the tuple context: `site_id`, `question_id`, `model_id`, `condition`. This allows post-run analysis of error patterns (e.g., "all errors came from site S032" or "Mistral Large timed out on 12 questions").

---

## 11. CLI Interface

### 11.1 Command Structure

```
run-benchmark [phase] [options]

Phases:
  archive     Run the content archival phase only
  validate    Run pre-flight validation only
  run         Run the inference loop only (assumes archive exists)
  all         Run archive → validate → run in sequence (default)

Options:
  --config <path>         Path to benchmark-config.json (default: ./benchmark-config.json)
  --resume                Resume from checkpoint (default: true if checkpoint exists)
  --no-resume             Start fresh, ignoring any existing checkpoint
  --force-rerun <model>   Re-run a specific model even if checkpointed as complete
  --dry-run               Run validation and content assembly but skip actual inference calls
  --verbose               Enable Debug-level logging
  --log-file <path>       Override log file path (default: ../results/run-benchmark.log)
```

### 11.2 Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Phase completed successfully (all tuples processed, though some may be excluded) |
| 1 | Pre-flight validation failed (Fatal check) |
| 2 | Inference endpoint unreachable (after retries) |
| 3 | Unrecoverable internal error |
| 4 | Disk full or I/O error |
| 130 | Interrupted by operator (Ctrl+C). Checkpoint is written before exit. |

### 11.3 Ctrl+C Handling

The runner registers a `Console.CancelKeyPress` handler that:

1. Sets a cancellation flag (via `CancellationToken`).
2. Waits for the current in-flight inference request to complete (or timeout).
3. Writes the current checkpoint state.
4. Flushes and closes `raw-data.csv`.
5. Exits with code 130.

This ensures that a Ctrl+C produces a clean, resumable state rather than a corrupted checkpoint or half-written CSV row.

---

## 12. Open Questions and Future Considerations

These items are known unknowns that will be resolved during implementation. They are documented here so the implementer knows to make deliberate decisions rather than accidental ones.

### 12.1 Tokenizer Integration in .NET

The methodology requires per-model-family token counts (§2.6), which means running each model family's tokenizer on the assembled content. In Python, this is straightforward (`transformers.AutoTokenizer`). In C#/.NET, the options are:

| Option | Pros | Cons |
|--------|------|------|
| **Shell out to Python** (`python -c "from transformers import ..."`) | Uses the canonical tokenizers. Most accurate. | Requires Python + transformers installed. Adds ~1-2s per tokenization call. For 5,720 × 2 conditions × 2 tokenizers = ~22,880 calls, this adds ~6-12 hours. |
| **Use Ollama's `/api/tokenize` endpoint** (if available) | No Python dependency. Uses the same tokenizer the model actually uses. Fast (local HTTP call). | Endpoint may not exist in all Ollama versions. Requires the model to be loaded. May not support the reference tokenizer (Llama) while a different model is active. |
| **Pre-compute token counts** in a separate Python script | Decouple tokenization from the C# runner entirely. Run a Python script that reads the archive and questions, computes all token counts, and writes them to a lookup file. The runner reads the lookup. | Adds a pre-processing step. But tokenization only depends on the content (not the model's response), so it can be done before inference. |
| **Use a .NET BPE tokenizer library** (e.g., Microsoft.ML.Tokenizers) | Pure .NET, no external dependencies. | May not have exact parity with HuggingFace tokenizers. Need to verify that token counts match within acceptable tolerance. |

**Recommended direction:** Pre-compute token counts in a separate Python script (option 3). This keeps the C# runner free of Python dependencies, avoids the performance penalty of per-call shelling, and produces a deterministic lookup table that can be verified independently. The script (`scripts/precompute-token-counts.py`) would read the archive and questions, compute all token counts using the canonical HuggingFace tokenizers, and output a lookup file (`archive/token-counts.json`) keyed by `(site_id, question_id, condition, family)`. The runner reads this lookup during content assembly instead of tokenizing inline. The implementer may choose a different option if this approach proves impractical, but any alternative must produce token counts that match the HuggingFace tokenizers within ±1% tolerance.

### 12.2 LlmsTxtKit API Surface

The Content Assembler's Condition B pipeline depends on LlmsTxtKit for:
- Parsing an llms.txt file into a structured document model.
- Identifying which section a given URL belongs to.
- Retrieving the site title and summary from the llms.txt header.

The exact API surface of LlmsTxtKit is not yet finalized (the library is under active development). The Content Assembler should be designed against an **interface** (e.g., `ILlmsTxtParser`) that the LlmsTxtKit implementation satisfies, with a fallback inline implementation available if needed. This insulates the runner from LlmsTxtKit API changes.

### 12.3 Ollama Model Loading Automation

Ollama can load models on first request, but it can only keep one model in memory at a time (unless configured for multi-model serving). When the Orchestrator moves from model N to model N+1, the first inference request for model N+1 triggers an unload of model N and a load of model N+1. This takes 30-120 seconds for large models.

The runner should detect this loading phase (either by timing the warm-up prompts or by polling Ollama's status endpoint) and log it clearly, so the operator doesn't think the runner has hung.

### 12.4 Response Text Sanitization

Model responses may contain characters that break CSV formatting (newlines, commas, double quotes). The Result Writer must properly escape these per RFC 4180. `CsvHelper` handles this automatically if used. If writing CSV manually, the implementer must be careful about multi-line response texts.

### 12.5 Large Model Memory Pressure

The largest model (Mistral Large 123B at ~130GB Q8_0) will consume most of the Mac Studio's 512GB unified memory. During inference with large context windows, the KV cache adds further memory pressure. The runner should not perform any memory-intensive operations (like loading the entire archive into memory) while inference is active. Content assembly should read from disk on-demand, not pre-load.

---

<!--
  Document history:
  - 2026-02-26: Initial draft. Architecture-level design for the data collection runner.
-->
