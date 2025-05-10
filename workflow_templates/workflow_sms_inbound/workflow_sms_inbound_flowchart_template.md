### Flowchart: Workflow - SMS Inbound - Processing Incoming SMS Messages

**Description:** This flowchart illustrates how the SMS Inbound Workflow processes incoming SMS messages, identifies sender intent, and routes messages to the appropriate Mcp assistant or human agent for action.

```mermaid
graph TD
    subgraph "Initiation & Logging"
        A["Trigger: New SMS Received (via SMS Gateway Webhook)"] --> B("Input Data: Sender Phone, Recipient Phone, Message Body, Timestamp, Message ID");
        B --> C["Log Incoming SMS Details (Message ID, Sender, Timestamp, Body)"];
    end

    subgraph "Sender Identification & Keyword Check"
        C --> D["Identify Sender: Query CRM System API with Sender Phone Number"];
        D -- Sender Found --> E_KNOWN("Context: Known Customer/Contact ID: {{customer_id}}");
        D -- Sender Not Found --> E_UNKNOWN("Context: Unknown Sender");
        E_KNOWN --> F;
        E_UNKNOWN --> F;
        F["Check for Standard Keywords (STOP, HELP, INFO) in Message Body"];
        F -- Keyword Matched --> G{Keyword Type?};
    end

    subgraph "Standard Keyword Handling"
        G -- "STOP" --> H_STOP["Process Opt-Out: Update Opt-Out List DB"];
        H_STOP --> I_STOP_CONFIRM{"Send STOP Confirmation SMS? (Configurable)"};
        I_STOP_CONFIRM -- Yes --> J_STOP_REPLY["Send Opt-Out Confirmation via Mcp SMS Outbound"];
        J_STOP_REPLY --> K_END_KEYWORD(["End: STOP Processed"]);
        I_STOP_CONFIRM -- No --> K_END_KEYWORD;

        G -- "HELP" / "INFO" --> H_HELP["Retrieve Standard Reply from Standard SMS Replies KB"];
        H_HELP --> J_HELP_REPLY["Send Help/Info Reply via Mcp SMS Outbound"];
        J_HELP_REPLY --> K_END_KEYWORD;
    end

    subgraph "Intent Recognition & Routing (No Standard Keyword)"
        F -- No Keyword Match --> L["Perform Intent Recognition & Entity Extraction (Pass SMS Body & Sender Context to Mcp Thinking Agent API)"];
        L -- Error from Thinking Agent --> M_THINK_FAIL["Error Handling: Log Thinking Agent Failure, Escalate to Default Human Queue"];
        L -- Success --> N("Output: Intent, Confidence Score, Extracted Entities");
        N --> O{Intent Confidence > Threshold? (`intent_confidence_threshold_for_mcp_routing`) AND Clear Target Mcp?};
        O -- Yes (High Confidence & Clear Target) --> P["Route to Target Mcp Assistant (e.g., McpCalendar, McpOrderLookup) with SMS Details & Entities"];
        P --> Q_MCP_HANDLED(["End: Routed to Mcp Assistant"]);
        O -- No (Low Confidence / No Clear Target / Unknown Intent) --> R;
        R{Attempt FAQ Lookup? (If Intent Suggests Query)};
        R -- Yes --> S["Query Mcp Knowledge Base API with Parsed Query"];
        S -- Answer Found --> T["Formulate & Send FAQ Answer via Mcp SMS Outbound"];
        T --> U_FAQ_HANDLED(["End: FAQ Answered"]);
        S -- No Answer Found / Error --> V;
        R -- No (Not FAQ-like) --> V;
    end

    subgraph "Human Escalation & Acknowledgement"
        V["Escalate to Human Agent Queue (`human_escalation_queue_sms`) with SMS Details, Sender Context, Thinking Agent Output"];
        V --> W{"Send Acknowledgement SMS to Sender? (Configurable)"};
        W -- Yes --> X_ACK_REPLY["Send Acknowledgement from Standard SMS Replies KB via Mcp SMS Outbound"];
        X_ACK_REPLY --> Y_ESCALATED(["End: Escalated to Human Agent"]);
        W -- No --> Y_ESCALATED;
        M_THINK_FAIL --> Y_ESCALATED; # Also ends in escalation
    end

    %% Styling (Optional)
    classDef default fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef humanEsc fill:#f5e2d9,stroke:#c16f42,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;

    class F,G,I_STOP_CONFIRM,O,R,W decision;
    class V,M_THINK_FAIL humanEsc;
    class K_END_KEYWORD,Q_MCP_HANDLED,U_FAQ_HANDLED,Y_ESCALATED successNode;
```

**Key Elements Customized for Workflow - SMS Inbound:**
*   **SMS Gateway Trigger:** Clearly starts with an incoming SMS.
*   **Sender Identification:** Step to check if the sender is known via CRM.
*   **Standard Keyword Handling:** Dedicated paths for STOP, HELP, INFO for quick, automated responses.
*   **Mcp Thinking Agent Integration:** Central role for NLU, intent recognition, and entity extraction.
*   **Confidence-Based Routing:** Logic to decide between routing to another Mcp or escalating based on intent confidence.
*   **FAQ Lookup:** Option to query Mcp Knowledge Base for simple questions.
*   **Human Escalation Path:** Clear routing to human agents for complex or unrecognized intents.
*   **Automated Replies:** Use of Mcp SMS Outbound for confirmations and standard responses.

