### Prompt Template: Workflow - SMS Outbound - Send SMS Message

**1. Objective/Goal of this Prompt:**
   - To instruct the SMS Outbound Workflow to send a specific SMS message to a designated recipient phone number, often triggered by another Mcp assistant or a system event.

**2. User/System Input Variables (Typically from an internal Mcp or system):**
   - `{{recipient_phone_number}}`: (The phone number to send the SMS to, e.g., "+15551234567")
   - `{{sender_phone_number_id}}`: (Identifier for the company's phone number to send from, e.g., "main_marketing_sms_line", "support_sms_number". This allows using different outbound numbers for different purposes. The workflow will map this ID to an actual number.)
   - `{{sms_message_body}}`: (The text content of the SMS to be sent, e.g., "Your appointment on May 15th at 2 PM is confirmed.", "Your order #ORD123 has shipped.")
   - `{{message_type}}`: (Optional: Type of message, e.g., "transactional", "notification", "marketing_opt_in_only", "reminder". Helps with logging, compliance, and potentially routing through different gateway priorities.)
   - `{{tracking_id}}`: (Optional: A unique ID to correlate this outbound SMS with an internal process or event, e.g., "APPT_CONF_789", "ORDER_SHIP_NOTIF_123")
   - `{{allow_reply}}`: (Optional: Boolean, indicates if replies to this SMS should be actively processed by the SMS Inbound workflow. Defaults to true for most non-marketing messages.)
   - `{{delivery_priority}}`: (Optional: "high", "standard". May influence SMS gateway routing if supported.)

**3. Contextual Instructions for AI (SMS Outbound Workflow):**
   - Desired Output Format: (Confirmation of SMS submission to the gateway, including a message ID from the gateway, and status. Or an error if submission failed.)
     - Example Output: `{"status": "submitted_to_gateway", "gateway_message_id": "SM_zyxwvu987654", "recipient_phone_number": "+15551234567", "tracking_id": "APPT_CONF_789"}`
     - Example Output: `{"status": "failed", "error_code": "INVALID_RECIPIENT_NUMBER", "error_message": "The recipient phone number is not valid.", "tracking_id": "APPT_CONF_789"}`
   - Tone/Style: (The tone is inherent in the `{{sms_message_body}}` provided by the triggering system. This workflow focuses on reliable delivery.)
   - Key information to focus on or exclude: (Ensure the recipient has not opted out if `message_type` is marketing. Use the correct `sender_phone_number_id`. Log the attempt and outcome. Handle character limits and encoding for SMS.)

**4. Example Usage (Triggered by McpCalendar for appointment confirmation):**
   - `recipient_phone_number`: "+12125550199"
   - `sender_phone_number_id`: "customer_service_sms"
   - `sms_message_body`: "REMINDER: Your appointment with Dr. Smith is tomorrow, May 11th, at 10:00 AM. Reply C to confirm or R to reschedule."
   - `message_type`: "reminder"
   - `tracking_id`: "APPT_REMIND_456"
   - `allow_reply`: true

**5. Expected Output/Action:**
   - The SMS Outbound Workflow will:
     1. Validate input parameters, especially `recipient_phone_number` and `sms_message_body` (e.g., length).
     2. Look up the actual sender phone number based on `{{sender_phone_number_id}}` from configuration.
     3. Check opt-out status for `{{recipient_phone_number}}` if `{{message_type}}` is "marketing_opt_in_only" or as per general policy. If opted out, do not send and log/report appropriately.
     4. Submit the SMS message to the configured SMS Gateway Provider API.
     5. Receive a message ID and status from the gateway.
     6. Log the outbound SMS attempt, gateway message ID, recipient, and status (e.g., "submitted", "failed").
     7. Return a confirmation object with the status and gateway message ID, or an error object if submission failed.
     - Example for the above: `{"status": "submitted_to_gateway", "gateway_message_id": "SM_ghijk098765", "recipient_phone_number": "+12125550199", "tracking_id": "APPT_REMIND_456"}`
