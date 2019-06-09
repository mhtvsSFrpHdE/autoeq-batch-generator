﻿# Preset argument
# Both full path and relative path will work
# The reason to use full path at here is we often copy path from Everything search software
# This headphone model is just for demo purpose.
$inputFolder = "C:\AutoEq-master\innerfidelity\data\onear\Audio Technica ATH-M50x"

# The reason to use relative path at here is human read friendly
$outputFolder = "myresults\m50x"

# Headphone type, skip generate if curve type mismatch.
# Available option:
# "OnEar"
# "InEar"
$headphoneType = "OnEar"

# AutoEq install path
$autoEqInstallPath = "C:\AutoEq-master"

# Release the gain value limit
$maxGain = "24.0"
$trebleMaxGain = $maxGain





# Set cmd script file location
$CMD_SCRIPT_FILE = "$autoEqInstallPath\AutoEqBatch.cmd"



# Other default values
$libCtspw = ".\cstpw.ps1"
$libSimpleCatch = ".\simplecatch.ps1"

$configPathTargetCurve = ".\targetCurve.json"
$configPathRegenerate = ".\regenerate.json"

$displayNamePrefix = "_simulate_"
$displayNameRegenerate = "regenerate"

$universalHeadphoneType = "None"
$venvDetectPath = "$autoEqInstallPath\venv"
$bassBoostZeroValue = "0.0"

$errMsg = "ERR:"
$errMsgEmptyValueInConfig = "$errMsg Empty value in config file."
$errMsgFailedToInitialize = "$errMsg Failed to initialize."
$errMsgUnknownBehavior = "$errMsg Unknown behavior in regenerate config"

$behaviorStandardization = "Standardization"
$behaviorMimesis = "Mimesis"

# Global placeholder
$targetCurveObjectArray = $null
$regenerateObjectArray = $null
$checkInitialize = $false

# TODO
# Use namespace to arrange function

# Check config file
function Environment_Initialize {
    # Read all files

    # Try to confirm code library
    Get-Content $libCtspw | Out-Null
    Get-Content $libSimpleCatch | Out-Null

    # Load config file
    $script:targetCurveObjectArray = Get-Content $configPathTargetCurve | ConvertFrom-Json
    $script:regenerateObjectArray = Get-Content $configPathRegenerate | ConvertFrom-Json

    foreach($configEntry in $targetCurveObjectArray){
        if($configEntry.CompensationFile -eq $null){
            throw $errMsgEmptyValueInConfig
        }
        if($configEntry.HeadphoneType -eq $null){
            throw $errMsgEmptyValueInConfig
        }
        if($configEntry.ResultDisplayName -eq $null){
            throw $errMsgEmptyValueInConfig
        }
        if($configEntry.Behavior -eq $null){
            throw $errMsgEmptyValueInConfig
        }
    }

    # Confirm initialize success in the very end
    #    if there is no exception
    $script:checkInitialize = $true
}

