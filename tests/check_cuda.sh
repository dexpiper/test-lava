check_line () {
    echo "nvidia-smi output: $*"
    if [$* == ""]; then
        echo "Command nvidia-smi not found. Starting FIRESTARTER without CUDA"
    elif [[ "$*" == *"has failed"* ]]; then
        echo "No CUDA on this machine. Starting FIRESTARTER without CUDA"
        return 0
    else
        echo "CUDA device found, starting FIRESTARTER with CUDA"
        return 1
    fi
}

start_cuda_job () {
    if [ $CUDA == 1 ]; then
        echo "lava-test-case firestarter-test --shell /root/FIRESTARTER/src/FIRESTARTER_CUDA -t 300"
    else
        echo "lava-test-case firestarter-test --shell /root/FIRESTARTER/src/FIRESTARTER -t 300"
    fi
}


CUDA=1
output=$(nvidia-smi)
check_line $output
if [ $? == 0 ]; then
    CUDA=0
fi
start_cuda_job
