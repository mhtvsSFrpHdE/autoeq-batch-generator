# Preset argument
# Both full path and relative path will work
# The reason to use full path at here is we often copy path from Everything search software
# This headphone model is just for demo purpose.
$inputFolder = "C:\AutoEq-master\innerfidelity\data\onear\Audio Technica ATH-M50x"

# The reason to use relative path at here is human read friendly
$outputFolder = "myresults\m50x"

# Set data source like "innerfidelity".
# Common option:
# "headphonecom"
# "innerfidelity"
# "rtings"
$dataSource = "innerfidelity"

# Headphone type, skip generate if curve type mismatch.
# Available option:
# "OverEar"
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
$configPath = ".\targetCurve.json"

# $dataSourceInnerfidelity = "innerfidelity"
# $dataSourceHeadphonecom = "headphonecom"
# $dataSourceRtings = "rtings"
$displayNamePrefix = "_simulate_"
$universalHeadphoneType = "None"
# $calibrationFileHeadphonecomToInnerfidelity = "calibration\headphonecom_to_innerfidelity.csv"
# $calibrationFileInnerfidelityToHeadphonecom = "calibration\innerfidelity_to_headphonecom.csv"
# $calibrationFileInnerfidelityToRtings = "calibration\innerfidelity_to_rtings.csv"
# $calibrationFileRtingsToInnerfidelity = "calibration\rtings_to_innerfidelity.csv"
$venvDetectPath = "$autoEqInstallPath\venv"

$errMsg = "ERR:"
$errMsgEmptyValueInConfig = "$errMsg Empty value in config file."
$errMsgFailedToInitialize = "$errMsg Failed to initialize."

# Global placeholder
$targetCurveObjectArray = $null
$checkInitialize = $false

# TODO
# Use namespace to arrange function
# Preprocess script running environment
function EnvironmentSetup {
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
function AutoEq_ScriptHeader {
    CreateCmdScript

    # So Windows XP doesn't really have a UTF-8 code page, will not work on that.
    # Use 65001 code page to cover the non-ANSI file name.
    WriteCmdScript "chcp 65001"
    WriteCmdScript "cd /d `"$autoEqInstallPath`""
    WriteCmdScript "call venv\Scripts\activate.bat"
}

# Code about fill argument to frequency_response.py
function AutoEq_ScriptBody {
    # Read target curve config file
    $targetCurveObjectArray = Get-Content $targetCurveJsonPath | ConvertFrom-Json

    # Loop through the array and export single object
    foreach ($targetCurveObject in $targetCurveObjectArray) {
        # Create a bool to check headphone type
        $checkHeadphoneType = $false

        # Try not to apply curve to wrong headphone type
        # For example, DO NOT apply in ear curve to on ear headphones
        # As a "JUST DO IT" method, fill $universalHeadphoneType to targetCurve.json
           # to ignore headphone type.
        if ( ($headphoneType -eq $targetCurveObject.HeadphoneType) -or ($targetCurveObject.HeadphoneType -eq $universalHeadphoneType) ){
            $checkHeadphoneType = $true
        }

        # Update compensationFile
        $compensationFile = $targetCurveObject.CompensationFile

        # Update result save path by using result display name
        $resultDisplayName = $targetCurveObject.ResultDisplayName
        $savePath = $outputFolder + $displayNamePrefix + $resultDisplayName

        if ($checkHeadphoneType){
            #TODO

            # Regenerate required target result by using our own argument

            # Confirm this is a simulate other headphone behavior or just use compensation file

            # Generate different command by condition
        }


        # $useCalibrationFile = $false

        # # Assign by if statement later
        # $calibrationFile = ""

        # # If headphone data come from different data souce
        # if ( !($dataSource -eq $targetCurveObject.DataSource) ){
        #     $useCalibrationFile = $true

        #     # Set file path when trying to use calibration file
        #     if ( ($dataSource -eq $dataSourceHeadphonecom) -and ($targetCurveObject.DataSource -eq $dataSourceInnerfidelity) ){
        #         $calibrationFile = $calibrationFileHeadphonecomToInnerfidelity
        #     }
        #     elseif ( ($dataSource -eq $dataSourceInnerfidelity) -and ($targetCurveObject.DataSource -eq $dataSourceHeadphonecom) ){
        #         $calibrationFile = $calibrationFileInnerfidelityToHeadphonecom
        #     }
        #     elseif ( ($dataSource -eq $dataSourceInnerfidelity) -and ($targetCurveObject.DataSource -eq $dataSourceRtings) ){
        #         $calibrationFile = $calibrationFileInnerfidelityToRtings
        #     }
        #     elseif ( ($dataSource -eq $dataSourceRtings) -and ($targetCurveObject.DataSource -eq $dataSourceInnerfidelity) ){
        #         $calibrationFile = $calibrationFileRtingsToInnerfidelity
        #     }
        #     else{
        #         # No calibration available, skip use calibration file
        #         $useCalibrationFile = $false
        #     }
        # }

        # if ($checkHeadphoneType){
        #     if ($useCalibrationFile){
        #         WriteCmdScript "python .\frequency_response.py --input_dir=`"$inputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFile`" --calibration=`"$calibrationFile`" --equalize --max_gain $maxGain --treble_max_gain $trebleMaxGain"
        #     }
        #     else{
        #         WriteCmdScript "python .\frequency_response.py --input_dir=`"$inputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFile`" --equalize --max_gain $maxGain --treble_max_gain $trebleMaxGain"
        #     }
        # }
    }
}

# Write pause and exit at the end of cmd script
function AutoEq_ScriptFoot {
    WriteCmdScript "pause"
    WriteCmdScript "exit"
}

# Call functions
EnvironmentSetup
AutoEq_ScriptHeader
AutoEq_ScriptBody
AutoEq_ScriptFoot

# Run AutoEq
RunCmdScript
# quit powershell
exit