# Preprocess script running environment
function Environment_Setup {
    # If venv folder doesn't exist(first run)
    # or just skip environment setup
    if (! (Test-Path $venvDetectPath) ) {
        Write-Output "You don't have AutoEq environment requirement installed."
        Write-Output "Confirm to start the install script."
        Pause
        Write-Output ""

        # Create the environment setup script
        CreateCmdScript
        WriteCmdScript "chcp 65001"
        WriteCmdScript "cd /d `"$autoEqInstallPath`""
        WriteCmdScript "python -m pip install --upgrade pip"
        WriteCmdScript "pip install virtualenv"
        WriteCmdScript "virtualenv venv -v"
        WriteCmdScript "call venv\Scripts\activate.bat"
        WriteCmdScript "pip install -r requirements.txt"
        WriteCmdScript "pause"
        WriteCmdScript "exit"

        $keepLoopMark = $false
        do {
            # Run environment setup script
            RunCmdScript -Wait
    
            # Ask user for the script execute result
            Write-Output "Did the requirements installed successfully?"
            Write-Output "Or there's error needs to be fix manually?"
            Write-Output ""
            Write-Output "Y, all success(run AutoEq)."
            Write-Output "N, I do it manually(stop script)."
            Write-Output "R, Anyway, just retry it for me."
            Write-Output "Default is N."
            Write-Output ""
    
            $ReadUserResult = 0
            $ReadUser = Read-Host "Y/N/R" 
            Write-Output ""
            Switch ($ReadUser) 
            { 
                Y {$ReadUserResult = 1} 
                N {$ReadUserResult = 2} 
                R {$ReadUserResult = 3}
                Default {$ReadUserResult = 2} 
            }
    
            if ($ReadUserResult -eq 3){
                $keepLoopMark = $true
            }
            elseif ($ReadUserResult -eq 2) {
                exit
            }
            else {
                $keepLoopMark = $false
            }
        } while ($keepLoopMark)
    }
}

# Config execute environment
function AutoEqScript_Header {
    CreateCmdScript

    # So Windows XP doesn't really have a UTF-8 code page, will not work on that.
    # Use 65001 code page to cover the non-ANSI file name.
    WriteCmdScript "chcp 65001"
    WriteCmdScript "cd /d `"$autoEqInstallPath`""
    WriteCmdScript "call venv\Scripts\activate.bat"
}

# Code about fill argument to frequency_response.py
function AutoEqScript_Body {
    # Loop through the array and export single object
    foreach ($targetCurveObject in $targetCurveObjectArray) {
        # Try not to apply curve to wrong headphone type
        # For example, DO NOT apply in ear curve to on ear headphones
        # As a "JUST DO IT" method, fill $universalHeadphoneType to targetCurve.json
           # to ignore headphone type check

        # Create a bool to check headphone type
        $checkHeadphoneType = $false
        if ( ($headphoneType -eq $targetCurveObject.HeadphoneType) -or ($targetCurveObject.HeadphoneType -eq $universalHeadphoneType) ){
            $checkHeadphoneType = $true
        }

        # Use this bool for further action
        # DO NOTHING if the value is false (if not pass headphone type check)
        if ($checkHeadphoneType){
            # Export compensationFile
            $compensationFileForTarget = $targetCurveObject.CompensationFile

            # Export result save path by using result display name
            $resultDisplayName = $targetCurveObject.ResultDisplayName
            $savePath = $outputFolder + $displayNamePrefix + $resultDisplayName

            # Confirm this is a mimesis other headphone behavior or just use compensation file
            # Generate different command by condition

            # When Standardization a headphone by using basic command argument
            if ($targetCurveObject.Behavior -eq $behaviorStandardization){
                WriteCmdScript "REM Standardization"
                WriteCmdScript "python frequency_response.py --input_dir=`"$inputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFileForTarget`" --equalize --max_gain $maxGain --treble_max_gain $trebleMaxGain"
            }
            # When mimesis a headphone to another headphone
            # The logic is more complex a little bit
            elseif($targetCurveObject.Behavior -eq $behaviorMimesis){
                # Export headphone values
                $compensationFileForHeadphone = $null
                $bassBoostForHeadphone = $null
                $iemBassBoostForHeadphone = $null
                foreach ($regenerateObjectForHeadphone in $regenerateObjectArray) {
                    $regenInputPathContainForHeadphone = $regenerateObjectForHeadphone.InputPathContain
                    if($inputFolder -like "*$regenInputPathContainForHeadphone*"){
                        $compensationFileForHeadphone = $regenerateObjectForHeadphone.CompensationFile
                        $bassBoostForHeadphone = $regenerateObjectForHeadphone.BassBoost
                        $iemBassBoostForHeadphone = $regenerateObjectForHeadphone.IemBassBoost
                    }
                }

                # Regenerate required "mimesis target" result by using our own argument
                # The mainly regenerate reason is release max_gain limit

                # We need to know the "mimesis target" default result belong to which data source
                # Scan config file
                foreach ($regenerateObjectForTarget in $regenerateObjectArray){
                    # Export data source path from config
                    $regenInputPathContainForTarget = $regenerateObjectForTarget.InputPathContain
                    
                    # If mimesis target matched with this config entry
                    if ($compensationFileForTarget -like "*$regenInputPathContainForTarget*"){
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
                        WriteCmdScript "REM Mimesis"
                        if ($regenIemBassBoost -eq $bassBoostZeroValue){
                            WriteCmdScript "python frequency_response.py --input_dir=`"$regenInputFolderPath`" --output_dir=`"$regenSavePath`" --compensation=`"$regenCompensationFile`" --equalize --bass_boost=$regenBassBoost --max_gain $maxGain --treble_max_gain $trebleMaxGain"
                        }
                        else{
                            WriteCmdScript "python frequency_response.py --input_dir=`"$regenInputFolderPath`" --output_dir=`"$regenSavePath`" --compensation=`"$regenCompensationFile`" --equalize --iem_bass_boost=$regenIemBassBoost --max_gain $maxGain --treble_max_gain $trebleMaxGain"
                        }
                        
                        # Then we can use the regenerated result for real operaton             
                        # Generate regenerated csv path
                        $regenCsvPath = "$regenSavePath\$regenInputFolderName.csv"
                        
                        # Finally
                        # jaakkopasanen: "Something like this"
                        if($iemBassBoostForHeadphone -eq $bassBoostZeroValue){
                            WriteCmdScript "python frequency_response.py --input_dir=`"$inputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFileForHeadphone`" --sound_signature=`"$regenCsvPath`" --equalize --bass_boost=$bassBoostForHeadphone --max_gain $maxGain --treble_max_gain $trebleMaxGain"
                        }
                        else{
                            WriteCmdScript "python frequency_response.py --input_dir=`"$inputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFileForHeadphone`" --sound_signature=`"$regenCsvPath`" --equalize --iem_bass_boost=$iemBassBoostForHeadphone --max_gain $maxGain --treble_max_gain $trebleMaxGain"
                        }
                    }
                }
            }
            # Opps, there is a unknown behavior in the config file
            else{
                Write-Error $errMsgUnknownBehavior
                exit
            }
        }
    }
}

# Write pause and exit at the end of cmd script
function AutoEqScript_Foot {
    WriteCmdScript "pause"
    WriteCmdScript "exit"
}

# Call functions
Environment_Initialize
if($checkInitialize){
    . $libCtspw
    . $libSimpleCatch
    try{
        # Prepare environment
        Environment_Setup

        # Create script
        AutoEqScript_Header
        AutoEqScript_Body
        AutoEqScript_Foot

        # Run AutoEq
        RunCmdScript
    }
    catch{
        SimpleCatch $_
    }

}
else{
    Write-Error $errMsgFailedToInitialize
    exit 1
}

# quit powershell
exit