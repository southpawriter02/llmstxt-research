# Benchmark Scoring Rubric

> **Status:** Refined (v2)
> **Created:** 2026-02-22
> **Last Updated:** 2026-02-25
> **Traces To:** Story 4.1, Task 4.1.6
> **Depends On:** Metrics defined in [`../README.md`](../README.md) and [`../../PROPOSAL.md`](../../PROPOSAL.md) (Project 3 § Methodology)
> **Used By:** Scoring phase (Weeks 13-14), analysis notebook (`results/analysis.ipynb`)

---

This document defines how every model response in the benchmark is scored. It covers all five metrics (three primary, two secondary), provides worked examples at each scoring level, and documents the procedural controls that protect against scorer bias.

The scoring rubric is the contract between data collection and analysis. If it's ambiguous, the results are unreliable. Every edge case documented here is one fewer judgment call made under fatigue at 2 AM during scoring week.

---

## 1. Scoring Overview

Each model response is scored on five metrics. The first three are primary (used in all statistical analyses); the last two are secondary (reported but not included in headline comparisons).

| Metric | Type | Scale | Applies To |
|--------|------|-------|------------|
| Factual Accuracy | Primary | 0-3 ordinal | All responses |
| Hallucination Rate | Primary | Integer count | All responses |
| Token Efficiency | Primary | Integer (token count) | All content pairs |
| Completeness | Secondary | Binary | All responses |
| Citation Fidelity | Secondary | 0-2 ordinal | Responses where attribution is expected |

Scoring is performed **after** data collection is complete, on randomized, blinded response sets. The scorer does not know which condition (A or B) produced a given response at the time of scoring.

---

## 2. Factual Accuracy (0-3 Ordinal)

**Definition:** How well does the model's response match the gold-standard answer in factual substance?

The gold-standard answer is the researcher-authored correct answer sourced directly from the site's content (stored in `gold-answers.json`). Scoring compares the model's response against this reference, not against the scorer's independent knowledge of the topic.

### Scale

| Score | Label | Criteria |
|-------|-------|----------|
| **0** | Completely Wrong | The response contradicts the gold-standard answer, provides fabricated information, or fails to address the question. No meaningful overlap with the correct answer. |
| **1** | Partially Correct | The response contains some correct information relevant to the question, but has significant errors, major omissions, or includes incorrect claims that undermine the answer's reliability. |
| **2** | Mostly Correct | The response is substantially accurate and addresses the core of the question. Minor details may be missing or slightly imprecise, but the answer would not mislead a reader relying on it. |
| **3** | Fully Correct | The response matches the gold-standard answer in all material respects. It may use different wording or include additional correct context, but the factual content is equivalent. |

### Decision Rules

- **Correct but incomplete:** A response that correctly answers part of a multi-part question scores **1** or **2** depending on how much is covered, not **3**. Completeness is tracked separately, but factual accuracy requires addressing the full question.
- **Correct with hallucinations:** A response that contains the correct answer but also includes fabricated claims scores no higher than **2**. The hallucination is counted separately under Metric 2, but its presence caps the accuracy score because a reader cannot distinguish the real from the fabricated.
- **Correct from wrong source:** If the model provides the right answer but attributes it to the wrong section, page, or concept within the site, score the factual accuracy normally (the answer is still correct) but flag it in hallucination counting as a Source Confusion instance.
- **Refusal to answer:** If the model declines to answer (e.g., "I don't have enough information"), score **0**. The model was given the content; inability to extract an answer from it is a failure of the condition being tested.
- **Overly general answers:** If the model provides a generically correct answer that could apply to any site (e.g., "Stripe is a payment processing company") without engaging the specific content provided, score **1**. The response isn't wrong, but it doesn't demonstrate content comprehension.

### Worked Examples

The following examples use real questions and gold-standard answers from the benchmark corpus. Each example demonstrates the scoring boundary at a specific complexity level.

#### Example 2.1 — Single-Fact Question

**Question (S009-Q01):** "What is the underlying technology that Turso uses as its production-ready SQLite fork?"
**Gold-standard answer:** "Turso uses libSQL as its production-ready, open-contribution fork of SQLite, which serves as the underlying technology powering all Turso database features including native replication, embedded replicas, and remote database access."

