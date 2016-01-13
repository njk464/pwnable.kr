First I connected to the server with the command 

ssh fd@pwnable.kr -p 2222

Afterwards by using the command 

ls -l

I found out that the file fd.c is not protected

vi fd.c

char buf[32];
int main(int argc, char* argv[], char* envp[]){
    if(argc<2){
        printf("pass argv[1] a number\n");
        return 0;
    }
    int fd = atoi( argv[1] ) - 0x1234;
    int len = 0;
    len = read(fd, buf, 32);
    if(!strcmp("LETMEWIN\n", buf)){
        printf("good job :)\n");
        system("/bin/cat flag");
        exit(0);
    }
    printf("learn about Linux file IO\n");
    return 0;

}

The code is comparing the input to 0x1234 which is 4660 in decimal. So when I enter

./fd 4660

I get past the first barrier. I then enter 

LETMEWIN

and then I got the flag.

./fd 4660
LETMEWIN
good job :)
mommy! I think I know what a file descriptor is!!

flag = mommy! I think I know what a file descriptor is!!
