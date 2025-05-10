### Flowchart: Mcp Thinking Agent - Request Analysis and Routing Decision

**Description:** This flowchart illustrates the process by which the Mcp Thinking Agent analyzes an incoming request, determines intent and entities, and decides on the appropriate action (route to Mcp, direct answer, clarify, or escalate).

```mermaid
graph TD
    subgraph "Request Ingestion & Initial Processing"
        A["Trigger: Request for Analysis (from Main Assistant, SMS/Email Inbound, etc.)"] --> B("Input Data: Request Source, Request ID, User Context, Input Modality, Input Data, Preferred Language, Available Mcps");
        B --> C["Validate Input Parameters & Log Initial Request"];
        C -- Invalid --> E_INVALID_REQ_TA["Error Handling: Log Invalid Request, Notify Triggering System"];
        C -- Valid --> D;
    end

    subgraph "NLU & Contextualization"
        D{"Input Modality?"};
        D -- "text"/"voice_transcript" --> NLU_PROC["Perform NLU: Call NLU Service Provider API (Input Data, Language, Context)"];
        D -- "structured_data" --> NLU_STRUCT("Use Provided Intent/Entities, Optionally Refine with NLU Service");
        NLU_PROC -- NLU Error --> E_NLU_FAIL["Error Handling: Log NLU Failure, Potentially Escalate to HITL (NLU Critical Failure)"];
        NLU_PROC -- NLU Success --> NLU_OUT("NLU Output: Intent(s), Confidence Score(s), Extracted Entities");
        NLU_STRUCT --> NLU_OUT;
        NLU_OUT --> CTX_AUG{Augment with User Context? (User Context Service API)};
        CTX_AUG -- Yes --> CTX_CALL["Call User Context Service API"];
        CTX_CALL -- Context Error --> CTX_DONE("Context Augmentation Skipped/Failed, Proceed with Available Context");
        CTX_CALL -- Context Success --> CTX_DATA("Enriched User Context Available");
        CTX_DATA --> DECISION_INPUT;
        CTX_DONE --> DECISION_INPUT;
        CTX_AUG -- No --> DECISION_INPUT;
    end

    subgraph "Decision Making Core"
        DECISION_INPUT["Input to Decision Engine: NLU Output, User Context, Mcp/Workflow Manifest, Routing Rules"] --> DM1["Consult Mcp/Workflow Manifest (from Mcp KB API) & Intent Routing Rules Engine KB"];
        DM1 --> DM2{Primary Intent & Confidence vs. Thresholds?};
        DM2 -- Direct Answer Possible? (High Confidence & FAQ Match in Direct Answer KB) --> DA1["Formulate Direct Answer from KB"];
        DA1 --> DA_OUT(["Output: Action=Direct Answer, Answer Content, Source"]);

        DM2 -- Route to Mcp/Workflow Possible? (High Confidence & Clear Target) --> RT1["Identify Target Mcp/Workflow & Action"];
        RT1 --> RT2["Prepare Parameters for Target Mcp/Workflow"];
        RT2 --> RT_OUT(["Output: Action=Route to Mcp, Target Mcp, Target Action, Parameters"]);

        DM2 -- Multi-Intent Detected? (`enable_multi_intent_detection`) --> MI1{"Apply Multi-Intent Handling Strategy (`multi_intent_handling_strategy`)"};
        MI1 -- "primary_then_secondary_sequential_suggestion" --> MI_SEQ(["Output: Action=Multi-Step Dispatch, List of Sequential Steps (Target Mcp, Action, Params for each)"]);
        MI1 -- "ask_user_to_choose" --> CLARIFY_MULTI_INTENT(["Output: Action=Clarification Needed, Clarification Question (Choose Intent)"]);
        MI1 -- "primary_only" --> RT1; # Treat primary as single intent for routing

        DM2 -- Clarification Needed? (Confidence in `clarification_prompt_threshold_confidence_range` or Ambiguous) --> CL1["Formulate Clarification Question"];
        CL1 --> CL_OUT(["Output: Action=Clarification Needed, Clarification Question"]);

        DM2 -- Low Confidence / No Clear Target / Sensitive Intent --> ESC1["Determine Escalation Target Queue & Reason"];
        ESC1 --> ESC2["Prepare Summary for Human Agent"];
        ESC2 --> ESC_OUT(["Output: Action=Escalate to Human, Target Queue, Reason, Summary"]);
    end

    subgraph "Output Generation & Error Paths"
        DA_OUT --> F_OUT;
        RT_OUT --> F_OUT;
        MI_SEQ --> F_OUT;
        CLARIFY_MULTI_INTENT --> F_OUT;
        CL_OUT --> F_OUT;
        ESC_OUT --> F_OUT;
        F_OUT["Generate Final Structured JSON Output (including Reasoning Log)"] --> Z_END_TA_SUCCESS(["End: Thinking Agent Processing Complete, Decision Returned to Triggering System"]);

        E_INVALID_REQ_TA --> Z_END_TA_ERROR(["End: Process Terminated Due to Error"]);
        E_NLU_FAIL -- HITL Escalation for NLU Critical Failure --> ESC1;
        E_NLU_FAIL -- No HITL / Non-Critical --> Z_END_TA_ERROR;
    end

    %% Styling (Optional)
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef humanEsc fill:#f5e2d9,stroke:#c16f42,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef nluProc fill:#e2f0d9,stroke:#5a8f22,stroke-width:2px;

    class D,DM2,CTX_AUG,MI1 decision;
    class E_NLU_FAIL,E_INVALID_REQ_TA errorNode;
    class DA_OUT,RT_OUT,MI_SEQ,CLARIFY_MULTI_INTENT,CL_OUT,ESC_OUT,Z_END_TA_SUCCESS successNode;
    class NLU_PROC,NLU_STRUCT,NLU_OUT nluProc;
```

**Key Elements Customized for Mcp Thinking Agent:**
*   **NLU Core:** Central block for Natural Language Understanding (Intent Recognition, Entity Extraction).
*   **Context Augmentation:** Optional step to fetch and use richer user context.
*   **Mcp/Workflow Manifest & Routing Rules:** Consultation of knowledge sources to inform decisions.
*   **Multiple Decision Paths:** Clear branches for Direct Answer, Route to Mcp, Multi-Intent Handling, Clarification, and Human Escalation.
*   **Confidence Thresholds:** Explicit use of confidence scores to guide decision logic.
*   **Structured Output:** Emphasis on generating a detailed JSON output for the calling system.
*   **Reasoning Log:** Inclusion of a reasoning log to explain the agent's decision process.
*   **HITL Integration:** Points where Human-in-the-Loop can be triggered for NLU failures or ambiguous routing.

