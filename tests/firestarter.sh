git clone https://github.com/tud-zih-energy/FIRESTARTER
cd FIRESTARTER
mkdir build
cd build
cmake .. .
make
lava-test-case firestarter-test --shell ./src/FIRESTARTER -t 300