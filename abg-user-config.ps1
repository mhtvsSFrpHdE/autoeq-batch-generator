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





# The values you can change, but not recommend.

# AutoEq install path
$autoEqInstallPath = "C:\AutoEq-master"

# Release the gain value limit
$maxGain = "24.0"
$trebleMaxGain = $maxGain