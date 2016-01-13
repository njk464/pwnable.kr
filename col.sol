After connecting to the server with the command

ssh col@pwnable.kr -p2222

I found out that the file col.c was viewable.

ls -l
vi col.c
#include <stdio.h>
#include <string.h>
unsigned long hashcode = 0x21DD09EC;
unsigned long check_password(const char* p){
    int* ip = (int*)p;
    int i;
    int res=0;
    for(i=0; i<5; i++){
        res += ip[i];
    }
    return res;
}

int main(int argc, char* argv[]){
    if(argc<2){
        printf("usage : %s [passcode]\n", argv[0]);
        return 0;
    }
    if(strlen(argv[1]) != 20){
        printf("passcode length should be 20 bytes\n");
        return 0;
    }

    if(hashcode == check_password( argv[1] )){
        system("/bin/cat flag");
        return 0;
    }
    else
        printf("wrong passcode.\n");
    return 0;
}

The program takes in 20 bytes and then compares them to the variable hashcode by converting the char* to an int* (4 byte intervals).
The 5 ints in the 20 bytes are then added and checked to see if they equal the variable hashcode.

0x21DD09EC = 0x06C5CEC8 * 4 + 0x06C5CECC

Since the system is little endian we can run 

./col $(perl -e 'print "\xc8\xce\xc5\x06"x4 . "\xcc\xce\xc5\x06"')

This gets us the flag "daddy! I just managed to create a hash collision :)"
