## Master Template Structures for Mcp Assistants and Workflows

This document outlines the master structures for the four types of templates (Prompt, Configuration, Operational Guideline, and Flowchart) to be created for each Mcp assistant and workflow. These master structures will ensure consistency and comprehensiveness when drafting the individual templates.

### 1. Master Prompt Template Structure (PT)

**Purpose:** To provide a standardized format for users or systems to interact with or trigger an Mcp assistant or workflow effectively.

**Structure:**

```markdown
### Prompt Template: [Assistant/Workflow Name] - [Specific Task/Interaction]

**1. Objective/Goal of this Prompt:**
   - (Clearly state what this specific prompt aims to achieve, e.g., "To retrieve customer contact history for Mcp Knowledge Base," "To initiate the Mcp Invoice generation for a completed project.")

**2. User/System Input Variables:**
   - `{{variable_name_1}}`: (Description of the variable, e.g., Customer ID, Project Name, Date Range)
   - `{{variable_name_2}}`: (Description)
   - (Add all necessary input placeholders)

**3. Contextual Instructions for AI (If applicable for direct AI interaction):**
   - Desired Output Format: (e.g., JSON, plain text summary, bullet points)
   - Tone/Style (if generating text): (e.g., Formal, concise, detailed)
   - Key information to focus on or exclude:

**4. Example Usage:**
   - (Provide a concrete example of how to fill out this prompt with sample data for the variables.)

**5. Expected Output/Action:**
   - (Describe what the system/assistant should do or produce in response to this prompt, e.g., "Returns a JSON object with customer history," "Triggers the Mcp Invoice workflow and returns a confirmation ID.")
```

### 2. Master Configuration Template Structure (CT)

**Purpose:** To define the setup parameters, integrations, and operational settings for an Mcp assistant or workflow.

**Structure:**

```yaml
# Configuration Template: [Assistant/Workflow Name]

# 1. General Settings
assistant_workflow_name: "[Name]"
version: "1.0.0"
status: "Development" # Options: Development, Active, Inactive, Deprecated
description: "[Brief description of the assistant/workflow]"
owner_team: "[Team responsible]"

# 2. API & Service Integrations (Repeat for each service)
integrations:
  - service_name: "[e.g., Email_Service, Calendar_API, CRM_System]"
    api_endpoint: "[URL]"
    api_key_env_var: "[Environment variable name for API key, e.g., MCP_EMAIL_API_KEY]"
    # Add other necessary credentials or connection strings (e.g., client_id, client_secret, database_url)
    timeout_seconds: 30
    retry_attempts: 3

# 3. Knowledge Base & Data Source Links/Paths
knowledge_sources:
  - name: "Primary Business KB"
    type: "[e.g., Database, Document Store, API]"
    path_or_endpoint: "[Path/URL to Mcp Knowledge Base or relevant section]"
    access_credentials_env_var: "[Optional: Env var for credentials]"
  # Add other relevant KBs or data sources

# 4. Workflow-Specific Parameters (Highly variable based on assistant/workflow)
workflow_parameters:
  parameter_name_1: "[Default Value]"
  parameter_description_1: "[Description of what this parameter does]"
  # Add more parameters as needed

# 5. Trigger Conditions (For event-driven workflows)
trigger_conditions: # (e.g., for "Add to Knowledge Base" workflow)
  - event_source: "[e.g., Document_Upload_System, Email_Parser]"
    event_type: "[e.g., new_document_added, document_updated]"
    filters: # Optional filters on the event
      # - field: "file_type"
      #   value: "pdf"

# 6. Logging & Monitoring
logging:
  log_level: "INFO" # Options: DEBUG, INFO, WARNING, ERROR, CRITICAL
  log_destination: "[e.g., File path, Centralized Logging Service URL]"
monitoring:
  metrics_endpoint: "[Optional: Endpoint for exposing performance metrics]"
  alerting_rules:
    # - metric: "error_rate"
    #   threshold: "5%"
    #   notification_channel: "[e.g., Email, Slack]"

# 7. Security & Permissions
security:
  required_roles_for_execution: # Roles needed to trigger/manage this workflow/assistant
    # - "OfficeManager"
    # - "SystemAdmin"
  data_encryption_at_rest: true
  data_encryption_in_transit: true

# 8. Human-in-the-Loop (HITL) Configuration (If applicable)
hitl_config:
  trigger_on_confidence_below: 0.7 # Example: Trigger HITL if AI confidence is below 70%
  escalation_queue: "[Name of human review queue or contact point]"
  max_wait_time_for_human_seconds: 3600
```

