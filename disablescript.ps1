<#
.AUTHOR
  Gabriel Jabour
.VERSION
  1.0
.DATE
  2025-08-04
#>

<#
.SYNOPSIS
  Bulk-offboard users: remove from all AD groups and disable accounts, based on a list of identities.
.DESCRIPTION
  Reads a text file (`identities.txt`) containing one identifier per line:
    - If the line contains “@”, it's treated as a UserPrincipalName (UPN).
    - Otherwise, it's treated as a sAMAccountName.
  For each identity, the script:
    1. Finds the AD user.
    2. Removes them from all groups except “Domain Users”.
    3. Disables the user account.
.PARAMETER IdFile
  Path to the text file with one identity (UPN or sAMAccountName) per line.
.EXAMPLE
  # Place identities.txt next to the script, then:
  .\Offboard-Users-FromFile.ps1 -IdFile .\identities.txt
.NOTES
  - Requires ActiveDirectory module (RSAT) and rights to modify groups & accounts.
  - Run PowerShell as Administrator.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$IdFile
)

# Load AD module
Import-Module ActiveDirectory -ErrorAction Stop

# Read and clean identities file
if (-not (Test-Path $IdFile)) {
    Write-Error "File not found: $IdFile"
    exit 1
}
$idents = Get-Content $IdFile |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not ($_ -like '#*') }  # skip blank / comment

if (-not $idents) {
    Write-Error "No valid identities found in $IdFile"
    exit 1
}

foreach ($identity in $idents) {
    Write-Host "▶ Processing identity: $identity" -ForegroundColor Cyan

    # Determine lookup type
    if ($identity -like '*@*') {
        $user = Get-ADUser -Filter { UserPrincipalName -eq $identity } -ErrorAction SilentlyContinue
    } else {
        $user = Get-ADUser -Filter { SamAccountName -eq $identity } -ErrorAction SilentlyContinue
    }

    if (-not $user) {
        Write-Warning "⚠️  User not found: $identity"
        continue
    }
    Write-Host "🔍 Found: $($user.SamAccountName) ($($user.DistinguishedName))"

    # Remove from all groups except Domain Users
    $groups = Get-ADPrincipalGroupMembership -Identity $user |
              Where-Object { $_.Name -ne 'Domain Users' }
    if ($groups.Count -gt 0) {
        foreach ($g in $groups) {
            try {
                Remove-ADGroupMember -Identity $g -Members $user -Confirm:$false -ErrorAction Stop
                Write-Host "✅ Removed from group: $($g.Name)"
            }
            catch {
                Write-Warning "⚠️  Failed to remove from $($g.Name): $_"
            }
        }
    } else {
        Write-Host "ℹ️  No extra group memberships found."
    }

    # Disable account
    try {
        Disable-ADAccount -Identity $user -ErrorAction Stop
        Write-Host "🔒 Disabled account: $($user.SamAccountName)" -ForegroundColor Green
    }
    catch {
        Write-Warning "⚠️  Failed to disable account: $_"
    }

    Write-Host "🎯 Offboarded $($user.SamAccountName)`n" -ForegroundColor Magenta
}

Write-Host "🏁 All done." -ForegroundColor Cyan