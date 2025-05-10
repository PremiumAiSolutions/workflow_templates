## Operational Guideline: Workflow - SMS Outbound

**Version:** 1.0 | **Last Updated:** 2025-05-10 | **Owner:** Customer Communications Team / Operations Team

**Section 1: Identity & Core Purpose**
   1.1. **Name/Identifier:** Workflow - SMS Outbound Sending
   1.2. **Primary User/Team:** This is an automated workflow, triggered by other Mcp assistants (e.g., McpCalendar, McpInvoice, McpEstimate), the SMS Inbound Workflow (for replies), or system event triggers.
   1.3. **Core Mission/Overall Goal:** To reliably and efficiently send templated or dynamically generated SMS messages to specified recipients via the configured SMS gateway. This workflow ensures messages are sent from the correct sender ID, adhere to compliance rules (like opt-out checks for marketing messages), and that sending attempts and outcomes are logged.
   1.4. **Key Performance Indicators (KPIs) for Success:**
       - SMS send success rate (submitted to gateway): > 99.8%
       - SMS delivery rate (as reported by gateway, if available): > 95%
       - Average time to submit SMS to gateway (from trigger): < X seconds (e.g., 5 seconds)
       - Compliance with opt-out lists for applicable message types: 100%
       - Accuracy of sender ID usage based on `sender_phone_number_id`.

**Section 2: Foundational Knowledge & Context**
   2.1. **Link to Overall Business Master Prompt:** [Link to Company_Master_Prompt.md or central knowledge repository]
   2.2. **Specific Domain Knowledge Sources:**
       - SMS Gateway Provider API documentation (for send message API, error codes, delivery reports)
       - CRM System (for opt-out status lookup)
       - Sender Phone Number Mapping KB (to resolve `sender_phone_number_id` to actual numbers/SIDs)
       - Opt-Out List DB (or CRM query logic)
       - SMS Compliance Guidelines KB (TCPA, GDPR, character limits, content restrictions)
       - URL Shortener Service API documentation (if used).
   2.3. **Key Interacting Systems/Assistants:**
       - Triggering Mcp Assistants or System Events.
       - SMS Gateway Provider API (core integration for sending)
       - CRM System API (for opt-out checks)
       - URL Shortener Service API (optional)
       - Mcp Knowledge Base (for Sender Phone Number Mapping, Compliance Guidelines)
       - AirQ OS (if applicable, for secure gateway credential management and audit logging)

