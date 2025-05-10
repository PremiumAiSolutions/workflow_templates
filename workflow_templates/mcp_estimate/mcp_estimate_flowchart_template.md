### Flowchart: Mcp Estimate - Estimate/Quote Lifecycle Management

**Description:** This flowchart illustrates how the Mcp Estimate assistant manages the lifecycle of customer estimates/quotes, including creation, sending, status tracking, customer decisions (accept/decline), conversion to order/invoice, and report generation, with escalations for approvals or issue resolution.

```mermaid
graph TD
    subgraph "Initiation & Request Type"
        A["Trigger: Estimate Action Request (Main Assistant, CRM Event, UI)"] --> B("Input Data: Action (Create, Send, Status, Accept/Decline, Convert, Report), Customer ID, Opportunity ID, Estimate Details, Estimate ID, Decision Reason, Report Criteria");
        B --> C{"Validate Action & Required Parameters"};
        C -- Invalid --> E_INVALID["Error Handling: Log Error, Notify Requester of Invalid Input"];
        C -- Valid --> D{"Select Action Path"};
        D -- Create Estimate --> PROC_CREATE_EST;
        D -- Send Estimate --> PROC_SEND_EST;
        D -- Get Estimate Status --> PROC_STATUS_EST;
        D -- Accept/Decline Estimate --> PROC_DECISION_EST;
        D -- Convert Estimate --> PROC_CONVERT_EST;
        D -- Generate Report --> PROC_REPORT_EST;
        D -- Send Follow-up (Scheduled) --> PROC_FOLLOWUP_EST;
    end

    subgraph "Process: Create Estimate" # PROC_CREATE_EST
        PROC_CREATE_EST[Action: Create Estimate] --> CE1["Fetch Customer (CRM), Opportunity (CRM), Product/Service Details (Catalog API)"];
        CE1 --> CE2["Apply Pricing Rules (Pricing Engine/KB), Calculate Line Totals, Subtotal, Discounts, Estimated Taxes"];
        CE2 --> CE3["Generate Unique Estimate Number & Set Validity Date (Default Terms)"];
        CE3 --> CE4{HITL Triggered? (Discount %, Total Amount, Non-Standard Terms)};
        CE4 -- Yes --> CE_HITL_APPROVAL["Escalate to Sales Manager for Approval (Estimate Draft, Reasons)"];
        CE_HITL_APPROVAL -- Approved --> CE5;
        CE_HITL_APPROVAL -- Rejected --> E_APPROVAL_REJECTED_EST["Log Rejection, Notify Requester"];
        CE4 -- No --> CE5;
        CE5["Save Estimate Record to CRM/Sales System API"];
        CE5 -- Save Error --> E_CRM_API_FAIL_EST["Error Handling: Log CRM API Failure"];
        CE5 -- Save Success --> CE6["Generate Estimate PDF (Using Template & PDF Gen Service API)"];
        CE6 -- PDF Error --> E_PDF_FAIL_EST["Error Handling: Log PDF Generation Failure"];
        CE6 -- PDF Success --> CE7(["End: Estimate Created (Draft/Approved). Return Confirmation, Estimate ID, PDF Link."]);
        CE7 -- Auto-Send Enabled? --> PROC_SEND_EST; # Optionally auto-send
    end

    subgraph "Process: Send Estimate" # PROC_SEND_EST
        PROC_SEND_EST[Action: Send Estimate] --> SE1["Retrieve Estimate Record & PDF (From CRM / File Storage)"];
        SE1 -- Not Found/Error --> E_ESTIMATE_NOT_FOUND["Error Handling: Estimate Not Found or PDF Missing"];
        SE1 -- Found --> SE2["Identify Recipient Email (Customer CRM / Override)"];
        SE2 --> SE3["Send Estimate via Mcp Email Assistant API (with Tracking Opt.)"];
        SE3 -- Send Error --> E_EMAIL_FAIL_EST["Error Handling: Log Email Send Failure"];
        SE3 -- Send Success --> SE4["Update Estimate Status to 'Sent' (and 'Viewed' if tracked) in CRM"];
        SE4 --> SE5(["End: Estimate Sent Successfully. Return Confirmation."]);
    end

    subgraph "Process: Get Estimate Status" # PROC_STATUS_EST
        PROC_STATUS_EST[Action: Get Estimate Status] --> STES1["Query CRM/Sales System API for Estimate ID"];
        STES1 -- Not Found --> E_ESTIMATE_NOT_FOUND;
        STES1 -- Found --> STES2(["End: Return Estimate Status & Key Details (Amount, Valid Until, Current Status)."]);
    end

    subgraph "Process: Accept/Decline Estimate" # PROC_DECISION_EST
        PROC_DECISION_EST[Action: Accept/Decline Estimate] --> DE1["Validate Estimate ID & Decision (Accept/Decline, Reason)"];
        DE1 --> DE2["Update Estimate Status in CRM/Sales System (Accepted/Declined, Store Reason/Feedback)"];
        DE2 -- Update Error --> E_CRM_API_FAIL_EST;
        DE2 -- Update Success --> DE3(["End: Estimate Status Updated. Notify Sales Rep."]);
        DE3 -- Accepted --> PROC_CONVERT_EST; # Trigger conversion if accepted
    end

    subgraph "Process: Convert Accepted Estimate" # PROC_CONVERT_EST
        PROC_CONVERT_EST[Action: Convert Estimate] --> CV1["Retrieve Accepted Estimate Details from CRM"];
        CV1 --> CV2{Convert to Order or Invoice? (Configurable)};
        CV2 -- To Order --> CV3_ORDER["Pass Details to Order Management System API (Create Order)"];
        CV3_ORDER -- OMS Error --> E_OMS_FAIL_EST["Error: OMS Order Creation Failed"];
        CV3_ORDER -- OMS Success --> CV4_ORDER(["End: Order Created. Return Order ID. Update Estimate Status to 'Converted_to_Order'."]);
        CV2 -- To Invoice --> CV3_INVOICE["Pass Details to Mcp Invoice Assistant API (Create Invoice)"];
        CV3_INVOICE -- Invoice Error --> E_INVOICE_FAIL_EST["Error: Mcp Invoice Creation Failed"];
        CV3_INVOICE -- Invoice Success --> CV4_INVOICE(["End: Invoice Created. Return Invoice ID. Update Estimate Status to 'Converted_to_Invoice'."]);
    end

    subgraph "Process: Generate Estimate Report" # PROC_REPORT_EST
        PROC_REPORT_EST[Action: Generate Report] --> RE1["Parse Report Criteria (Type, Date Range, Filters)"];
        RE1 --> RE2["Query CRM/Sales System API for Estimate Data"];
        RE2 -- Query Error --> E_CRM_API_FAIL_EST;
        RE2 -- Query Success --> RE3["Format Data & Generate Report File (CSV, PDF) to `output_destination_report`"];
        RE3 -- Report Gen Error --> E_REPORT_FAIL_EST["Error Handling: Log Report Generation Failure"];
        RE3 -- Report Gen Success --> RE4(["End: Report Generated. Return Path to Report / Summary."]);
    end

    subgraph "Process: Send Estimate Follow-up (Scheduled)" # PROC_FOLLOWUP_EST
        PROC_FOLLOWUP_EST[Action: Send Follow-up] --> FU1["Scan Estimates in CRM for Status 'Sent' & Nearing Expiry (based on Reminder Rules)"];
        FU1 -- No Follow-ups Due --> FU_END(["End: No Follow-ups to Send."]);
        FU1 -- Follow-ups Due --> FU2(For Each Estimate Requiring Follow-up);
        FU2 --> FU3["Generate Follow-up Email Content (Templated)"];
        FU3 --> FU4["Send Follow-up via Mcp Email Assistant API"];
        FU4 -- Send Error --> E_EMAIL_FAIL_FOLLOWUP["Log Follow-up Send Failure"];
        FU4 -- Send Success --> FU5["Log Follow-up Sent for Estimate"];
        FU5 --> FU2; # Next estimate
        FU2 -- Done --> FU_END;
    end

    subgraph "Common Error & End Paths"
        E_INVALID --> Z_END_ERROR_EST(["End: Process Terminated Due to Error"]);
        E_CRM_API_FAIL_EST --> Z_END_ERROR_EST;
        E_PDF_FAIL_EST --> Z_END_ERROR_EST;
        E_EMAIL_FAIL_EST --> Z_END_ERROR_EST;
        E_ESTIMATE_NOT_FOUND --> Z_END_ERROR_EST;
        E_OMS_FAIL_EST --> Z_END_ERROR_EST;
        E_INVOICE_FAIL_EST --> Z_END_ERROR_EST;
        E_REPORT_FAIL_EST --> Z_END_ERROR_EST;
        E_APPROVAL_REJECTED_EST --> Z_END_ERROR_EST;
        E_EMAIL_FAIL_FOLLOWUP --> Z_END_ERROR_EST; # May not terminate whole process, just log
    end

    %% Styling (Optional)
    classDef default fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef humanEsc fill:#f5e2d9,stroke:#c16f42,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;

    class C,D,CE4,CV2 decision;
    class CE_HITL_APPROVAL humanEsc;
    class E_INVALID,E_CRM_API_FAIL_EST,E_PDF_FAIL_EST,E_EMAIL_FAIL_EST,E_ESTIMATE_NOT_FOUND,E_OMS_FAIL_EST,E_INVOICE_FAIL_EST,E_REPORT_FAIL_EST,E_APPROVAL_REJECTED_EST,E_EMAIL_FAIL_FOLLOWUP errorNode;
    class CE7,SE5,STES2,DE3,CV4_ORDER,CV4_INVOICE,RE4,FU_END successNode;
```

**Key Elements Customized for Mcp Estimate:**
*   **Multiple Action Paths:** Main dispatcher for Create, Send, Status, Accept/Decline, Convert, Report, and Follow-ups.
*   **Pricing & Discount Logic:** Steps for applying pricing rules and handling discounts, including HITL for approvals.
*   **CRM/Sales System Integration:** Core interactions for storing and retrieving estimate data.
*   **PDF Generation & Emailing:** Specific sub-processes for creating and sending estimate documents.
*   **Status Lifecycle Management:** Tracking estimate through Draft, Sent, Viewed, Accepted, Declined, Expired, Converted.
*   **Conversion to Order/Invoice:** Logic for transforming an accepted estimate into a downstream sales order or invoice.
*   **Automated Follow-ups:** Scheduled process for sending reminders before expiry.
*   **Human Escalation Triggers:** For estimate approvals (discounts, total amount, non-standard terms).

