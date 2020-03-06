import argparse
import locale
import configparser

from pathlib import Path as plPath
from os import path as osPath

# Place some placeholders
args = None
configEnvironment = configparser.ConfigParser()

# Read command line arguments


def pythonArgParser():
    global args

    argParser = argparse.ArgumentParser()

    # MultiHeadphone
    argParser.add_argument("-m", "--multiHeadphone",
                           help="Force specify multi headphone mode",
                           action="store_true")
    # Overwrite
    argParser.add_argument("-o", "--overwrite",
                           help="Overwrite existing results",
                           action="store_true")
    # AllToAll
    argParser.add_argument("-a", "--allToAll",
                           help="Turn on all to all preprocessor",
                           action="store_true")

    args = argParser.parse_args()

# Preprocess argument
# the argument should not change by code after preprocess


def myArgParser():
    pythonArgParser()

    if args.allToAll is True:
        args.multiHeadphone = True
        args.override = False

# Read config files


def pythonConfigParser():
    global configEnvironment

    configEnvironmentPath = plPath(R'./environment.ini')
    configEnvironment.read(configEnvironmentPath)

# Preprocess config
# the config should not change by code after preprocess


def myLocaleParser():
    global configEnvironment

    # Check system language
    languageRoot = configEnvironment['language']['root']
    systemLanguage = locale.getdefaultlocale()[0]
    languageCurrent = languageRoot + systemLanguage + '/'  # language/en_US/

    currentLanguageExists = osPath.exists(plPath(languageCurrent))
    if currentLanguageExists is True:
        languageCurrent = configEnvironment['language']['fallback']
    #

    # Apply language to path
    configPathMessage = configEnvironment['message']['configPathMessage']
    configPathMessage = languageCurrent + \
        configPathMessage  # language/en_US/message.xml

    configEnvironment['message']['configPathMessage'] = configPathMessage


def myConfigParser():
    pythonConfigParser()

    myLocaleParser()