### 3. Master Operational Guideline Template Structure (OGT)

**Purpose:** To define the purpose, scope, behavior, constraints, and operational procedures for an Mcp assistant or workflow. (Adapted from the previously created `custom_agent_instructions_template.md`)

**Structure:**

```markdown
## Operational Guideline: [Assistant/Workflow Name]

**Version:** 1.0 | **Last Updated:** YYYY-MM-DD | **Owner:** [Team/Individual]

**Section 1: Identity & Core Purpose**
   1.1. **Name/Identifier:** [e.g., Mcp Email (No Human in Loop), Workflow - SMS Inbound]
   1.2. **Primary User/Team:** [Who interacts with or benefits from this?]
   1.3. **Core Mission/Overall Goal:** [1-2 sentences: Primary objective and value created.]
   1.4. **Key Performance Indicators (KPIs) for Success:** [How is success measured?]

**Section 2: Foundational Knowledge & Context**
   2.1. **Link to Overall Business Master Prompt:** [URL or reference to the main company context document]
   2.2. **Specific Domain Knowledge Sources:** [List databases, style guides, product docs, etc., this assistant/workflow MUST use or be aware of. Prioritize.]
   2.3. **Key Interacting Systems/Assistants:** [Other Mcp assistants or systems this one relies on or provides input to.]

**Section 3: Operational Parameters & Task Definitions**
   3.1. **Primary Tasks & Responsibilities:** [Detailed list of what it does.]
       - Task 1: [Description, Desired Outcome, Key Steps]
       - Task 2: [...]
   3.2. **Input Triggers/Formats:** [How is it activated? What data format does it expect?]
   3.3. **Expected Outputs/Formats:** [What does it produce? In what format?]
   3.4. **Step-by-Step Process Overview (High-Level):** [Brief overview of its internal workflow.]
   3.5. **Decision-Making Logic:** [Key rules or models it uses. When to consult the "Mcp Thinking Agent".]

**Section 4: Communication Style & Tone (If assistant interacts externally/with users)**
   4.1. **Overall Tone:** [e.g., Professional, Neutral, Friendly but direct]
   4.2. **Specific Language Guidelines:** [Use of jargon, addressing users, etc.]
   4.3. **Confirmation/Notification Practices:** [When and how to send confirmations or notifications.]

**Section 5: Constraints & Boundaries (Obstructions)**
   5.1. **Explicit Prohibitions:** [What it MUST NEVER do or say.]
   5.2. **Scope Limitations:** [Tasks OUTSIDE its scope.]
   5.3. **Data Privacy & Security Rules:** [Confidential data types, handling protocols. Adherence to AirQ principles if applicable.]
   5.4. **Operational Limits:** [e.g., Max API calls per minute, data processing limits.]

**Section 6: Error Handling & Escalation Procedures**
   6.1. **Common Error Scenarios & Codes:** [List known errors and their meanings.]
   6.2. **Automated Resolution Steps:** [How it attempts to self-correct.]
   6.3. **Escalation Path:** [When and how to escalate to Main Assistant, specific human role, or log for review.]

**Section 7: Human-in-the-Loop (HITL) Procedures (If applicable, e.g., Mcp Email HITL)**
   7.1. **Criteria for Triggering HITL:** [e.g., Low confidence score, specific keywords, ambiguity detected.]
   7.2. **Information to Provide to Human Reviewer:** [What context/data is presented?]
   7.3. **Process for Incorporating Human Feedback/Decision:** [How is the human input used to continue the task?]
   7.4. **Learning from HITL:** [How are HITL instances used to improve the automated process?]

**Section 8: Maintenance & Updates**
   8.1. **Update Frequency for these Guidelines:** [e.g., Quarterly, As needed]
   8.2. **Key Contacts for Issues/Updates:** [Who to contact for problems or suggestions.]
   8.3. **Monitoring & Performance Review:** [How its performance is tracked and reviewed.]

**Section 9: Dependencies on Proprietary Systems (e.g., AirQ)**
   9.1. **Interaction with AirQ OS:** [Describe how this assistant/workflow leverages or is managed by AirQ.]
   9.2. **Data Handling within AirQ:** [Specific protocols for data processed via AirQ.]
```

