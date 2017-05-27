nasm/nasm -f bin -o boot.bin boot.asm
nasm/nasm -f bin -o kernel.bin kernel.asm

cp boot.bin boot.img
cp kernel.bin kernel.img