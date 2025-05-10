### Flowchart: Mcp Email (Human in the Loop) - Draft, Review, Approve, Send

**Description:** This flowchart illustrates the process where the Mcp Email (Human in the Loop) assistant drafts an email, routes it for human review and approval, and then dispatches it upon receiving approval.

```mermaid
graph TD
    subgraph "Initiation & Draft Request"
        A["Trigger: User/System Request for Email Draft (e.g., Main Assistant, UI)"] --> B("Input Data: Recipient, Purpose, Source Info, Suggested Template, Key Points, Desired Tone, Urgency");
    end

    subgraph "AI-Assisted Email Drafting"
        B --> C["Parse Request & Gather Context (Query Mcp KB for Source Info)"];
        C --> D["Select/Adapt Base Template or Compose New Draft (Subject & Body)"];
        D --> E["Incorporate Key Points & Adhere to Desired Tone/Style Guide"];
        E --> F["Generate Draft ID & Package Draft with Context (Original Request, Sources Used)"];
    end

    subgraph "Human Review & Approval Workflow"
        F --> G["Submit Draft to Human Review Workflow System API (e.g., Task Management System)"];
        G --> H["Draft Assigned to Reviewer/Queue (e.g., Customer Service Tier1)"];
        H --> I{Reviewer Action: Review Draft, Edit (Optional)};
        I -- Approve Send --> J["Approval Logged in Review System"];
        I -- Reject Draft --> K["Rejection Logged with Feedback in Review System"];
        I -- Request Further Edits / Reassign --> H; # Loop back for more edits or different reviewer
    end

    subgraph "Post-Approval Processing & Dispatch"
        J --> L["Receive Approved Email Content (Potentially Edited) from Review System"];
        L --> M["Check Approved Recipient Email Against Suppression List DB"];
        M -- Recipient on List --> N_SUPPRESSED["Error Handling: Log Suppression, Abort Send, Notify Reviewer/Requester"];
        M -- Recipient Not on List --> O["Prepare Attachments (If Any, Validate Paths, Size/Type)"];
        O -- Attachment Error --> N_ATTACHMENT["Error Handling: Log Attachment Error, Notify Reviewer (Decide: Send w/o or Fail?)"];
        O -- Attachments OK / No Attachments --> P;
        P["Construct Final Email Object (To, From, Subject, Approved Body, Attachments)"];
        P --> Q["Send Email via Primary Email Gateway Service API"];
        Q -- Send Attempted --> R{"Gateway Response: Success or Failure?"};
        R -- Success (Accepted by Gateway) --> S["Log Successful Send (with Final Message ID)"];
        R -- Failure (Gateway Error) --> T["Log Failed Send (with Error Details)"];
        T --> U{Attempt Retry (If Transient Error & Configured)};
        U -- Retry Successful --> S;
        U -- Retry Failed / Not Retriable --> N_GATEWAY_FAIL["Error Handling: Log Critical Failure, Escalate to System Ops"];
    end

    subgraph "Completion & Notification"
        S --> Z_SUCCESS(["End: Approved Email Sent Successfully & Logged. Notify Requester."]);
        K --> Z_REJECTED(["End: Draft Rejected. Notify Requester with Feedback."]);
        N_SUPPRESSED --> Z_END_ERROR(["End: Process Terminated Due to Suppression"]);
        N_ATTACHMENT --> Z_END_ERROR; # Or Z_SUCCESS if sent without attachments
        N_GATEWAY_FAIL --> Z_END_ERROR;
    end

    %% Styling (Optional)
    classDef default fill:#e6f3ff,stroke:#007bff,stroke-width:2px;
    classDef review fill:#fff9c4,stroke:#fbc02d,stroke-width:2px;
    classDef decision fill:#fff3cd,stroke:#ffc107,stroke-width:2px;
    classDef errorNode fill:#f8d7da,stroke:#dc3545,stroke-width:2px;
    classDef successNode fill:#d4edda,stroke:#28a745,stroke-width:2px;

    class H,I,M,R,U decision;
    class G,J,K review;
    class N_SUPPRESSED,N_ATTACHMENT,T,N_GATEWAY_FAIL errorNode;
    class S,Z_SUCCESS successNode;
```

**Key Elements Customized for Mcp Email (Human in the Loop):**
*   **AI Drafting Phase:** Clearly shows the AI's role in preparing the initial draft.
*   **Human Review Workflow Integration:** Central to this process, showing submission to and actions from a review system.
*   **Reviewer Actions:** Includes Approve, Reject, Edit.
*   **Post-Approval Steps:** Details actions taken *after* a human has approved the email, including suppression checks and final dispatch.
*   **Error Handling:** Differentiates errors in drafting, review system interaction, and post-approval sending.
*   **Notifications:** Highlights notifications to the original requester and potentially reviewers at various stages (draft submitted, draft rejected, email sent).
*   **Completion Paths:** Multiple end states depending on approval, rejection, or sending errors.