**Section 3: Operational Parameters & Task Definitions**
   3.1. **Primary Tasks & Responsibilities:**
       - **Task 1: Receive and Validate Send SMS Request**
           - Description: Accept the request to send an SMS from a triggering system.
           - Desired Outcome: Validated request with all necessary information (recipient, sender ID, message body, type).
           - Key Steps: Parse request, check mandatory fields (`recipient_phone_number`, `sender_phone_number_id`, `sms_message_body`), validate phone number format, check message length against `max_sms_segments_per_message`.
       - **Task 2: Resolve Sender Phone Number**
           - Description: Map the provided `sender_phone_number_id` to an actual phone number or messaging service SID from the SMS Gateway.
           - Desired Outcome: Correct sender identity is determined for the SMS Gateway API call.
           - Key Steps: Query Sender Phone Number Mapping KB using `sender_phone_number_id` (or use `default_sender_phone_number_id` if not provided/invalid).
       - **Task 3: Check Opt-Out Status (If Applicable)**
           - Description: Verify if the recipient has opted out of receiving SMS messages of the given `message_type`.
           - Desired Outcome: Message is not sent to opted-out recipients for relevant message types; compliance is maintained.
           - Key Steps: If `message_type` is in `check_opt_out_for_message_types`, query Opt-Out List DB (or CRM API) for `recipient_phone_number`. If opted out, log and terminate sending for this recipient.
       - **Task 4: Shorten URLs in Message Body (If Applicable)**
           - Description: If `url_shortening_enabled_for_message_types` applies and message contains URLs, shorten them.
           - Desired Outcome: SMS message body is more concise, saving characters.
           - Key Steps: Parse `sms_message_body` for URLs, call URL Shortener Service API for each, replace original URLs with shortened versions.
       - **Task 5: Submit SMS to Gateway**
           - Description: Send the prepared SMS message content to the SMS Gateway Provider API.
           - Desired Outcome: SMS is successfully accepted by the gateway for delivery; a gateway message ID is received.
           - Key Steps: Construct API request for SMS Gateway (including resolved sender, recipient, final message body, priority), make API call.
       - **Task 6: Log Send Attempt and Outcome**
           - Description: Record the details of the SMS send attempt, including gateway response.
           - Desired Outcome: Audit trail of all outbound SMS activity.
           - Key Steps: Log `tracking_id`, gateway message ID, recipient, sender used, status ("submitted", "failed"), error codes, number of segments.
   3.2. **Input Triggers/Formats:**
       - API call (JSON format as per `workflow_sms_outbound_prompt_template.md`) from other Mcps or systems.
   3.3. **Expected Outputs/Formats (Response to Triggering System):**
       - JSON object: `{"status": "submitted_to_gateway" or "failed", "gateway_message_id": "...", "error_code": "...", "error_message": "...", "tracking_id": "..."}`
   3.4. **Step-by-Step Process Overview (High-Level):**
       1. Receive Send SMS Request.
       2. Validate Request Parameters.
       3. Resolve Sender Phone Number ID.
       4. Check Opt-Out Status (if applicable for message type).
       5. If Opted-Out: Log and Exit for this recipient.
       6. Shorten URLs (if applicable).
       7. Submit SMS to Gateway API.
       8. Log Gateway Response (Success/Failure, Message ID).
       9. Return Status to Triggering System.
   3.5. **Decision-Making Logic:**
       - Strict adherence to opt-out checks based on `check_opt_out_for_message_types`.
       - Selection of sender number based on `Sender_Phone_Number_Mapping_KB`.
       - Character set validation (`character_set_validation`) and segmentation logic (`max_sms_segments_per_message`) before sending.
       - URL shortening based on `url_shortening_enabled_for_message_types`.

**Section 4: Communication Style & Tone**
   4.1. **Overall Tone:** Not applicable for the workflow itself, as the `sms_message_body` is provided by the triggering system. The workflow ensures reliable delivery.
   4.2. **Specific Language Guidelines:** Ensure `sms_message_body` adheres to `SMS_Compliance_Guidelines_KB` (e.g., no prohibited content, clear opt-out instructions for marketing if not handled by trigger system).
   4.3. **Confirmation/Notification Practices:** Provides status (submitted/failed) back to the triggering system/Mcp.

