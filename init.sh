#! /bin/bash

sleep 10

# Compile SU2 on the main node in the session
echo "Compiling SU2"
cd /home/nimbix/data/
bash /home/nimbix/data/compile_SU2.sh

echo "Changing to /home/nimbix/data directory to begin data processing."

# Get bash filename from session initialization
while [[ -n "$1" ]]; do
    case "$1" in
	-file)
	    shift
        BASH_FILE="$1"
		;;
	esac
    shift
done

# Call the bash file
source "$BASH_FILE"
cd $(dirname $BASH_FILE)
chmod +x "$BASH_FILE" 
