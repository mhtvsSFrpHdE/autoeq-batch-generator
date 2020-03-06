import argparse

# Place some placeholders
args = None
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