| Score | Example Response | Reasoning |
|-------|-----------------|-----------|
| **0** | "Turso is built on top of CockroachDB, a distributed SQL database designed for cloud-native applications." | Contradicts gold standard. Turso uses libSQL (a SQLite fork), not CockroachDB. |
| **1** | "Turso uses a fork of SQLite as its underlying database technology." | Partially correct — identifies the SQLite fork relationship, but doesn't name libSQL or mention that it's open-contribution. Missing the specific technology name is a significant omission. |
| **2** | "Turso is powered by libSQL, a fork of SQLite. It enables features like embedded replicas and remote database access." | Substantially correct. Correctly names libSQL, mentions key features. Minor omission of "production-ready" and "open-contribution" descriptors, but wouldn't mislead a reader. |
| **3** | "The underlying technology is libSQL, Turso's open-contribution fork of SQLite. It powers native replication, embedded replicas, and remote access across all Turso databases." | Matches gold standard in all material respects. Different wording, same facts. |

#### Example 2.2 — Multi-Section-Synthesis Question

**Question (S001-Q01):** "According to Stripe's documentation, what is the primary backend object for payments and what modern frontend tool option is recommended instead of the legacy Card Element?"
**Gold-standard answer:** "The primary backend object for payments in Stripe is PaymentIntent, which manages the payment process and tracks its status throughout the transaction lifecycle. The recommended modern frontend tool is the Payment Element, which replaces the legacy Card Element by supporting multiple payment methods in a single, embeddable UI component."

| Score | Example Response | Reasoning |
|-------|-----------------|-----------|
| **0** | "Stripe uses Charge objects for payments and recommends using Stripe.js for all frontend payment forms." | Both parts wrong. The primary object is PaymentIntent (not Charge), and the recommended frontend tool is Payment Element (not generic Stripe.js). |
| **1** | "The PaymentIntent is the main object for handling payments in Stripe." | Correctly identifies PaymentIntent but entirely omits the second part of the question about the frontend tool. Answers only half the synthesis question. |
| **2** | "Stripe uses PaymentIntent as the primary backend payment object. For the frontend, the Payment Element is recommended as a modern alternative to the Card Element." | Substantially correct on both parts. Minor omission of "manages the payment process and tracks status" and "multiple payment methods in a single UI component," but captures the synthesis correctly. |
| **3** | "PaymentIntent is the primary backend payment object, tracking the payment lifecycle. The modern frontend replacement for the legacy Card Element is the Payment Element, which supports multiple payment methods in one embeddable UI component." | All material facts from both sections present. |

**Scoring note for synthesis questions:** The key boundary between score 1 and score 2 for multi-section-synthesis questions is whether the response addresses *all* sections the question requires. A response that perfectly answers one section but ignores the other scores **1**, not **2**, because the synthesis itself was not demonstrated.

#### Example 2.3 — Conceptual-Relationship Question

**Question (S003-Q07):** "How do idempotency keys in Resend prevent duplicate emails, and what trade-offs exist between email scheduling and immediate sending?"
**Gold-standard answer:** "Idempotency keys prevent duplicate emails by checking whether an identical email with the same key has been sent in the last 24 hours, returning the same response without resending if found. Trade-offs between scheduling and immediate sending include precision of delivery timing and the ability to cancel scheduled emails before they're sent, versus the simplicity and predictability of immediate sends."

| Score | Example Response | Reasoning |
|-------|-----------------|-----------|
| **0** | "Resend uses rate limiting to prevent duplicate emails. Scheduling allows you to queue up emails for later delivery." | Fabricates a mechanism (rate limiting ≠ idempotency keys) and doesn't describe the actual trade-off relationship. |
| **1** | "Idempotency keys help prevent duplicates by ensuring the same email isn't sent twice. Scheduled emails can be cancelled before sending." | Partially correct — the duplicate prevention description is vague (misses the 24-hour window and same-key mechanism), and the trade-off analysis is one-sided (only mentions cancellation, not the precision vs. simplicity trade-off). |
| **2** | "Idempotency keys work by checking if an email with the same key was already sent within 24 hours. If so, the original response is returned instead of sending again. Scheduling offers the benefit of cancellation but adds complexity compared to immediate sending." | Captures the core mechanism and touches on the trade-off. Minor gap: doesn't explicitly frame "precision of delivery timing" as a scheduling advantage. |
| **3** | "When you include an idempotency key, Resend checks whether an email with that key was sent in the last 24 hours and returns the cached response instead of resending. The trade-off between scheduling and immediate sending involves delivery timing precision and cancellability for scheduled emails versus the simplicity and predictability of sending immediately." | Both the mechanism and the trade-off relationship are fully articulated. |

