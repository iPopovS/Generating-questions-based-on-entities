{
  "nodes": [
    {
      "parameters": {},
      "id": "02eb426b-0ee7-4f9c-9af5-939299a230a1",
      "name": "Start",
      "type": "n8n-nodes-base.manualTrigger",
      "position": [
        -864,
        992
      ],
      "typeVersion": 1
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "split-pct-field",
              "name": "split_pct",
              "value": 40,
              "type": "number"
            }
          ]
        },
        "options": {}
      },
      "id": "06f1f74b-8e7b-4542-b4a5-9d4bf0794283",
      "name": "Edit Fields",
      "type": "n8n-nodes-base.set",
      "position": [
        -608,
        992
      ],
      "typeVersion": 3.4
    },
    {
      "parameters": {
        "jsCode": "const splitPct = ($input.first().json.split_pct ?? 60) / 100;\n\nconst questions = $input.first().json.all_questions\n  .trim()\n  .split(/\\n(?=\\d+\\.)/)\n  .map(q => q.trim())\n  .filter(q => q.length > 0);\n\nconst answers = $input.first().json.all_answers\n  .trim()\n  .split(/\\n(?=\\d+\\.)/)\n  .map(a => a.trim())\n  .filter(a => a.length > 0);\n\nconst cutoff = Math.ceil(questions.length * splitPct);\nconst firstPart    = questions.slice(0, cutoff);\nconst lastPart     = questions.slice(cutoff);\nconst firstPartAns = answers.slice(0, cutoff);\nconst lastPartAns  = answers.slice(cutoff);\n\nconst qa_block = firstPart.map((q, i) => {\n  const a = firstPartAns[i] || '?';\n  const num = i + 1;\n  return `${num}. Q: ${q.replace(/^\\d+\\.\\s*/, '')}\\n   A: ${a.replace(/^\\d+\\.\\s*/, '')}`;\n}).join('\\n');\n\nreturn [{\n  json: {\n    dialogue_passage:   $input.first().json.dialogue_passage,\n    split_pct:          Math.round(splitPct * 100),\n    remaining_pct:      Math.round((1 - splitPct) * 100),\n    questions_first_pt: firstPart.join('\\n'),\n    questions_last_pt:  lastPart.join('\\n'),\n    answers_last_pt:    lastPartAns.join('\\n'),\n    qa_block_first_pt:  qa_block,\n    last_qa_pair:       qa_block.split('\\n').slice(-2).join('\\n'),\n    n_first_pt:         firstPart.length,\n    n_last_pt:          lastPart.length,\n    total_questions:    questions.length\n  }\n}];"
      },
      "id": "283c55d6-9eb1-4479-b645-2b65c1819aa1",
      "name": "Compute Split",
      "type": "n8n-nodes-base.code",
      "position": [
        400,
        992
      ],
      "typeVersion": 2
    },
    {
      "parameters": {
        "jsCode": "const items = $input.all();\n\nconst rows = [];\n\nitems.forEach((item, dialogueIndex) => {\n  const dialogueNumber = dialogueIndex + 1;\n  const parsed = typeof item.json.output === 'string' \n    ? JSON.parse(item.json.output) \n    : item.json.output;\n\n  const pairs = parsed.pairs;\n  const score3Count = pairs.filter(p => p.score === 3).length;\n\n  pairs.forEach((pair) => {\n    rows.push({\n      json: {\n        \"Dialogue\": dialogueNumber,\n        \"Real Question\": pair.real,\n        \"Generated Question\": pair.generated,\n        \"Score\": pair.score,\n        \"How Many Predicted\": null\n      }\n    });\n  });\n\n  rows.push({\n    json: {\n      \"Dialogue\": dialogueNumber,\n      \"Real Question\": null,\n      \"Generated Question\": null,\n      \"Score\": null,\n      \"How Many Predicted\": score3Count\n    }\n  });\n});\n\nreturn rows;"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        368,
        768
      ],
      "id": "d295cdab-02b0-4ea3-9bf1-8d30afd55884",
      "name": "Results1"
    },
    {
      "parameters": {
        "model": "openai/gpt-oss-120b",
        "options": {}
      },
      "type": "@n8n/n8n-nodes-langchain.lmChatOpenRouter",
      "typeVersion": 1,
      "position": [
        528,
        1200
      ],
      "id": "91f5c8c1-94c1-4285-ab2a-6d3f8ca99315",
      "name": "OpenRouter Chat Model1",
      "credentials": {
        "openRouterApi": {
          "id": "",
          "name": ""
        }
      }
    },
    {
      "parameters": {
        "model": "openai/gpt-oss-120b",
        "options": {}
      },
      "type": "@n8n/n8n-nodes-langchain.lmChatOpenRouter",
      "typeVersion": 1,
      "position": [
        1072,
        1200
      ],
      "id": "eb2d6001-0455-4d54-b783-50452e163afd",
      "name": "OpenRouter Chat Model2",
      "credentials": {
        "openRouterApi": {
          "id": "",
          "name": ""
        }
      }
    },
    {
      "parameters": {
        "model": "openai/gpt-oss-120b",
        "options": {}
      },
      "type": "@n8n/n8n-nodes-langchain.lmChatOpenRouter",
      "typeVersion": 1,
      "position": [
        1824,
        1200
      ],
      "id": "f06bcd75-760b-4beb-bc53-627a07d70846",
      "name": "OpenRouter Chat Model3",
      "credentials": {
        "openRouterApi": {
          "id": "",
          "name": ""
        }
      }
    },
    {
      "parameters": {
        "fileSelector": "dialogues_50.xlsx",
        "options": {}
      },
      "type": "n8n-nodes-base.readWriteFile",
      "typeVersion": 1.1,
      "position": [
        -400,
        992
      ],
      "id": "04646d8f-a30d-48d1-87e5-7a4e416b18a8",
      "name": "Read file"
    },
    {
      "parameters": {
        "operation": "xlsx",
        "options": {}
      },
      "type": "n8n-nodes-base.extractFromFile",
      "typeVersion": 1.1,
      "position": [
        -208,
        992
      ],
      "id": "ea18b2af-d5ea-4651-ac04-9bd35e1c717c",
      "name": "Extract from File"
    },
    {
      "parameters": {
        "options": {}
      },
      "type": "n8n-nodes-base.splitInBatches",
      "typeVersion": 3,
      "position": [
        0,
        992
      ],
      "id": "f635a950-90f8-4db9-ac4b-4f40922c2b61",
      "name": "Loop Over Items"
    },
    {
      "parameters": {
        "assignments": {
          "assignments": [
            {
              "id": "52f7073a-6eb0-47dd-95e1-3cb81263a295",
              "name": "all_questions",
              "value": "={{ $json.questions }}",
              "type": "string"
            },
            {
              "id": "dcd3bc3d-d256-40f6-aeb1-fcba874280de",
              "name": "all_answers",
              "value": "={{ $json.answers }}",
              "type": "string"
            },
            {
              "id": "9530171c-3142-44e2-886c-1993cc17909f",
              "name": "dialogue_passage",
              "value": "={{ $json.story }}",
              "type": "string"
            },
            {
              "id": "split-pct-passthrough",
              "name": "split_pct",
              "value": "={{ $('Edit Fields').item.json.split_pct }}",
              "type": "number"
            }
          ]
        },
        "options": {}
      },
      "id": "fc135c59-2b6d-4377-8a7f-5a22d96ad6b6",
      "name": "Prepare Input",
      "type": "n8n-nodes-base.set",
      "position": [
        208,
        992
      ],
      "typeVersion": 3.4
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "=PASSAGE:\n{{ $json.dialogue_passage }}\n\n---\nQUESTIONS AND ANSWERS ALREADY COVERED (first {{ $json.split_pct }}% — {{ $json.n_first_pt }} questions):\n{{ $json.qa_block_first_pt }}\n\n---\nI need {{ $json.n_last_pt }} more questions (the remaining {{ $json.remaining_pct }}%). Find at least {{ $json.n_last_pt }} unasked answer spans from the passage.\nReturn the JSON object.",
        "options": {
          "systemMessage": "You are a reading-comprehension passage analyst.\n\nYou will receive a passage and the first portion of questions already asked (with their answers). Your job is to identify facts in the passage that have NOT yet been covered by any question in the provided set.\n\n## Task\n\nRead the passage carefully. Extract every distinct verifiable fact — entity attributes, events, quantities, names, locations, outcomes, quotes, comparisons. \n\nThen cross-check: which facts have already been asked about in the Q+A pairs? Remove those.\n\nWhat remains are CANDIDATE ANSWER SPANS — the facts the conversation hasn't reached yet.\n\n## Output\n\nReturn ONLY valid JSON. No markdown, no preamble.\n\n{\n  \"style\": {\n    \"avg_length\": \"<very_short|short|medium|long>\",\n    \"uses_ellipsis\": <true|false>,\n    \"uses_yes_no\": <true|false>,\n    \"tone\": \"<conversational|formal>\",\n    \"example_q\": \"<the shortest or most elliptical question from the provided set>\",\n    \"yes_no_rate\": \"<fraction of provided questions that are yes/no questions, e.g. 0.4>\"\n  },\n  \"covered_facts\": [\n    \"<brief description of each fact already addressed by the Q+A>\"\n  ],\n  \"candidate_spans\": [\n    {\n      \"answer\": \"<exact phrase or short passage span>\",\n      \"answer_type\": \"<yes_no|person|location|time|count|attribute|quote|action>\",\n      \"context\": \"<one sentence explaining what this fact is about>\",\n      \"momentum\": \"<high|medium|low — how closely it follows from the last Q+A pair>\"\n    }\n  ]\n}\n\n## Rules\n\n- candidate_spans must be facts LITERALLY PRESENT in the passage. Do not infer or invent.\n- covered_facts and candidate_spans must be exhaustive but non-overlapping.\n- Order candidate_spans by momentum descending: high-momentum facts first (those that continue the last Q+A chain), low-momentum facts last (those that introduce a new sub-topic).\n- Produce at least N candidate spans where N equals the number of questions needed (stated in the user message). It is fine to produce more.\n- Do not generate any questions. Output facts only."
        }
      },
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 3.1,
      "position": [
        608,
        992
      ],
      "id": "fd1b4cc8-ee7e-4617-8e10-12e913e85637",
      "name": "AI Agent_1",
      "retryOnFail": true
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "=SPEAKER'S STYLE (from {{ $('Compute Split').item.json.split_pct }}% analysis):\n{{ $json.style }}\nMost representative short question: \"{{ $json.example_q }}\"\nYes/no rate in provided questions: {{ $json.yes_no_rate }}\n\n---\nQUESTIONS ALREADY ASKED (do not repeat any of these):\n{{ $('Compute Split').item.json.questions_first_pt }}\n\n---\nTARGET ANSWER SPANS — generate one question per span, in order:\n{{ $json.spans_text }}\n\n---\nGenerate exactly {{ $('Compute Split').item.json.n_last_pt }} questions, numbered starting from {{ $('Compute Split').item.json.n_first_pt + 1 }}.\nUse the first {{ $('Compute Split').item.json.n_last_pt }} spans from the target list.\nEach question must be answerable by its corresponding answer span.",
        "options": {
          "systemMessage": "You are a reading-comprehension question stylist.\n\nYou receive a list of target answer spans — facts from a passage — and your job is to phrase a question for each one that sounds exactly like the human speaker in this conversation.\n\n## Your only job\n\nConvert each answer span into a question in the speaker's exact voice. You are not choosing topics. You are not reading the passage for new content. You are phrasing questions.\n\n## Style matching rules (apply all of them)\n\n1. Match question length exactly. Study the example question and the avg_length field.\n   - very_short: 1–3 words (\"why?\" / \"where?\" / \"how many?\")\n   - short: 4–6 words (\"where did he go?\" / \"was it working?\")\n   - medium: 7–10 words\n   - long: full grammatical sentences\n\n2. Match yes/no rate. If yes_no_rate=0.5, roughly half your generated questions should be answerable yes/no. For a yes/no answer span, phrase as: \"did he receive threats?\" not \"what threats did he receive?\"\n\n3. Use ellipsis when the speaker does. If example_q shows ellipsis (bare \"why?\" / \"and?\"), chain some of your questions as bare follow-ups referencing the previous question.\n\n4. Match pronoun usage. If the provided questions say \"where is it?\" not \"where is the Vatican Library?\", use \"it\" — not the full name.\n\n5. Match tone. Conversational = contractions, informal word order. Formal = complete grammatical sentences.\n\n## Output\n\nONLY the numbered questions, one per line, starting from the number provided.\nNo headers. No explanations. No answer text.\nDo NOT produce more questions than the count requested.\nDo NOT repeat any question from the provided set."
        }
      },
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 3.1,
      "position": [
        1120,
        992
      ],
      "id": "28ba4965-f3c8-497d-b484-840880da6557",
      "name": "AI Agent_2",
      "retryOnFail": true
    },
    {
      "parameters": {
        "promptType": "define",
        "text": "=REAL questions with answers (ground truth — last {{ $('Compute Split').item.json.remaining_pct }}%):\n{{ $json.real_qa_labeled }}\n\n---\nGENERATED questions with their target answer spans (the passage facts they were built to ask about):\n{{ $json.generated_questions_labeled }}\n\n---\nFor each real question R1, R2, ...:\n1. Find the single best matching generated question from the pool above.\n2. Compare the real answer to the generated question's target span — these are both grounded in the passage, so you can compare them directly without inference.\n3. Assign a score 0–3 per the rubric.\n4. Once a generated question is matched, remove it from the pool.\n5. Omit pairs where the best available score is 0.",
        "options": {
          "systemMessage": "You are an expert evaluator of reading-comprehension questions.\n\nYour task: given a set of real questions (with their answers) and a set of generated questions (with the target answer spans they were built from), find the best semantic match from the generated set for each real question, then score that match.\n\n## How to score a pair\n\nYou are given the real question's answer and the generated question's target span. Both are grounded in the same passage. Compare them directly — no inference needed.\n\nFor each candidate generated question, reason in two steps:\n\nSTEP 1 — Compare real answer to target span.\nRead the real answer and the generated question's target span side by side. Ask: do they refer to the same fact, the same sentence, or the same region of the passage?\n\nSTEP 2 — Assign score using this ladder:\n\nScore 3 — Same passage span.\nThe real answer and the target span come from the same sentence or clause. A reader pointing to that text would satisfy both questions. The questions are interchangeable in terms of what they extract from the passage.\n\nStrict test: if one question extracts a name and the other confirms the existence of that same name via yes/no, that is NOT score 3 — extracting and confirming are different operations on the same span → score 2.\n\nScore 2 — Same passage region, different operation or different specificity.\nThe real answer and the target span are drawn from the same paragraph or closely connected sentences, but they extract different pieces of information. This includes:\n- One extracts a name, the other confirms existence (yes/no) of that same entity\n- One is a general version (\"are any cases cited?\"), the other is a specific instance of the same thing (\"was Reynolds cited?\")\n- Same entity, same general topic, but different attributes extracted\n\nScore 1 — Same named entity, unrelated facts.\nThe real answer and the target span both involve the same named character, place, or event — but they describe different facts about it. The answers would come from different sentences in the passage.\n\nScore 0 — No meaningful connection.\nThe real answer and the target span refer to different entities, different topics, or the connection is only at the level of grammatical form. This includes:\n- Different entities or topics entirely\n- Short vague questions (\"what?\", \"where?\") where the referents differ\n- Pairs where the only shared element is a pronoun that points to different people\n\n## Matching rules\n\n1. Work through the real questions one at a time (R1, R2, ...).\n2. For each real question, find the single best generated question by score.\n3. Once a generated question is matched, remove it from the pool — it cannot be matched again.\n4. If the best available match scores 0, report no pair for that real question.\n5. Only output pairs where the score is 1 or higher.\n\n## Calibration examples\n\nReal: \"are any cases cited?\"  Real answer: \"Yes\"\nGenerated: \"did the Court accept Jefferson's comments in Reynolds v. United States?\"  Target span: \"Reynolds v. United States (1879) — the Court wrote it may be accepted as an authoritative declaration\"\n→ Score 3. The real answer \"Yes\" and the target span both come from the Reynolds sentence. That sentence is what proves cases were cited, and is exactly what the generated question targets.\n\nReal: \"what court is discussed?\"  Real answer: \"Supreme Court\"\nGenerated: \"has Jefferson's wall of separation been cited by the Supreme Court?\"  Target span: \"cited repeatedly by the U.S. Supreme Court\"\n→ Score 2. Same span in the passage, but the real answer extracts the court's name while the target span frames it as a yes/no confirmation. Different operations on the same text.\n\nReal: \"from what year?\"  Real answer: \"1947\"\nGenerated: \"did Justice Black quote Jefferson about the wall of separation in 1947?\"  Target span: \"In Everson v. Board of Education (1947), Justice Hugo Black wrote...\"\n→ Score 2. Same passage sentence, but the real answer extracts the year while the target span frames it as a yes/no about a specific action. Different operations.\n\nReal: \"is a judge mentioned?\"  Real answer: \"Yes\"\nGenerated: \"did Justice Black quote Jefferson about the wall of separation in 1947?\"  Target span: \"Justice Hugo Black wrote: In the words of Thomas Jefferson...\"\n→ Score 2. Both answered yes, and from the same sentence. But \"is a judge mentioned?\" is a general existence check while the generated question targets a specific judge performing a specific action — different specificity.\n\nReal: \"how many?\"  Real answer: \"Reynolds v. United States\"\nGenerated: \"was the worship ban strictly enforced there?\"  Target span: \"The Dutch colony of New Netherland banned other worship\"\n→ Score 0. Target span is about the worship ban; real answer is a case name. Completely different parts of the passage.\n\nReal: \"Can anyone use this library?\"  Real answer: \"conditions for access\"\nGenerated: \"who can access it?\"  Target span: \"open to anyone who can document their qualifications and research needs\"\n→ Score 3. Real answer and target span both come from the same access-conditions sentence. Interchangeable questions.\n\nReal: \"what court is discussed?\"  Real answer: \"Supreme Court\"\nGenerated: \"who sits on the Supreme Court?\"  Target span: \"the justices are appointed by the President\"\n→ Score 1. Same named entity (Supreme Court), but the real answer and target span describe completely different facts about it.\n\n## Output format\n\nReturn ONLY valid JSON — no markdown, no preamble, no commentary outside the JSON.\n\n{\n  \"pairs\": [\n    {\n      \"real\": \"<exact text of the real question>\",\n      \"generated\": \"<exact text of the matched generated question>\",\n      \"score\": <1–3>\n    }\n  ]\n}"
        }
      },
      "type": "@n8n/n8n-nodes-langchain.agent",
      "typeVersion": 3.1,
      "position": [
        1872,
        992
      ],
      "id": "d935ab8f-7490-48ac-a285-6df2fb98bf05",
      "name": "AI Agent_3",
      "retryOnFail": true
    },
    {
      "parameters": {
        "jsCode": "const raw = $input.first().json.output;\nlet analysis;\ntry {\n  const cleaned = raw.replace(/```json\\n?|```/g, '').trim();\n  analysis = JSON.parse(cleaned);\n} catch(e) {\n  analysis = {\n    style: { avg_length: 'short', uses_ellipsis: true, uses_yes_no: true,\n             tone: 'conversational', example_q: '', yes_no_rate: '0.4' },\n    covered_facts: [],\n    candidate_spans: []\n  };\n}\n\nconst spans_text = (analysis.candidate_spans || []).map((s, i) =>\n  `${i+1}. Answer: \"${s.answer}\"\\n   Type: ${s.answer_type}\\n   Context: ${s.context}\\n   Momentum: ${s.momentum}`\n).join('\\n\\n');\n\nreturn [{\n  json: {\n    dialogue_passage:    $input.first().json.dialogue_passage,\n    qa_block_first_pt:   $input.first().json.qa_block_first_pt,\n    questions_first_pt:  $input.first().json.questions_first_pt,\n    questions_last_pt:   $input.first().json.questions_last_pt,\n    answers_last_pt:     $input.first().json.answers_last_pt,\n    split_pct:           $input.first().json.split_pct,\n    remaining_pct:       $input.first().json.remaining_pct,\n    n_first_pt:          $input.first().json.n_first_pt,\n    n_last_pt:           $input.first().json.n_last_pt,\n    total_questions:     $input.first().json.total_questions,\n    style:               JSON.stringify(analysis.style),\n    example_q:           analysis.style?.example_q || '',\n    yes_no_rate:         analysis.style?.yes_no_rate || '0.4',\n    spans_text:          spans_text,\n    n_spans:             (analysis.candidate_spans || []).length\n  }\n}];"
      },
      "id": "02b75cd2-1b9c-4de8-834b-7bd838824a20",
      "name": "Parse Spans",
      "type": "n8n-nodes-base.code",
      "position": [
        928,
        992
      ],
      "typeVersion": 2
    },
    {
      "parameters": {
        "jsCode": "const generatedQuestions = $input.first().json.output;\n\nreturn [{\n  json: {\n    total_questions_original:    $input.first().json.total_questions,\n    split_pct:                   $input.first().json.split_pct,\n    remaining_pct:               $input.first().json.remaining_pct,\n    questions_provided:          $input.first().json.n_first_pt,\n    questions_generated:         $input.first().json.n_last_pt,\n    questions_first_pt:          $input.first().json.questions_first_pt,\n    questions_generated_last_pt: generatedQuestions,\n    full_question_set:           $input.first().json.questions_first_pt + '\\n' + generatedQuestions\n  }\n}];"
      },
      "id": "d6038155-6317-4311-baa1-fd4b6171879c",
      "name": "Format Final Output",
      "type": "n8n-nodes-base.code",
      "position": [
        1456,
        992
      ],
      "typeVersion": 2
    },
    {
      "parameters": {
        "jsCode": "const strip = (text) =>\n  String(text || '')\n    .trim()\n    .split('\\n')\n    .map(line => line.trim().replace(/^\\d+[\\.\\)]\\s*/, '').trim())\n    .filter(line => line.length > 0);\n\nconst real_last_qs  = strip($('Compute Split').item.json.questions_last_pt);\nconst real_last_ans = strip($('Compute Split').item.json.answers_last_pt);\nconst generated_last = strip($input.first().json.questions_generated_last_pt);\n\nconst spans = String($('Parse Spans').item.json.spans_text || '')\n  .trim()\n  .split(/\\n\\n+/)\n  .map(s => s.trim())\n  .filter(s => s.length > 0);\n\nconst real_qa_labeled = real_last_qs.map((q, i) => {\n  const a = real_last_ans[i] || '?';\n  return `R${i + 1}: ${q}\\n    Answer: ${a}`;\n});\n\nconst generated_labeled = generated_last.map((q, i) => {\n  const span = spans[i] || '';\n  return `G${i + 1}: ${q}\\n    Target span: ${span}`;\n});\n\nreturn [{\n  json: {\n    total_questions_original:    $input.first().json.total_questions,\n    split_pct:                   $input.first().json.split_pct,\n    remaining_pct:               $input.first().json.remaining_pct,\n    questions_provided:          $input.first().json.questions_provided,\n    questions_first_pt:          $input.first().json.questions_first_pt,\n    questions_generated_last_pt: $input.first().json.questions_generated_last_pt,\n\n    n_real:                      real_last_qs.length,\n    n_generated:                 generated_last.length,\n    real_qa_labeled:             real_qa_labeled.join('\\n\\n'),\n    generated_questions_labeled: generated_labeled.join('\\n\\n')\n  }\n}];"
      },
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [
        1664,
        992
      ],
      "id": "b2c5fdff-5712-46d5-89b6-1c990dbe322f",
      "name": "Code in JavaScript"
    },
    {
      "parameters": {
        "operation": "xlsx",
        "options": {}
      },
      "type": "n8n-nodes-base.convertToFile",
      "typeVersion": 1.1,
      "position": [
        576,
        768
      ],
      "id": "a208bd41-c941-4fbc-9363-71c6f05cfec9",
      "name": "Convert to File2"
    }
  ],
  "connections": {
    "Start": {
      "main": [
        [
          {
            "node": "Edit Fields",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Edit Fields": {
      "main": [
        [
          {
            "node": "Read file",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Compute Split": {
      "main": [
        [
          {
            "node": "AI Agent_1",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Results1": {
      "main": [
        [
          {
            "node": "Convert to File2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "OpenRouter Chat Model1": {
      "ai_languageModel": [
        [
          {
            "node": "AI Agent_1",
            "type": "ai_languageModel",
            "index": 0
          }
        ]
      ]
    },
    "OpenRouter Chat Model2": {
      "ai_languageModel": [
        [
          {
            "node": "AI Agent_2",
            "type": "ai_languageModel",
            "index": 0
          }
        ]
      ]
    },
    "OpenRouter Chat Model3": {
      "ai_languageModel": [
        [
          {
            "node": "AI Agent_3",
            "type": "ai_languageModel",
            "index": 0
          }
        ]
      ]
    },
    "Read file": {
      "main": [
        [
          {
            "node": "Extract from File",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Extract from File": {
      "main": [
        [
          {
            "node": "Loop Over Items",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Loop Over Items": {
      "main": [
        [
          {
            "node": "Results1",
            "type": "main",
            "index": 0
          }
        ],
        [
          {
            "node": "Prepare Input",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Prepare Input": {
      "main": [
        [
          {
            "node": "Compute Split",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "AI Agent_1": {
      "main": [
        [
          {
            "node": "Parse Spans",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "AI Agent_2": {
      "main": [
        [
          {
            "node": "Format Final Output",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "AI Agent_3": {
      "main": [
        [
          {
            "node": "Loop Over Items",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Parse Spans": {
      "main": [
        [
          {
            "node": "AI Agent_2",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Format Final Output": {
      "main": [
        [
          {
            "node": "Code in JavaScript",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Code in JavaScript": {
      "main": [
        [
          {
            "node": "AI Agent_3",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  },
  "pinData": {},
  "meta": {
    "templateCredsSetupCompleted": true,
    "instanceId": "16ad688201c255ae80a8c3f9eaaa3c6f3cf9bb89d61949ff0d6dfc09f3d06d70"
  }
}
