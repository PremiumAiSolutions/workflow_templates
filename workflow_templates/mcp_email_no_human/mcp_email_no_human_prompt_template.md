### Prompt Template: Mcp Email (No Human in the Loop) - Send Automated Email

**1. Objective/Goal of this Prompt:**
   - To instruct the Mcp Email (No Human in the Loop) assistant to compose and send a fully automated email based on predefined criteria or a specific trigger, without requiring human review before sending.

**2. User/System Input Variables:**
   - `{{recipient_email}}`: (The email address of the recipient.)
   - `{{recipient_name}}`: (Optional: Name of the recipient for personalization.)
   - `{{email_template_id}}`: (Identifier for a pre-approved email template to be used, e.g., "welcome_email_v1", "invoice_notification_v2", "password_reset_v3")
   - `{{template_variables}}`: (A structured object or JSON string containing key-value pairs to populate placeholders within the chosen email template, e.g., `{"user_name": "John Doe", "invoice_number": "INV-00123", "due_date": "2025-05-25", "reset_link": "https://example.com/reset?token=xyz"}`)
   - `{{subject_override}}`: (Optional: If provided, this subject line will be used instead of the one defined in the `email_template_id`.)
   - `{{attachments}}`: (Optional: A list of file paths or URLs for documents to be attached to the email. Paths should be accessible to the Mcp Email assistant.)
   - `{{send_time}}`: (Optional: Scheduled time for sending the email, e.g., "YYYY-MM-DD HH:MM UTC". If not provided, send immediately.)
   - `{{tracking_tags}}`: (Optional: List of tags for email tracking and analytics, e.g., ["campaign_spring_promo", "user_segment_new"])

**3. Contextual Instructions for AI (Mcp Email - No Human in the Loop):**
   - Desired Output Format: (Confirmation of email being queued for sending, including a message ID or tracking reference.)
   - Tone/Style: (The tone will be dictated by the chosen `email_template_id`. The assistant itself should be neutral and factual in its confirmation.)
   - Key information to focus on or exclude: (Strictly adhere to the chosen `email_template_id` and populate variables accurately. No deviation from the template content is permitted. Ensure all attachments are valid and accessible before attempting to send.)

**4. Example Usage:**
   - `recipient_email`: "jane.doe@example.com"
   - `recipient_name`: "Jane Doe"
   - `email_template_id`: "invoice_notification_v2"
   - `template_variables`: `{"user_name": "Jane Doe", "invoice_number": "INV-00456", "invoice_amount": "$250.00", "due_date": "2025-06-10", "payment_link": "https://company.com/pay/INV-00456"}`
   - `attachments`: ["/mnt/invoices/INV-00456.pdf"]
   - `send_time`: "now"

**5. Expected Output/Action:**
   - The Mcp Email (No Human in the Loop) assistant will:
     1. Validate the `recipient_email` format.
     2. Retrieve the email content and subject from the specified `email_template_id`.
     3. Populate the template placeholders using the provided `template_variables`.
     4. If `subject_override` is provided, use it as the email subject.
     5. Prepare any specified `attachments`.
     6. Queue the email for sending via the configured email service, either immediately or at the `send_time`.
     7. Return a confirmation message, e.g., "Email based on template 'invoice_notification_v2' for jane.doe@example.com has been queued. Message ID: EMAIL-XYZ789."
     8. Log the sending attempt and outcome (success/failure with reason).