**Scoring note for conceptual-relationship questions:** The key distinction is whether the response articulates the *relationship* — not just the individual concepts. A response that correctly defines both idempotency keys and email scheduling but doesn't explain the trade-off between them scores **1** or **2**, not **3**.

### Complexity-Specific Scoring Guidance

The benchmark includes three question complexity levels (defined in `methodology.md` §3.1). Each level has distinct scoring characteristics that affect how the 0-3 scale is applied.

**Single-fact questions** ask for a specific piece of information from one section. The scoring boundary between 2 and 3 is typically precision: does the response include the specific name, value, or term the gold standard identifies? These questions have the tightest expected variance — most correct responses will score 2 or 3.

**Multi-section-synthesis questions** require combining information from two or more sections. The scoring boundary between 1 and 2 is coverage: does the response address *all* required sections? A response that perfectly addresses one section but ignores the other scores 1, not 2, because synthesis was not demonstrated. The boundary between 2 and 3 is integration quality: does the response show how the sections connect, or does it just list facts from each?

**Conceptual-relationship questions** ask the model to explain trade-offs, dependencies, or distinctions between concepts. The scoring boundary between 1 and 2 is whether the *relationship* is articulated versus merely listing both concepts. The boundary between 2 and 3 is whether the relationship characterization matches the gold standard in substance — describing the right trade-offs, the right dependencies, or the right distinctions.

**Analysis implication:** The per-complexity-level subgroup analysis (see `methodology.md` §3.2) tests whether Condition B (llms.txt Markdown) produces larger improvements for synthesis and relationship questions than for single-fact questions. Scorers should be aware that complexity labels exist, but should *not* adjust their scoring based on complexity — score purely against the gold standard. The complexity-differentiated analysis is performed statistically after scoring, not during it.

---

## 3. Hallucination Rate (Integer Count)

**Definition:** The number of distinct claims in the model's response that are not supported by the source content provided to the model.

A "claim" is a factual assertion that could be independently verified or refuted. Opinions, hedging language ("it might be..."), and meta-commentary ("Based on the provided content...") are not claims.

### Hallucination Categories

Each hallucinated claim is classified into exactly one category:

| Category | Code | Definition | Example |
|----------|------|------------|---------|
| Factual Fabrication | `H-FAB` | The model invents a fact that does not appear in the source content and is not a reasonable inference from it. | "The API supports GraphQL endpoints" when the documentation only describes REST. |
| Source Confusion | `H-SRC` | The model attributes information to the wrong section, page, or concept within the source content. The information may exist in the source, but the attribution is incorrect. | "As described in the Authentication section..." when the information is actually in the Rate Limiting section. |
| Extrapolation | `H-EXT` | The model makes an inference that goes beyond what the source content states and presents it as fact rather than inference. | "This means the API can handle approximately 10,000 requests per second" when the documentation only states the rate limit is 100 requests per minute per key. |
| Temporal Hallucination | `H-TMP` | The model presents outdated, future, or temporally incorrect information. | "Starting in Q3 2025, the API will support..." when no such timeline appears in the source. |

### Counting Rules

- **One claim = one count.** If the model fabricates three facts in a single sentence, that's three hallucinations, not one.
- **Repeated hallucinations count once.** If the model states the same fabricated fact in two different sentences, count it once. It's the same claim.
- **Category trumps severity.** A minor fabrication and a major fabrication each count as one hallucination. Severity is not part of the count; it's captured in the factual accuracy score.
- **Hedged claims still count.** "The API likely supports WebSocket connections" is still a hallucination if the source content says nothing about WebSocket support. The hedge makes it less misleading but doesn't make it supported.
- **Correct inferences don't count.** If the source says "API keys are 32-character alphanumeric strings" and the model says "API keys are case-sensitive," that's a reasonable inference from "alphanumeric" (which typically implies case-sensitivity in API contexts). Use judgment, and document borderline cases in the scoring notes.

### Recording Format

