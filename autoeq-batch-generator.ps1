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
$headphoneType = "OverEar"

# AutoEq install path
$autoEqInstallPath = "C:\AutoEq-master"

# Release the gain value limit
$maxGain = "24.0"
$trebleMaxGain = $maxGain





# Set cmd script file location
$CMD_SCRIPT_FILE = "$autoEqInstallPath\AutoEqBatch.cmd"
# Load code library
. ".\cstpw.ps1"

# Other default values
$targetCurveJsonPath = ".\targetCurve.json"
$dataSourceInnerfidelity = "innerfidelity"
$dataSourceHeadphonecom = "headphonecom"
$dataSourceRtings = "rtings"
$displayNamePrefix = "_simulate_"

# Write script
# So Windows XP doesn't really have a UTF-8 code page, will not work on that.
# Use 65001 code page to cover the non-ANSI file name.
CreateCmdScript
WriteCmdScript "chcp 65001"
WriteCmdScript "cd /d `"$autoEqInstallPath`""
WriteCmdScript "call venv\Scripts\activate.bat"

# Read target curve config file
$targetCurveObjectArray = Get-Content $targetCurveJsonPath | ConvertFrom-Json

# Loop through the array and export single object
foreach ($targetCurveObject in $targetCurveObjectArray) {
    # Create two bool variable and initalize as false
    $checkHeadphoneType = $useCalibrationFile = $false
    # Assign by if statement later
    $calibrationFile = ""

    if ($headphoneType -eq $targetCurveObject.HeadphoneType){
        $checkHeadphoneType = $true
    }

    # If headphone data come from different data souce
    if ( !($dataSource -eq $targetCurveObject.DataSource) ){
        $useCalibrationFile = $true

        # Set file path when trying to use calibration file
        if ( ($dataSource -eq $dataSourceHeadphonecom) -and ($targetCurveObject.DataSource -eq $dataSourceInnerfidelity) ){
            $calibrationFile = "calibration\headphonecom_to_innerfidelity.csv"
        }
        elseif ( ($dataSource -eq $dataSourceInnerfidelity) -and ($targetCurveObject.DataSource -eq $dataSourceHeadphonecom) ){
            $calibrationFile = "calibration\innerfidelity_to_headphonecom.csv"
        }
        elseif ( ($dataSource -eq $dataSourceInnerfidelity) -and ($targetCurveObject.DataSource -eq $dataSourceRtings) ){
            $calibrationFile = "calibration\innerfidelity_to_rtings.csv"
        }
        elseif ( ($dataSource -eq $dataSourceRtings) -and ($targetCurveObject.DataSource -eq $dataSourceInnerfidelity) ){
            $calibrationFile = "calibration\rtings_to_innerfidelity.csv"
        }
        else{
            # No calibration available, skip use calibration file
            $useCalibrationFile = $false
        }
    }

    # Update compensationFile
    $compensationFile = $targetCurveObject.CompensationFile

    # Update result save path by using result display name
    $resultDisplayName = $targetCurveObject.ResultDisplayName
    $savePath = $outputFolder + $displayNamePrefix + $resultDisplayName

    if ($headphoneType){
        if ($useCalibrationFile){
            WriteCmdScript "python .\frequency_response.py --input_dir=`"$inputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFile`" --calibration=`"$calibrationFile`" --equalize --max_gain $maxGain --treble_max_gain $trebleMaxGain"
        }
        else{
            WriteCmdScript "python .\frequency_response.py --input_dir=`"$inputFolder`" --output_dir=`"$savePath`" --compensation=`"$compensationFile`" --equalize --max_gain $maxGain --treble_max_gain $trebleMaxGain"
        }
    }
}

# Write pause and exit at the end of cmd script
WriteCmdScript "pause"
WriteCmdScript "exit"

# Call explorer to simulate user double-click behavior then quit powershell
# Double click this damn cmd script
explorer "$CMD_SCRIPT_FILE"
# quit powershell
exit