## Workflow and Assistant Template Mapping

This document outlines the specific template types to be created for each workflow and Mcp assistant as per the user's request. The user has confirmed a desire for a combination of Prompt, Configuration, Operational Guideline, and Flowchart templates for each item.

**Key for Template Types:**
*   **PT:** Prompt Template (for user interaction or triggering)
*   **CT:** Configuration Template (for setup parameters, connections)
*   **OGT:** Operational Guideline Template (defining purpose, scope, style, constraints)
*   **FT:** Flowchart Template (visualizing the process flow)

**List of Workflows and Assistants with Required Templates:**

1.  **Main Assistant (Office Manager)**
    *   PT, CT, OGT, FT
    *   *Note:* This is a central control unit; templates will reflect its orchestration role.

2.  **Mcp Knowledge Base**
    *   PT (for querying/interacting), CT, OGT, FT (for data ingestion/retrieval processes)

3.  **Mcp Email (No Human in the Loop)**
    *   PT, CT, OGT, FT

4.  **Mcp Email (Human in the Loop)**
    *   PT, CT, OGT, FT
    *   *Note:* Templates will differ significantly from the 'no human in the loop' version, especially OGT and FT.

5.  **Mcp Calendar**
    *   PT, CT, OGT, FT

6.  **Mcp Receptionist**
    *   PT, CT, OGT, FT

7.  **Mcp Dispatch**
    *   PT, CT, OGT, FT

8.  **Mcp Scrape**
    *   PT, CT, OGT, FT

9.  **Mcp Invoice**
    *   PT, CT, OGT, FT

10. **Mcp Estimate**
    *   PT, CT, OGT, FT

11. **Workflow - SMS Inbound**
    *   PT (for how the system processes/interprets inbound SMS), CT, OGT, FT

12. **Workflow - SMS Outbound**
    *   PT (for triggering/crafting outbound SMS), CT, OGT, FT

13. **Mcp - Thinking Agent**
    *   PT, CT, OGT, FT
    *   *Note:* This agent determines which Mcp to use; templates will focus on its decision-making logic and routing.

14. **Workflow - Add to Knowledge Base**
    *   PT (e.g., for submitting documents), CT (for storage/indexing rules), OGT (for trigger conditions, acceptable formats, error handling), FT
    *   *Note:* Triggered when docs are added or updated.

This mapping confirms that a comprehensive set of four distinct templates will be developed for each of the 14 specified workflows and assistants. The next step will be to design a master structure for these templates.
