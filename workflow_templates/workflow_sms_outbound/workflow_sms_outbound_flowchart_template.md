### Flowchart: Workflow - SMS Outbound - Sending SMS Messages

**Description:** This flowchart illustrates how the SMS Outbound Workflow sends SMS messages, including recipient validation, opt-out checks, and interaction with the SMS gateway.

```mermaid
graph TD
    subgraph "Initiation & Validation"
        A["Trigger: Send SMS Request (from Mcp Assistant, System Event, SMS Inbound Reply)"] --> B("Input Data: Recipient Phone, Sender Phone ID, Message Body, Message Type, Tracking ID, Allow Reply, Priority");
        B --> C{"Validate Request Parameters (Recipient Format, Body Length, Sender ID Exists?)"};
        C -- Invalid --> E_INVALID_REQ["Error Handling: Log Invalid Request, Notify Triggering System"];
        C -- Valid --> D["Resolve Sender Phone Number ID to Actual Number/Gateway SID (from Sender Phone Number Mapping KB)"];
        D -- Mapping Failed --> E_SENDER_ID_FAIL["Error Handling: Log Sender ID Resolution Failure, Use Default or Notify Triggering System"];
        D -- Mapping Success --> F;
    end

    subgraph "Compliance & Preparation"
        F{"Check Opt-Out Status for Recipient Phone? (Based on `message_type` and `check_opt_out_for_message_types` config)"};
        F -- Yes, Check Opt-Out --> G["Query CRM System API / Opt-Out List DB for Recipient's Opt-Out Status"];
        G -- Opted-Out --> H_OPT_OUT["Action: Do Not Send. Log Opt-Out. Notify Triggering System."];
        H_OPT_OUT --> Z_END_OPT_OUT(["End: Process Terminated Due to Opt-Out"]);
        G -- Not Opted-Out / Error Querying --> I; # Proceed if not opted-out or if opt-out check fails (configurable behavior)
        F -- No, Opt-Out Check Not Required --> I;
        I{"Shorten URLs in Message Body? (Based on `url_shortening_enabled_for_message_types` config)"};
        I -- Yes --> J["Call URL Shortener Service API for URLs in Message Body"];
        J -- Shortening Error --> K_URL_FAIL_WARN["Warning: URL Shortening Failed. Proceed with Long URLs. Log Warning."];
        K_URL_FAIL_WARN --> L;
        J -- Shortening Success --> L_URL_SHORTENED("Message Body Updated with Shortened URLs");
        L_URL_SHORTENED --> L;
        I -- No --> L;
        L["Prepare Final Message Body (Validate Character Set, Check Segmentation `max_sms_segments_per_message`)"];
    end

    subgraph "Gateway Submission & Logging"
        L --> M["Submit SMS to SMS Gateway Provider API (Recipient, Resolved Sender, Final Body, Priority)"];
        M -- Gateway Submission Error (e.g., Auth, Funds, Invalid Number, Rejected) --> N_GATEWAY_FAIL["Error Handling: Log Gateway Submission Failure (Error Code, Message). Notify Triggering System."];
        N_GATEWAY_FAIL --> Z_END_ERROR_SEND(["End: Process Terminated Due to Gateway Error"]);
        M -- Gateway Submission Success --> O("Gateway Response: Success, Gateway Message ID");
        O --> P["Log Outbound SMS Attempt & Outcome (Tracking ID, Gateway Message ID, Recipient, Sender, Status: Submitted, Segments)"];
        P --> Q_SENT_SUCCESS(["End: SMS Submitted to Gateway. Return Success & Gateway Message ID to Triggering System."]);
    end

    %% Styling (Optional)
    classDef default fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef warningNode fill:#fff3cd,stroke:#ffc107,stroke-width:2px;

    class C,F,I decision;
    class E_INVALID_REQ,E_SENDER_ID_FAIL,N_GATEWAY_FAIL errorNode;
    class K_URL_FAIL_WARN warningNode;
    class Z_END_OPT_OUT,Z_END_ERROR_SEND,Q_SENT_SUCCESS successNode;
```

**Key Elements Customized for Workflow - SMS Outbound:**
*   **Trigger Agnostic:** Can be called by any authorized internal system or Mcp.
*   **Sender ID Resolution:** Maps an internal ID to an actual sending number/service ID.
*   **Opt-Out Check:** Crucial compliance step for relevant message types.
*   **URL Shortening:** Optional step to optimize message length.
*   **Gateway Interaction:** Focuses on the API call to the SMS Gateway Provider.
*   **Logging:** Detailed logging of the send attempt and outcome.
*   **Status Feedback:** Returns a clear status (submitted/failed) and gateway message ID to the caller.

