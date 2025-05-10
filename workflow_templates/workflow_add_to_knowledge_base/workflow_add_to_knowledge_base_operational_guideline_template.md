## Operational Guideline: Workflow - Add to Knowledge Base

**Version:** 1.0 | **Last Updated:** 2025-05-10 | **Owner:** Knowledge Management Team / AI Content Team

**Section 1: Identity & Core Purpose**
   1.1. **Name/Identifier:** Workflow - Add to Knowledge Base
   1.2. **Primary User/Team:** This is an automated workflow, triggered by document events (file system changes, DMS webhooks) or manual submissions. It interacts with text extraction services, NLU/Thinking Agent, and the Mcp Knowledge Base API.
   1.3. **Core Mission/Overall Goal:** To automate the process of ingesting new or updated documents into the Mcp Knowledge Base. This involves fetching the document, extracting its content, analyzing and structuring the information (e.g., chunking, summarizing, tagging), and preparing it for efficient search and retrieval within the KB. The goal is to keep the KB current, accurate, and comprehensive with minimal manual effort.
   1.4. **Key Performance Indicators (KPIs) for Success:**
       - Percentage of supported documents successfully processed and ingested/updated: > 98%
       - Average time to process a document (from trigger to KB readiness/ingestion): < X minutes (e.g., 5 mins for a 10-page doc)
       - Accuracy of content extraction and structuring (vs. manual review): > 95%
       - Reduction in manual effort for KB updates: > 80%
       - Quality of generated summaries and tags (as rated by KM team or user feedback).

**Section 2: Foundational Knowledge & Context**
   2.1. **Link to Overall Business Master Prompt:** [Link to Company_Master_Prompt.md or central knowledge repository]
   2.2. **Specific Domain Knowledge Sources:**
       - Document Source APIs/SDKs (for accessing document content)
       - Text Extraction Service API (capabilities for different formats, OCR quality)
       - Mcp Thinking Agent / NLU Service (for document analysis models: summarization, keyword extraction, Q&A identification, structure parsing, PII detection)
       - Mcp Knowledge Base API (for existing entry lookup, ingestion requirements, schema)
       - Supported Document Formats List (internal config)
       - PII Detection Patterns KB (if PII handling is active)
       - KB Section Categorization Rules KB (logic for suggesting target KB sections).
   2.3. **Key Interacting Systems/Assistants:**
       - Document Source Systems (File Systems, DMS, S3, etc. - triggers the workflow)
       - Text Extraction Service API (for raw text and basic structure)
       - Mcp Thinking Agent API (or specialized NLU for content analysis)
       - Mcp Knowledge Base API (for checking existing entries and ingestion)
       - Human Review Queue System (for content flagged for review)
       - AirQ OS (if applicable, for secure document processing, hosting advanced analysis models, or managing the KB itself)

