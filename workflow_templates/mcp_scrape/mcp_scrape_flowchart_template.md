### Flowchart: Mcp Scrape - Web Content Extraction Process

**Description:** This flowchart illustrates how the Mcp Scrape assistant fetches web pages, parses content, extracts specified data using selectors, handles errors, formats the output, and stores or returns the results, including escalation to human specialists for complex issues.

```mermaid
graph TD
    subgraph "Initiation & Request Validation"
        A["Trigger: Scrape Request (Main Assistant, Scheduler, UI, Workflow Event)"] --> B("Input Data: Target URLs, Data to Extract (Selectors), Output Format/Destination, Scraping Parameters, Error Handling Policy");
        B --> C{"Validate Request Parameters (URL Format, Selector Syntax, Output Options)"};
        C -- Invalid --> E_INVALID["Error Handling: Log Error, Notify Requester of Invalid Input"];
        C -- Valid --> D;
    end

    subgraph "Scraping Loop (For Each URL)"
        D["Initialize Aggregated Data Container"];
        D --> URL_LOOP_START(For Each Target URL);
        URL_LOOP_START --> F["Configure Scraping Engine (User Agent, Proxy, JS Rendering, Waits, Cookies)"];
        F --> G{"Respect robots.txt? (If Enabled)"};
        G -- Yes --> H["Fetch & Check robots.txt for URL Domain"];
        H -- Disallowed --> I_ROBOTS_DISALLOWED["Log: Scraping Disallowed by robots.txt. Skip URL / Error as per Policy."];
        I_ROBOTS_DISALLOWED --> URL_LOOP_END;
        H -- Allowed / Not Checked --> J;
        G -- No --> J;
        J["Fetch Web Page Content (Handle Redirects, Apply Delays)"];
        J -- Fetch Error (Network, HTTP Error) --> K{Retry Fetch? (Max Retries)};
        K -- Yes --> J; # Loop back to retry fetch
        K -- No --> L_FETCH_ERROR["Log Fetch Error for URL. Handle as per `on_error_handling` (e.g., Skip URL)."];
        L_FETCH_ERROR --> URL_LOOP_END;
        J -- Fetch Success --> M["Parse Page Content (HTML, JSON, etc.)"];
        M --> N["Render JavaScript (If Enabled, Wait for Selectors)"];
        N -- JS Error --> O_JS_ERROR["Log JS Rendering Error. Handle as per `on_error_handling`."];
        O_JS_ERROR --> URL_LOOP_END;
        N -- JS Success / Not Enabled --> P;
        P["Extract Data using Defined Selectors/Patterns (For Each Item in `data_to_extract`)"];
        P --> Q{Selector Found & Data Extracted? (For Each Selector)};
        Q -- No (Selector Not Found / Empty) --> R_SELECTOR_FAIL["Log Selector Failure. Handle as per `on_error_handling` (e.g., Null Value, Skip Item)."];
        R_SELECTOR_FAIL --> P; # Continue with next selector for this URL
        Q -- Yes --> S["Add Extracted Data for this URL to Aggregated Data Container"];
        S --> URL_LOOP_END(End For Each URL Loop);
    end

    subgraph "Output Generation & Error Handling"
        URL_LOOP_END --> T["Format Aggregated Data to `output_format` (JSON, CSV, etc.)"];
        T --> U{Save to `output_destination`? (File or Mcp KB)};
        U -- Yes --> V["Save Formatted Data (via File Storage API or Mcp KB API)"];
        V -- Save Error --> W_SAVE_ERROR["Error Handling: Log Save Error. Notify Requester."];
        V -- Save Success --> X;
        U -- No (Return Directly) --> X;
        X["Compile Summary Report (URLs Processed, Successes, Failures, Output Location/Data)"];
        X --> Y(["End: Scraping Completed. Return Summary Report & Data/Link."]);
    end

    subgraph "Human Escalation for Persistent Issues"
        L_FETCH_ERROR -- Suspect IP Block / CAPTCHA --> HITL_IP_BLOCK{"Trigger HITL (IP Block / CAPTCHA)?"};
        O_JS_ERROR -- Suspect Complex Anti-Scraping --> HITL_ANTI_SCRAPE{"Trigger HITL (Anti-Scraping)?"};
        R_SELECTOR_FAIL -- Persistent Selector Failure --> HITL_SELECTOR_FAIL{"Trigger HITL (Persistent Selector Failure)?"};
        
        HITL_IP_BLOCK -- Yes --> ESC_HUMAN["Escalate to Scraping Specialist Queue with URL, Error, Screenshot (opt), Proxy Info"];
        HITL_ANTI_SCRAPE -- Yes --> ESC_HUMAN;
        HITL_SELECTOR_FAIL -- Yes --> ESC_HUMAN;

        ESC_HUMAN --> AA_HUMAN_ACTION("Human Specialist Reviews & Takes Action (Update Selectors, Change Proxy, Manual Extraction, etc.)");
        AA_HUMAN_ACTION -- Updated Config / Manual Data --> AB_HUMAN_OUTCOME(["End: Issue Handled by Specialist. Data (Potentially Manual) Available / Job Re-queued with New Config."]);
        E_INVALID --> Z_END_ERROR(["End: Process Terminated Due to Invalid Input"]);
        W_SAVE_ERROR --> Z_END_ERROR;
    end

    %% Styling (Optional)
    classDef default fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef loop fill:#e0f2f1,stroke:#00796b,stroke-width:2px;
    classDef humanEsc fill:#f5e2d9,stroke:#c16f42,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;

    class C,G,K,Q,U,HITL_IP_BLOCK,HITL_ANTI_SCRAPE,HITL_SELECTOR_FAIL decision;
    class URL_LOOP_START,URL_LOOP_END loop;
    class ESC_HUMAN,AA_HUMAN_ACTION humanEsc;
    class E_INVALID,I_ROBOTS_DISALLOWED,L_FETCH_ERROR,O_JS_ERROR,R_SELECTOR_FAIL,W_SAVE_ERROR errorNode;
    class Y,AB_HUMAN_OUTCOME successNode;
```

**Key Elements Customized for Mcp Scrape:**
*   **URL Loop:** Explicitly shows processing for each target URL.
*   **Robots.txt Check:** Optional step based on configuration.
*   **JS Rendering & Waits:** Key considerations for dynamic websites.
*   **Selector-Based Extraction:** Core logic for pulling specific data points.
*   **Error Handling per URL/Selector:** Granular error management based on policy.
*   **Data Aggregation & Formatting:** Steps to combine data from multiple URLs and convert to desired output.
*   **Output Destination:** Options to save to file, KB, or return directly.
*   **Human Escalation Triggers:** Specific conditions for involving scraping specialists (CAPTCHA, IP blocks, persistent selector failures).

