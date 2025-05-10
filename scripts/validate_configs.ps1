# Workflow Templates YAML Validator
# This script validates the YAML configuration files in the workflow_templates directory
# Checks syntax, required fields, and provides helpful error messages

param (
    [string]$ConfigPath = "..\workflow_templates",
    [switch]$Verbose
)

# Make sure we have the required module
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Host "The 'powershell-yaml' module is required. Would you like to install it now? (Y/N)"
    $confirm = Read-Host
    if ($confirm -eq 'Y' -or $confirm -eq 'y') {
        Install-Module -Name powershell-yaml -Force -Scope CurrentUser
    }
    else {
        Write-Host "Please install the 'powershell-yaml' module manually using:"
        Write-Host "Install-Module -Name powershell-yaml -Force -Scope CurrentUser"
        exit 1
    }
}

Import-Module powershell-yaml

# Required fields for all configs
$requiredFields = @(
    "description", 
    "integrations", 
    "knowledge_sources", 
    "workflow_parameters", 
    "trigger_conditions", 
    "logging", 
    "security"
)

# Colors for output
$colorSuccess = "Green"
$colorError = "Red"
$colorWarning = "Yellow"
$colorInfo = "Cyan"

Write-Host "Starting validation of YAML configuration files..." -ForegroundColor $colorInfo

$configFiles = Get-ChildItem -Path $ConfigPath -Recurse -Filter "*_config_template.yaml"
$totalFiles = $configFiles.Count
$validFiles = 0
$errorFiles = 0

Write-Host "Found $totalFiles configuration files to validate." -ForegroundColor $colorInfo

foreach ($file in $configFiles) {
    $fileErrors = 0
    $fileWarnings = 0
    
    Write-Host "`nValidating $($file.FullName)..." -ForegroundColor $colorInfo
    
    try {
        # Read and parse YAML
        $content = Get-Content -Path $file.FullName -Raw
        $yaml = ConvertFrom-Yaml -Yaml $content -ErrorAction Stop
        
        # Check for required fields
        foreach ($field in $requiredFields) {
            if (-not $yaml.ContainsKey($field)) {
                Write-Host "  ERROR: Missing required field '$field'" -ForegroundColor $colorError
                $fileErrors++
            }
        }
        
        # Check for placeholder URLs that need replacing
        $yamlString = $content.ToLower()
        if ($yamlString -match "http:\/\/[a-z-]+\-service" -or 
            $yamlString -match "yourcompany\.com" -or 
            $yamlString -match "example\.com") {
            Write-Host "  WARNING: File contains placeholder URLs that need to be replaced" -ForegroundColor $colorWarning
            $fileWarnings++
        }
        
        # Check for Unix-style paths on Windows
        if ($yamlString -match "\/var\/log\/" -or 
            $yamlString -match "\/path\/to\/") {
            Write-Host "  WARNING: File contains Unix-style paths that should be adapted for Windows" -ForegroundColor $colorWarning
            $fileWarnings++
        }
        
        # Check for future dates
        if ($yamlString -match "202[5-9][-]") {
            Write-Host "  WARNING: File contains future dates (2025+) that should be updated" -ForegroundColor $colorWarning
            $fileWarnings++
        }
        
        if ($fileErrors -eq 0) {
            Write-Host "  VALID YAML: Syntax check passed" -ForegroundColor $colorSuccess
            $validFiles++
            
            if ($fileWarnings -gt 0) {
                Write-Host "  File passed validation with $fileWarnings warnings" -ForegroundColor $colorWarning
            }
            else {
                Write-Host "  File passed validation with no warnings" -ForegroundColor $colorSuccess
            }
        }
        else {
            Write-Host "  File failed validation with $fileErrors errors and $fileWarnings warnings" -ForegroundColor $colorError
            $errorFiles++
        }
    }
    catch {
        Write-Host "  ERROR: Invalid YAML syntax: $_" -ForegroundColor $colorError
        $errorFiles++
    }
    
    if ($Verbose) {
        Write-Host "  File details: Size: $($file.Length) bytes, Last modified: $($file.LastWriteTime)" -ForegroundColor $colorInfo
    }
}

Write-Host "`nValidation Summary:" -ForegroundColor $colorInfo
Write-Host "  Total files validated: $totalFiles" -ForegroundColor $colorInfo
Write-Host "  Valid files: $validFiles" -ForegroundColor $colorSuccess
Write-Host "  Files with errors: $errorFiles" -ForegroundColor ($errorFiles -gt 0 ? $colorError : $colorSuccess)

if ($errorFiles -gt 0) {
    Write-Host "`nPlease fix the errors above before implementing these templates." -ForegroundColor $colorInfo
    exit 1
}
else {
    Write-Host "`nAll configuration files passed basic validation. You may still need to replace placeholders and adapt paths." -ForegroundColor $colorSuccess
    exit 0
} 