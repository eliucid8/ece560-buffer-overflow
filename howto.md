# how to do the hackermannery

turn off ASLR: (works until next reboot)
`echo 0 | sudo tee /proc/sys/kernel/randomize_va_space`
Compile without W^X
add: `-fno-stack-protector -z execstack` as flags on your compile command.

install your deps:
`sudo apt install gdb nasm build-essential`

check out the unix syscall table:
[https://filippo.io/linux-syscall-table/]