Hallucinations are recorded per-response in the scoring data. Each entry includes the exact text span from the model output that triggered the hallucination count, enabling post-hoc audit and inter-rater calibration:

```json
{
  "response_id": "R001-A-Q03",
  "hallucination_count": 2,
  "hallucinations": [
    {
      "category": "H-FAB",
      "model_text_span": "The API supports batch operations for up to 100 items per request.",
      "claim": "Batch operations supporting up to 100 items",
      "note": "Source content describes only single-item endpoints. No batch endpoint documented."
    },
    {
      "category": "H-SRC",
      "model_text_span": "As noted in the Quick Start guide, authentication requires...",
      "claim": "Attribution to Quick Start guide",
      "note": "Authentication information is documented on the Advanced Configuration page, not Quick Start."
    }
  ]
}
```

---

## 4. Token Efficiency (Integer)

**Definition:** The number of input tokens in the content provided to the model under each condition.

This is a measurement, not a judgment. There is no "good" or "bad" token count--the metric captures whether llms.txt-curated Markdown (Condition B) is more or less token-efficient than HTML-derived text (Condition A) for the same content.

### Measurement Protocol

- **Tokenizer:** Use the tokenizer corresponding to the model being tested. For models using the Llama tokenizer, use `tiktoken` with the appropriate encoding. For other model families, use the tokenizer specified in the model's documentation.
- **What's counted:** Only the content portion of the prompt. The system prompt and question are constant across conditions and are not included in the token count.
- **When it's measured:** At content pair generation time (during data collection), not during scoring. Token counts are pre-computed and stored in the raw data.

### Analysis Framework

Token efficiency is analyzed at three levels:

1. **Per-site aggregates:** Mean and median token count for Condition A vs. Condition B across all content pairs for a given site. This captures how much more or less verbose the llms.txt content is compared to the HTML-derived text for the same documentation.

2. **Cross-site distribution:** The distribution of per-site deltas (B minus A, as a percentage) across all 37 corpus sites. This answers: "How consistently is llms.txt more or less token-efficient?"

3. **Efficiency-quality correlation:** Scatter plot of token delta vs. factual accuracy delta per question, testing whether token savings (or costs) correlate with quality changes. This addresses the concern that shorter context might sacrifice important information.

**Reporting convention:** Negative delta means Condition B (llms.txt) uses fewer tokens. Positive delta means Condition B uses more. All deltas are reported both as absolute token counts and as percentages relative to Condition A.

### Recording Format

```json
{
  "content_pair_id": "S001-P03",
  "condition_a_tokens": 4821,
  "condition_b_tokens": 2103,
  "tokenizer": "llama-3-tokenizer",
  "delta": -2718,
  "delta_pct": -56.4
}
```

---

## 5. Completeness (Binary)

**Definition:** Does the response address all parts of the question?

This is distinct from factual accuracy. A response can be factually accurate but incomplete (answers one part of a two-part question correctly), or complete but inaccurate (addresses all parts of the question but gets them wrong).

### Scale

| Value | Label | Criteria |
|-------|-------|----------|
| **1** | Complete | The response addresses every distinct element of the question. For multi-part questions, each part receives at least a partial answer. |
| **0** | Incomplete | The response omits one or more asked-for elements entirely. Partial answers to individual elements still count as addressing them. |

### Decision Rules

- **Single-fact questions:** Almost always scored **1** (Complete) unless the model refuses to answer or provides a completely off-topic response.
- **Multi-part questions:** Score **0** if any part is entirely unaddressed. "How does the API handle authentication and rate limiting?" requires at least some answer to _both_ authentication and rate limiting.
- **Tangential information:** A response that provides extensive tangential information but never addresses the actual question is scored **0**.
- **"I don't know" for one part:** If the model says "I don't have information about X" for one part of a multi-part question but answers the rest, score **0**. The model acknowledged the part exists but couldn't answer it.

### Complexity-Specific Completeness Guidance

The completeness check is complexity-aware because each complexity level implies a different "parts of the question" structure:

**Single-fact:** Completeness requires addressing the specific fact asked for. A response that discusses the general topic area without stating the specific fact is incomplete (score 0). For example, if the question asks "What is the underlying technology that Turso uses?" and the response discusses Turso's feature set without naming libSQL, it's incomplete.

