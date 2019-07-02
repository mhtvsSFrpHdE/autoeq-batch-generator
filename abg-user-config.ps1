# Preset argument
# Set to true if you want to use for multiple headphones mode.
# In this mode, the following value will ignored.
$multiHeadphoneMode = $false

# Both full path and relative path will work
# The reason to use full path at here is we often copy path from Everything search software
# This headphone model is just for demo purpose.
$inputFolder_default = "C:\AutoEq-master\innerfidelity\data\onear\Audio Technica ATH-M50x"

# The reason to use relative path at here is human read friendly
$outputFolder_default = "myresults\m50x"

# Headphone type, skip generate if curve type mismatch.
# Available option:
# "OnEar"
# "InEar"
$headphoneType_default = "OnEar"

# Pip download server
# Specify you own pip options(experimental)
#
# This demo shows you want to use a download mirror located in China.
# You must add a space character at the end of the variable.
#   pip install -i https://pypi.tuna.tsinghua.edu.cn/simple virtualenv
#   $pipCustomArgument = "-i https://pypi.tuna.tsinghua.edu.cn/simple "
#
# Leave it blank to use default options:
# Notic that in this case there is no space character.
#   $pipCustomArgument = ""
$pipCustomArgument = "-i https://pypi.tuna.tsinghua.edu.cn/simple "




# The values you can change, but not recommend.

# AutoEq install path
$autoEqInstallPath = "C:\AutoEq-master"

# Set cmd script file location
$CSTPW_SCRIPT_FILE = "$autoEqInstallPath\AutoEqBatch.cmd"

# Release the gain value limit
$maxGain = "24.0"
$trebleMaxGain = $maxGain

# Overwrite exist result
$behaviorOverwriteExistResult = $false

# Auto run saved script
$behaviorAutoRunSavedScript = $true