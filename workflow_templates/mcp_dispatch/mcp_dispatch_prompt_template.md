### Prompt Template: Mcp Dispatch - Assign Task/Resource

**1. Objective/Goal of this Prompt:**
   - To instruct the Mcp Dispatch assistant to assign a specific task, job, or resource (e.g., field technician, delivery driver, equipment) to a designated target (e.g., location, customer, incident) based on various criteria like availability, proximity, skills, and priority.

**2. User/System Input Variables:**
   - `{{task_job_id}}`: (Unique identifier for the task or job needing dispatch, e.g., "SERVICE_CALL_789", "DELIVERY_ORDER_456")
   - `{{task_description}}`: (Brief description of the task, e.g., "Repair HVAC unit", "Deliver package to customer", "Investigate network outage")
   - `{{target_location}}`: (Address or coordinates of where the task needs to be performed, e.g., `{"address": "123 Main St, Anytown, USA"}` or `{"latitude": 34.0522, "longitude": -118.2437}`)
   - `{{required_skills}}`: (Optional: List of skills needed for the task, e.g., `["HVAC_certified", "level_2_technician", "crane_operator"]`)
   - `{{priority}}`: (Task priority, e.g., "High", "Medium", "Low", "Emergency")
   - `{{preferred_resource_id}}`: (Optional: If a specific resource/personnel is preferred, their ID.)
   - `{{earliest_start_time}}`: (Optional: Earliest time the task can begin, e.g., "YYYY-MM-DDTHH:MM:SSZ")
   - `{{latest_end_time_or_due_date}}`: (Optional: Deadline for task completion, e.g., "YYYY-MM-DDTHH:MM:SSZ")
   - `{{additional_context}}`: (Optional: Any other relevant information, e.g., "Customer reports loud banging noise.", "Gate code: #1234")

**3. Contextual Instructions for AI (Mcp Dispatch):**
   - Desired Output Format: (Confirmation of dispatch, including assigned resource ID, estimated time of arrival (ETA) if applicable, and a dispatch reference ID.)
   - Tone/Style: (Efficient, clear, and decisive.)
   - Key information to focus on or exclude: (Optimize for factors like proximity, skill match, availability, and priority. Clearly state if no suitable resource is found or if there are conflicts. Provide ETA if possible.)

**4. Example Usage:**
   - `task_job_id`: "INCIDENT_A452"
   - `task_description`: "Power outage reported at downtown substation."
   - `target_location`: `{"address": "55 Power Grid Rd, Anytown, USA"}`
   - `required_skills`: `["high_voltage_certified", "substation_maintenance"]`
   - `priority`: "Emergency"
   - `earliest_start_time`: "now"
   - `additional_context`: "Entry requires security clearance. Contact site manager on arrival."

**5. Expected Output/Action:**
   - The Mcp Dispatch assistant will:
     1. Validate the input parameters.
     2. Query available resources (personnel, vehicles, equipment) based on current status, location, `required_skills`, and availability within the `earliest_start_time` and `latest_end_time_or_due_date`.
     3. Apply dispatch logic (e.g., nearest available qualified unit, round-robin, skill-based routing, priority weighting).
     4. If a suitable resource is found:
        a. Assign the `task_job_id` to the selected resource.
        b. Notify the resource with task details and `target_location`.
        c. Calculate an ETA if applicable.
        d. Return a confirmation: "Task INCIDENT_A452 assigned to Technician ID T789 (John Doe). ETA: 45 minutes. Dispatch ID: DISP-XYZ123."
     5. If no suitable resource is found or if there are conflicts:
        a. Log the failure to dispatch.
        b. Return a message: "Unable to dispatch task INCIDENT_A452. No suitable resources available meeting criteria. Options: [Suggest alternatives like queuing, widening search, or manual review]."
     6. Log the dispatch attempt and outcome.
