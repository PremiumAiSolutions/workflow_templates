### Flowchart: Mcp Invoice - Invoice Lifecycle Management

**Description:** This flowchart illustrates how the Mcp Invoice assistant manages the lifecycle of customer invoices, including creation, sending, status tracking, payment recording, reminder dispatch, and report generation, with escalations for approvals or issue resolution.

```mermaid
graph TD
    subgraph "Initiation & Request Type"
        A["Trigger: Invoice Action Request (Main Assistant, OMS Event, Scheduler, UI)"] --> B("Input Data: Action (Create, Send, Status, Payment, Report), Customer ID, Order IDs/Invoice Details, Invoice ID, Payment Details, Report Criteria");
        B --> C{"Validate Action & Required Parameters"};
        C -- Invalid --> E_INVALID["Error Handling: Log Error, Notify Requester of Invalid Input"];
        C -- Valid --> D{"Select Action Path"};
        D -- Create Invoice --> PROC_CREATE;
        D -- Send Invoice --> PROC_SEND;
        D -- Get Invoice Status --> PROC_STATUS;
        D -- Record Payment --> PROC_PAYMENT;
        D -- Generate Report --> PROC_REPORT;
        D -- Send Reminders (Scheduled) --> PROC_REMINDERS;
    end

    subgraph "Process: Create Invoice" # PROC_CREATE
        PROC_CREATE[Action: Create Invoice] --> CR1["Fetch Customer Data (CRM) & Order/Service Details (OMS/Input)"];
        CR1 --> CR2["Calculate Line Items, Subtotal, Discounts, Taxes (Tax API/DB)"];
        CR2 --> CR3["Generate Unique Invoice Number & Set Due Date (Default Terms)"];
        CR3 --> CR4{Amount Exceeds HITL Threshold? (`trigger_on_invoice_amount_exceeds_threshold`)};
        CR4 -- Yes --> CR_HITL_APPROVAL["Escalate to Billing Specialist for Approval"];
        CR_HITL_APPROVAL -- Approved --> CR5;
        CR_HITL_APPROVAL -- Rejected --> E_APPROVAL_REJECTED["Log Rejection, Notify Requester"];
        CR4 -- No --> CR5;
        CR5["Save Invoice Record to Accounting/Billing System API"];
        CR5 -- Save Error --> E_ACCT_API_FAIL["Error Handling: Log Accounting API Failure"];
        CR5 -- Save Success --> CR6["Generate Invoice PDF (Using Template & PDF Gen Service API)"];
        CR6 -- PDF Error --> E_PDF_FAIL["Error Handling: Log PDF Generation Failure"];
        CR6 -- PDF Success --> CR7(["End: Invoice Created (Draft/Approved). Return Confirmation, Invoice ID, PDF Link."]);
        CR7 --> PROC_SEND; # Optionally auto-send after creation
    end

    subgraph "Process: Send Invoice" # PROC_SEND
        PROC_SEND[Action: Send Invoice] --> S1["Retrieve Invoice Record & PDF (From Accounting System / File Storage)"];
        S1 -- Not Found/Error --> E_INVOICE_NOT_FOUND["Error Handling: Invoice Not Found or PDF Missing"];
        S1 -- Found --> S2["Identify Recipient Email (Customer CRM / Override)"];
        S2 --> S3["Send Invoice via Mcp Email Assistant API"];
        S3 -- Send Error --> E_EMAIL_FAIL["Error Handling: Log Email Send Failure"];
        S3 -- Send Success --> S4["Update Invoice Status to 'Sent' in Accounting System"];
        S4 --> S5(["End: Invoice Sent Successfully. Return Confirmation."]);
    end

    subgraph "Process: Get Invoice Status" # PROC_STATUS
        PROC_STATUS[Action: Get Invoice Status] --> ST1["Query Accounting/Billing System API for Invoice ID"];
        ST1 -- Not Found --> E_INVOICE_NOT_FOUND;
        ST1 -- Found --> ST2(["End: Return Invoice Status & Key Details (Amount, Due Date, Paid Status)."]);
    end

    subgraph "Process: Record Payment" # PROC_PAYMENT
        PROC_PAYMENT[Action: Record Payment] --> P1["Validate Payment Details (Amount, Date, Method, Transaction ID)"];
        P1 --> P2["Query Accounting/Billing System for Invoice ID & Balance"];
        P2 -- Not Found --> E_INVOICE_NOT_FOUND;
        P2 -- Found --> P3{Payment Discrepancy? (`trigger_on_payment_discrepancy_detected`)};
        P3 -- Yes --> P_HITL_DISCREPANCY["Escalate to Billing Specialist for Review/Resolution"];
        P_HITL_DISCREPANCY -- Resolved --> P4;
        P_HITL_DISCREPANCY -- Unresolved --> E_PAYMENT_ISSUE["Log Issue, Notify Requester"];
        P3 -- No --> P4;
        P4["Update Invoice in Accounting System (Apply Payment, Adjust Balance, Update Status to Paid/Partially Paid)"];
        P4 -- Update Error --> E_ACCT_API_FAIL;
        P4 -- Update Success --> P5(["End: Payment Recorded Successfully. Return Confirmation & Updated Status."]);
    end

    subgraph "Process: Generate Invoice Report" # PROC_REPORT
        PROC_REPORT[Action: Generate Report] --> R1["Parse Report Criteria (Type, Date Range, Filters)"];
        R1 --> R2["Query Accounting/Billing System API for Invoice Data"];
        R2 -- Query Error --> E_ACCT_API_FAIL;
        R2 -- Query Success --> R3["Format Data & Generate Report File (CSV, PDF) to `output_destination_report`"];
        R3 -- Report Gen Error --> E_REPORT_FAIL["Error Handling: Log Report Generation Failure"];
        R3 -- Report Gen Success --> R4(["End: Report Generated. Return Path to Report / Summary."]);
    end

    subgraph "Process: Send Payment Reminders (Scheduled)" # PROC_REMINDERS
        PROC_REMINDERS[Action: Send Reminders] --> RM1["Scan Invoices in Accounting System for Due/Overdue Status based on Reminder Rules"];
        RM1 -- No Reminders Due --> RM_END(["End: No Reminders to Send."]);
        RM1 -- Reminders Due --> RM2(For Each Invoice Requiring Reminder);
        RM2 --> RM3["Generate Reminder Email Content (Templated)"];
        RM3 --> RM4["Send Reminder via Mcp Email Assistant API"];
        RM4 -- Send Error --> E_EMAIL_FAIL_REMINDER["Log Reminder Send Failure"];
        RM4 -- Send Success --> RM5["Log Reminder Sent for Invoice"];
        RM5 --> RM2; # Next invoice
        RM2 -- Done --> RM_END;
    end

    subgraph "Common Error & End Paths"
        E_INVALID --> Z_END_ERROR(["End: Process Terminated Due to Error"]);
        E_ACCT_API_FAIL --> Z_END_ERROR;
        E_PDF_FAIL --> Z_END_ERROR;
        E_EMAIL_FAIL --> Z_END_ERROR;
        E_INVOICE_NOT_FOUND --> Z_END_ERROR;
        E_PAYMENT_ISSUE --> Z_END_ERROR;
        E_REPORT_FAIL --> Z_END_ERROR;
        E_APPROVAL_REJECTED --> Z_END_ERROR;
        E_EMAIL_FAIL_REMINDER --> Z_END_ERROR; # May not terminate whole process, just log
    end

    %% Styling (Optional)
    classDef default fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef humanEsc fill:#f5e2d9,stroke:#c16f42,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;

    class C,D,CR4,P3 decision;
    class CR_HITL_APPROVAL,P_HITL_DISCREPANCY humanEsc;
    class E_INVALID,E_ACCT_API_FAIL,E_PDF_FAIL,E_EMAIL_FAIL,E_INVOICE_NOT_FOUND,E_PAYMENT_ISSUE,E_REPORT_FAIL,E_APPROVAL_REJECTED,E_EMAIL_FAIL_REMINDER errorNode;
    class CR7,S5,ST2,P5,R4,RM_END successNode;
```

**Key Elements Customized for Mcp Invoice:**
*   **Multiple Action Paths:** Main dispatcher for Create, Send, Status, Payment, Report, and Reminders.
*   **Financial Calculations:** Explicit steps for calculating totals, taxes, etc.
*   **Accounting System Integration:** Core interactions with the Accounting/Billing System API for most actions.
*   **PDF Generation & Emailing:** Specific sub-processes for creating and sending invoice documents.
*   **Payment Recording Logic:** Includes handling potential discrepancies.
*   **Reporting Capabilities:** Flow for generating various invoice-related reports.
*   **Automated Reminders:** Scheduled process for sending payment reminders.
*   **Human Escalation Triggers:** For invoice approval (large amounts) and payment discrepancies.

