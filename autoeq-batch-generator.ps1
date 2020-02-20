param (
    [switch] $DisableAutoRun = $false,
    [switch] $MultiHeadphone = $false,
    [switch] $Overwrite = $false
)

function CheckFiles {
    param (
        $FilesToCheckArray = @()
    )

    $passedCheck = $true

    foreach ($file in $FilesToCheckArray) {
        try {
            Get-Content $file -ErrorAction Stop | Out-Null
            # Write-Host "Passed: $file"
        }
        catch {
            $passedCheck = $false
            Write-Host "ERR: $file"
        }
    }

    if (!$passedCheck) {
        Write-Error "One or more software file courroupted."
        exit 1
    }
}

# Define interact files
$filesToCheckArray = @(
    ".\abg-core.ps1",
    ".\abg-magic-value.ps1",
    ".\abg-message.ps1",
    ".\abg-software-struct.ps1",
    ".\abg-user-config.ps1"
)
# Check them
CheckFiles -FilesToCheckArray $filesToCheckArray

# Import software struct from interact file
# This will force update $filesToCheckArray
. ".\abg-software-struct.ps1"
# Check them
CheckFiles -FilesToCheckArray $filesToCheckArray

# If CheckFiles function passed, run abg-core
& ".\abg-core.ps1" -Overwrite:$Overwrite -DisableAutoRun:$DisableAutoRun -MultiHeadphone:$MultiHeadphone