### Flowchart: Workflow - Add to Knowledge Base - Document Processing and Ingestion

**Description:** This flowchart illustrates the automated process of ingesting new or updated documents into the Mcp Knowledge Base, including document fetching, text extraction, content analysis, structuring, quality assessment, and preparation for KB ingestion (with optional direct ingestion).

```mermaid
graph TD
    subgraph "Trigger & Validation"
        A["Trigger: Document Event (File System, DMS Webhook, Manual Upload, API)"] --> B("Input Data: Document URI, Source Type, Metadata, Event Type");
        B --> C{"Validate Event & Document (Format, Size, Accessibility)?"};
        C -- Invalid --> E_INVALID_DOC["Error Handling: Log Invalid Document/Event, Notify Source/Admin"];
        C -- Valid --> D["Log Validated Document Processing Request"];
    end

    subgraph "Document Fetching & Text Extraction"
        D --> F["Fetch Document Content from URI (using appropriate Source API/SDK)"];
        F -- Fetch Error --> E_FETCH_FAIL["Error Handling: Log Fetch Failure, Notify Admin"];
        F -- Fetch Success --> G["Perform Text Extraction (Call Text Extraction Service API - OCR if needed)"];
        G -- Extraction Error --> E_EXTRACT_FAIL["Error Handling: Log Extraction Failure, Potentially Escalate to HITL (Extraction Quality Review)"];
        G -- Extraction Success --> H("Extracted Text & Basic Structure (e.g., pages)");
    end

    subgraph "Content Analysis & Structuring (via Mcp Thinking Agent / NLU)"
        H --> I["Analyze Content (Call Mcp Thinking Agent/NLU API for Structure, Summary, Keywords, Q&A, PII, Categorization)"];
        I -- Analysis Error --> E_ANALYSIS_FAIL["Error Handling: Log Analysis Failure, Potentially Escalate to HITL (Content Review)"];
        I -- Analysis Success --> J("Analyzed Content: Structured Data, Summaries, Tags, PII Flags, Suggested KB Sections");
    end

    subgraph "Ingestion Mode & KB Interaction"
        J --> K{"Determine Ingestion Mode (New/Update)? Check Mcp KB API for Existing Entry (by ID/Title)"};
        K -- KB API Error --> E_KB_LOOKUP_FAIL["Error Handling: Log KB Lookup Failure, Proceed as New or Escalate"];
        K -- Existing Entry Found --> L_UPDATE_MODE("Ingestion Mode: Update/Replace Existing");
        K -- No Existing Entry --> L_NEW_MODE("Ingestion Mode: Create New");
        L_UPDATE_MODE --> M;
        L_NEW_MODE --> M;
    end

    subgraph "Content Chunking & Quality Assessment"
        M["Chunk Content for KB (Apply Chunking Strategy, Max Token Size)"] --> N("Content Chunks with Associated Metadata");
        N --> O{"Assess Quality & Check HITL Triggers (Extraction Score, NLU Confidence, PII Flags, Ambiguity)?"};
        O -- Needs Human Review (HITL Triggered) --> P_HITL["Route to Human Review Queue (KB_Content_Review_Queue) with Processed Data & Reason"];
        P_HITL --> Z_END_HITL_REVIEW(["End: Document Awaiting Human Review"]);
        O -- Cleared for Auto-Ingestion --> Q;
    end

    subgraph "KB Preparation & Optional Direct Ingestion"
        Q["Prepare Final Data Payload for Mcp Knowledge Base API (Entry Title, Tags, Sections, Chunks, Ingestion Mode)"] --> R("Formatted KB Ingestion Payload");
        R --> S{"Direct Ingest to KB Enabled (`direct_ingest_to_kb_after_processing`)?"};
        S -- Yes --> T["Call Mcp Knowledge Base API to Ingest/Update Entry"];
        T -- KB Ingestion Error --> E_KB_INGEST_FAIL["Error Handling: Log KB Ingestion Failure, Notify Admin, Potentially Requeue or Escalate to HITL"];
        T -- KB Ingestion Success --> U_INGEST_SUCCESS("KB Entry Successfully Ingested/Updated");
        U_INGEST_SUCCESS --> V;
        S -- No --> V;
        V["Log Final Processing Outcome (Success, Failed, Sent for Review, Ingested)"] --> Z_END_SUCCESS_KB_ADD(["End: Document Processed for KB"]);
    end

    subgraph "Error Terminations"
        E_INVALID_DOC --> Z_END_ERROR_KB_ADD(["End: Process Terminated Due to Error"]);
        E_FETCH_FAIL --> Z_END_ERROR_KB_ADD;
        E_EXTRACT_FAIL -- No HITL / Critical --> Z_END_ERROR_KB_ADD;
        E_ANALYSIS_FAIL -- No HITL / Critical --> Z_END_ERROR_KB_ADD;
        E_KB_LOOKUP_FAIL --> Z_END_ERROR_KB_ADD; # Or proceed with caution
        E_KB_INGEST_FAIL -- No Retry/HITL --> Z_END_ERROR_KB_ADD;
    end

    %% Styling (Optional)
    classDef default fill:#f9f9f9,stroke:#333,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef hitlNode fill:#f5e2d9,stroke:#c16f42,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef processingStep fill:#e6f3ff,stroke:#007bff,stroke-width:2px;

    class C,K,O,S decision;
    class P_HITL,Z_END_HITL_REVIEW hitlNode;
    class E_INVALID_DOC,E_FETCH_FAIL,E_EXTRACT_FAIL,E_ANALYSIS_FAIL,E_KB_LOOKUP_FAIL,E_KB_INGEST_FAIL,Z_END_ERROR_KB_ADD errorNode;
    class Z_END_SUCCESS_KB_ADD,U_INGEST_SUCCESS successNode;
    class F,G,I,M,Q,R,T processingStep;
```

**Key Elements Customized for Workflow - Add to Knowledge Base:**
*   **Document-Centric Trigger:** Starts with a document event.
*   **Multi-Stage Processing:** Clear stages for fetching, text extraction, content analysis, structuring, and quality control.
*   **External Service Integration:** Explicit calls to Text Extraction Service and Mcp Thinking Agent/NLU.
*   **KB API Interaction:** For checking existing entries and (optionally) direct ingestion.
*   **Content Chunking:** Specific step to prepare content for optimal KB indexing and retrieval.
*   **Quality Assessment & HITL:** Decision point for routing content to human review if quality thresholds are not met or issues are detected (e.g., PII).
*   **Configurable Direct Ingestion:** Option to either prepare data for a separate ingestion step or ingest directly into the Mcp KB.
*   **Detailed Logging:** Implied at each major step for traceability and debugging.

