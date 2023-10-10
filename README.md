# exploit-starter-kit

## Overview

This is a minimal example of a buffer overflow exploit used as part of Duke University's ECE 560 (Intro to Computer Security). It should work on any modern Linux.
 
To use, you'll need to [disable ASLR](http://askubuntu.com/questions/318315/how-can-i-temporarily-disable-aslr-address-space-layout-randomization). Also, [this post explains how to turn off W^X](https://www.m0skit0.org/2012/11/disabling-aslr-and-nx-in-linux.html) (also known as NX support) at compile time (done by default by the Makefile in the starter kit linked below). 
 
To do the exploit as-is:
* **Prepare environment**: In your Linux environment, install nasm (“sudo apt install nasm”).
* **Get set up**: Download/clone, extract, and test the example exploit kit.
  * The Makefile is set up to build the vulnerable program with W^X disabled.
  * Read through the vulnerable program “vuln1.c” and the attack script “attack.asm” closely. 
  * [Watch this walkthrough video I recorded](https://youtu.be/q4iGAocXo0o). 
    * NOTE: This video was recorded for an earlier version of the demo, so there are slight differences, in particular, it claims that we need to avoid null bytes in the attack buffer, this is actually not true for a gets() exploit. It also shows a global-based overflow, while the current version is stack-based.   
* **Run demo**: ``./demo``
  * The demo script will run the program first normally, then with the attack buffer. 
  * The included attack will make the program skip saying “Bye!” and exit with status code 5 instead of the usual 0.  Recall that the exit status of a program can be checked by running “echo $?” after the program exits. The demo script should show this.
  * Assuming your VM’s memory map looks like mine, you may be able to run the attack straight away by executing the “demo” script.  If it doesn’t work (e.g., segfault), you may need to update the memory location constants ``buffer_ptr`` and ``func_ptr`` in the attack script, re-build, and try again. The vulnerable program helpfully announces these pointer locations when run.

At this point, you can develop fancier attack buffers to do more stuff. If you're starting with this kit for an ECE 560 homework, refer back to the assignment for what to do next. 

## Resources
Here’s some random links and tips to help you:
* [GDB quick reference card](http://users.ece.utexas.edu/~adnan/gdb-refcard.pdf).
* [Syscall numbers](https://filippo.io/linux-syscall-table/). Also, [alternate source with register indicators](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/).
* Intel x86 assembly reference:
  * [The giant Intel big book: the authoritative source](http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-instruction-set-reference-manual-325383.pdf).
  * [The felixcloutier x86 instruction reference](https://www.felixcloutier.com/x86/).
  * [NASM manual](http://www.nasm.us/doc/), including [instruction list](http://www.nasm.us/doc/nasmdocb.html).
  * Low-level conversions between hex bytes and CPU instructions: 
[Numeric order](http://ref.x86asm.net/coder64.html), [mnemonic order](http://ref.x86asm.net/coder64-abc.html).
* You can use “``ndisasm -b64 <file>``” to do a raw disassembly of your attack buffer, with output in Intel (NASM) syntax.
* You can use “``hd <file>``” to get a hexdump of it, which is useful when looking for nulls or whitespace bytes that snuck into your attack buffer.

Have fun!