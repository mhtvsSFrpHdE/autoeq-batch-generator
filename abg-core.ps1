# Load software struct
. ".\abg-software-struct.ps1"

# User input values
. $interactConfigPathUserConfig

# Other default values

# Magic value
. $interactConfigPathMagicValue

# Message
. $interactConfigPathMessage



# Global variable
$targetCurveObjectArray = $null
$regenerateObjectArray = $null
$multiHeadphoneObjectArray = $null
$checkInitialize = $false

# Environment initialize
function Environment_Initialize {
    # Load config file
    $script:targetCurveObjectArray = Get-Content $configPathTargetCurve -ErrorAction Stop | ConvertFrom-Json
    $script:regenerateObjectArray = Get-Content $configPathRegenerate -ErrorAction Stop | ConvertFrom-Json
    $script:multiHeadphoneObjectArray = Get-Content $configPathMultiHeadphone -ErrorAction Stop | ConvertFrom-Json

    # Confirm initialize success in the very end
    #    if there is no exception
    $script:checkInitialize = $true
}

# Preprocess script running environment
function Environment_Setup {
    # If venv folder doesn't exist(first run)
    # or just skip environment setup
    if (! (Test-Path $venvDetectPath) ) {
        Write-Host $usrMsgVenvNotFound
        Write-Host $usrMsgVenvNotFound2
        Write-Host $usrMsgBlankLine
        Pause
        Write-Host $usrMsgBlankLine

        # Create the environment setup script
        #TODO add custom pip option
        Cstpw_CreateScript
        Cstpw_WriteScript "chcp 65001"
        Cstpw_WriteScript "cd /d `"$autoEqInstallPath`""
        Cstpw_WriteScript "python -m pip install --upgrade pip"
        Cstpw_WriteScript ("pip install " + $pipCustomArgument + "virtualenv")
        Cstpw_WriteScript "virtualenv venv -v"
        Cstpw_WriteScript "call venv\Scripts\activate.bat"
        Cstpw_WriteScript "pip install " + $pipCustomArgument + "-r requirements.txt"
        Cstpw_WriteScript "pause"
        Cstpw_WriteScript "exit"

        # This variable tell loop to do again or not.
        # The "Retry" feature.
        $keepLoopMark = $false
        do {
            # Run environment setup script
            Cstpw_RunScript -Wait
    
            # Ask user for the script execute result
            Write-Host $usrMsgAskVenvStatus
            Write-Host $usrMsgAskVenvStatus2
            Write-Host $usrMsgBlankLine
            Write-Host $usrMsgAskVenvStatusYes
            Write-Host $usrMsgAskVenvStatusNo
            Write-Host $usrMsgAskVenvStatusRetry
            Write-Host $usrMsgAskVenvStatusDefault
            Write-Host $usrMsgBlankLine
    
            $readUserResult = 0
            $readUser = Read-Host "Y/N/R" 
            Write-Host $usrMsgBlankLine
            Switch ($readUser) { 
                Y { $readUserResult = 1 } 
                N { $readUserResult = 2 } 
                R { $readUserResult = 3 }
                Default { $readUserResult = 2 } 
            }
    
            if ($readUserResult -eq 3) {
                $keepLoopMark = $true
            }
            elseif ($readUserResult -eq 1) {
                $keepLoopMark = $false
            }
            else {
                exit
            }
        } while ($keepLoopMark)
    }
}

# Config execute environment
function AutoEqScript_Header {
    Cstpw_CreateScript

    # So Windows XP doesn't really have a UTF-8 code page, will not work on that.
    # Use 65001 code page to cover the non-ANSI file name.
    Cstpw_WriteScript "chcp 65001"
    Cstpw_WriteScript "cd /d `"$autoEqInstallPath`""
    Cstpw_WriteScript "call venv\Scripts\activate.bat"
}

# Code about fill argument to frequency_response.py
# This function designed for one at a time
# There is a wrapper for multiple at the elsewhere
function AutoEqScript_CoreWorker {
    param (
        $InputFolder,
        $OutputFolder,
        $HeadphoneType
    )

    # Loop through the array and export single object
    foreach ($targetCurveObject in $targetCurveObjectArray) {
        # Try not to apply curve to wrong headphone type
        # For example, DO NOT apply in ear curve to on ear headphones
        # As a "JUST DO IT" method, fill $universalHeadphoneType to targetCurve.json
        # to ignore headphone type check

        # Create a bool to check headphone type
        $checkHeadphoneType = $false
        if ( ($HeadphoneType -eq $targetCurveObject.HeadphoneType) -or ($targetCurveObject.HeadphoneType -eq $universalHeadphoneType) ) {
            $checkHeadphoneType = $true
        }

        # Use this bool for further action
        # DO NOTHING if the value is false (if not pass headphone type check)
        if ($checkHeadphoneType) {
            # Export compensationFile
            $compensationFileForTarget = $targetCurveObject.CompensationFile

            # Export result save path by using result display name
            $resultDisplayName = $targetCurveObject.ResultDisplayName
            $savePath = $OutputFolder + $displayNamePrefix + $resultDisplayName

            # Confirm this is a mimesis other headphone behavior or just use compensation file
            # Generate different command by condition

            # When Standardization a headphone by using basic command argument
            if ($targetCurveObject.Behavior -eq $behaviorStandardization) {
                Cstpw_WriteScript "REM Standardization"
                Cstpw_WriteScript "python frequency_response.py --input_dir=`"$InputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFileForTarget`" --equalize --max_gain $maxGain --treble_max_gain $trebleMaxGain"
            }
            # When mimesis a headphone to another headphone
            # The logic is more complex a little bit
            elseif ($targetCurveObject.Behavior -eq $behaviorMimesis) {
                # Export headphone values
                $compensationFileForHeadphone = $null
                $bassBoostForHeadphone = $null
                $iemBassBoostForHeadphone = $null
                foreach ($regenerateObjectForHeadphone in $regenerateObjectArray) {
                    $regenInputPathContainForHeadphone = $regenerateObjectForHeadphone.InputPathContain
                    if ($InputFolder -like "*$regenInputPathContainForHeadphone*") {
                        $compensationFileForHeadphone = $regenerateObjectForHeadphone.CompensationFile
                        $bassBoostForHeadphone = $regenerateObjectForHeadphone.BassBoost
                        $iemBassBoostForHeadphone = $regenerateObjectForHeadphone.IemBassBoost
                    }
                }

                # Regenerate required "mimesis target" result by using our own argument
                # The mainly regenerate reason is release max_gain limit

                # We need to know the "mimesis target" default result belong to which data source
                # Scan config file
                foreach ($regenerateObjectForTarget in $regenerateObjectArray) {
                    # Export data source path from config
                    $regenInputPathContainForTarget = $regenerateObjectForTarget.InputPathContain
                    
                    # If mimesis target matched with this config entry
                    if ($compensationFileForTarget -like "*$regenInputPathContainForTarget*") {
                        # Export regenerate purpose input folder
                        $regenInputFolderPath = Split-Path $compensationFileForTarget
                        $regenInputFolderName = Split-Path $compensationFileForTarget | Split-Path -Leaf

                        # Export regenerate purpose save path
                        # $regenerateDisplayName = $regenerateObjectForTarget.DisplayName
                        $regenSavePath = "$autoEqInstallPath\$displayNameRegenerate\$regenInputFolderName"

                        # Export regenerate purpose compensation file
                        $regenCompensationFile = $regenerateObjectForTarget.CompensationFile

                        # Export other default values
                        $regenBassBoost = $regenerateObjectForTarget.BassBoost
                        $regenIemBassBoost = $regenerateObjectForTarget.IemBassBoost

                        # A test shows --bass_boost and --iem_bass_boost can't be given together
                        # So if one of them equal to zero, it will be disabled.
                        Cstpw_WriteScript "REM Mimesis"
                        if ($regenIemBassBoost -eq $bassBoostZeroValue) {
                            Cstpw_WriteScript "python frequency_response.py --input_dir=`"$regenInputFolderPath`" --output_dir=`"$regenSavePath`" --compensation=`"$regenCompensationFile`" --equalize --bass_boost=$regenBassBoost --max_gain $maxGain --treble_max_gain $trebleMaxGain"
                        }
                        else {
                            Cstpw_WriteScript "python frequency_response.py --input_dir=`"$regenInputFolderPath`" --output_dir=`"$regenSavePath`" --compensation=`"$regenCompensationFile`" --equalize --iem_bass_boost=$regenIemBassBoost --max_gain $maxGain --treble_max_gain $trebleMaxGain"
                        }
                        
                        # Then we can use the regenerated result for real operaton             
                        # Generate regenerated csv path
                        $regenCsvPath = "$regenSavePath\$regenInputFolderName.csv"
                        
                        # Finally
                        # jaakkopasanen: "Something like this"
                        if ($iemBassBoostForHeadphone -eq $bassBoostZeroValue) {
                            Cstpw_WriteScript "python frequency_response.py --input_dir=`"$InputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFileForHeadphone`" --sound_signature=`"$regenCsvPath`" --equalize --bass_boost=$bassBoostForHeadphone --max_gain $maxGain --treble_max_gain $trebleMaxGain"
                        }
                        else {
                            Cstpw_WriteScript "python frequency_response.py --input_dir=`"$InputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFileForHeadphone`" --sound_signature=`"$regenCsvPath`" --equalize --iem_bass_boost=$iemBassBoostForHeadphone --max_gain $maxGain --treble_max_gain $trebleMaxGain"
                        }
                    }
                }
            }
            # Opps, there is a unknown behavior in the config file
            else {
                Write-Error $errMsgUnknownBehavior
                exit
            }
        }
    }
}

