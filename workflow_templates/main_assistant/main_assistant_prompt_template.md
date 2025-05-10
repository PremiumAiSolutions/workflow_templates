### Prompt Template: Main Assistant (Office Manager) - Delegate Task to Mcp Assistant

**1. Objective/Goal of this Prompt:**
   - To instruct the Main Assistant (Office Manager) to delegate a specific task to an appropriate Mcp Assistant and monitor its execution.

**2. User/System Input Variables:**
   - `{{task_description}}`: (Detailed description of the task to be performed, e.g., "Schedule a meeting with Client X for next week regarding Project Y.", "Generate an invoice for completed services for Client Z, project ID 123.", "Scrape website ABC.com for new articles on topic 'AI in healthcare'.")
   - `{{target_mcp_assistant_suggestion}}`: (Optional: User's suggestion for which Mcp Assistant should handle the task, e.g., "Mcp Calendar", "Mcp Invoice", "Mcp Scrape")
   - `{{priority}}`: (Task priority, e.g., High, Medium, Low)
   - `{{due_date}}`: (Optional: Desired completion date/time for the task, e.g., "YYYY-MM-DD HH:MM")
   - `{{required_inputs_for_mcp}}`: (A structured object or string containing any specific data the target Mcp assistant will need, e.g., For Mcp Calendar: `{"client_name": "Client X", "topic": "Project Y", "preferred_times": ["next Monday AM", "next Tuesday PM"]}`)

**3. Contextual Instructions for AI (Main Assistant):**
   - Desired Output Format: (Confirmation of task delegation, including assigned Mcp Assistant and a tracking ID.)
   - Tone/Style: (Professional and confirmatory.)
   - Key information to focus on or exclude: (Ensure the Main Assistant confirms understanding and identifies the best Mcp Assistant if no suggestion is provided or if the suggestion is suboptimal. It should also confirm receipt of all necessary inputs for the delegated Mcp assistant.)

**4. Example Usage:**
   - `task_description`: "Generate an estimate for a new website development project for 'Tech Solutions Inc'. Scope includes 5 pages, e-commerce integration, and basic SEO. Details are in project brief #TS005."
   - `target_mcp_assistant_suggestion`: "Mcp Estimate"
   - `priority`: "High"
   - `due_date`: "2025-05-15 17:00"
   - `required_inputs_for_mcp`: `{"client_name": "Tech Solutions Inc.", "project_scope_document_id": "#TS005", "service_items": [{"item": "Website Design (5 pages)", "qty": 1}, {"item": "E-commerce Module", "qty": 1}, {"item": "Basic SEO Setup", "qty": 1}]}`

**5. Expected Output/Action:**
   - The Main Assistant (Office Manager) will:
     1. Analyze the `task_description`.
     2. Determine the most appropriate Mcp Assistant (e.g., Mcp Estimate, Mcp Calendar, Mcp Invoice) to handle the task, considering `target_mcp_assistant_suggestion` if provided.
     3. Verify that all `required_inputs_for_mcp` are sufficient for the chosen Mcp Assistant.
     4. Delegate the task to the selected Mcp Assistant.
     5. Return a confirmation message to the user, e.g., "Task 'Generate estimate for Tech Solutions Inc.' has been delegated to Mcp Estimate. Tracking ID: MA-TASK-001. Priority: High. Due: 2025-05-15 17:00."
     6. Monitor the task's progress via the Mcp Assistant.
