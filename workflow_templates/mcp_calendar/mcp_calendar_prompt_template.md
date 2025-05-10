### Prompt Template: Mcp Calendar - Manage Calendar Events

**1. Objective/Goal of this Prompt:**
   - To instruct the Mcp Calendar assistant to create, find, update, or delete calendar events for specified users or resources.

**2. User/System Input Variables:**
   - `{{action}}`: (The desired action, e.g., "create_event", "find_events", "update_event", "delete_event")
   - `{{calendar_ids}}`: (List of calendar IDs to interact with, e.g., `["user1@example.com", "meeting_room_A@example.com"]`)
   - `{{event_details}}`: (Object containing event information. Structure varies based on action.)
     - For `create_event`: `{"summary": "Team Meeting", "start_time": "YYYY-MM-DDTHH:MM:SSZ", "end_time": "YYYY-MM-DDTHH:MM:SSZ", "attendees": ["user2@example.com", "user3@example.com"], "location": "Conference Room 1", "description": "Weekly sync-up"}`
     - For `find_events`: `{"time_min": "YYYY-MM-DDTHH:MM:SSZ", "time_max": "YYYY-MM-DDTHH:MM:SSZ", "query_text": "Project Alpha meeting", "max_results": 10}`
     - For `update_event`: `{"event_id": "existing_event_id_to_update", "updated_fields": {"summary": "Revised Team Meeting", "location": "Virtual Meeting"}}`
     - For `delete_event`: `{"event_id": "existing_event_id_to_delete"}`
   - `{{send_notifications}}`: (Optional, boolean for create/update/delete: Whether to send notifications to attendees, e.g., true/false. Defaults to true for changes.)
   - `{{user_on_behalf_of}}`: (Optional: If the Main Assistant or another user is making the request on behalf of someone else, specify their ID, e.g., "manager_user_id_for_permissions_check")

**3. Contextual Instructions for AI (Mcp Calendar):**
   - Desired Output Format:
     - `create_event`: Confirmation with event ID and link.
     - `find_events`: List of event objects matching criteria.
     - `update_event`: Confirmation of update with event ID.
     - `delete_event`: Confirmation of deletion.
   - Tone/Style: (Factual and confirmatory.)
   - Key information to focus on or exclude: (Ensure time zones are handled correctly. For `find_events`, provide clear summaries. For modifications, clearly state what was changed.)

**4. Example Usage (Create Event):**
   - `action`: "create_event"
   - `calendar_ids`: `["project_team_calendar@example.com"]`
   - `event_details`: `{"summary": "Project Phoenix Kick-off", "start_time": "2025-06-01T10:00:00-07:00", "end_time": "2025-06-01T11:30:00-07:00", "attendees": ["userA@example.com", "userB@example.com"], "location": "Main Conference Hall", "description": "Initial planning session for Project Phoenix."}`
   - `send_notifications`: true

**5. Expected Output/Action:**
   - The Mcp Calendar assistant will:
     1. Validate the `action` and required fields in `event_details`.
     2. Authenticate and authorize access to the specified `calendar_ids` (potentially checking `user_on_behalf_of` permissions).
     3. Perform the requested calendar operation (create, find, update, delete) using the integrated calendar service API.
     4. If `send_notifications` is true for create/update/delete, ensure the calendar service sends them.
     5. Return a confirmation message or the requested data, e.g., for `create_event`: "Event 'Project Phoenix Kick-off' created successfully. Event ID: CAL-EVT-9876. Link: [calendar_event_link]"
