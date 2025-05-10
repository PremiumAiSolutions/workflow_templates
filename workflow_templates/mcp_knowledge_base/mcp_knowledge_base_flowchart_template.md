### Flowchart: Mcp Knowledge Base - Query & Ingestion Process

**Description:** This flowchart illustrates the two primary processes of the Mcp Knowledge Base: 1) Handling user queries for information retrieval, and 2) Ingesting new or updated documents into the knowledge base.

```mermaid
graph TD
    subgraph "Process 1: Information Query & Retrieval"
        A_QUERY["Trigger: User/System Query (e.g., via Main Assistant, API call)"] --> B_QUERY("Input Data: Query Text, Filters (optional), Max Results, Response Format Preference");
        B_QUERY --> C_QUERY["Parse & Validate Query"];
        C_QUERY -- Valid --> D_QUERY["Formulate Search Strategy (Semantic/Keyword/Hybrid)"];
        C_QUERY -- Invalid --> E_QUERY["Error Handling: Return 'Invalid Query' / Request Clarification"];
        D_QUERY --> F_QUERY["Execute Search against Vector Database Service"];
        F_QUERY --> G_QUERY["Retrieve Ranked Document IDs/Chunks"];
        G_QUERY -- Results Found --> H_QUERY["Fetch Full Content/Snippets for Ranked Results"];
        G_QUERY -- No Results --> I_QUERY["Return 'No Information Found' / Suggest Query Refinement"];
        H_QUERY --> J_QUERY["Process Results with NLP Service (e.g., Summarization, Answer Extraction)"];
        J_QUERY --> K_QUERY["Format Response (with Sources/Citations) based on Preference"];
        K_QUERY --> L_QUERY["Return Formatted Answer to Requester"];
    end

    subgraph "Process 2: Content Ingestion (via 'Workflow - Add to Knowledge Base')"
        A_INGEST["Trigger: New/Updated Document Detected in Staging Area / Direct Submission via API (via 'Workflow - Add to KB')"] --> B_INGEST("Input Data: Document File, Metadata (optional)");
        B_INGEST --> C_INGEST["Validate Document (File Type, Size)"];
        C_INGEST -- Valid --> D_INGEST["Send Document to Document Parser Service"];
        C_INGEST -- Invalid --> E_INGEST["Error Handling: Log Error, Quarantine File, Notify Knowledge Manager"];
        D_INGEST --> F_INGEST["Receive Parsed Text & Extracted Metadata"];
        F_INGEST --> G_INGEST["Generate Embeddings using NLP Service"];
        G_INGEST --> H_INGEST["Store Document Original (Optional, if not already stored) & Metadata"];
        H_INGEST --> I_INGEST["Store Text Chunks & Embeddings in Vector Database Service (Primary_Vector_Store)"];
        I_INGEST --> J_INGEST["Update Search Index (if applicable, or handled by Vector DB)"];
        J_INGEST --> K_INGEST["Log Successful Ingestion & Notify (e.g., Knowledge Manager, original submitter)"];
        D_INGEST -- Parsing Failed --> E_INGEST;
        G_INGEST -- Embedding Failed --> E_INGEST;
        I_INGEST -- Storage Failed --> E_INGEST;
    end

    subgraph "Shared Services & Error Paths"
        L_QUERY --> Z_QUERY_END(["End: Query Process Complete"]);
        E_QUERY --> Z_QUERY_END;
        I_QUERY --> Z_QUERY_END;
        K_INGEST --> Z_INGEST_END(["End: Ingestion Process Complete"]);
        E_INGEST --> Z_INGEST_END;
    end

    %% Styling (Optional)
    classDef queryProcess fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef ingestProcess fill:#e9f5e9,stroke:#28a745,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;

    class A_QUERY,B_QUERY,C_QUERY,D_QUERY,F_QUERY,G_QUERY,H_QUERY,J_QUERY,K_QUERY,L_QUERY queryProcess;
    class A_INGEST,B_INGEST,C_INGEST,D_INGEST,F_INGEST,G_INGEST,H_INGEST,I_INGEST,J_INGEST,K_INGEST ingestProcess;
    class E_QUERY,I_QUERY,E_INGEST errorNode;
```

**Key Elements Customized for Mcp Knowledge Base:**
*   **Two Main Processes:** Clearly distinguishes between information retrieval (querying) and content ingestion.
*   **Query Process Trigger:** User/system queries.
*   **Query Input Data:** Natural language query, optional filters, result limits, format preferences.
*   **Query Validation:** Basic checks on query structure or length.
*   **Query Decision/Action:** Involves search strategy (semantic/keyword), interaction with Vector DB and NLP services.
*   **Query Output:** Formatted answers with sources.
*   **Ingestion Process Trigger:** New/updated documents, often managed by the "Workflow - Add to Knowledge Base".
*   **Ingestion Input Data:** Document files and metadata.
*   **Ingestion Validation:** File type and size checks.
*   **Ingestion Actions:** Document parsing, embedding generation, storage in Vector DB, index updates.
*   **Ingestion Output:** Confirmation of successful ingestion or error details.
*   **Error Handling:** Specific error paths for both query and ingestion processes, including notifications to relevant parties (e.g., Knowledge Manager).
*   **Shared Services:** Highlights reliance on Document Parser, NLP Service, and Vector Database Service.