**Section 3: Operational Parameters & Task Definitions**
   3.1. **Primary Tasks & Responsibilities:**
       - **Task 1: Receive and Validate Document Event**
           - Description: Accept trigger event (e.g., new file, DMS webhook) with document URI and metadata.
           - Desired Outcome: Event validated, document URI confirmed, initial log created.
           - Key Steps: Parse event payload, check `document_uri`, `document_source_type`, `event_type`. Check if document format is in `Supported_Document_Formats_List`. Check against `max_document_size_mb_for_processing`.
       - **Task 2: Fetch Document Content**
           - Description: Retrieve the actual document from its source using `document_uri`.
           - Desired Outcome: Document content (binary or stream) is available for processing.
           - Key Steps: Use appropriate Document Source API/SDK based on `document_source_type`.
       - **Task 3: Perform Text Extraction**
           - Description: Convert document content into plain text, potentially with basic structural information (e.g., page numbers, headings if service supports).
           - Desired Outcome: Clean, usable text extracted from the document. Quality score if available.
           - Key Steps: Call Text Extraction Service API with document content. Enable OCR if `ocr_enabled_for_pdf_images` is true.
       - **Task 4: Content Analysis & Structuring (via Mcp Thinking Agent/NLU)**
           - Description: Analyze extracted text to identify structure, key information, generate summaries, tags, and prepare for chunking.
           - Desired Outcome: Enriched content with metadata, summaries, keywords, Q&A pairs (if applicable), and PII flags (if configured).
           - Key Steps: Send extracted text and `document_metadata` to Mcp Thinking Agent (or specialized NLU) for: document structure parsing, summarization (`auto_summarization_enabled`), keyword/tag generation (`auto_generate_tags_count`), Q&A extraction, PII detection (using `PII_Detection_Patterns_KB` and `pii_handling_action`), and suggestion of `target_kb_sections` (using `KB_Section_Categorization_Rules_KB`).
       - **Task 5: Determine Ingestion Mode & Check for Existing Entry**
           - Description: Decide if this is a new KB entry or an update to an existing one.
           - Desired Outcome: `ingestion_mode` ("create_new", "replace_existing_if_found_else_create", "update_specific_chunks") is determined.
           - Key Steps: If `event_type` is "document_updated" or `default_ingestion_mode_for_update_event` suggests, query Mcp Knowledge Base API using `document_id_in_source` or by matching `document_metadata.title` to find existing KB entry ID.
       - **Task 6: Chunk Content for KB**
           - Description: Divide the analyzed content into smaller, indexed chunks suitable for KB retrieval.
           - Desired Outcome: A list of content chunks, each with associated text, source location (page/section), and extracted metadata (keywords, summary snippet).
           - Key Steps: Apply `content_chunking_strategy` (e.g., by heading, paragraph, fixed token size `max_chunk_size_tokens_for_kb`).
       - **Task 7: Assess Quality & Determine Need for Human Review**
           - Description: Evaluate the quality of extraction and analysis to decide if automated ingestion is appropriate.
           - Desired Outcome: Document is either cleared for auto-ingestion or flagged for `human_review_queue_kb_content`.
           - Key Steps: Check text extraction quality score against `min_text_extraction_quality_score_for_auto_ingestion`. Check NLU confidence scores (if provided by Thinking Agent) against `trigger_on_low_content_analysis_confidence_score`. Check if PII was flagged and `pii_handling_action` is "flag_for_review". Check for ambiguous categorization or unsupported structures as per HITL config.
       - **Task 8: Prepare Data for KB Ingestion API / Direct Ingest**
           - Description: Format the processed chunks and metadata into the schema required by Mcp Knowledge Base API.
           - Desired Outcome: A complete payload ready for the KB.
           - Key Steps: Assemble JSON or other format with entry title, tags, target sections, content chunks, and ingestion mode.
           - (Optional) If `direct_ingest_to_kb_after_processing` is true and not flagged for review: Call Mcp Knowledge Base API to ingest/update the entry.
   3.2. **Input Triggers/Formats:**
       - File system events, DMS webhooks (JSON), manual upload API calls (multipart/form-data or JSON with document URI).
   3.3. **Expected Outputs/Formats (Internal state or to subsequent ingestion step):**
       - JSON object: `{"status": "processed_for_kb_ingestion" or "needs_human_review" or "failed_processing", "document_uri_processed": ..., "extracted_content_chunks": [...], "suggested_kb_entry_title": ..., "suggested_kb_tags": [...], "target_kb_sections_confirmed": [...], "ingestion_mode": ..., "error_code": ..., "reason_for_review": ...}`
   3.4. **Step-by-Step Process Overview (High-Level):**
       1. Document Event Triggered.
       2. Validate Event & Document Accessibility/Format/Size.
       3. Fetch Document.
       4. Extract Text (with OCR if needed).
       5. Analyze Content (Structure, Summaries, Tags, Q&A, PII - via Thinking Agent/NLU).
       6. Determine Ingestion Mode (New/Update).
       7. Chunk Content.
       8. Assess Quality & Check HITL Triggers.
       9. If Needs Review: Route to `human_review_queue_kb_content` with processed data.
       10. If Cleared: Prepare final data for Mcp KB. (Optional: Directly ingest into Mcp KB).
       11. Log Outcome.
   3.5. **Decision-Making Logic:**
       - Supported document formats and size limits.
       - Text extraction quality thresholds (`min_text_extraction_quality_score_for_auto_ingestion`).
       - NLU confidence scores for analysis tasks.
       - `pii_handling_action` (none, redact, flag).
       - Rules for `ingestion_mode` based on `event_type` and existing KB entry matching.
       - HITL triggers for various quality or ambiguity issues.

**Section 4: Communication Style & Tone**
   4.1. **Overall Tone:** Not applicable for direct end-user communication. Internal logging should be precise. Summaries generated for KB chunks should be objective and informative.
   4.2. **Specific Language Guidelines:** (For generated content like summaries, tags)
       - Summaries: Concise, neutral, accurately reflecting chunk content.
       - Tags/Keywords: Relevant, specific, consistent with existing KB taxonomy if possible.
   4.3. **Confirmation/Notification Practices:**
       - Logs processing status for each document.
       - May notify an admin or content owner if processing fails repeatedly or if a document is flagged for urgent review.
       - If `direct_ingest_to_kb_after_processing` is true, Mcp KB API response (success/failure of ingestion) should be logged.

**Section 5: Constraints & Boundaries (Obstructions)**
   5.1. **Explicit Prohibitions:**
       - MUST NOT attempt to process documents exceeding `max_document_size_mb_for_processing`.
       - MUST NOT process unsupported file formats (not in `Supported_Document_Formats_List`).
       - MUST NOT ingest content into KB that fails quality checks and is flagged for review, unless explicitly overridden by a human reviewer.
       - MUST adhere to `pii_handling_action` (e.g., not auto-ingest PII if policy is to flag/redact first).
   5.2. **Scope Limitations:**
       - Accuracy of text extraction depends on the Text Extraction Service and document quality/format.
       - Quality of content analysis (summaries, tags, etc.) depends on Mcp Thinking Agent/NLU models.
       - Does not typically handle complex document version control beyond simple replacement or new entry creation (advanced versioning is a DMS/KB feature).
       - Does not create the KB structure itself (sections, taxonomy); it populates existing structures.
   5.3. **Data Privacy & Security Rules:**
       - Document content can be highly sensitive and contain PII or confidential business information. Must be handled according to `Company_Sensitive_Data_Handling_Policy_v1.8.pdf`.
       - Securely manage credentials for document sources, text extraction, NLU, and KB APIs.
       - Temporary storage of documents during processing must be secure and cleaned up.
       - Comply with AirQ OS data security protocols if applicable, especially if processing sensitive documents or using AirQ for KB storage/analysis.
   5.4. **Operational Limits:**
       - Respect API rate limits of all integrated services.
       - Processing time per document should be monitored to avoid bottlenecks.

