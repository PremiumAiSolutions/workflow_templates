## Operational Guideline: Workflow - SMS Inbound

**Version:** 1.0 | **Last Updated:** 2025-05-10 | **Owner:** Customer Communications Team / Operations Team

**Section 1: Identity & Core Purpose**
   1.1. **Name/Identifier:** Workflow - SMS Inbound Processing
   1.2. **Primary User/Team:** This is an automated workflow, triggered by the SMS Gateway. It interacts with Mcp Thinking Agent, various Mcp functional assistants, and potentially human agents for escalations.
   1.3. **Core Mission/Overall Goal:** To efficiently process all incoming SMS messages, accurately determine sender intent, identify the sender if possible, and route the message to the appropriate Mcp assistant for automated handling or to a human agent queue for manual intervention. This workflow aims to ensure timely and relevant responses to SMS communications, manage opt-outs, and provide a seamless experience for SMS users.
   1.4. **Key Performance Indicators (KPIs) for Success:**
       - Percentage of SMS messages successfully routed to the correct Mcp/human queue: > 98%
       - Average time to process and route an incoming SMS (from gateway receipt to Mcp/human handoff): < X seconds (e.g., 15 seconds)
       - Intent recognition accuracy (by Mcp Thinking Agent for SMS): > 90%
       - Successful handling of standard keywords (STOP, HELP, INFO): 100%
       - Reduction in misrouted SMS messages requiring manual re-routing.

**Section 2: Foundational Knowledge & Context**
   2.1. **Link to Overall Business Master Prompt:** [Link to Company_Master_Prompt.md or central knowledge repository]
   2.2. **Specific Domain Knowledge Sources:**
       - SMS Gateway Provider API documentation (for understanding trigger payloads and capabilities)
       - CRM System (for sender identification via phone number)
       - Mcp Thinking Agent (for NLU models, intent definitions, entity extraction rules specific to SMS)
       - SMS Intent Recognition Rules KB (keywords, regex patterns, NLU model pointers)
       - Standard SMS Replies KB (templates for automated responses)
       - Opt-Out List DB (to manage STOP requests)
       - Company policies on SMS communication, PII handling, and TCPA/GDPR compliance (or relevant local regulations).
   2.3. **Key Interacting Systems/Assistants:**
       - SMS Gateway Provider (triggers the workflow)
       - CRM System API (for sender lookup)
       - Mcp Thinking Agent API (for intent recognition and routing decisions)
       - Mcp Knowledge Base API (for FAQ handling)
       - Mcp SMS Outbound Workflow API (for sending replies)
       - Various Mcp functional assistants (Mcp Calendar, Mcp Order Lookup, etc. - as determined by Mcp Thinking Agent)
       - Human Agent Queuing System (for escalations)
       - AirQ OS (if applicable, for secure message handling and intent processing infrastructure)

