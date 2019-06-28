# Load software struct
. ".\abg-software-struct.ps1"

# Load user config for AutoEq install path
. $interactConfigPathUserConfig

# Load library
. $libFolderIterator

# Global variable
$targetCurveObjectArray = @()
$multiHeadphoneObjectArray = @()
$regenerateObjectArray = Get-Content $configPathRegenerate | ConvertFrom-Json

function DoSomethingFunction {
    param (
        $InputFile,
        $OutputFileArray
    )
    
    # Get information from input file
    $currentHeadphoneType = "";
    $currentResultDisplayName = "";

    switch -wildcard ($InputFile) {
        "*\inear\*" {
            $currentHeadphoneType = "InEar"
            break
        }
        "*\onear\*" {
            $currentHeadphoneType = "OnEar"
            break
        }
        "*\earbud\*" {
            $currentHeadphoneType = "Earbud"
            break
        }
        default {
            $currentHeadphoneType = "None"
            break
        }
    }

    $skipThisItem = $true
    foreach ($regenerateObject in $regenerateObjectArray) {
        if ($InputFile.Contains($regenerateObject.InputPathContain)) {
            $currentResultDisplayName = $regenerateObject.InputPathContain.Replace("`\", "_")
            $skipThisItem = $false
            break
        }
    }

    # The Behavior set to Mimesis for all target curve while using all to all mode
    #TODO ResultDisplayName still don't have headphone name
    $myObj = New-Object -TypeName psobject -Property @{
        CompensationFile  = $InputFile;
        HeadphoneType     = $currentHeadphoneType;
        ResultDisplayName = $currentResultDisplayName;
        Behavior          = "Mimesis"
    }

    if (!$skipThisItem) {
        $script:targetCurveObjectArray += $myObj
    }
}

FolderIterator -InputFolder $autoEqInstallPath -InputFileType ".csv" -Recurse

$targetCurveObjectArray | ConvertTo-Json | Out-File -LiteralPath ".\targetCurveAll.json"