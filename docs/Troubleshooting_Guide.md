# Troubleshooting Guide for Workflow Templates

This guide provides solutions for common issues you might encounter when implementing the Mcp Assistants and Workflow Templates.

## Table of Contents

1. [Configuration Issues](#configuration-issues)
2. [API Integration Issues](#api-integration-issues)
3. [Mermaid Flowchart Rendering](#mermaid-flowchart-rendering)
4. [Path and Platform Compatibility](#path-and-platform-compatibility)
5. [Template Variables and Placeholders](#template-variables-and-placeholders)
6. [Validation and Testing](#validation-and-testing)

## Configuration Issues

### Issue: YAML Configuration Files Syntax Errors

**Symptoms:**
- Error messages when loading configuration files
- Services failing to start
- "Invalid YAML" errors

**Solutions:**
- Use the validation script in `scripts/validate_configs.ps1` to check your YAML files
- Ensure proper indentation (YAML is sensitive to spaces)
- Avoid tab characters, use spaces instead
- Use quotes around strings containing special characters

### Issue: Missing Required Configuration Fields

**Symptoms:**
- Workflows fail to initialize
- Error logs showing missing properties

**Solutions:**
- Run validation script to identify missing fields
- Review the master template structure document
- Ensure all required sections are present and properly populated

### Issue: Environment Variables Not Being Recognized

**Symptoms:**
- "Missing API key" errors
- Authentication failures

**Solutions:**
- Verify environment variables are correctly set at the system or user level
- Check naming conventions (case-sensitive in some systems)
- For Windows, restart applications after setting new environment variables
- Consider using a `.env` file with a proper loader for development

## API Integration Issues

### Issue: API Connection Failures

**Symptoms:**
- Timeout errors
- Connection refused errors
- SSL/TLS errors

**Solutions:**
- Verify endpoint URLs are correct and accessible
- Check network connectivity and firewall settings
- Ensure API credentials are valid and have proper permissions
- Verify SSL certificates are valid and recognized

### Issue: API Rate Limiting

**Symptoms:**
- "Too many requests" errors
- Throttling messages
- Inconsistent API response times

**Solutions:**
- Implement exponential backoff and retry mechanisms
- Adjust `rate_limit_per_minute` in configuration files
- Consider batching requests where applicable
- Use queuing systems for high-volume operations

## Mermaid Flowchart Rendering

### Issue: Flowcharts Not Rendering Properly

**Symptoms:**
- Diagrams appear as code instead of visualizations
- Incorrect connections or layout

**Solutions:**
- Use VS Code with the Markdown Preview Mermaid extension
- Try online Mermaid editors like https://mermaid.live
- Ensure Mermaid syntax is correct (check indentation, arrow types)
- Update to the latest version of your Markdown viewer

### Issue: Custom Styling Not Applied to Flowcharts

**Symptoms:**
- Default colors/styles showing instead of custom ones
- Missing node styles

**Solutions:**
- Verify CSS class definitions match the class assignments
- Check that your Markdown renderer supports Mermaid styling
- Simplify styles for better compatibility across platforms

## Path and Platform Compatibility

### Issue: Path Separators in Configuration Files

**Symptoms:**
- File not found errors
- Access denied errors
- Incorrect path resolution

**Solutions:**
- On Windows, use backslashes `\` or escaped backslashes `\\` in paths
- For cross-platform compatibility, consider using relative paths where possible
- Replace Unix-style paths like `/var/log/` with Windows equivalents like `C:\logs\`
- Use environment variables to define base paths that differ between environments

### Issue: Line Ending Differences

**Symptoms:**
- Unexpected characters in files
- Parser errors with no clear cause

**Solutions:**
- Set consistent line endings in your editor (LF or CRLF)
- Use `.gitattributes` to enforce consistent line endings if using Git
- Consider using tools like dos2unix or unix2dos when necessary

## Template Variables and Placeholders

### Issue: Unresolved Template Variables

**Symptoms:**
- Templates showing raw `{{variable}}` syntax in output
- Missing data in generated content

**Solutions:**
- Verify all required variables are defined and passed to the template
- Check for typos in variable names (case-sensitive)
- Implement fallback values for optional variables
- Add validation for required variables before template processing

### Issue: Date/Time Format Incompatibilities

**Symptoms:**
- Date parsing errors
- Incorrect date representations

**Solutions:**
- Use ISO 8601 format (YYYY-MM-DD) for maximum compatibility
- Include timezone information where relevant
- Replace placeholder dates (2025+) with current dates

## Validation and Testing

### Issue: Difficulty Validating Template Implementations

**Symptoms:**
- Uncertainty about whether templates are implemented correctly
- Unexpected behavior in production

**Solutions:**
- Use the provided validation script to check syntax and required fields
- Create a test environment with sample data to verify workflows
- Develop unit tests for critical components
- Implement logging at key points to trace execution flow

### Issue: Integration Testing Challenges

**Symptoms:**
- Components work individually but fail when connected
- Difficult to reproduce issues

**Solutions:**
- Create end-to-end test scenarios that cover common workflows
- Use mock services for external dependencies during testing
- Implement comprehensive logging across all components
- Consider developing a simplified test harness for the integration points

## Additional Resources

- Use the PowerShell validation script in `scripts/validate_configs.ps1`
- Refer to the master template structures document for detailed field requirements
- For Mermaid flowchart guidance, visit [Mermaid Documentation](https://mermaid-js.github.io/mermaid/)
- For YAML syntax help, see [YAML Reference Card](https://yaml.org/refcard.html) 