**Section 3: Operational Parameters & Task Definitions**
   3.1. **Primary Tasks & Responsibilities:**
       - **Task 1: Receive and Log Incoming SMS**
           - Description: Accept the incoming SMS payload from the SMS Gateway.
           - Desired Outcome: SMS message details (sender, recipient, body, timestamp, message ID) are captured and logged.
           - Key Steps: Parse gateway webhook payload, validate essential fields, create initial log entry.
       - **Task 2: Identify Sender (If Possible)**
           - Description: Attempt to match the `sender_phone_number` with a known contact in the CRM.
           - Desired Outcome: Sender identified as a known customer/contact, or flagged as unknown. Customer context retrieved if known.
           - Key Steps: Query CRM System API with `sender_phone_number` (normalized format).
       - **Task 3: Handle Standard Keywords (STOP, HELP, INFO)**
           - Description: Check for and process predefined keywords that require immediate, standard actions.
           - Desired Outcome: Opt-outs processed, help/info messages sent, and processing stops for these keywords.
           - Key Steps: Match `sms_message_body` against `supported_keywords_auto_handle`. If "STOP", update Opt-Out List DB and (if configured) send confirmation via Mcp SMS Outbound. If "HELP" or "INFO", retrieve standard reply from Standard SMS Replies KB and send via Mcp SMS Outbound.
       - **Task 4: Perform Intent Recognition & Entity Extraction**
           - Description: If not a standard keyword, pass the `sms_message_body` (and sender context if known) to the Mcp Thinking Agent for NLU.
           - Desired Outcome: A primary intent, confidence score, and any extracted entities (e.g., order number, date, name) are returned.
           - Key Steps: Call Mcp Thinking Agent API with SMS content and relevant context (e.g., known customer status).
       - **Task 5: Route Based on Intent (Decision Logic)**
           - Description: Based on the recognized intent and confidence, decide the next action (route to Mcp, send auto-reply, escalate).
           - Desired Outcome: The SMS is directed to the most appropriate handler.
           - Key Steps:
             - If intent confidence > `intent_confidence_threshold_for_mcp_routing` and a clear Mcp target is identified by Thinking Agent: Route to the specified Mcp assistant API with original SMS details and extracted entities.
             - If intent is FAQ-like and Mcp KB can handle: Route to Mcp Knowledge Base API.
             - If intent confidence is low, or intent is "unknown_intent", or `unknown_sender_escalation_policy` dictates: Escalate to `human_escalation_queue_sms`.
             - If multiple conflicting high-confidence intents: Escalate to HITL (if configured).
       - **Task 6: Send Acknowledgement/Holding Message (If Configured)**
           - Description: If processing might take time or if escalating, send an acknowledgement.
           - Desired Outcome: Sender is informed their message is received.
           - Key Steps: Use Mcp SMS Outbound to send a pre-defined message from Standard SMS Replies KB.
   3.2. **Input Triggers/Formats:**
       - Webhook from SMS Gateway (typically JSON payload with sender, recipient, message body, timestamp, message ID).
   3.3. **Expected Outputs/Formats (Internal Action Objects):**
       - Object instructing the next step: `{"action_type": "route_to_mcp", "target_mcp": "McpName", ...}`
       - Object instructing SMS reply: `{"action_type": "send_sms_reply", "recipient_phone_number": ..., "reply_message_body": ...}`
       - Object instructing escalation: `{"action_type": "escalate_to_human", "queue_id": ..., ...}`
   3.4. **Step-by-Step Process Overview (High-Level):**
       1. SMS Received from Gateway.
       2. Log SMS.
       3. Identify Sender (CRM Lookup).
       4. Check for Standard Keywords (STOP, HELP, INFO). If match, process and exit.
       5. Perform Intent Recognition (via Mcp Thinking Agent).
       6. Evaluate Intent Confidence & Routing Rules.
       7. Route to appropriate Mcp Assistant, Mcp KB, or Human Escalation Queue.
       8. Send Acknowledgement if needed.
       9. Log final action taken.
   3.5. **Decision-Making Logic:**
       - Priority to standard keywords (STOP, HELP).
       - Relies heavily on Mcp Thinking Agent for intent classification and entity extraction.
       - Uses `intent_confidence_threshold_for_mcp_routing` to decide between automated Mcp routing and human escalation.
       - `unknown_sender_escalation_policy` guides handling of messages from unrecognized numbers.
       - HITL rules for ambiguous cases from Thinking Agent.

**Section 4: Communication Style & Tone (For any automated replies)**
   4.1. **Overall Tone:** Concise, professional, helpful, and compliant with SMS best practices (e.g., character limits, clarity).
   4.2. **Specific Language Guidelines:**
       - STOP confirmation: Clear confirmation of opt-out.
       - HELP/INFO: Provide requested information succinctly or direct to a web page.
       - Acknowledgements: Brief and reassuring.
   4.3. **Confirmation/Notification Practices:**
       - Confirm STOP requests if legally required or configured.
       - Acknowledge receipt if immediate processing isn't possible.

**Section 5: Constraints & Boundaries (Obstructions)**
   5.1. **Explicit Prohibitions:**
       - MUST NOT send promotional messages in response to an inbound SMS unless the inbound SMS explicitly opted into such promotions.
       - MUST strictly honor STOP requests and update the Opt-Out List DB immediately.
       - MUST NOT attempt to re-engage a user who has sent "STOP" unless they send "START" or a similar opt-in keyword.
       - MUST NOT process messages from numbers on a global blocklist (if maintained).
   5.2. **Scope Limitations:**
       - This workflow is primarily for routing and initial handling. Complex conversations or transactions are handed off to specialized Mcp assistants or humans.
       - Does not typically handle MMS (multimedia messages) unless the SMS Gateway and Thinking Agent are configured for it.
       - NLU accuracy is dependent on the Mcp Thinking Agent and its training.
   5.3. **Data Privacy & Security Rules:**
       - SMS message content can contain PII and must be handled according to `Company_PII_Handling_Policy_v2.1.pdf`.
       - Sender phone numbers are PII.
       - Securely manage credentials for CRM and other integrated APIs.
       - Comply with AirQ OS data security protocols if applicable, especially for message content and sender PII.
       - Adhere to TCPA, GDPR, and other relevant communication regulations.
   5.4. **Operational Limits:**
       - Respect API rate limits of Mcp Thinking Agent, CRM, and other Mcp assistants.
       - Be mindful of SMS Gateway rate limits for any replies sent via Mcp SMS Outbound.

