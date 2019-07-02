param (
    $DefaultSavePath = "myresults"
)

# Load software struct
. ".\abg-software-struct.ps1"

# Load user config for AutoEq install path
. $interactConfigPathUserConfig

# Load message
. $interactConfigPathMessage

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

    # Some of the value may be null if not skipping.
    if (!$skipThisItem) {
        # The Behavior set to Mimesis for all target curve while using all to all mode
        #TODO ResultDisplayName still don't have headphone name
        $currentTargetCurveResultDisplayName = ($OutputFileArray[2].Replace(" ", "_") + "_$currentResultDisplayName").ToLower()
        $currentTargetCurveObj = New-Object -TypeName psobject -Property @{
            CompensationFile  = $InputFile;
            HeadphoneType     = $currentHeadphoneType;
            ResultDisplayName = $currentTargetCurveResultDisplayName;
            Behavior          = "Mimesis"
        }
        
        $currentMultiHeadphoneInputFolder = Split-Path $InputFile
        $currentMultiHeadphoneOutputFolder = ("$DefaultSavePath\" + $OutputFileArray[2].Replace(" ", "_") + "_$currentResultDisplayName").ToLower()
        $currentMultiHeadphoneObj = New-Object -TypeName psobject -Property @{
            InputFolder   = $currentMultiHeadphoneInputFolder;
            OutputFolder  = $currentMultiHeadphoneOutputFolder;
            HeadphoneType = $currentHeadphoneType
        }

        $script:targetCurveObjectArray += $currentTargetCurveObj
        $script:multiHeadphoneObjectArray += $currentMultiHeadphoneObj
    }
}

Write-Host $usrMsgImWorkingAllToAll
FolderIterator -InputFolder $autoEqInstallPath -InputFileType ".csv" -Recurse

$targetCurveObjectArray | ConvertTo-Json | Out-File -LiteralPath ".\targetCurveAll.json"
$multiHeadphoneObjectArray | ConvertTo-Json | Out-File -LiteralPath ".\multiHeadphoneAll.json"