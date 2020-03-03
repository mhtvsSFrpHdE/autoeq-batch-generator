# Library
$libCtspw = ".\cstpw.ps1"
$libFolderIterator = ".\folder-iterator.ps1"
$libSimpleCatch = ".\simplecatch.ps1"

# Config
$configPathTargetCurve = ".\targetCurve.json"
$configPathRegenerate = ".\regenerate.json"
$configPathMultiHeadphone = ".\multiHeadphone.json"

# Interact config(use ps1 as config)
$interactConfigPathMessage = ".\abg-message.ps1"
$interactConfigPathMagicValue = ".\abg-magic-value.ps1"
$interactConfigPathUserConfig = ".\abg-user-config.ps1"

# All files array(overwrite exist variable that defined by abg launcher)
$script:filesToCheckArray = @(
    $libCtspw,
    $libSimpleCatch,
    $configPathTargetCurve,
    $configPathRegenerate,
    $configPathMultiHeadphone,
    $configPathMultiHeadphone,
    $interactConfigPathMagicValue,
    $interactConfigPathUserConfig
)