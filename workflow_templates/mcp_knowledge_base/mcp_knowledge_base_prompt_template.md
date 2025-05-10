### Prompt Template: Mcp Knowledge Base - Query Information

**1. Objective/Goal of this Prompt:**
   - To query the Mcp Knowledge Base for specific information or to get answers to questions based on its stored content.

**2. User/System Input Variables:**
   - `{{query_text}}`: (The natural language question or search query, e.g., "What is our company policy on remote work?", "Find all documents related to Project Alpha Q1 results.", "Who is the primary contact for Client Y?")
   - `{{filter_criteria}}`: (Optional: Structured criteria to narrow down the search, e.g., `{"document_type": "SOP", "creation_date_after": "2024-01-01", "keywords": ["security", "compliance"]}`)
   - `{{max_results}}`: (Optional: Maximum number of results to return, e.g., 5)
   - `{{response_format_preference}}`: (Optional: Preferred format for the answer, e.g., "summary", "direct_quote_with_source", "list_of_documents")

**3. Contextual Instructions for AI (Mcp Knowledge Base):**
   - Desired Output Format: (Based on `response_format_preference` or a default (e.g., concise answer with source links).)
   - Tone/Style: (Informative, factual, and neutral.)
   - Key information to focus on or exclude: (Prioritize information from most recently updated documents unless specified otherwise. Clearly cite sources for all information provided.)

**4. Example Usage:**
   - `query_text`: "What are the steps for onboarding a new employee?"
   - `filter_criteria`: `{"document_type": "HR_Policy", "status": "active"}`
   - `max_results`: 1
   - `response_format_preference`: "step_by_step_list_with_source_document_link"

**5. Expected Output/Action:**
   - The Mcp Knowledge Base will:
     1. Parse the `query_text` and `filter_criteria`.
     2. Search its indexed content for relevant information.
     3. Rank and select the most relevant results up to `max_results`.
     4. Formulate an answer in the `response_format_preference` (or default format), including citations or links to source documents.
     5. Return the answer to the requester, e.g., "The steps for onboarding a new employee are: 1. [Step 1], 2. [Step 2]... (Source: HR Onboarding Policy V3.2, link: /docs/hr_onboarding_v3.2.pdf)."
