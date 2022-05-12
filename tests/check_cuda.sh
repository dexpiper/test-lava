check_line () {
    echo "$*"
    if [[ "$*" == *"has failed"* ]]; then
        echo "No CUDA on this machine"
        return 0
    else
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
output=$(lspci | grep VGA)
check_line $output
if [ $? == 0 ]; then
    CUDA=0
    break
fi
echo "CUDA: " $CUDA
start_cuda_job
