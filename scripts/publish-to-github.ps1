<#
Publish the repository to GitHub from a local directory.
Usage:
  - Run from the project root or call from scripts folder: .\scripts\publish-to-github.ps1
  - Example (uses gh CLI to create and push remote):
    .\scripts\publish-to-github.ps1 -RepoName elk-logging-project -Owner your-github-username -CreateRemote

This script will:
  - Initialize Git repo if needed
  - Commit all files
  - Optionally create a GitHub repo using GitHub CLI (gh) and push

Note: gh CLI must be installed and authenticated (gh auth login) to use --CreateRemote
#>
param(
    [string]$RepoName = "elk-logging-project",
    [string]$Owner = "",
    [switch]$Private,
    [switch]$CreateRemote
)

# Ensure script runs from repo root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir
Set-Location ..\

# Check for git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "git is not found in PATH. Install git and try again."
    exit 1
}

# Initialize git if needed
if (-not (Test-Path -Path ".git")) {
    git init
    Write-Output "Initialized empty Git repository in $(Get-Location)\.git/"
} else {
    Write-Output "Git repository already initialized."
}

# Add files and commit
try {
    git add -A
    git commit -m "Initial commit: Centralized logging & monitoring with ELK Stack" -q
    Write-Output "Committed all files."
} catch {
    Write-Output "Nothing to commit or commit failed. Continuing..."
}

if ($CreateRemote) {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "The 'gh' CLI is not installed. Install it from https://cli.github.com/ and run 'gh auth login' to authenticate."
        exit 1
    }

    $visibility = if ($Private) { "--private" } else { "--public" }

    if (-not $Owner) {
        $Owner = Read-Host -Prompt "Enter GitHub owner (username or org) to create repo under"
    }

    $fullName = "$Owner/$RepoName"
    Write-Output "Creating remote repo $fullName on GitHub (visibility: $($visibility -replace '--',''))"
    gh repo create $fullName $visibility --source . --remote origin --push
    if ($LASTEXITCODE -eq 0) {
        Write-Output "Repository created and pushed to GitHub: https://github.com/$fullName"
    } else {
        Write-Error "Failed to create or push repo with gh."
    }
} else {
    Write-Output "No remote is created. To create one manually, run the commands below:";
    Write-Output "git remote add origin https://github.com/<owner>/$RepoName.git";
    Write-Output "git branch -M main";
    Write-Output "git push -u origin main";
}