# Wrapper of AutoEqScript_CoreWorker
# Enable to use multi headphone mode
function AutoEqScript_Body {
    if ($multiHeadphoneMode) {
        foreach ($headphoneObject in $multiHeadphoneObjectArray) {
            AutoEqScript_CoreWorker -InputFolder $headphoneObject.InputFolder -OutputFolder $headphoneObject.OutputFolder -HeadphoneType $headphoneObject.HeadphoneType
        }
    }
    else {
        AutoEqScript_CoreWorker -InputFolder $inputFolder_default -OutputFolder $outputFolder_default -HeadphoneType $headphoneType_default
    }
}

# Write pause and exit at the end of cmd script
function AutoEqScript_Foot {
    Cstpw_WriteScript "pause"
    Cstpw_WriteScript "exit"
}





# Main
# Initialize code
Environment_Initialize
# Check initialize result
if ($checkInitialize) {
    # Load library
    . $libCtspw
    . $libSimpleCatch
    # Overwrite library default value
    # The default value "UTF8NoBOM" hasn't support by powershell yet
    $script:cstpw_scriptEncoding = "UTF8"
    try {
        # Prepare environment
        Environment_Setup

        # Create script
        AutoEqScript_Header
        AutoEqScript_Body
        AutoEqScript_Foot

        # Run AutoEq
        Cstpw_RunScript
    }
    catch {
        SimpleCatch $_
    }

}
else {
    Write-Error $errMsgFailedToInitialize
    exit 1
}

# quit powershell
exit