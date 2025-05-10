### Flowchart: Mcp Email (No Human in the Loop) - Automated Email Dispatch

**Description:** This flowchart illustrates the fully automated process by which the Mcp Email (No Human in the Loop) assistant sends emails based on predefined templates and triggers, without any human review prior to dispatch.

```mermaid
graph TD
    subgraph "Initiation & Input"
        A["Trigger: API Call / System Event (e.g., Main Assistant, CRM, Scheduler)"] --> B("Input Data: Recipient Email, Template ID, Template Variables, Subject Override (opt), Attachments (opt), Send Time (opt), Tracking Tags (opt)");
    end

    subgraph "Processing & Validation"
        B --> C["Validate Input Parameters (Recipient Format, Template ID Exists, Variable Sufficiency)"];
        C -- Invalid --> E_VALIDATION["Error Handling: Log Error, Notify Triggering System/User of Invalid Request"];
        C -- Valid --> D["Check Recipient Email Against Suppression List DB"];
        D -- Recipient on List --> E_SUPPRESSED["Error Handling: Log Suppression, Abort Send for this Recipient, Notify (Optional)"];
        D -- Recipient Not on List --> F["Retrieve Email Template Content from Repository (e.g., Mcp KB or File System)"];
        F -- Template Not Found --> E_TEMPLATE_NF["Error Handling: Log Error, Notify Triggering System/Admin"];
        F -- Template Found --> G["Populate Template with Provided Variables"];
        G --> H["Prepare Attachments: Validate Paths, Check Size/Type Limits (via File Storage Service API)"];
        H -- Attachment Error --> E_ATTACHMENT["Error Handling: Log Attachment Error, Notify Triggering System (Decide: Send w/o attachment or Fail?)"];
        H -- Attachments OK / No Attachments --> I;
    end

    subgraph "Email Dispatch & Logging"
        I["Construct Email Object (To, From, Subject, Body, Attachments)"];
        I --> J["Send Email via Primary Email Gateway Service API"];
        J -- Send Attempted --> K{"Gateway Response: Success or Failure?"};
        K -- Success (Accepted by Gateway) --> L["Log Successful Send Attempt (with Message ID from Gateway)"];
        K -- Failure (Gateway Error / Rejection) --> M["Log Failed Send Attempt (with Error Details from Gateway)"];
        M --> N{Attempt Retry (If Transient Error & Configured)};
        N -- Retry Successful --> L;
        N -- Retry Failed / Not Retriable --> E_GATEWAY_FAIL["Error Handling: Log Critical Failure, Escalate to System Ops / Marketing Automation Team"];
    end

    subgraph "Completion & Notification"
        L --> Z_SUCCESS(["End: Email Queued/Sent Successfully & Logged"]);
        E_VALIDATION --> Z_END_ERROR(["End: Process Terminated Due to Invalid Input"]);
        E_SUPPRESSED --> Z_END_ERROR;
        E_TEMPLATE_NF --> Z_END_ERROR;
        E_ATTACHMENT --> Z_END_ERROR; # Or potentially Z_SUCCESS if configured to send without failed attachments
        E_GATEWAY_FAIL --> Z_END_ERROR;
    end

    %% Styling (Optional)
    classDef default fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;

    class C,D,K,N decision;
    class E_VALIDATION,E_SUPPRESSED,E_TEMPLATE_NF,E_ATTACHMENT,M,E_GATEWAY_FAIL errorNode;
    class L,Z_SUCCESS successNode;
```

**Key Elements Customized for Mcp Email (No Human in the Loop):**
*   **Trigger:** API call or system event (fully automated).
*   **Input Data:** Includes `template_id` and `template_variables` as key inputs.
*   **Validation Checks:** Critical for ensuring automated sends are based on valid data and approved templates.
*   **Suppression List Check:** A mandatory step before any send attempt.
*   **Template Retrieval & Population:** Core logic involves fetching and filling pre-defined templates.
*   **Attachment Handling:** Validation of attachments against configured limits.
*   **Email Gateway Interaction:** The primary action is dispatching via an external email service.
*   **Retry Logic:** For transient gateway errors.
*   **Error Handling:** Specific error paths for various failure points (validation, suppression, template issues, attachments, gateway failures) with notifications to system admins or triggering systems, not individual users for review.
*   **No Human Review Loop:** The flowchart explicitly shows no path for human review of the email content before sending.
*   **Completion Status:** Focuses on whether the email was successfully queued/sent by the gateway and logged.

