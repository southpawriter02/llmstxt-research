# Benchmark Methodology

**Status:** 🔲 Not started — will be written during corpus selection (Phase 1–2)

---

> This document will provide the detailed methodology specification for the Context Collapse Mitigation Benchmark, including corpus selection criteria, experimental design, scoring rubric rationale, and statistical analysis plan.
>
> For the study overview, see [README.md](README.md).
> For the full methodology rationale, see the [project proposal](../PROPOSAL.md) (Project 3 § Methodology).

<!-- TODO: Write methodology specification. Sections to include:

  1. Corpus Selection Criteria
     - Minimum requirements for inclusion (well-formed llms.txt, 5+ Markdown pages, substantial content)
     - Sector diversity targets
     - Exclusion criteria

  2. Content Pair Generation
     - Condition A (Control): HTML → text pipeline description
     - Condition B (Treatment): llms.txt Markdown retrieval process
     - How LlmsTxtKit's llmstxt_compare tool is used

  3. Question Design
     - Complexity levels (single-fact, multi-section synthesis, relationship questions)
     - Question authoring guidelines
     - Gold-standard answer criteria

  4. Model Selection
     - Families: Llama, Mistral, Qwen, Gemma, etc.
     - Size range rationale (why test multiple sizes)
     - Quantization and inference parameter standardization

  5. Scoring Protocol
     - Factual accuracy (0–3 scale) — criteria and examples per level
     - Hallucination counting — categorization scheme
     - Completeness — binary criteria
     - Citation fidelity — scoring where applicable
     - Inter-rater reliability (if applicable)

  6. Statistical Analysis Plan
     - Paired comparisons (same question × same model × different condition)
     - Test selection (Wilcoxon signed-rank for ordinal, paired t-test for continuous)
     - Multiple comparisons correction
     - Effect size calculation
     - Pre-registration of hypotheses (if applicable)

  7. Limitations and Threats to Validity
     - Hardware-specific inference behavior
     - Scorer bias (single researcher scoring)
     - Corpus selection bias
     - Generalizability to proprietary models
-->