**Multi-section-synthesis:** Completeness requires addressing material from *all* cited source sections. The question's `source_sections` field in `questions.json` documents which sections must be covered. If a question synthesizes information from "Authentication" and "Webhooks" and the response only addresses Authentication, score 0.

**Conceptual-relationship:** Completeness requires articulating the relationship, not just the individual concepts. If the question asks "How do X and Y differ in their approach to Z?" and the response describes X and Y independently without comparing them, score 0 — the comparison was the asked-for element.

---

## 6. Citation Fidelity (0-2 Ordinal)

**Definition:** When the model cites or attributes information to specific parts of the source content, how accurate are those citations?

This metric applies only when the question or response context implies source attribution. Many responses won't include citations at all, and that's expected--not every question requires them.

### Applicability

| Scenario | Citation Fidelity Applies? |
|----------|--------------------------|
| Question asks "According to the documentation, what is...?" | Yes |
| Question asks "What does the Quick Start guide say about...?" | Yes |
| Model spontaneously cites sections ("As described in the API Reference...") | Yes |
| Question is a simple factual query with no attribution framing | Only if the model includes citations |
| Model answers without any citations or attributions | **N/A** -- mark as not applicable |

### Scale

| Score | Label | Criteria |
|-------|-------|----------|
| **0** | No Citations | The response should include citations based on the question framing, but doesn't. Or: the model includes citations but they are entirely fabricated (citing sections or pages that don't exist). |
| **1** | Inaccurate Citations | Citations are present and reference real sections/pages, but the attributed information doesn't come from the cited source. The citation exists; it just points to the wrong place. |
| **2** | Accurate Citations | Citations are present and correctly attribute information to the right sections/pages in the source content. |

### Decision Rules

- **When marked N/A:** If citation fidelity is not applicable (the question didn't ask for attribution and the model didn't provide any), record as `null` in the scoring data. Do not score it as 0.
- **Partial accuracy:** If a response includes three citations, two accurate and one inaccurate, score **1**. Any inaccurate citation caps the score.
- **Vague citations:** "According to the documentation..." is too vague to evaluate. If the question asked for specific attribution and the model provides only vague references, score **0**.

---

## 7. Scoring Procedure

### 7.1 Blinding

The scorer must not know which condition (A or B) produced a given response at the time of scoring. The blinding mechanism works as follows:

1. **Randomization:** After data collection, all responses are assigned randomized response IDs that do not encode the condition. The mapping from response ID to condition is stored in a separate file not opened during scoring.
2. **Presentation order:** Responses are presented to the scorer in randomized order, interleaving conditions. The scorer does not see responses for the same question grouped together.
3. **Unblinding:** After all scoring is complete, the condition mapping is applied to the scored data for analysis.

### 7.2 Scoring Order

1. Score all responses for **Factual Accuracy** first (full pass through all responses).
2. Score all responses for **Hallucination Rate** second (second full pass).
3. Score all responses for **Completeness** third.
4. Score all responses for **Citation Fidelity** fourth (only applicable responses).
5. Token Efficiency is pre-computed and does not require manual scoring.

**Rationale for separate passes:** Scoring one metric at a time reduces context-switching cognitive load and improves consistency. Scoring accuracy and hallucinations in the same pass risks conflating the two assessments.

### 7.3 Scoring Notes

For every response, the scorer records free-text notes explaining the rationale for each score. These notes serve two purposes: they enable post-hoc review of borderline decisions, and they provide qualitative data for the study write-up.

