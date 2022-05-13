#!/usr/bin/env bash


############################################################
# USAGE: run_approp_firestarter [-t]                       #
#   -t set time for FIRESTARTER to burn (defaults to 300)  #
############################################################


# check output of nvidia-smi and return 0 or 1:
#   return 0 if no CUDA detected or command not found
#   else return 1
check_line () {
    echo "nvidia-smi output: $*"
    if [ "$*" == "" ]; then
        echo "Command nvidia-smi not found. Starting FIRESTARTER without CUDA"
    elif [[ "$*" == *"has failed"* ]]; then
        echo "No CUDA detected on this machine. Starting FIRESTARTER without CUDA"
        return 0
    elif [[ "$*" == *"CUDA Version"* ]]; then
        echo "CUDA device found, starting FIRESTARTER with CUDA"
        return 1
    else
        echo "Cannot detect CUDA info in nvidia-smi output, starting FIRESTARTER without CUDA"
        return 0
    fi
}

# run appropriate command: FIRESTARTER_CUDA with CUDA, else just bare FIRESTARTER
start_cuda_job () {
    if [ $CUDA == 1 ]; then
        lava-test-case firestarter-test --shell /root/FIRESTARTER/src/FIRESTARTER_CUDA -t $TIME
    else
        lava-test-case firestarter-test --shell /root/FIRESTARTER/src/FIRESTARTER -t $TIME
    fi
}


# read arguments
TIME=300                            # default time 300 sec
while getopts ":t:" options; do
    case "${options}" in
        t)
            TIME=${OPTARG}          # rewrite TIME from args
    esac
done

CUDA=1
output=$(nvidia-smi)
check_line $output
if [ $? == 0 ]; then
    CUDA=0
    echo "Run FIRESTARTER without CUDA for $TIME sec"
else
    echo "Run FIRESTARTER_CUDA for $TIME sec"
fi
start_cuda_job