**Section 6: Error Handling & Escalation Procedures**
   6.1. **Common Error Scenarios & Codes:**
       - `ERR_DOC_SOURCE_UNAVAILABLE_OR_FORBIDDEN`: Cannot access `document_uri`.
       - `ERR_UNSUPPORTED_FILE_FORMAT_OR_SIZE`: Document type/size not allowed.
       - `ERR_TEXT_EXTRACTION_FAILED`: Text Extraction Service error.
       - `ERR_CONTENT_ANALYSIS_FAILED`: Mcp Thinking Agent/NLU error.
       - `ERR_KB_API_FAILED`: Mcp Knowledge Base API error (e.g., during existing entry check or direct ingestion).
       - `ERR_PII_REDACTION_FAILED`: If auto-redaction is configured and fails.
   6.2. **Automated Resolution Steps:**
       - For transient API errors: Retry according to service integration configurations.
       - If a specific analysis step fails (e.g., summarization but tagging works): Log partial success and potentially flag for review with details of what failed.
   6.3. **Escalation Path:**
       - Persistent failures to process documents from a specific source: Alert Knowledge Management Admin / System Admin.
       - High rate of documents being flagged for human review: Investigate quality of source documents, text extraction, or NLU models.
       - Critical API failures (Text Extraction, Thinking Agent, KB API): Alert respective service owners / AI Core Team.
       - Documents failing PII handling as configured: Escalate to Data Security Officer / KM Admin.

**Section 7: Human-in-the-Loop (HITL) Procedures (For Content Review)**
   7.1. **Criteria for Triggering HITL:** (As defined in Section 3.5, 3.7 and `hitl_config`)
       - Low text extraction quality score.
       - Low confidence from content analysis (NLU/Thinking Agent).
       - Ambiguous KB section categorization.
       - PII detected and `pii_handling_action` is "flag_for_review".
       - Unsupported document structure for automated chunking.
       - Manual trigger for review by a content author.
   7.2. **Information to Provide to Human Reviewer (Knowledge Manager, Content SME):**
       - `document_uri`, original `document_metadata`.
       - Extracted text (full or preview), with highlighted issues if possible.
       - Suggested content chunks, title, tags, target KB sections from automated processing.
       - Reason(s) why the document was flagged for review.
       - Locations of flagged PII (if applicable).
       - A UI to edit extracted text, chunks, metadata, and confirm/change target KB sections.
   7.3. **Process for Incorporating Human Feedback/Decision:**
       - Human reviewer validates/corrects extracted text, adjusts chunking, refines summaries/tags, confirms target KB sections, and approves for ingestion.
       - Reviewer can also reject the document for KB ingestion if unsuitable.
       - The system updates the processed data based on human input and then proceeds to (or triggers) KB ingestion.
   7.4. **Learning from HITL:**
       - Analyze HITL review patterns to identify common extraction errors, NLU misinterpretations, or areas where categorization rules need improvement.
       - Use feedback to fine-tune Text Extraction Service parameters, retrain NLU models in Mcp Thinking Agent, or update `KB_Section_Categorization_Rules_KB`.
       - Identify problematic document sources or formats that consistently require review.

**Section 8: Maintenance & Updates**
   8.1. **Update Frequency for these Guidelines:** Bi-annually, or as document sources, processing technologies (OCR, NLU), or KB ingestion requirements change.
   8.2. **Key Contacts for Issues/Updates:** Knowledge Management Team Lead, AI Content Team Lead, AI Core Team (for Thinking Agent/NLU), IT (for document sources).
   8.3. **Monitoring & Performance Review:** KPIs (Section 1.4) reviewed monthly/quarterly. Processing times, failure rates, HITL queue length, and quality of ingested content monitored.

**Section 9: Dependencies on Proprietary Systems (e.g., AirQ)**
   9.1. **Interaction with AirQ OS:** AirQ could host high-performance text extraction services, advanced NLU models for content analysis (especially for proprietary document types or complex information extraction), or even the Mcp Knowledge Base itself if it requires secure, high-throughput capabilities. AirQ might also manage the secure processing pipeline for sensitive documents.
   9.2. **Data Handling within AirQ:** Any document content, extracted text, or PII processed or stored within AirQ infrastructure must adhere to its most stringent data governance, encryption, access control, and audit logging policies, ensuring the confidentiality and integrity of the organization's knowledge assets.
