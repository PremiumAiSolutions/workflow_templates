### Flowchart: Mcp Dispatch - Task/Resource Assignment Process

**Description:** This flowchart illustrates how the Mcp Dispatch assistant receives dispatch requests, identifies and selects optimal resources, assigns tasks, notifies resources, calculates ETAs, and handles exceptions, including escalation to human dispatchers.

```mermaid
graph TD
    subgraph "Initiation & Request Validation"
        A["Trigger: Dispatch Request (Main Assistant, CRM, IoT, Manual UI)"] --> B("Input Data: Task ID, Description, Location, Skills, Priority, Time Constraints, Context");
        B --> C{"Validate Request Parameters (Completeness, Validity)"};
        C -- Invalid --> E_INVALID["Error Handling: Log Error, Notify Requester of Invalid Input"];
        C -- Valid --> D;
    end

    subgraph "Resource Identification & Selection"
        D["Query Resource Management System API: Find Resources (Status, Location, Skills, Availability)"];
        D --> F["Filter Resources by Required Skills, Availability within Time Constraints, Service Area"];
        F --> G{Suitable Resources Found?};
        G -- No --> H_NO_RESOURCE["No Suitable Resources Found"];
        G -- Yes --> I["Apply Dispatch Algorithm (e.g., Nearest Available Skilled, Round Robin) to Rank/Select Optimal Resource"];
        I --> J{Optimal Resource Selected? (Algorithm Output)};
        J -- No (e.g., multiple equally viable for high priority, algorithm inconclusive) --> H_NO_OPTIMAL;
        J -- Yes --> K;
    end

    subgraph "Assignment & Notification"
        K["Assign Task to Selected Resource (Update Task Management System)"];
        K --> L["Notify Resource via Mobile Worker Notification API (Job Details, Location, SOPs, Context)"];
        L --> M{Resource Accepts Dispatch? (Listen for Confirmation / Timeout)};
        M -- Rejected / Timeout --> N_REJECTED["Resource Rejected or Timed Out"];
        M -- Accepted --> O;
    end

    subgraph "ETA Calculation & Confirmation"
        O["Calculate ETA using Geo Location Service API (Resource Location, Target, Traffic)"];
        O --> P["Log Dispatch Details (Dispatch ID, Assigned Resource, Task ID, ETA)"];
        P --> Q(["End: Dispatch Successful. Return Confirmation (Dispatch ID, Resource, ETA) to Requester."]);
    end

    subgraph "Exception Handling & Human Escalation"
        H_NO_RESOURCE --> HITL_TRIGGER_NO_RESOURCE{"Trigger HITL (No Resource Found)?"};
        HITL_TRIGGER_NO_RESOURCE -- Yes --> ESC_HUMAN["Escalate to Human Dispatch Coordinator Queue with Task Details & Reason"];
        HITL_TRIGGER_NO_RESOURCE -- No (e.g., Queue Task) --> R_QUEUE_TASK(["End: Task Queued for Later Dispatch / Manual Review"]);
        
        H_NO_OPTIMAL --> HITL_TRIGGER_NO_OPTIMAL{"Trigger HITL (No Optimal Resource / Tie)?"};
        HITL_TRIGGER_NO_OPTIMAL -- Yes --> ESC_HUMAN;
        HITL_TRIGGER_NO_OPTIMAL -- No (e.g., Assign First Viable) --> K; # Or other fallback logic

        N_REJECTED --> HITL_TRIGGER_REJECTED{"Trigger HITL (Resource Rejected Critical Task)?"};
        HITL_TRIGGER_REJECTED -- Yes --> ESC_HUMAN;
        HITL_TRIGGER_REJECTED -- No --> S_REATTEMPT_DISPATCH{Attempt Re-Dispatch (Find Alternative Resource)};
        S_REATTEMPT_DISPATCH -- Yes --> D; # Loop back to resource identification
        S_REATTEMPT_DISPATCH -- No --> R_QUEUE_TASK;

        ESC_HUMAN --> T_HUMAN_ACTION("Human Dispatcher Reviews & Takes Action (Manual Assignment, Re-prioritize, etc.)");
        T_HUMAN_ACTION -- Manual Assignment Confirmed --> U_MANUAL_ASSIGN["Mcp Dispatch Executes Human-Confirmed Assignment"];
        U_MANUAL_ASSIGN --> K; # Re-enter flow at assignment
        T_HUMAN_ACTION -- Other Action --> V_HUMAN_OUTCOME(["End: Task Handled by Human Dispatcher"]);
        E_INVALID --> Z_END_ERROR(["End: Process Terminated Due to Error"]);
    end

    %% Styling (Optional)
    classDef default fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef humanEsc fill:#f5e2d9,stroke:#c16f42,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;

    class C,G,J,M,HITL_TRIGGER_NO_RESOURCE,HITL_TRIGGER_NO_OPTIMAL,HITL_TRIGGER_REJECTED,S_REATTEMPT_DISPATCH decision;
    class ESC_HUMAN,T_HUMAN_ACTION humanEsc;
    class E_INVALID errorNode;
    class Q,R_QUEUE_TASK,V_HUMAN_OUTCOME successNode;
```

**Key Elements Customized for Mcp Dispatch:**
*   **Resource Identification:** Detailed steps for querying, filtering, and selecting resources based on skills, availability, and location.
*   **Dispatch Algorithm Application:** Explicit step for applying the core logic to choose the optimal resource.
*   **Resource Notification & Acceptance:** Includes notifying the mobile worker and potentially waiting for acceptance.
*   **ETA Calculation:** Integration with Geo Location services for ETAs.
*   **Human Escalation Triggers:** Specific conditions for escalating to human dispatchers (no resource, no optimal choice, resource rejection).
*   **Re-Dispatch Logic:** Option to re-attempt dispatch if a resource rejects.
*   **Task Queuing:** Fallback option if immediate dispatch is not possible.

