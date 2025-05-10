### Prompt Template: Mcp Invoice - Manage Invoices

**1. Objective/Goal of this Prompt:**
   - To instruct the Mcp Invoice assistant to perform actions related to customer invoices, such as creating a new invoice, sending an existing invoice, checking the status of an invoice, or recording a payment.

**2. User/System Input Variables:**
   - `{{action}}`: (The desired action, e.g., "create_invoice", "send_invoice", "get_invoice_status", "record_payment", "generate_invoice_report")
   - `{{customer_id}}`: (Identifier for the customer, e.g., "CUST-00123")
   - `{{order_ids}}`: (Optional, for `create_invoice`: List of order IDs or service IDs to be invoiced, e.g., `["ORDER-789", "SERVICE-456"]`)
   - `{{invoice_id}}`: (Optional, for `send_invoice`, `get_invoice_status`, `record_payment`: The unique identifier of the invoice.)
   - `{{invoice_details}}`: (Object containing specific details, structure varies by action.)
     - For `create_invoice` (if not from `order_ids`): `{"line_items": [{"description": "Product A", "quantity": 2, "unit_price": 50.00}, {"description": "Service B", "hours": 3, "rate": 75.00}], "due_date": "YYYY-MM-DD", "tax_rate_percent": 8.25, "discount_amount": 10.00, "notes": "Thank you for your business!"}`
     - For `send_invoice`: `{"recipient_email_override": "finance@client.com", "send_method": "email_pdf"}` (Defaults to customer's primary billing contact)
     - For `record_payment`: `{"payment_amount": 250.00, "payment_date": "YYYY-MM-DD", "payment_method": "Credit Card", "transaction_id": "CH_XYZ123"}`
     - For `generate_invoice_report`: `{"report_type": "outstanding_invoices", "date_range_start": "YYYY-MM-DD", "date_range_end": "YYYY-MM-DD", "customer_id_filter": "CUST-00123"}`
   - `{{output_destination_report}}`: (Optional, for `generate_invoice_report`: Path to save the report, e.g., "/home/ubuntu/reports/outstanding_invoices_may.csv")

**3. Contextual Instructions for AI (Mcp Invoice):**
   - Desired Output Format:
     - `create_invoice`: Confirmation with new Invoice ID and a link to view/download it.
     - `send_invoice`: Confirmation of sending.
     - `get_invoice_status`: Invoice status (e.g., "Draft", "Sent", "Paid", "Overdue") and key details.
     - `record_payment`: Confirmation of payment recording and updated invoice status.
     - `generate_invoice_report`: Path to the generated report or summary of the report.
   - Tone/Style: (Professional, accurate, and clear.)
   - Key information to focus on or exclude: (Ensure all financial calculations are precise. Use customer data from CRM/Billing system. Clearly state invoice numbers and amounts. For reports, ensure data accuracy and proper filtering.)

**4. Example Usage (Create Invoice from Order):**
   - `action`: "create_invoice"
   - `customer_id`: "CUST-00789"
   - `order_ids`: `["ORD-2025-05-001", "ORD-2025-05-002"]`
   - `invoice_details`: `{"due_date": "2025-06-10", "notes": "Combined invoice for May orders."}`

**5. Expected Output/Action:**
   - The Mcp Invoice assistant will:
     1. Validate the `action` and required parameters.
     2. Authenticate and authorize access to billing/accounting systems.
     3. Perform the requested invoice operation:
        - `create_invoice`: Fetch order details (if `order_ids` provided) or use `invoice_details`, calculate totals (subtotal, tax, total), generate a unique invoice ID, save to billing system, generate PDF.
        - `send_invoice`: Retrieve invoice PDF, send to customer (e.g., via Mcp Email assistant), update invoice status to "Sent".
        - `get_invoice_status`: Query billing system for the invoice status and details.
        - `record_payment`: Update invoice in billing system with payment details, adjust balance, update status (e.g., to "Paid").
        - `generate_invoice_report`: Query billing system based on criteria, format report (e.g., CSV), save to `output_destination_report`.
     4. Return a confirmation message or the requested data/report path, e.g., for `create_invoice`: "Invoice INV-2025-00123 created successfully for customer CUST-00789. Amount: $350.75. PDF: [link_to_invoice.pdf]"