### 4. Master Flowchart Template Structure (FT)

**Purpose:** To visually or textually represent the process flow of an Mcp assistant or workflow.

**Structure (using Mermaid syntax as a primary example, with placeholders for customization):**

```markdown
### Flowchart: [Assistant/Workflow Name]

**Description:** (Brief overview of the process depicted in the flowchart.)

```mermaid
graph TD
    subgraph "Initiation & Input"
        A["Trigger: {{Workflow_Trigger_Description}} (e.g., Inbound SMS, API Call, Scheduled Event)"] --> B("Input Data: {{Input_Data_Description}}");
    end

    subgraph "Processing & Core Logic"
        B --> C["Validate Input: {{Validation_Checks}}"];
        C -- Valid --> D{"Decision Point / Thinking Agent Query: {{Decision_Question}}?"};
        C -- Invalid --> E["Error Handling: Log & Notify {{Notification_Target}} / Escalate to Main Assistant"];
        D -- Option 1 --> F1["Action/Sub-Process 1: {{Action1_Description}} (e.g., Query Mcp Knowledge Base)"];
        D -- Option 2 --> G1["Action/Sub-Process 2: {{Action2_Description}} (e.g., Call Mcp Calendar API)"];
        D -- Option N --> H1["Action/Sub-Process N: {{ActionN_Description}}"];
        F1 --> I{Is Human Intervention Needed? (HITL Check)};
        G1 --> I;
        H1 --> I;
    end

    subgraph "Human-in-the-Loop (Optional)"
        I -- Yes --> J["Route to Human Review Queue: {{Queue_Name}}"];
        J --> K("Human Action/Decision: {{Human_Input_Description}}");
        K --> L["Incorporate Human Feedback"];
        I -- No --> M["Continue Automated Process"];
        L --> M;
    end

    subgraph "Output & Completion"
        M --> N["Generate Output: {{Output_Data_Description}}"];
        N --> O["Log Action & Outcome: {{Logging_Details}}"];
        O --> P["Send Notifications (If any): {{Notification_Recipients_And_Content}}"];
        P --> Z(["End: {{Workflow_Completion_Status}}"]);
        E --> Z; # Error path completion
    end

    %% Styling (Optional)
    classDef default fill:#f9f,stroke:#333,stroke-width:2px;
    classDef errorNode fill:#ffcccc,stroke:#cc0000,stroke-width:2px;
    class E errorNode;
```

**Key Elements to Customize in Flowchart:**
*   `{{Workflow_Trigger_Description}}`: How the workflow starts.
*   `{{Input_Data_Description}}`: What data it receives.
*   `{{Validation_Checks}}`: How input is validated.
*   `{{Notification_Target}}`: Who gets notified of errors.
*   `{{Decision_Question}}`: Key decision points, possibly involving the Thinking Agent.
*   `{{ActionX_Description}}`: Specific steps or calls to other Mcp assistants/systems.
*   `HITL Check`: Conditions for human intervention.
*   `{{Queue_Name}}`: Where HITL tasks are routed.
*   `{{Human_Input_Description}}`: What the human provides.
*   `{{Output_Data_Description}}`: What the workflow produces.
*   `{{Logging_Details}}`: What gets logged.
*   `{{Notification_Recipients_And_Content}}`: Details of any final notifications.
*   `{{Workflow_Completion_Status}}`: How the workflow concludes.
```

This master structure document will serve as the foundation for creating the specific templates for each of the 14 workflows and assistants identified in `workflow_template_mapping.md`.
