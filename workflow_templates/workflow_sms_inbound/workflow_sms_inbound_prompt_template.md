### Prompt Template: Workflow - SMS Inbound - Process Incoming SMS

**1. Objective/Goal of this Prompt:**
   - To instruct the SMS Inbound Workflow to process a newly received SMS message, determine its intent, and route it for appropriate action or response, potentially engaging other Mcp assistants.

**2. User/System Input Variables (Typically from SMS Gateway/Platform):**
   - `{{sender_phone_number}}`: (The phone number of the person who sent the SMS, e.g., "+15551234567")
   - `{{recipient_phone_number}}`: (The company's phone number that received the SMS, e.g., "+1800COMPANY")
   - `{{sms_message_body}}`: (The text content of the SMS, e.g., "Hi, I need to reschedule my appointment.", "INFO", "STOP")
   - `{{received_timestamp}}`: (Timestamp of when the SMS was received, e.g., "YYYY-MM-DDTHH:MM:SSZ")
   - `{{message_id}}`: (Unique identifier for the SMS message from the gateway, e.g., "SM_xxxxxxxxxxxxxxx")
   - `{{country_code}}`: (Optional: Country code of the sender, e.g., "US")

**3. Contextual Instructions for AI (SMS Inbound Workflow / Mcp Thinking Agent):**
   - Desired Output Format: (An action to be taken, e.g., route to Mcp Calendar, route to Mcp Knowledge Base for FAQ, send automated reply, escalate to human agent, log interaction. Output should include a status and any relevant data for the next step.)
     - Example Output: `{"action_type": "route_to_mcp", "target_mcp": "McpCalendar", "original_request": { ...input_variables... }, "parsed_intent": "reschedule_appointment", "extracted_entities": {"appointment_id": "APP-123"}}`
     - Example Output: `{"action_type": "send_sms_reply", "recipient_phone_number": "{{sender_phone_number}}", "reply_message_body": "Thank you for your message. We will process your request shortly."}`
     - Example Output: `{"action_type": "escalate_to_human", "queue_id": "sms_support_queue", "original_request": { ...input_variables... }, "reason": "Complex query"}`
   - Tone/Style: (Internally, this is about efficient processing. If generating an immediate auto-reply, the tone should be professional and helpful.)
   - Key information to focus on or exclude: (Prioritize intent recognition. Identify keywords like "STOP", "HELP", "INFO". Extract key entities like appointment IDs, order numbers, question keywords. Determine if the sender is a known customer by looking up `{{sender_phone_number}}` in CRM.)

**4. Example Usage (Incoming SMS):**
   - `sender_phone_number`: "+12025550123"
   - `recipient_phone_number`: "+1800COMPANY"
   - `sms_message_body`: "I want to check the status of my order #ORD5678"
   - `received_timestamp`: "2025-05-10T20:10:00Z"
   - `message_id`: "SM_abcdef123456"

**5. Expected Output/Action:**
   - The SMS Inbound Workflow (potentially via Mcp Thinking Agent) will:
     1. Validate input parameters.
     2. Log the incoming SMS message.
     3. Attempt to identify the sender by looking up `{{sender_phone_number}}` in the CRM or customer database.
     4. Parse `{{sms_message_body}}` for intent and entities (e.g., using NLU, keyword matching, regex).
        - Handle standard keywords: "STOP" (opt-out), "HELP" (provide help info), "INFO" (provide company info).
     5. Based on intent:
        a. If opt-out ("STOP"): Record opt-out, send confirmation if required by regulations.
        b. If help/info request: Formulate and send a standard reply (possibly via Mcp SMS Outbound workflow).
        c. If transactional (e.g., order status, reschedule appointment): Extract relevant entities, identify the appropriate Mcp assistant (e.g., Mcp Order, Mcp Calendar), and route the request to that Mcp along with sender details and extracted information.
        d. If a general query: Route to Mcp Knowledge Base for an answer. If no answer, or complex, escalate to a human agent queue.
        e. If unrecognized intent: Send a polite acknowledgement and escalate to a human agent queue.
     6. Return an action object detailing the next step (e.g., route to Mcp, send reply, escalate).
     - Example for the above: `{"action_type": "route_to_mcp", "target_mcp": "McpOrderLookup", "original_request": { ...input_variables... }, "parsed_intent": "order_status_query", "extracted_entities": {"order_number": "ORD5678"}, "customer_identified": true, "customer_id": "CUST-00456"}`
