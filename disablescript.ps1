<#
.SYNOPSIS
  Bulk offboard users: removes all AD group memberships (except Domain Users) and disables accounts,
  based on a list of identifiers (UPN or sAMAccountName) in a text file.
.DESCRIPTION
  Reads a text file (e.g., "identities.txt") containing one identifier per line:
    - If the line contains '@', it's treated as a UserPrincipalName (UPN).
    - Otherwise, it's treated as a sAMAccountName.
  For each identity, the script:
    1. Locates the AD user.
    2. Removes the user from all groups except 'Domain Users'.
    3. Disables the user account.
.PARAMETER IdFile
  Path to the text file with one UPN or sAMAccountName per line.
.EXAMPLE
  .\disablescript.ps1 -IdFile .\identities.txt
.NOTES
  - Requires RSAT ActiveDirectory module and appropriate AD permissions.
  - Run in an elevated PowerShell session (Administrator).
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$IdFile
)

# Import the ActiveDirectory module
Import-Module ActiveDirectory -ErrorAction Stop

# Verify that the input file exists
if (-not (Test-Path $IdFile)) {
    Write-Error "❌ File not found: $IdFile"
    exit 1
}

# Read identities, skipping blanks and comments
$idents = Get-Content $IdFile |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') }

if ($idents.Count -eq 0) {
    Write-Error "❌ No valid identities found in $IdFile"
    exit 1
}

foreach ($identity in $idents) {
    Write-Host "Processing: $identity" -ForegroundColor Cyan

    # Determine if identifier is UPN or sAMAccountName
    if ($identity -like '*@*') {
        $user = Get-ADUser -Filter "UserPrincipalName -eq '$identity'" -ErrorAction SilentlyContinue
    } else {
        $user = Get-ADUser -Filter "SamAccountName -eq '$identity'" -ErrorAction SilentlyContinue
    }

    if (-not $user) {
        Write-Warning "⚠️  User not found: $identity"
        continue
    }

    Write-Host "Found user: $($user.SamAccountName)" -ForegroundColor Green

    # Remove user from all groups except 'Domain Users'
    $groups = Get-ADPrincipalGroupMembership -Identity $user |
              Where-Object { $_.Name -ne 'Domain Users' }

    foreach ($g in $groups) {
        try {
            Remove-ADGroupMember -Identity $g -Members $user -Confirm:$false -ErrorAction Stop
            Write-Host "Removed from: $($g.Name)"
        } catch {
            Write-Warning "⚠️  Failed to remove from $($g.Name): $_"
        }
    }

    # Disable the user account
    try {
        Disable-ADAccount -Identity $user -ErrorAction Stop
        Write-Host "Disabled account: $($user.SamAccountName)" -ForegroundColor Yellow
    } catch {
        Write-Warning "⚠️  Failed to disable account: $_"
    }

    Write-Host "--- Completed offboarding for $($user.SamAccountName) ---" -ForegroundColor Magenta
    Write-Host "" # blank line for readability
}

Write-Host "All done." -ForegroundColor Cyan