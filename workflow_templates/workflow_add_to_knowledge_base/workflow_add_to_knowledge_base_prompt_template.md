### Prompt Template: Workflow - Add to Knowledge Base - Process Document for KB Ingestion

**1. Objective/Goal of this Prompt:**
   - To instruct the "Add to Knowledge Base" workflow to process a newly added or updated document, extract relevant information, structure it, and prepare it for ingestion into the Mcp Knowledge Base.

**2. User/System Input Variables (Typically from a file system monitor, document management system webhook, or manual trigger):**
   - `{{document_source_type}}`: (Type of source, e.g., "file_system_event", "dms_webhook", "manual_upload", "api_submission")
   - `{{document_uri}}`: (URI or path to the document, e.g., "file:///path/to/new_policy_v3.pdf", "dms://doc_id=XYZ123", "s3://bucket/docs/faq_update.docx")
   - `{{document_id_in_source}}`: (Optional: Unique ID of the document in its source system, e.g., "XYZ123")
   - `{{document_type_hint}}`: (Optional: Hint about the document type, e.g., "policy_document", "faq_list", "product_manual", "meeting_minutes", "technical_specification", "plain_text_notes")
   - `{{document_metadata}}`: (Optional: Object containing metadata from the source, e.g., `{"title": "New Employee Onboarding Policy", "author": "HR Department", "version": "3.0", "last_modified_by": "jane.doe", "tags": ["hr", "policy", "onboarding"], "target_kb_sections": ["HR Policies", "New Hires"]}`)
   - `{{event_type}}`: ("document_added", "document_updated")
   - `{{trigger_timestamp}}`: (Timestamp of the event, e.g., "YYYY-MM-DDTHH:MM:SSZ")

**3. Contextual Instructions for AI (Add to Knowledge Base Workflow / Mcp Thinking Agent if involved in pre-processing):**
   - Desired Output Format: (Structured data ready for Mcp Knowledge Base ingestion, or a status indicating success/failure/needs_review.)
     - Example Output (Success): `{"status": "processed_for_kb_ingestion", "document_uri_processed": "{{document_uri}}", "extracted_content_chunks": [{"chunk_id": 1, "text_content": "...", "source_page_or_section": "Page 1", "keywords": ["onboarding", "first_day"], "summary": "..."}, ...], "suggested_kb_entry_title": "New Employee Onboarding Policy v3.0", "suggested_kb_tags": ["hr", "policy", "onboarding", "new_hire_procedure"], "target_kb_sections_confirmed": ["HR Policies", "New Hires"], "quality_score": 0.92, "ingestion_mode": "replace_or_create"}` (if `event_type` is `document_updated` and an existing KB entry is found based on `document_id_in_source` or title match)
     - Example Output (Needs Review): `{"status": "needs_human_review", "document_uri_processed": "{{document_uri}}", "reason_for_review": "Low confidence in content extraction or categorization.", "extracted_data_preview": { ... }, "suggested_actions": ["Verify extracted text accuracy", "Confirm target KB sections"]}`
     - Example Output (Failure): `{"status": "failed_processing", "document_uri_processed": "{{document_uri}}", "error_code": "UNSUPPORTED_FILE_FORMAT", "error_message": "Cannot process .xyz files."}`
   - Tone/Style: (Internal processing focus. If generating summaries, they should be objective and concise.)
   - Key information to focus on or exclude: (Prioritize accurate text extraction. Identify key sections, headings, Q&A pairs if FAQ. Extract or generate relevant keywords/tags. Determine if this is a new entry or an update to an existing one. Handle different document formats like PDF, DOCX, TXT, Markdown. Potentially identify PII and flag/redact if configured.)

**4. Example Usage (File system event for a new PDF):**
   - `document_source_type`: "file_system_event"
   - `document_uri`: "file:///mnt/shared_drive/hr_documents/New_PTO_Policy_2025.pdf"
   - `document_type_hint`: "policy_document"
   - `document_metadata`: `{"title": "Updated PTO Policy 2025", "department": "HR", "effective_date": "2025-01-01"}`
   - `event_type`: "document_added"
   - `trigger_timestamp`: "2025-05-10T20:15:00Z"

**5. Expected Output/Action:**
   - The "Add to Knowledge Base" Workflow will:
     1. Validate input parameters, especially `document_uri`.
     2. Log the incoming document processing request.
     3. Fetch/Access the document content from `document_uri`.
     4. Perform text extraction (e.g., using OCR for images in PDFs, text parsers for DOCX/TXT).
     5. (Optional) Pre-process text: Clean up, normalize, sentence segmentation, etc.
     6. Perform content analysis (potentially using Mcp Thinking Agent or specialized NLU models):
        - Identify document structure (headings, sections, tables).
        - Extract key phrases, topics, and entities.
        - Generate a summary of the document or key sections.
        - If `document_type_hint` is "faq_list", extract Q&A pairs.
        - Suggest relevant tags/keywords based on content and `document_metadata`.
        - Determine `target_kb_sections` based on content, metadata, or pre-defined rules.
     7. Determine `ingestion_mode`: If `event_type` is "document_updated", try to find a corresponding existing entry in Mcp Knowledge Base (e.g., by `document_id_in_source` or title matching) to suggest an update/replace. Otherwise, it's a new entry.
     8. Chunk the content into manageable pieces for KB indexing and retrieval, associating metadata with each chunk (source page, section, etc.).
     9. Assess processing quality. If confidence is low (e.g., poor text extraction, ambiguous categorization), flag for human review.
     10. Format the extracted and analyzed data into the structure required by the Mcp Knowledge Base ingestion API.
     11. Return a structured JSON output as described in "Desired Output Format". The actual ingestion into Mcp KB might be a subsequent step triggered by this output, or this workflow could directly call the Mcp KB ingestion API if configured.
     - For the example: `{"status": "processed_for_kb_ingestion", "document_uri_processed": "file:///mnt/shared_drive/hr_documents/New_PTO_Policy_2025.pdf", "extracted_content_chunks": [{"chunk_id": 1, "text_content": "Section 1: Eligibility...", ...}], "suggested_kb_entry_title": "Updated PTO Policy 2025", "suggested_kb_tags": ["hr", "policy", "pto", "leave"], "target_kb_sections_confirmed": ["HR Policies", "Employee Benefits"], "ingestion_mode": "create_new"}`
