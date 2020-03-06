import argparse

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

print(args.multiHeadphone)