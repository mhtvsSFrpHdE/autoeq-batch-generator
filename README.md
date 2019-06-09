# autoeq-batch-generator
**Contact**  
See https://github.com/mhtvsSFrpHdE/contact-me  

**What is this**  
In normally you need to type in the AutoEq launch command and argument in order to use it.  
When you want to generate five eq settings for same headphone, things not that handy.  
The powershell script will read the predefined config file, and do something automated.
- Change working directory
- Change code page to prevent wrong encoding
- Check virtualenv environment
- Install virtualenv and other dependencies if they are not exist
- Active virtualenv
- Control output folder
- Add output folder suffix for different curve
- Control max_gain, treble_max_gain value
- Pause after command execute

Planned feature:
- Update command generator core code to latest AutoEq API 

**How to use**  
Before execute, you need to download my dependencies library:  
https://github.com/mhtvsSFrpHdE/cmd-script-the-powershell-way  
https://github.com/mhtvsSFrpHdE/simple-catch  

Paste the ```cstpw.ps1``` and other "ps1" files to the same folder as ```autoeq-batch-generator.ps1```.

Use your text editor to open ```autoeq-batch-generator.ps1``` but do not run it.  
At the top of the file, you will see:
```
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

...
```
The importance of each option is decreasing from top to bottom.  
After fill all the in-script config,  
open ```targetCurve.json```,
in this file you will see:
```
...
    {
    "CompensationFile":  "C:\\AutoEq-master\\compensation\\harman_over-ear_2018.csv",
		"HeadphoneType":  "OverEar",
    "DataSource":  "None",
    "ResultDisplayName":  "harman_oe_2018"
    },
    {
    "CompensationFile":  "C:\\AutoEq-master\\compensation\\harman_in-ear_2017-2.csv",
		"HeadphoneType":  "InEar",
    "DataSource":  "None",
    "ResultDisplayName":  "harman_ie_2017-2"
    },
...
```
It's default content is just for demo purpose,  
the data stored as "object in array",  
so carefully edit the content or add more repeat.  

Once all argument were defined,  
run the ```autoeq-batch-generator.ps1```, your batch should start working.
