#!/bin/bash

set -euo pipefail

# If the number of args is not between 1 and 3, print usage and exit
if [ $# -lt 1 ] || [ $# -gt 3 ]; then
    echo "Usage: run-modeegdriver.sh <tty> [nsd-host] [nsd-port]"
    echo "Example: run-modeegdriver.sh /dev/ttyUSB0 localhost 8336"
    exit 1
fi

# Configure the serial port
stty -F "${1}" -icrnl -ixon -echoctl -echoke

# Pause to make sure the serial port is ready
sleep 1

# Start the driver to interface between the EEG and the NSD
modeegdriver -d "${1}" "${2:-}" "${3:-}"
