# Preset argument
# Set to true if you want to use for multiple headphones mode.
# In this mode, the following value will ignored.
behaviorMultiHeadphone = False

# Both full path and relative path will work
# The reason to use full path at here is we often copy path from Everything search software
# This headphone model is just for demo purpose.
inputFolderDefault = r"C:\AutoEq-master\oratory1990\data\onear\Audio-Technica ATH-M50x"

# The reason to use relative path at here is human read friendly
outputFolderDefault = r"myresults\m50x"

# Pip download server
# Specify you own pip options(experimental)
#
# This demo shows you want to use a download mirror located in China.
# You must add a space character at the end of the variable.
#   pip install -i https://pypi.tuna.tsinghua.edu.cn/simple virtualenv
#   pipCustomArgument = "-i https://pypi.tuna.tsinghua.edu.cn/simple "
#
# Leave it blank to use default options:
# Notic that in this case there is no space character.
#   pipCustomArgument = ""
pipCustomArgument = r""




# The values you can change, but not recommend.

# AutoEq install path
autoEqInstallPath = r"C:\AutoEq-master"

# Set cmd script file location
CSTPW_SCRIPT_FILE = r"autoEqInstallPath\AutoEqBatch.cmd"

# Release the gain value limit
maxGain = "48.0"
trebleMaxGain = maxGain

# Overwrite exist result
behaviorOverwriteExistResult = False

# Auto run saved script
behaviorAutoRunSavedScript = True