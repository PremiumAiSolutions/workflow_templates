### Prompt Template: Mcp Thinking Agent - Determine Action/Route Request

**1. Objective/Goal of this Prompt:**
   - To instruct the Mcp Thinking Agent to analyze an incoming user request (text, voice transcript, or structured data from another system), understand its intent, extract relevant entities, and determine the most appropriate Mcp assistant, workflow, or human agent to handle it, or if the Thinking Agent can provide a direct answer.

**2. User/System Input Variables:**
   - `{{request_source}}`: (Identifier of the source system or channel, e.g., "Main_Assistant_UI", "Workflow_SMS_Inbound", "Mcp_Email_Inbound_Parser", "External_API_Call")
   - `{{request_id}}`: (Unique identifier for this specific request, e.g., "REQ-20250510-00123")
   - `{{user_id_or_session_id}}`: (Optional: Identifier for the user or session, e.g., "USER-007", "SESSION-ABCDE")
   - `{{user_context}}`: (Optional: Object containing relevant user context, e.g., `{"customer_id": "CUST-001", "previous_interaction_summary": "Asked about order status yesterday", "current_location_if_relevant": "New York"}`)
   - `{{input_modality}}`: ("text", "voice_transcript", "structured_data")
   - `{{input_data}}`: (The actual request content.)
     - If `input_modality` is "text" or "voice_transcript": `"Can you book a meeting with John Doe for next Tuesday at 2 PM regarding the new project?"`
     - If `input_modality` is "structured_data": `{"intent_suggestion": "schedule_meeting", "entities": {"attendee": "John Doe", "date_time_suggestion": "next Tuesday 2 PM", "topic": "new project"}, "original_source_data": { ... }}` (e.g., from a pre-processing step)
   - `{{preferred_language}}`: (Optional: User's preferred language, e.g., "en-US", "es-ES")
   - `{{available_mcps_and_workflows}}`: (Optional, can be dynamically fetched or pre-configured: A list or manifest of currently available Mcp assistants and workflows with their capabilities/triggers, e.g., `["McpCalendar:schedule_meeting,cancel_meeting", "McpInvoice:create_invoice,get_invoice_status", "Workflow_Order_Lookup:get_order_details"]`)

**3. Contextual Instructions for AI (Mcp Thinking Agent):**
   - Desired Output Format: (A structured JSON object detailing the recognized intent, extracted entities, confidence scores, and the recommended action/routing decision.)
     - Example Output (Route to Mcp): `{"request_id": "REQ-20250510-00123", "primary_intent": "schedule_meeting", "intent_confidence": 0.95, "extracted_entities": {"attendees": ["John Doe"], "datetime_expressions": ["next Tuesday at 2 PM"], "topic": "new project"}, "action_decision": "route_to_mcp", "target_mcp_or_workflow": "McpCalendar", "target_mcp_action_or_trigger": "schedule_meeting_task", "parameters_for_target": {"attendees": ["John Doe"], "datetime_suggestion": "2025-05-20T14:00:00", "subject": "Meeting: new project"}, "reasoning_log": ["Input identified as meeting scheduling request.", "McpCalendar is best suited."]}`
     - Example Output (Direct Answer): `{"request_id": "REQ-20250510-00124", "primary_intent": "query_company_address", "intent_confidence": 0.99, "action_decision": "direct_answer", "answer_content": "Our main office is located at 123 Main Street, Anytown, USA.", "source_of_answer": "Mcp_Knowledge_Base/company_info_faq"}`
     - Example Output (Escalate to Human): `{"request_id": "REQ-20250510-00125", "primary_intent": "complex_complaint", "intent_confidence": 0.80, "action_decision": "escalate_to_human", "target_queue": "customer_support_tier2", "escalation_reason": "Sensitive complaint requiring human empathy and investigation.", "summary_for_human": "User expressed strong dissatisfaction with recent service..."}`
   - Tone/Style: (Internally, analytical and precise. If generating a summary for human escalation, it should be objective and concise.)
   - Key information to focus on or exclude: (Prioritize accurate intent recognition. Perform robust entity extraction. Consider `user_context`. If multiple intents are detected, identify primary vs. secondary. Use `available_mcps_and_workflows` to make informed routing decisions. Log decision-making steps.)

**4. Example Usage (Text input from Main Assistant):**
   - `request_source`: "Main_Assistant_UI"
   - `request_id`: "REQ-MA-00789"
   - `user_id_or_session_id`: "USER-DavidT"
   - `user_context`: `{"customer_id": "CUST-00123", "active_project_id": "PROJ-XYZ"}`
   - `input_modality`: "text"
   - `input_data`: "What's the status of my invoice #INV-5678 and can I also get a copy of the proposal for project XYZ?"
   - `preferred_language`: "en-US"

**5. Expected Output/Action:**
   - The Mcp Thinking Agent will:
     1. Validate input parameters.
     2. Log the incoming request.
     3. Perform Natural Language Understanding (NLU) on `input_data` (if text/voice_transcript) to identify intent(s) and extract entities. Consider `user_context` and `preferred_language`.
     4. If `input_modality` is `structured_data`, validate and use the provided intent/entities, possibly refining them.
     5. Consult its knowledge of `available_mcps_and_workflows` and its internal decision-making logic (rules, models).
     6. Determine the best action:
        a. **Route to Mcp/Workflow:** If a specific Mcp or workflow can handle the primary intent. Formulate parameters for the target.
        b. **Direct Answer:** If the request is a simple query that the Thinking Agent can answer using its direct knowledge or a quick lookup (e.g., from a core FAQ in Mcp Knowledge Base).
        c. **Clarification Needed:** If the request is ambiguous, formulate a clarifying question to send back to the user (via the `request_source`).
        d. **Escalate to Human:** If the intent is complex, sensitive, requires empathy, or no Mcp can handle it.
        e. **Sequential Actions:** If multiple distinct tasks are identified (e.g., invoice status AND proposal copy), it might decide to handle them sequentially or create sub-tasks, potentially routing to different Mcps. (The example output above might simplify this to a primary action or suggest a multi-step plan if capable).
     7. Generate a structured JSON output as described in "Desired Output Format", including the decision, target, parameters, and reasoning.
     - For the example: It might identify two intents: "get_invoice_status" and "get_document_copy". It could decide to route to McpInvoice for the first, and McpKnowledgeBase (or a document management Mcp) for the second. The output might be a list of actions or a primary action with a note about the secondary request.
       Alternatively, a more sophisticated Thinking Agent might output: `{"request_id": "REQ-MA-00789", "action_decision": "multi_step_dispatch", "steps": [{"target_mcp_or_workflow": "McpInvoice", "target_mcp_action_or_trigger": "get_invoice_status_task", "parameters_for_target": {"invoice_id": "INV-5678", "customer_id": "CUST-00123"}}, {"target_mcp_or_workflow": "McpDocumentRetrieval", "target_mcp_action_or_trigger": "get_document_task", "parameters_for_target": {"document_type": "proposal", "project_id": "PROJ-XYZ", "customer_id": "CUST-00123"}}], "reasoning_log": ["Identified two distinct requests: invoice status and document retrieval."]}`
