check_line () {
    if [ $1 == *"NVIDIA-SMI has failed"* ]; then
        return 1
    else
        return 0
    fi
}

start_cuda_job () {
    echo "lava-test-case firestarter-test --shell /root/FIRESTARTER/src/FIRESTARTER_CUDA -t 300"
}

start_nocuda_job () {
    NO_CUDA=1
    echo "lava-test-case firestarter-test --shell /root/FIRESTARTER/src/FIRESTARTER -t 300"
}


NO_CUDA=0
readarray -t lines < <(lspci | grep VGA)
for line in "${lines[@]}"; do
    check_line $line
    if [ $? == 1 ]; then
        start_nocuda_job
        break
    fi
done
echo "NO_CUDA: " $NO_CUDA
if [ $NO_CUDA != 1 ]; then
    start_cuda_job
fi
