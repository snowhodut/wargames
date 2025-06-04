![](Attachments/A13617A2-88AD-4A42-8FD9-EF04F71CDB8E.png)


```c
#include <stdio.h>
#include <fcntl.h>

#define PW_LEN 10
#define XORKEY 1

void xor(char* s, int len){
        int i;
        for(i=0; i<len; i++){
                s[i] ^= XORKEY;
        }
}

int main(int argc, char* argv[]){

        int fd;
        if(fd=open("/home/mistake/password",O_RDONLY,0400) < 0){
                printf("can't open password %d\n", fd);
                return 0;
        }

        printf("do not bruteforce...\n");
        sleep(time(0)%20);

        char pw_buf[PW_LEN+1];
        int len;
        if(!(len=read(fd,pw_buf,PW_LEN) > 0)){
                printf("read error\n");
                close(fd);
                return 0;
        }

        char pw_buf2[PW_LEN+1];
        printf("input password : ");
        scanf("%10s", pw_buf2);

        // xor your input
        xor(pw_buf2, 10);

        if(!strncmp(pw_buf, pw_buf2, PW_LEN)){
                printf("Password OK\n");
                system("/bin/cat flag\n");
        }
        else{
                printf("Wrong Password\n");
        }

        close(fd);
        return 0;
}
```

힌트: operator priority
연산자를 잘 보자.

```c
int fd;
if(fd=open("/home/mistake/password",O_RDONLY,0400) < 0){
	printf("can't open password %d\n", fd);
	return 0;
}
```

위 코드에서, `=` 연산자는 `<` 연산자에게 우선순위가 밀리기 때문에 `open("", O_RDONLY, 0400) < 0`의 결과가 `fd`에 저장된다.

`open` 함수가 정상적으로 작동하면 `file descriptor`의 값인 양수를 리턴하고 실패하면 -1을 리턴한다.

따라서, 위 크기 비교 연산의 값으로는 거짓, 즉 0이 저장되고 `fd`는 표준 입력이 된다.
`./mistake`를 실행했을 때 `do not bruteforce...` 이후에 입력을 받는 이유가 이 때문이다.

이때 입력하는 값이 `pw_buf`에 저장된다.
이후 `input password : ` 이후 입력하는 10바이트의 값이 `pw_buf2`에 저장되고, `pw_buf2`에 저장된 값은 xor 연산을 거친다.
결과적으로 `pw_buf`와 xor 연산을 거친 `pw_buf2`를 비교해 값이 같으면 flag를 볼 수 있다.

#### exploit

`pw_buf2`로 10바이트의 값을 받으므로, `pw_buf`에도 10바이트의 값을 입력해준다.
A를 10번 입력했다.

![](Attachments/66FFAC9F-6F2D-4CDE-96CA-A9286A52E708.png)

A의 아스키 코드 값은 0x41이다.

```c
void xor(char* s, int len){
        int i;
        for(i=0; i<len; i++){
                s[i] ^= XORKEY;
        }
}
```

상수 `XORKEY`의 값은 1로 정의되어 있으므로, 0x41 = 0100 0001과 0000 0001을 xor 연산한다.
0100 0000 = 0x40이므로, A의 xor 연산 값은 @이다.

`pw_buf2` 값으로 @를 10번 입력한다.

![](Attachments/FAC8B0F9-6CC1-4A29-9CA3-4FAB042E335C.png)

🚩