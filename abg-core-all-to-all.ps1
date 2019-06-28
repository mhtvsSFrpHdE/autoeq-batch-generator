# Load software struct
. ".\abg-software-struct.ps1"

# Load user config for AutoEq install path
. $interactConfigPathUserConfig

# Load library
. $libFolderIterator

# Global variable
$targetCurveObjectArray = @()
$regenerateObjectArray = Get-Content $configPathRegenerate | ConvertFrom-Json

function DoSomethingFunction {
    param (
        $InputFile
    )
    
    # Get information from input file
    $currentHeadphoneType = "";
    $currentResultDisplayName = "";

    switch -wildcard ($InputFile){
        "*\inear\*"{
            $currentHeadphoneType = "InEar"
            break
        }
        "*\onear\*"{
            $currentHeadphoneType = "OnEar"
            break
        }
        "*\earbud\*"{
            $currentHeadphoneType = "Earbud"
            break
        }
        default{
            $currentHeadphoneType = "None"
            break
        }
    }

    $skipThisItem = $true
    foreach ($regenerateObject in $regenerateObjectArray) {
        if ($InputFile.Contains($regenerateObject.InputPathContain)) {
            $currentResultDisplayName = $regenerateObject.InputPathContain.replace("`\", "_")
            $skipThisItem = $false
            break
        }
    }

    # The Behavior set to Mimesis for all target curve while using all to all mode
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

Write-Host "##########"
$targetCurveObjectArray | ConvertTo-Json | Out-File -LiteralPath ".\targetCurveAll.json"