**Section 6: Error Handling & Escalation Procedures**
   6.1. **Common Error Scenarios & Codes:**
       - `ERR_SMS_GATEWAY_PAYLOAD_INVALID`: Incoming data from gateway is malformed.
       - `ERR_CRM_LOOKUP_FAILED`: Cannot connect to CRM or phone number not found (not an error if unknown sender is expected).
       - `ERR_THINKING_AGENT_FAILED`: Mcp Thinking Agent API error or timeout.
       - `ERR_MCP_ROUTING_TARGET_UNAVAILABLE`: Target Mcp assistant API is down.
       - `ERR_OPT_OUT_DB_UPDATE_FAILED`: Could not record STOP request.
   6.2. **Automated Resolution Steps:**
       - For API unavailability (Thinking Agent, Mcp targets): Retry according to configuration.
       - If Thinking Agent fails consistently: Escalate to a default human queue with the raw SMS.
   6.3. **Escalation Path:**
       - If intent confidence is below `trigger_on_intent_confidence_below_threshold` (from HITL config): Escalate to `human_escalation_queue_sms`.
       - If Mcp Thinking Agent returns "unknown_intent" or conflicting intents: Escalate to `human_escalation_queue_sms`.
       - If `unknown_sender_escalation_policy` dictates immediate escalation for unknown senders: Escalate.
       - Persistent processing failures: Escalate to Communications Systems Support / IT.

**Section 7: Human-in-the-Loop (HITL) Procedures (For routing decisions)**
   7.1. **Criteria for Triggering HITL:** (As defined in Section 6.3 and HITL configuration)
       - Low intent confidence from Mcp Thinking Agent.
       - "Unknown intent" identified by Thinking Agent.
       - Multiple high-confidence conflicting intents.
       - Specific complex patterns that are pre-configured for human review.
   7.2. **Information to Provide to Human Reviewer (e.g., Tier 1 SMS Support):**
       - Original SMS message ID, sender phone number, full SMS message body.
       - Identified customer details from CRM (if any).
       - Output from Mcp Thinking Agent (intents, entities, confidence scores).
       - Timestamp of receipt.
   7.3. **Process for Incorporating Human Feedback/Decision:**
       - Human agent reviews the SMS and Thinking Agent output, then manually categorizes the intent and/or routes the SMS to the correct Mcp assistant or handles it directly.
       - The system should allow the human agent to trigger actions (e.g., "Route to McpCalendar with these parameters", "Send this manual reply via Mcp SMS Outbound").
   7.4. **Learning from HITL:**
       - Analyze HITL instances to identify patterns of misclassification or new intents.
       - Use insights to update `SMS_Intent_Recognition_Rules_KB`, retrain NLU models in Mcp Thinking Agent, or add new standard replies.
       - Identify common queries from unknown senders that could be automated.

**Section 8: Maintenance & Updates**
   8.1. **Update Frequency for these Guidelines:** Quarterly, or as SMS gateway capabilities, Mcp Thinking Agent models, or communication regulations change.
   8.2. **Key Contacts for Issues/Updates:** Customer Communications Team Lead, AI Development Team (for Thinking Agent), Operations Team.
   8.3. **Monitoring & Performance Review:** KPIs (Section 1.4) reviewed weekly/monthly. Intent recognition accuracy, escalation rates, and processing times monitored continuously.

**Section 9: Dependencies on Proprietary Systems (e.g., AirQ)**
   9.1. **Interaction with AirQ OS:** The Mcp Thinking Agent, if performing complex NLU for SMS intent, might run on AirQ infrastructure for performance and scalability. AirQ could also provide a secure environment for managing the SMS message queue and ensuring reliable delivery to the Thinking Agent or other Mcps.
   9.2. **Data Handling within AirQ:** SMS content and associated PII, if processed through AirQ, must adhere to its highest standards for data security, encryption, and access control, especially given the personal nature of SMS communications.
