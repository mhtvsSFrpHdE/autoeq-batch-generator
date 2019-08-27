# autoeq-batch-generator
**Contact**  
See https://github.com/mhtvsSFrpHdE/contact-me  

**What is this**  
The AutoEq project:  
https://github.com/jaakkopasanen/AutoEq  
In normally you need to type in the AutoEq launch command and argument in order to use it.  
When you want to generate five eq settings for same headphone, things not that handy.  
The powershell script will read the predefined config file, and do something automated.
- Easy translate to your local language
- Change code page to prevent wrong encoding
- Change working directory into AutoEq download folder
- Check virtualenv environment
- Install virtualenv and other dependencies if they are not exist
- Active virtualenv
- Custom output folder
- Name output folder by different headphone or curve
- Custom max_gain, treble_max_gain value
- Pause after all command executed
- Multiple headphone to multiple target curve at once
- Extreme all to all mode

Planned feature:
- None

**How to use**  
Before execute, you need to download my dependencies library:  
https://github.com/mhtvsSFrpHdE/cmd-script-the-powershell-way  
https://github.com/mhtvsSFrpHdE/simple-catch  
https://github.com/mhtvsSFrpHdE/folder-iterator  

Paste the ```cstpw.ps1``` and other "ps1" files to the same folder as ```autoeq-batch-generator.ps1```.  
If you use release branch(recommend), they should already in there.

Use your text editor to open ```abg-user-config.ps1``` but do not run it.  
At the top of the file, you will see:
```
# Preset argument
# Set to true if you want to use for multiple headphones mode.
# In this mode, the following value will ignored.
$multiHeadphoneMode = $false

# Both full path and relative path will work
# The reason to use full path at here is we often copy path from Everything search software
# This headphone model is just for demo purpose.
$inputFolder_default = "C:\AutoEq-master\innerfidelity\data\onear\Audio Technica ATH-M50x"
...
```
The importance of each option is decreasing from top to bottom.  
After fill all the in-script config,  
open ```targetCurve.json```,
in this file you will see:
```
...
    {
        "CompensationFile":  "C:\\AutoEq-master\\compensation\\loudspeaker_in-room_flat_2013.csv",
		"HeadphoneType":  "None",
        "ResultDisplayName":  "harman_ls_2013",
        "Behavior": "Standardization"
    },
    {
        "CompensationFile":  "C:\\AutoEq-master\\compensation\\harman_over-ear_2018.csv",
		"HeadphoneType":  "OnEar",
        "ResultDisplayName":  "harman_oe_2018",
        "Behavior": "Standardization"

    },
...
```
It's default content is just for demo purpose,  
the data stored as "object in array",  
so carefully edit the content or add more repeat.  
The "Behavior" have two option, ```Standardization``` and ```Mimesis```.  
You use ```Standardization``` for headphone data to compensation files,  
but use ```Mimesis``` for headphone data to another headphone data.  

If you want to use multi headphone mode,  
turn this to true,
```
# Preset argument
# Set to true if you want to use for multiple headphones by launch once
$multiHeadphoneMode = $false
```
then go to ```multiHeadphone.json``` for the arguments.  

Once all argument were defined,  
run the ```autoeq-batch-generator.ps1```, your batch should start working.  
Use this for overwrite exist(delete first) result, by default is skip exist result.  
```autoeq-batch-generator.ps1 -Overwrite```  
Use this for generate script but do not run immediately, by default is run it.  
```autoeq-batch-generator.ps1 -DisableAutoRun```  
They can use at same time, for example  
```autoeq-batch-generator.ps1 -Overwrite -DisableAutoRun```  