**Section 5: Constraints & Boundaries (Obstructions)**
   5.1. **Explicit Prohibitions:**
       - MUST NOT send messages to recipients who have opted out (for message types requiring opt-out check).
       - MUST NOT send messages that violate content policies defined in `SMS_Compliance_Guidelines_KB` or SMS gateway terms.
       - MUST NOT use sender IDs not configured in `Sender_Phone_Number_Mapping_KB` without an override mechanism and logging.
   5.2. **Scope Limitations:**
       - This workflow is responsible for the act of sending; message content creation is the responsibility of the triggering system/Mcp.
       - Delivery status beyond "submitted to gateway" depends on gateway capabilities (e.g., webhooks for delivery reports, which would be handled by a separate status update workflow or the SMS Inbound workflow if it's a reply).
       - Does not typically handle inbound replies directly; those are processed by Workflow - SMS Inbound if `allow_reply` was true.
   5.3. **Data Privacy & Security Rules:**
       - Recipient phone numbers and message content are PII and must be handled according to `Company_PII_Handling_Policy_v2.1.pdf`.
       - Securely manage highly sensitive SMS Gateway API credentials.
       - Comply with AirQ OS data security protocols if applicable, especially for API key management and logging.
       - Adhere to TCPA, GDPR, and other relevant communication regulations regarding outbound messaging.
   5.4. **Operational Limits:**
       - Respect API rate limits of the SMS Gateway Provider.
       - Adhere to `max_sms_segments_per_message` to avoid unexpected costs or delivery issues.

**Section 6: Error Handling & Escalation Procedures**
   6.1. **Common Error Scenarios & Codes (from Gateway or internal):**
       - `ERR_INVALID_RECIPIENT_NUMBER`: Phone number format incorrect or not a valid number.
       - `ERR_OPTED_OUT`: Recipient has opted out of this message type.
       - `ERR_GATEWAY_AUTH_FAILED`: SMS Gateway API credentials invalid.
       - `ERR_GATEWAY_INSUFFICIENT_FUNDS`: Account balance low with gateway provider.
       - `ERR_GATEWAY_MESSAGE_REJECTED`: Gateway rejected message (e.g., content violation, blocked number).
       - `ERR_SENDER_ID_NOT_PROVISIONED`: The chosen sender phone number is not active on the gateway.
       - `ERR_URL_SHORTENER_FAILED`: URL shortener service unavailable or failed.
   6.2. **Automated Resolution Steps:**
       - For transient gateway errors (e.g., temporary network issue): Retry sending up to `retry_attempts` configured for the SMS Gateway API integration.
       - If URL shortener fails: Send message with original long URLs (log a warning).
   6.3. **Escalation Path:**
       - Persistent gateway authentication failures (`ERR_GATEWAY_AUTH_FAILED`): Critical alert to CommunicationsAdminRole / SystemAdminRole.
       - Insufficient funds (`ERR_GATEWAY_INSUFFICIENT_FUNDS`): Alert to Finance/Comms Admin.
       - High rate of `ERR_GATEWAY_MESSAGE_REJECTED` or `ERR_SENDER_ID_NOT_PROVISIONED`: Alert to CommunicationsAdminRole to investigate gateway configuration or sender ID issues.
       - If HITL is enabled for persistent delivery failures (as per config): Escalate to `SMS_Delivery_Specialist_Queue` with details.

**Section 7: Human-in-the-Loop (HITL) Procedures**
   7.1. **Criteria for Triggering HITL:** Typically `enabled: false` for this workflow. If enabled for specific scenarios:
       - Persistent delivery failures to a number known to be valid, after retries.
       - Repeated rejections by the gateway for messages that appear compliant.
   7.2. **Information to Provide to Human Reviewer (SMS Delivery Specialist):**
       - `tracking_id`, recipient phone number, full message body sent, sender ID used, all gateway error codes and messages received, history of send attempts for this message.
   7.3. **Process for Incorporating Human Feedback/Decision:**
       - Human specialist can investigate with the SMS gateway, check number portability, review content for subtle compliance issues, or decide to attempt sending via an alternative channel if critical.
       - The system might allow the specialist to mark a number as permanently undeliverable.
   7.4. **Learning from HITL:**
       - Analyze HITL instances to identify issues with gateway providers, sender ID provisioning, or subtle compliance traps.
       - Use insights to update `SMS_Compliance_Guidelines_KB` or `Sender_Phone_Number_Mapping_KB`.

**Section 8: Maintenance & Updates**
   8.1. **Update Frequency for these Guidelines:** Annually, or as SMS gateway APIs, compliance regulations, or internal sender ID policies change.
   8.2. **Key Contacts for Issues/Updates:** Customer Communications Team Lead, AI Development Team, Operations Team.
   8.3. **Monitoring & Performance Review:** KPIs (Section 1.4) reviewed monthly. Send failure rates, delivery rates (if available), and gateway error patterns monitored continuously.

**Section 9: Dependencies on Proprietary Systems (e.g., AirQ)**
   9.1. **Interaction with AirQ OS:** AirQ could provide a secure vault for managing SMS Gateway API credentials and enforce strict access controls. It might also offer a robust, auditable logging mechanism for all outbound SMS traffic, ensuring compliance and traceability.
   9.2. **Data Handling within AirQ:** If message content or recipient PII passes through AirQ infrastructure, it must be handled with the highest level of security, encryption, and adherence to data governance policies mandated by AirQ.
