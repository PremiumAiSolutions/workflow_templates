### Prompt Template: Mcp Scrape - Scrape Web Content

**1. Objective/Goal of this Prompt:**
   - To instruct the Mcp Scrape assistant to extract specific data or content from one or more web pages (URLs) based on defined selectors or patterns.

**2. User/System Input Variables:**
   - `{{target_urls}}`: (List of one or more URLs to scrape, e.g., `["https://example.com/products", "https://blog.example.com/article-123"]`)
   - `{{data_to_extract}}`: (A structured object or list describing what data needs to be extracted from each URL. This could involve CSS selectors, XPath expressions, or semantic descriptions.)
     - Example: `[{"name": "product_title", "selector": "h1.product-title", "type": "text"}, {"name": "product_price", "selector": "span.price", "type": "number"}, {"name": "product_image_url", "selector": "img.main-product-image", "attribute": "src", "type": "url"}]`
     - Example (for a table): `{"name": "data_table", "selector": "table#results_table", "type": "table_to_json"}`
     - Example (for full page text): `{"name": "page_text", "type": "full_text_content"}`
   - `{{output_format}}`: (Desired format for the extracted data, e.g., "json", "csv", "text_file_per_url", "markdown")
   - `{{output_destination}}`: (Optional: Path to a file or a system location (e.g., Mcp Knowledge Base document ID) where the scraped data should be stored. If not provided, data might be returned directly in the response or a temporary location.)
   - `{{scraping_parameters}}`: (Optional: Object for advanced settings.)
     - `{"user_agent": "CustomScraperBot/1.0", "proxy_required": true, "render_javascript": true, "scroll_to_bottom_times": 3, "wait_for_selector": "#data-loaded-indicator", "cookies": [{"name": "session_id", "value": "xyz..."}]}`
   - `{{on_error_handling}}`: (Optional: How to handle errors for individual URLs or selectors, e.g., "skip_url_on_error", "return_partial_data", "fail_task_on_any_error". Defaults to "return_partial_data".)

**3. Contextual Instructions for AI (Mcp Scrape):**
   - Desired Output Format: (Confirmation of scraping completion, path to the output file/location, or the extracted data itself if small enough and `output_destination` is not set. Summary of URLs processed and any errors.)
   - Tone/Style: (Factual and informative.)
   - Key information to focus on or exclude: (Ensure accurate extraction based on selectors. Handle dynamic content if `render_javascript` is true. Respect website `robots.txt` and terms of service if configured to do so. Clearly report any URLs that failed to scrape or selectors that returned no data.)

**4. Example Usage:**
   - `target_urls`: `["https://www.example-ecommerce.com/category/laptops?page=1"]`
   - `data_to_extract`: `[{"name": "laptop_name", "selector": ".product-card .product-name", "type": "text_list"}, {"name": "laptop_price", "selector": ".product-card .product-price", "type": "text_list"}]`
   - `output_format`: "csv"
   - `output_destination`: "/home/ubuntu/scraped_data/laptops_page1.csv"
   - `scraping_parameters`: `{"render_javascript": false, "user_agent": "GoogleBot"}`

**5. Expected Output/Action:**
   - The Mcp Scrape assistant will:
     1. Validate input parameters, especially `target_urls` and `data_to_extract` structure.
     2. For each URL in `target_urls`:
        a. Fetch the web page content, applying `scraping_parameters` (user agent, proxy, JS rendering, scrolling, waits, cookies).
        b. Parse the HTML/content.
        c. Extract data based on the `data_to_extract` definitions (selectors, attributes).
        d. Handle errors for the URL/selector based on `on_error_handling` policy.
     3. Aggregate the extracted data from all URLs.
     4. Format the data according to `output_format`.
     5. Save the data to `output_destination` if provided, or prepare it for direct return.
     6. Return a confirmation message, e.g., "Scraping completed for 1 URL(s). Data saved to /home/ubuntu/scraped_data/laptops_page1.csv. 0 errors."
     7. If errors occurred: "Scraping completed for 1 URL(s). Data saved to /home/ubuntu/scraped_data/laptops_page1.csv. 1 URL failed (see log for details)."
     8. Log detailed scraping activity, including URLs processed, data points found/missed, and any errors.