Notes are especially important for:
- Any factual accuracy score of **1** or **2** (explain what was correct and what was missing/wrong)
- Any hallucination classification (document the specific claim and why it's unsupported)
- Any citation fidelity score of **0** or **1** (explain what was cited and why it's inaccurate)

---

## 8. Inter-Rater Reliability

### 8.1 Protocol

If a second rater is available:
- A **random 10-15% subset** of responses is independently scored by the second rater using the same rubric and blinding procedure.
- Agreement is measured using **Cohen's weighted kappa** for ordinal metrics (Factual Accuracy, Citation Fidelity) and **Cohen's kappa** for binary metrics (Completeness).
- Hallucination agreement is measured as **per-response count correlation** (Spearman's rho) and **category agreement** (Cohen's kappa on the assigned categories).

### 8.2 Disagreement Resolution

- If weighted kappa < 0.6 on any metric, the two raters discuss disagreements and refine the rubric with additional decision rules before re-scoring the subset.
- If weighted kappa ≥ 0.6, the primary rater's scores are used for all responses. The inter-rater reliability statistics are reported in the methodology section of the study write-up.

### 8.3 Single-Rater Fallback

If a second rater is not available, this is documented as an acknowledged limitation in the study write-up. The mitigation is:
- Blinding (the scorer doesn't know which condition produced the response)
- Separate scoring passes per metric (reduces cross-metric contamination)
- Mandatory scoring notes (enables post-hoc review)
- A 5% self-consistency check: the primary rater re-scores 5% of responses after a 48-hour delay and measures agreement with their own earlier scores

---

## 9. Edge Cases and Precedents

This section documents foreseeable edge cases based on corpus characteristics, plus a framework for recording new edge cases that arise during scoring. Each entry documents the situation, the decision made, and the rationale, establishing precedent for similar cases.

### Pre-Populated Edge Cases

These edge cases are anticipated based on the 37-site, 286-question corpus:

| # | Situation | Decision | Rationale |
|---|-----------|----------|-----------|
| EC-01 | **Model provides a more detailed correct answer than the gold standard.** For example, the gold standard mentions two features but the model correctly identifies four from the same source. | Score **3** for factual accuracy. The gold standard is a minimum bar, not a ceiling. Additional correct facts from the same source content are not hallucinations. | GA-3 says the gold standard contains "all material facts," but sources may contain additional correct details. Over-delivery of correct facts doesn't reduce accuracy. |
| EC-02 | **Model uses deprecated terminology that was correct when the gold standard was authored.** For instance, Stripe's "Standard/Express/Custom" account types vs. newer "controller properties" terminology. | Score based on substantive correctness, not terminology currency. If both terms refer to the same concept, score **2** or **3** depending on overall accuracy. | The benchmark tests content comprehension, not terminology awareness. Both the old and new terms appear in Stripe's documentation. |
| EC-03 | **Model correctly answers the question but from a different page than the gold standard's source_urls.** The same fact appears in multiple documentation pages. | Score factual accuracy normally (the answer is correct). Do not count as a hallucination unless the model fabricates the source attribution. | Many documentation sites have overlapping content across pages. The correct fact is the correct fact regardless of where the model found it. |
| EC-04 | **Numerical precision differences.** Gold standard says "24 hours" and the model says "1 day" or "approximately 24 hours." | Score **3** if the values are equivalent. Score **2** if there's meaningful imprecision (e.g., "about a day" when the exact window matters for implementation). | Equivalent expressions of the same value should not be penalized. Hedging that reduces precision should receive a minor deduction. |
| EC-05 | **Model refuses to answer citing insufficient context.** | Score **0** for factual accuracy, **0** for completeness. Record no hallucinations (refusal is not fabrication). | The model was provided the source content. Refusal indicates the condition failed to make the content usable. This is a meaningful signal for the study. |
| EC-06 | **Model provides the correct answer embedded in extensive irrelevant padding.** For example, a 500-word response where only two sentences address the question. | Score factual accuracy based on the relevant portion only. Score completeness normally. Count any fabricated claims in the padding as hallucinations. | Padding doesn't negate correct content, but fabricated padding claims are still hallucinations. The response's overall quality is captured across multiple metrics. |
| EC-07 | **Site content has changed since gold-standard authoring date (2026-02-25).** The model's answer matches the *current* site content but differs from the gold standard. | Score against the **gold standard**, not the current site content. Document the discrepancy in scoring notes. If widespread, flag for gold-standard update. | The benchmark measures model behavior against a frozen reference. Scoring against moving targets introduces noise. The verification date in `gold-answers.json` establishes the reference point. |
| EC-08 | **Non-English content in response.** The model includes code snippets, API paths, or configuration examples alongside natural language. | Score factual accuracy on the *claims* made, not on whether code examples are syntactically correct. Code snippets that illustrate the correct concept support a higher score; incorrect code that contradicts the gold standard reduces it. | The benchmark tests factual comprehension, not code generation quality. But code that contradicts stated facts is evidence of confusion. |
| EC-09 | **Model answers a different question than the one asked.** The response is factually accurate for some other question about the same site but doesn't address the actual question. | Score **0** for factual accuracy and **0** for completeness. Do not count the unasked-for content as hallucinations (it may be correct, just irrelevant). | Answering the wrong question is a comprehension failure, not a hallucination. The completeness score captures that the actual question was unaddressed. |
| EC-10 | **Model correctly identifies that a question premise is flawed.** For example, if a question asks about "three types" and the model says "the documentation describes two types, not three." | Score **3** if the model then provides the correct answer for what *does* exist. The model demonstrated superior comprehension by identifying the premise error. | During verification, we found and corrected 3 questions with flawed premises (S003-Q01, S010-Q02, S016-Q01). If any remain undiscovered, the model should not be penalized for catching them. |

### Runtime Edge Cases

Additional edge cases encountered during scoring are recorded below. When a new edge case arises, the scorer pauses, documents it here, and applies the decision consistently to all similar cases (including retroactively re-scoring earlier responses if necessary).

| # | Situation | Decision | Rationale |
|---|-----------|----------|-----------|
| _To be populated during scoring_ | | | |

---

## 10. Scoring Automation Opportunities

With 286 questions × N models × 2 conditions, the total response count could exceed 2,000. Pure manual scoring at this scale is time-consuming and fatigue-prone. The following metrics have varying degrees of automation potential:

| Metric | Automation Level | Method |
|--------|-----------------|--------|
| Token Efficiency | **Fully automated** | Pre-computed at content pair generation time. No manual scoring required. |
| Completeness | **Semi-automatable** | Keyword/phrase detection against question elements can flag likely-incomplete responses for manual review. Final judgment remains manual. |
| Citation Fidelity | **Semi-automatable** | Regex detection of citation patterns ("According to...", "As described in...") can identify responses requiring citation scoring. Applicability (N/A vs. scored) can be partially automated. |
| Factual Accuracy | **Manual with assist** | An LLM-as-judge approach (using a separate, larger model to compare the response against the gold standard) can provide a first-pass score for triage. All scores require human verification. |
| Hallucination Rate | **Manual** | Requires careful reading and cross-referencing against source content. No reliable automated shortcut exists. |

**Important constraint:** If LLM-as-judge is used for first-pass factual accuracy scoring, the judge model must not be one of the models being benchmarked, and the judge scores must be verified by the human scorer. The study write-up must disclose the use of automated assistance and report the human-judge agreement rate.

---

## 11. Data Recording Format

All scoring data is recorded in the raw results CSV (`results/raw-data.csv`) with the following columns per response:

| Column | Type | Description |
|--------|------|-------------|
| `response_id` | String | Randomized response identifier (does not encode condition) |
| `site_id` | String | Site identifier from `site-list.csv` |
| `question_id` | String | Question identifier from `questions.json` |
| `complexity` | Enum | `single-fact`, `multi-section-synthesis`, or `conceptual-relationship` (from `questions.json`) |
| `model_id` | String | Model identifier (family, size, quantization) |
| `condition` | Enum | `A` or `B` (added at unblinding, blank during scoring) |
| `factual_accuracy` | Integer | 0-3 |
| `hallucination_count` | Integer | ≥0 |
| `hallucination_categories` | String | Comma-separated codes (e.g., `H-FAB,H-SRC`); empty if count is 0 |
| `input_token_count` | Integer | Input tokens using the model family's tokenizer (pre-computed; see `methodology.md` §2.6) |
| `ref_token_count` | Integer | Input tokens using the Llama 3 reference tokenizer (pre-computed; see `methodology.md` §2.6) |
| `output_token_count` | Integer | Output tokens of the model's response (using model family's tokenizer) |
| `content_chars` | Integer | Character count of assembled content (tokenizer-independent size measure) |
| `completeness` | Integer | 0 or 1 |
| `citation_fidelity` | Integer or null | 0-2 or null if N/A |
| `scoring_notes` | String | Free-text rationale (required for accuracy <3, hallucinations >0, or citation fidelity <2) |
| `scorer_id` | String | Identifier of the person who scored this response |
| `scoring_date` | Date | ISO 8601 date of scoring |

A companion file (`results/hallucination-details.json`) stores the full hallucination records including `model_text_span`, `claim`, `category`, and `note` fields for every counted hallucination, keyed by `response_id`. This separation keeps the CSV manageable while preserving full audit detail.
