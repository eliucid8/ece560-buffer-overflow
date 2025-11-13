# how to do the hackermannery

turn off ASLR: (works until next reboot)
`echo 0 | sudo tee /proc/sys/kernel/randomize_va_space`
Compile without W^X
add: `-fno-stack-protector -z execstack` as flags on your compile command.

install your deps:
`sudo apt install gdb nasm build-essential`

check out the unix syscall table:
[https://filippo.io/linux-syscall-table/]

## the infra
I modified the demo script to take in an argument for different asm files.
This makes it easier to attempt extra credit


# the basic
we be smashing the stack for fun and profit.
Most of the exploit was already done tbh. The main thing to do was learn how to use nasm and figure out the linux syscall table.
the syscall to write to a file descriptor is 1
the file descriptor for stdout is 1
the location of the buffer we want to write is stored in `message`
and the length of said buffer is calculated for us in `message_len`

And hey presto! we have a hax0r!


# the multiline
Because the newline character (0x0A) is the terminator for `gets()`, I cannot include that character anywhere in my assembly file.
I tried multiple approaches:
First, I tried writing a different newline character, such as \r (but this is unfortunately not macos), so that didn't do anything.
I also tried a multibyte UTF line break but that didn't do anything either.
I then tried to manually set one of the characters in the buffer to newline during the execution of the custom code, but that resulted in a segfault.
So finally, I decided to reuse one of the newlines in `vuln1.c`. Using `gdb`, I got the memory location of `main()` and tried a few offsets from this around the `printf()`s until I got to the line that prints out where the locations of everything is. 
I then did some fine-grained digging until I stumbled onto the exact memory address of the newline, and added it as a constant to my asm file:
`%define newline_char 0x555555556077`
then, I used the write syscall to write a single byte from this memory location, and was able to print out a second line.

```
; message2 db "visit https://r.mtdv.me/videos/TLVPIoFKle for help"
; message2_len equ $-message2
```

But I was still not satisfied.
So i found a fun ascii image.
Initially, I duplicated my write syscall code for all 4 lines, but then I ran out of space in the buffer.
So instead, since each line of ascii art was the same length I was able to simply loop through and interleave priting the art and printing newlines.


