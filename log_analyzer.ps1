# Windows Network Setup Log Analyzer (PowerShell)
# Handles Unicode and provides detailed error analysis

param(
    [string]$LogPath = "C:\Windows\debug\NetSetup.LOG",
    [string]$OutputPath
)

# Error code reference table
$ErrorCodes = @{
    "0x0" = "Success"
    "0x2" = "File not found"
    "0x5" = "Access denied" 
    "0x43" = "Invalid computer name"
    "0x525" = "Domain controller not found"
    "0x52e" = "Invalid credentials"
    "0x534" = "Account restriction"
}

# Initialize counters
$stats = @{
    DomainJoins = 0
    WorkgroupJoins = 0
    Errors = 0
    ErrorDetails = @()
}

# Process log file
Get-Content $LogPath -Encoding UTF8 | ForEach-Object {
    if ($_ -match "NetpJoinDomain") { $stats.DomainJoins++ }
    if ($_ -match "NetpJoinWorkgroup") { $stats.WorkgroupJoins++ }
    
    if ($_ -match "status: (0x[0-9A-Fa-f]+)") {
        $code = $matches[1]
        if ($code -ne "0x0") {
            $stats.Errors++
            $description = if ($ErrorCodes.ContainsKey($code)) {
                $ErrorCodes[$code]
            } else {
                "Unknown error"
            }
            $errorInfo = @{
                Code = $code
                Description = $description
                Context = $_
            }
            $stats.ErrorDetails += $errorInfo
        }
    }
}

# Generate report
$report = @"
Windows Network Setup Log Analysis Report
==================================================
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

=== Basic Statistics ===
Domain Join Attempts: $($stats.DomainJoins)
Workgroup Joins: $($stats.WorkgroupJoins)
Errors Found: $($stats.Errors)

"@

# Add error details if any
if ($stats.Errors -gt 0) {
    $report += "`n=== Error Details ===`n"
    foreach ($error in $stats.ErrorDetails) {
        $report += "[Error $($stats.ErrorDetails.IndexOf($error)+1)]`n"
        $report += "Error Code: $($error.Code)`n"
        $report += "Description: $($error.Description)`n" 
        $report += "Context: $($error.Context)`n`n"
    }
} else {
    $report += "`nNo Errors Found`n"
}

# Output results
if ($OutputPath) {
    $report | Out-File $OutputPath -Encoding UTF8
    Write-Host "Report saved to: $OutputPath"
} else {
    $report
}
