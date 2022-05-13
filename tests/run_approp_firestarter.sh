#!/usr/bin/env bash

# Check if CUDA available with nvidia-smi, then start appropriate
# FIRESTARTER (with or without GPU load: FIRESTARTER_CUDA or bare FIRESTARTER)
# CUDA_ONLY test could be started with option -c

# maintainer: a.kurilov@yadro.com

########################################################################################
#                                                                                      #
# USAGE: ./run_approp_firestarter.sh [-c] [-f] [-d] [-g:] [ -m:] [-t:]                 #
#            [-l:] [-p:] [-n:] [-b:]                                                   #
#                                                                                      #
#     Uses standard FIRESTARTER options listed above (except -c)                       #
#     Please refer https://github.com/tud-zih-energy/FIRESTARTER#usage-and-options     #
#     Flags with ":" (colon) require arguments, but no explicit validation provided.   #
#                                                                                      #
#     Options -f, -d, -g and -m are only applicable for CUDA. They would be omitted    #
#         for CPU test.                                                                #
#     CPU-bound args would be ommitted in CUDA_ONLY test (if -c set)                   #
#                                                                                      #
#   SCRIPT-SPECIFIC:                                                                   #
#   -c Force only GPU test without CPU (FIRESTARTER_CUDA_ONLY)                         #
#                                                                                      #
#   FIRESTARTER-SPECIFIC:                                                              #
#   -f Use single precision matrix multiplications                      (GPU only)     #
#   -d Use double precision matrix multiplications instead of default   (GPU only)     #
#   -g Number of gpus to use, default: -1 (all)                         (GPU only)     #
#   -m Size of the matrix to calculate, default: 0 (maximum)            (GPU only)     #
#   -t TIMEOUT Set the timeout (seconds) after which FIRESTARTER terminates itself.    #
#      Instead of standard FIRESTARTER default (no timeout) script will set 300 sec    #
#      if no other timeout specified.                                                  #
#   -l LOAD Set the percentage of high CPU load to LOAD (%) default: 100               #
#   -p PERIOD Set the interval length for CPUs to PERIOD (usec), default: 100000       #
#   -n COUNT THREADS  Specify the number of threads                                    #
#   -b CPULIST Select certain CPUs. CPULIST format: "x,y,z", "x-y", "x-y/step"         #
#                                                                                      #
########################################################################################


# check output of nvidia-smi and return 0 or 1:
#   return 0 if no CUDA detected or command not found
#   else return 1
check_line () {
    echo "nvidia-smi output: $*"
    if [ "$*" == "" ]; then
        echo "Command nvidia-smi not found. Starting FIRESTARTER without CUDA"
        return 0
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
    if [ $CUDAONLY == 1 ]; then
    lava-test-case firestarter-test --shell /root/FIRESTARTER/src/FIRESTARTER_CUDA_ONLY \
$USEGPUFLOAT$USEGPUDOUBLE$GPUS$MATRIXSIZE$TIME
    elif [ $CUDA == 1 ]; then
        lava-test-case firestarter-test --shell /root/FIRESTARTER/src/FIRESTARTER_CUDA \
$USEGPUFLOAT$USEGPUDOUBLE$GPUS$MATRIXSIZE$TIME$LOAD$PERIOD$THREADS$BIND
    else
        lava-test-case firestarter-test --shell /root/FIRESTARTER/src/FIRESTARTER \
$TIME$LOAD$PERIOD$THREADS$BIND
    fi
}


# read arguments
CUDAONLY=0
USEGPUFLOAT=""
USEGPUDOUBLE=""
GPUS=""
MATRIXSIZE=""
TIME="-t 300 "                            # default time 300 sec, always set
LOAD=""
PERIOD=""
THREADS=""
BIND=""
while getopts ":cfdg:m:t:l:p:n:b:" options; do
    case "${options}" in
        c)
            CUDAONLY=1
        ;;

        f)
            USEGPUFLOAT="-f "
        ;;

        d)
            USEGPUDOUBLE="-d "
        ;;

        g)
            GPUS="-g ${OPTARG} "
        ;;

        m)
            MATRIXSIZE="-m ${OPTARG} "
        ;;

        t)
            TIME="-t ${OPTARG} "
        ;;

        l)
            LOAD="-l ${OPTARG} "
        ;;

        p)
            PERIOD="-p ${OPTARG} "
        ;;

        n)
            THREADS="-n ${OPTARG} "
        ;;

        b)
            BIND="-b ${OPTARG} "
        ;;

    esac
done


if [ $CUDAONLY == 1 ]; then
    echo "Run FIRESTARTER_CUDA_ONLY with: $TIME$LOAD$PERIOD$THREADS$BIND"
    start_cuda_job
    exit
fi

CUDA=1
output=$(nvidia-smi)
check_line $output

if [ $? == 0 ]; then
    CUDA=0
    echo "Run FIRESTARTER without CUDA with: $TIME$LOAD$PERIOD$THREADS$BIND"
else
    echo "Run FIRESTARTER_CUDA with: $USEGPUFLOAT$USEGPUDOUBLE$GPUS$MATRIXSIZE\
$TIME$LOAD$PERIOD$THREADS$BIND"
fi

start_cuda_job
