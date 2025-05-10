### Prompt Template: Mcp Estimate - Manage Estimates/Quotes

**1. Objective/Goal of this Prompt:**
   - To instruct the Mcp Estimate assistant to perform actions related to customer estimates or quotes, such as creating a new estimate, sending an existing estimate, checking its status, or converting an accepted estimate to an order/invoice.

**2. User/System Input Variables:**
   - `{{action}}`: (The desired action, e.g., "create_estimate", "send_estimate", "get_estimate_status", "accept_estimate", "decline_estimate", "convert_to_order", "generate_estimate_report")
   - `{{customer_id}}`: (Identifier for the customer, e.g., "CUST-00123")
   - `{{opportunity_id}}`: (Optional: Identifier for a sales opportunity this estimate is related to, e.g., "OPP-00456")
   - `{{estimate_id}}`: (Optional, for `send_estimate`, `get_estimate_status`, `accept_estimate`, `decline_estimate`, `convert_to_order`: The unique identifier of the estimate.)
   - `{{estimate_details}}`: (Object containing specific details, structure varies by action.)
     - For `create_estimate`: `{"line_items": [{"item_id": "PROD-A", "description_override": "Customized Product A", "quantity": 5, "unit_price_override": 48.00, "notes": "Special discount applied"}, {"service_id": "SERV-B", "description_override": "Extended Service B", "estimated_hours": 10, "hourly_rate_override": 70.00}], "valid_until_date": "YYYY-MM-DD", "tax_rate_percent_estimate": 8.00, "discount_details": {"type": "percentage", "value": 5, "reason": "Early bird offer"}, "terms_and_conditions_override": "This estimate is valid for 30 days...", "notes_to_customer": "We look forward to working with you!"}`
     - For `send_estimate`: `{"recipient_email_override": "purchasing@client.com", "send_method": "email_pdf_with_tracking"}` (Defaults to customer's primary sales contact)
     - For `accept_estimate` / `decline_estimate`: `{"reason_for_decision": "Price too high", "customer_feedback": "Will reconsider if price drops by 10%."}` (Reason optional for accept)
     - For `convert_to_order`: `{"target_order_system_id": "OMS_MAIN", "customer_po_number": "PO12345"}`
     - For `generate_estimate_report`: `{"report_type": "pending_estimates_by_sales_rep", "date_range_start": "YYYY-MM-DD", "date_range_end": "YYYY-MM-DD", "sales_rep_id_filter": "SALESREP_007"}`
   - `{{output_destination_report}}`: (Optional, for `generate_estimate_report`: Path to save the report, e.g., "/home/ubuntu/reports/pending_estimates_q2.csv")

**3. Contextual Instructions for AI (Mcp Estimate):**
   - Desired Output Format:
     - `create_estimate`: Confirmation with new Estimate ID, total estimated amount, and a link to view/download it.
     - `send_estimate`: Confirmation of sending.
     - `get_estimate_status`: Estimate status (e.g., "Draft", "Sent", "Viewed", "Accepted", "Declined", "Expired") and key details.
     - `accept_estimate` / `decline_estimate`: Confirmation of status update.
     - `convert_to_order`: Confirmation with new Order ID (from target system) or Invoice ID (if converting directly to invoice via Mcp Invoice).
     - `generate_estimate_report`: Path to the generated report or summary of the report.
   - Tone/Style: (Professional, persuasive, accurate, and clear.)
   - Key information to focus on or exclude: (Ensure all pricing and calculations are precise. Use product/service data from catalog. Clearly state estimate numbers, validity dates, and total amounts. For reports, ensure data accuracy and proper filtering.)

**4. Example Usage (Create Estimate):**
   - `action`: "create_estimate"
   - `customer_id`: "CUST-00999"
   - `opportunity_id`: "OPP-2025-007"
   - `estimate_details`: `{"line_items": [{"item_id": "SVC-CONSULT", "estimated_hours": 20, "hourly_rate_override": 150.00}], "valid_until_date": "2025-06-30", "notes_to_customer": "Initial consultation services as discussed."}`

**5. Expected Output/Action:**
   - The Mcp Estimate assistant will:
     1. Validate the `action` and required parameters.
     2. Authenticate and authorize access to CRM/Sales/Product Catalog systems.
     3. Perform the requested estimate operation:
        - `create_estimate`: Fetch product/service details from catalog (if `item_id`/`service_id` provided) or use `estimate_details`, calculate line totals, subtotal, apply discounts, estimate taxes, sum total, generate a unique estimate ID, save to CRM/Sales system, generate PDF.
        - `send_estimate`: Retrieve estimate PDF, send to customer (e.g., via Mcp Email assistant), update estimate status to "Sent".
        - `get_estimate_status`: Query CRM/Sales system for the estimate status and details.
        - `accept_estimate` / `decline_estimate`: Update estimate in CRM/Sales system with new status and reason/feedback.
        - `convert_to_order`: Pass estimate details to Order Management System (or Mcp Invoice if configured) to create a new order/invoice. Update estimate status to "Converted".
        - `generate_estimate_report`: Query CRM/Sales system based on criteria, format report (e.g., CSV), save to `output_destination_report`.
     4. Return a confirmation message or the requested data/report path, e.g., for `create_estimate`: "Estimate EST-2025-00088 created successfully for customer CUST-00999. Estimated Amount: $3000.00. Valid Until: 2025-06-30. PDF: [link_to_estimate.pdf]"
