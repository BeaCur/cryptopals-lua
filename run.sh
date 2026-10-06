#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Error: No arguments provided."
    echo "Usage: ./run.sh challenge1.lua"
    echo "       ./run.sh -a 4.txt challenge4.lua"
    exit 1
fi

zenroom "$@"
