### Prompt Template: Mcp Email (Human in the Loop) - Draft Email for Review

**1. Objective/Goal of this Prompt:**
   - To instruct the Mcp Email (Human in the Loop) assistant to draft an email based on a specific need or template, which will then be routed for human review and approval before sending.

**2. User/System Input Variables:**
   - `{{recipient_email}}`: (The email address of the intended recipient.)
   - `{{recipient_name}}`: (Optional: Name of the recipient for personalization.)
   - `{{email_purpose_description}}`: (A clear description of why the email is needed and what it should achieve, e.g., "Follow up on sales inquiry from Client X regarding product Y.", "Respond to customer complaint #C123 about late delivery.", "Draft a personalized outreach email to potential partner Z based on their recent company news.")
   - `{{source_information_references}}`: (Optional: List of document IDs, URLs, or text snippets from Mcp Knowledge Base or other sources that the AI should use to draft the email, e.g., `["KB_DOC_ID_ProductY_Details", "ClientX_CRM_Notes_LastCall"]`)
   - `{{suggested_email_template_id}}`: (Optional: Identifier for a base email template that can be adapted, e.g., "sales_follow_up_v1", "customer_service_reply_v2")
   - `{{key_points_to_include}}`: (Optional: Bullet points or specific phrases that MUST be included in the email draft.)
   - `{{desired_tone}}`: (Optional: Suggested tone for the email, e.g., "Empathetic and apologetic", "Professional and informative", "Enthusiastic and persuasive")
   - `{{urgency_for_review}}`: (Optional: Indication of how quickly the draft needs review, e.g., High, Medium, Low)

**3. Contextual Instructions for AI (Mcp Email - Human in the Loop):**
   - Desired Output Format: (A drafted email (subject and body) presented for review, along with a reference ID for the draft.)
   - Tone/Style: (The AI should attempt to match the `desired_tone` or infer an appropriate tone from the `email_purpose_description`. The draft should be well-structured and professional.)
   - Key information to focus on or exclude: (The AI should synthesize information from `source_information_references` and `key_points_to_include` to create a coherent and relevant draft. It should clearly indicate any assumptions made or information it couldn't find.)

**4. Example Usage:**
   - `recipient_email`: "john.smith@example.com"
   - `recipient_name`: "John Smith"
   - `email_purpose_description`: "Respond to John Smith's inquiry about our enterprise software solution. He asked about integration capabilities and pricing tiers."
   - `source_information_references`: `["KB_DOC_ID_EnterpriseSolution_Features", "KB_DOC_ID_Pricing_Tiers_2025"]`
   - `suggested_email_template_id`: "enterprise_inquiry_response_v1"
   - `key_points_to_include`: ["Mention our new Zapier integration.", "Highlight the 20% discount for annual subscriptions."]
   - `desired_tone`: "Helpful and professional"
   - `urgency_for_review`: "High"

**5. Expected Output/Action:**
   - The Mcp Email (Human in the Loop) assistant will:
     1. Analyze the `email_purpose_description` and other inputs.
     2. Retrieve information from `source_information_references` (e.g., via Mcp Knowledge Base).
     3. If `suggested_email_template_id` is provided, use it as a base; otherwise, compose from scratch.
     4. Draft the email subject and body, incorporating `key_points_to_include` and aiming for the `desired_tone`.
     5. Generate a draft ID (e.g., "DRAFT-EMAIL-ABC123").
     6. Route the draft email and its context (original request, sources used) to the designated human review queue.
     7. Return a confirmation to the requester, e.g., "Email draft for john.smith@example.com regarding 'Enterprise Solution Inquiry' has been created (Draft ID: DRAFT-EMAIL-ABC123) and sent for human review. Urgency: High."
