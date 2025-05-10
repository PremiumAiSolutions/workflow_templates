### Flowchart: Main Assistant (Office Manager) - Task Orchestration

**Description:** This flowchart illustrates the process by which the Main Assistant (Office Manager) receives a task, determines the appropriate Mcp Assistant for delegation, delegates the task, and monitors its progress through to completion or escalation.

```mermaid
graph TD
    subgraph "Initiation & Input"
        A["Trigger: User/System Task Request (e.g., API call, UI submission, Inbound Workflow Event)"] --> B("Input Data: Task Description, Priority, Due Date, Target Mcp Suggestion (optional), Required Inputs for Mcp");
    end

    subgraph "Processing & Core Logic"
        B --> C["Parse & Validate Task Request: Check for completeness and clarity"];
        C -- Valid --> D{"Determine Appropriate Mcp Assistant: Consult Mcp Thinking Agent / Mcp Assistant Registry"};
        C -- Invalid --> E["Error Handling: Request Clarification from User / Log Error & Notify Requester"];
        D -- Mcp Assistant Identified --> F["Verify/Gather Required Inputs for Target Mcp Assistant"];
        F -- Inputs Sufficient --> G["Delegate Task to Selected Mcp Assistant (e.g., Mcp Calendar, Mcp Invoice)"];
        F -- Inputs Insufficient --> E; # Loop back to request clarification/more info
        G --> H["Log Delegated Task in Active Task Log DB (Assign Tracking ID)"];
        H --> I["Confirm Task Delegation to Requester (with Tracking ID)"];
    end

    subgraph "Task Monitoring & Outcome Management"
        I --> J{"Monitor Task Status via Mcp Assistant (Periodic Check / Callback)"};
        J -- Status: In Progress --> J; # Loop for ongoing monitoring
        J -- Status: Completed Successfully --> K["Receive Completion Confirmation & Results from Mcp Assistant"];
        K --> L["Update Active Task Log DB: Mark as Completed"];
        L --> M["Notify Requester of Successful Completion (Provide Results/Outputs)"];
        J -- Status: Failed --> N["Receive Failure Notification from Mcp Assistant"];
        N --> O["Update Active Task Log DB: Mark as Failed"];
        O --> P{Attempt Automated Retry/Resolution (If defined in Mcp Assistant OGT)};
        P -- Retry Successful --> K; # Path to completion after retry
        P -- Retry Failed / No Retry Defined --> Q["Escalate Failure: Notify Requester & Relevant Stakeholders (e.g., Ops Team, Mcp Owner)"];
        J -- Status: Requires Human Intervention (HITL Flagged by Mcp Assistant) --> R["Route to Main Assistant HITL Queue / Office Manager Review"];
    end

    subgraph "Human-in-the-Loop (Main Assistant Level - Optional)"
        R --> S("Human (Office Manager) Reviews Escalation/HITL Request");
        S --> T{"Human Provides Decision/Input (e.g., Re-assign, Provide Missing Info, Cancel Task)"};
        T -- Re-delegate/Continue --> D; # Loop back to re-evaluate or re-delegate
        T -- Cancel Task --> U["Update Active Task Log DB: Mark as Cancelled by User"];
        U --> M_Cancelled["Notify Requester of Cancellation"];
    end

    subgraph "Output & Completion"
        M --> Z(["End: Task Successfully Completed & Reported"]);
        Q --> Z_Failed(["End: Task Failed & Escalated/Reported"]);
        M_Cancelled --> Z_Cancelled(["End: Task Cancelled & Reported"]);
        E --> Z_Error(["End: Task Request Invalid / Error in Processing"]);
    end

    %% Styling (Optional)
    classDef default fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;
    classDef hitlNode fill:#e2d9f3,stroke:#6f42c1,stroke-width:2px;

    class D,J,P,R,T decision;
    class E,Q errorNode;
    class M,Z successNode;
    class S,U,M_Cancelled hitlNode;
```

**Key Elements Customized for Main Assistant (Office Manager):**
*   **Trigger:** User or System Task Request.
*   **Input Data:** Includes task details, priority, and specific inputs for potential Mcp assistants.
*   **Validation Checks:** Ensures task requests are clear and actionable.
*   **Decision Question:** Involves consulting the Mcp Thinking Agent or Mcp Assistant Registry to choose the correct specialized Mcp assistant.
*   **Action Descriptions:** Focus on delegation to other Mcp assistants (Mcp Calendar, Mcp Invoice, etc.), logging, and monitoring.
*   **HITL Check:** At this level, HITL might involve the Office Manager reviewing complex delegations or failures from Mcp assistants.
*   **Output Data:** Confirmation of delegation, tracking IDs, and final task outcomes.
*   **Logging Details:** Comprehensive logging of delegation, progress, and outcomes in an Active Task Log DB.
*   **Notification Target:** Requester, relevant stakeholders, and escalation queues.
*   **Workflow Completion Status:** Task completed, failed, or cancelled, with appropriate reporting.

