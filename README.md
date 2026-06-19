# An approach for RAG performance improvement based on user requests predicting and interests Modelling

This repository contains the implementation and evaluation data for a research project investigating whether future user questions in reading-comprehension dialogues can be reliably predicted and used to pre-fetch relevant documents in Retrieval-Augmented Generation (RAG) systems before the user asks.

## Motivation

RAG systems generate responses by searching a knowledge base at query time, which introduces latency and computational load. If the next questions a user is likely to ask can be predicted from the current dialogue, the relevant document chunks can be retrieved in advance, reducing response time and cost.

This work treats question prediction as an empirical question: given the first N% of a dialogue's questions (and their answers and source passage), can a language model accurately generate the remaining (100 − N)% of questions?

---

### Passage span extraction

Grounds question generation in specific, verifiable facts from the source passage.

1. **Span Extractor LLM:** Receives the source passage and the first N% of Q+A pairs. Divides the passage into logical sections, maps which sections are already covered by existing questions, then extracts candidate answer spans from under-covered sections. Each span is annotated with its answer type, context sentence, section label, and conversational momentum. Also infers the speaker's style (question length, ellipsis rate, yes/no rate, pronoun usage, tone).
2. **Style Generator LLM:** Converts each candidate span into a question phrased in the speaker's exact voice. Does not read the passage or choose topics, those were determined upstream.
3. **LLM-as-a-Judge:** For each real test question (with its ground-truth answer), finds the best matching generated question (with its target span) and scores the pair 0–3 based on passage-span alignment.

**Results across context splits (50 dialogues):**

| Context given | Questions to predict | Num of predicted | Hit Rate |
|:---:|:---:|:---:|:---:|
| 20% | 16 | 5.36 | **33.5%** |
| 40% | 12 | 3.92 | **32.7%** |
| 60% | 8 | 1.58 | **19.8%** |
| 80% | 4 | 0.62 | **15.5%** |

---

## Evaluation metric

**Hit Rate** is the primary metric:

$$\text{Hit Rate} = \frac{1}{N} \sum_{i=1}^{N} \frac{T_i}{M} \times 100\%$$

where $N$ is the number of dialogues, $T_i$ is the number of score-3 predicted questions in dialogue $i$, and $M$ is the total number of test questions per dialogue.

The LLM-as-a-Judge assigns scores on the following scale:

| Score | Meaning |
|:---:|---|
| **3** | Same passage span. The real answer and the generated question's target span come from the same sentence; questions are interchangeable |
| **2** | Same passage region. Same paragraph but different information extracted, or one confirms what the other names |
| **1** | Same named entity, different fact. Both reference the same character or event but probe different facts |
| **0** | No meaningful connection |

Only score-3 pairs contribute to Hit Rate.

---

## Running the workflow

The full pipeline is implemented as an **n8n** workflow (`workflow.json`). It reads dialogues from an Excel file, loops over each one, runs the Span Extractor, then Style Generator, then Judge pipeline, and writes results to an output Excel file.

### Prerequisites

- [n8n](https://n8n.io/) (self-hosted or cloud)
- An API key to supported model providers
### Setup

1. Import `workflow.json` into your n8n.
2. Add your API credentials in the n8n credential store and connect them to each AI Agent node.
3. Upload your input Excel file (same format as `dialogues_50.xlsx`) to n8n or adjust the file path in the **Extract from File** node.
4. In the **Edit Fields** node at the start of the workflow, set `split_pct` to the desired context percentage (any integer between 20 and 80).
5. Execute the workflow. Results are written to an Excel file by the **Convert to File** node.

### Input file format

The input Excel file must have one row per dialogue with the following columns:

| Column | Description |
|---|---|
| `story` | The source passage text |
| `questions` | Newline-separated, numbered list of all 20 questions |
| `answers` | Newline-separated, numbered list of all 20 ground-truth answers |

---

## Data

**`dialogues_50.xlsx`**  50 reading-comprehension dialogues used for all evaluations. Each dialogue contains a source passage and exactly 20 questions with ground-truth answers. Passages are drawn from Wikipedia, Project Gutenberg, CNN, and MCTest sources.

**`Results_50_{20/40/60/80}p.xlsx`**  Per-dialogue judge output at each context split. Each file lists matched question pairs and their scores, plus a summary row per dialogue with the count of score-3 predictions.

---

## Key Findings

- Hit Rate is stable at ~33% for 20–40% context splits, then drops at 60–80%. The remaining questions at high split ratios are the most peripheral facts in the passage. they harder to predict regardless of how much context is available.
- The three main failure modes of the span extraction approach are: (1) different questions are created for the sampe entitites, (2) questions are generated for entities that are present in the text, but about which no questions were actually asked. (3) the generated questions went beyond the scope of the provided text.
