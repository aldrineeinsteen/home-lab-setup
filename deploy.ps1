# Home Lab Pi-hole Deployment Script (PowerShell)
# This script helps you deploy Pi-hole using Ansible on Windows

param(
    [switch]$DryRun,
    [switch]$Check,
    [switch]$Verbose,
    [switch]$Help
)

# Colors for output
$Green = "Green"
$Red = "Red"
$Yellow = "Yellow"
$Blue = "Cyan"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Show-Help {
    Write-ColorOutput "Home Lab Pi-hole Deployment Script" $Blue
    Write-ColorOutput "=====================================" $Blue
    Write-Host ""
    Write-Host "Usage: .\deploy.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -DryRun    Run in dry-run mode (check mode without changes)"
    Write-Host "  -Check     Same as -DryRun"
    Write-Host "  -Verbose   Run with verbose output"
    Write-Host "  -Help      Show this help message"
    Write-Host ""
    Write-Host "Prerequisites:"
    Write-Host "  1. Copy .env.template.sh to .env.sh and configure your settings"
    Write-Host "  2. Install Ansible (pip install ansible)"
    Write-Host "  3. Ensure SSH connectivity to target host"
    exit 0
}

if ($Help) {
    Show-Help
}

Write-ColorOutput "========================================" $Blue
Write-ColorOutput "  Home Lab Pi-hole Deployment Script" $Blue
Write-ColorOutput "========================================" $Blue

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$AnsibleDir = Join-Path $ProjectRoot "ansible"
$EnvFile = Join-Path $ProjectRoot ".env.sh"

# Check if .env.sh exists
if (-not (Test-Path $EnvFile)) {
    Write-ColorOutput "Error: .env.sh file not found!" $Red
    Write-ColorOutput "Please copy .env.template.sh to .env.sh and configure your settings:" $Yellow
    Write-Host "  Copy-Item .env.template.sh .env.sh"
    Write-Host "  # Edit .env.sh with your actual configuration"
    exit 1
}

# Check if Ansible is installed
try {
    $null = Get-Command ansible-playbook -ErrorAction Stop
    Write-ColorOutput "Ansible found!" $Green
} catch {
    Write-ColorOutput "Error: Ansible is not installed!" $Red
    Write-ColorOutput "Please install Ansible:" $Yellow
    Write-Host "  pip install ansible"
    Write-Host "  # or use Windows Subsystem for Linux (WSL)"
    exit 1
}

# Load environment variables from .env.sh
Write-ColorOutput "Loading environment variables..." $Green
$envVars = @{}

# Parse .env.sh file (basic parsing)
Get-Content $EnvFile | ForEach-Object {
    if ($_ -match '^export\s+([^=]+)=(.*)$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim().Trim('"').Trim("'")
        $envVars[$key] = $value
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

# Validate required variables
if (-not $envVars["PIHOLE_HOST"] -or -not $envVars["PIHOLE_USER"]) {
    Write-ColorOutput "Error: Required environment variables not set!" $Red
    Write-Host "Please ensure PIHOLE_HOST and PIHOLE_USER are configured in .env.sh"
    exit 1
}

$piholeHost = $envVars["PIHOLE_HOST"]
$piholeUser = $envVars["PIHOLE_USER"]
$piholeWebPort = $envVars["PIHOLE_WEBPORT"] ?? "80"
$piholeDnsPort = $envVars["PIHOLE_DNSPORT"] ?? "53"

Write-ColorOutput "Target: $piholeUser@$piholeHost" $Green

# Change to ansible directory
Set-Location $AnsibleDir

# Run syntax check
Write-ColorOutput "Checking playbook syntax..." $Green
try {
    & ansible-playbook -i inventory/hosts.yml site.yml --syntax-check
    if ($LASTEXITCODE -ne 0) {
        throw "Syntax check failed"
    }
} catch {
    Write-ColorOutput "Syntax check failed!" $Red
    exit 1
}

# Set dry-run mode if Check switch is used
if ($Check) { $DryRun = $true }

# Build ansible command
$ansibleArgs = @("-i", "inventory/hosts.yml", "site.yml")

if ($DryRun) {
    Write-ColorOutput "Running in DRY-RUN mode - no changes will be made" $Blue
    $ansibleArgs += "--check", "--diff"
} else {
    # Ask for confirmation only if not dry-run
    Write-ColorOutput "Ready to deploy Pi-hole to $piholeHost" $Yellow
    Write-ColorOutput "Web interface will be available at: http://$piholeHost`:$piholeWebPort/admin/" $Yellow
    Write-ColorOutput "DNS server will be available at: $piholeHost`:$piholeDnsPort" $Yellow
    Write-Host ""

    $confirmation = Read-Host "Continue with deployment? (y/N)"
    if ($confirmation -ne "y" -and $confirmation -ne "Y") {
        Write-Host "Deployment cancelled."
        exit 0
    }
    $ansibleArgs += "--ask-become-pass"
}

if ($Verbose) {
    $ansibleArgs += "-v"
}

# Run the playbook
if ($DryRun) {
    Write-ColorOutput "Starting Pi-hole deployment dry-run..." $Green
} else {
    Write-ColorOutput "Starting Pi-hole deployment..." $Green
}

try {
    & ansible-playbook @ansibleArgs
    
    if ($LASTEXITCODE -eq 0) {
        if ($DryRun) {
            Write-ColorOutput "========================================" $Blue
            Write-ColorOutput "  Dry-Run Complete!" $Blue
            Write-ColorOutput "========================================" $Blue
            Write-ColorOutput "No actual changes were made to the system." $Blue
            Write-ColorOutput "Review the output above to see what would be changed." $Blue
        } else {
            Write-ColorOutput "========================================" $Green
            Write-ColorOutput "  Deployment Complete!" $Green
            Write-ColorOutput "========================================" $Green
            Write-ColorOutput "Pi-hole web interface: http://$piholeHost`:$piholeWebPort/admin/" $Green
            Write-ColorOutput "DNS server: $piholeHost`:$piholeDnsPort" $Green
            Write-Host ""
            Write-ColorOutput "Next steps:" $Yellow
            Write-Host "1. Configure your router to use $piholeHost as DNS server"
            Write-Host "2. Or configure individual devices to use this DNS server"
            Write-Host "3. Access the web interface to customize settings"
        }
    } else {
        if ($DryRun) {
            Write-ColorOutput "Dry-run failed!" $Red
        } else {
            Write-ColorOutput "Deployment failed!" $Red
        }
        exit 1
    }
} catch {
    Write-ColorOutput "Deployment failed: $_" $Red
    exit 1
}