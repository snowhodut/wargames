![](Attachments/{1045E81F-2A44-4FA4-97FE-8684C5F0268F}.png)


### File Descriptor
- 시스템으로부터 할당받을 파일(소켓)을 대표하는 정수값
- 시스템이 열려 있는 파일에 접근하기 쉽도록 사용자에게 파일에 번호를 붙여 알려주는 것
- 프로세스가 메모리에 올라갈 때, 프로세스마다 fd의 번호가 사전에 배정되어 있음![](Attachments/Pasted%20image 20240914190533.png)




![](Attachments/{5C21E2AD-6031-4910-951F-46E0DA7C9A06}.png)

`flag`는 권한이 없어서 읽을 수 없다.
`fd`라는 실행파일이 존재하고 setuid가 fd_pwn의 권한으로 걸려 있다. `fd.c`를 이용해서 fd_pwn의 권한을 얻고 flag를 읽을 수 있는지 확인하자.

`$ cat fd.c`

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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
```
- fd라는 정수형 변수에, argv\[1]을 아스키 코드에서 정수로 변환하고 0x1234를 뺀 값을 저장한다.
	- `atoi`: C에서 문자열을 정수로 변환하는 ASCII to integer 함수
- fd가 가리키는 파일을 32바이트 읽어들여 buf에 저장하고, 정수형 변수 len에 읽어들인 바이트 수를 저장한다.
- buf에 저장된 문자열이 "LETMEWIN"이면 fd_pwn의 권한으로 flag의 내용을 보여준다.


#### 풀이
- fd를 0으로 설정하고(표준 입력), 표준 입력 스트림으로 `LETMEWIN`을 입력해 flag를 얻는다.

- fd를 0으로 설정
	- argv[1]을 정수형(10진수)로 바꾸고, 거기서 0x1234를 뺀 값이 fd의 번호가 된다.
		- argv[0]은 프로그램의 이름을, argv[1]은 두 번째 인자로 사용자로부터 입력받은 첫 번째 인자를 나타냄
		- `./program_name 1234`에서 argv[0]은 "./program_name", argv[1]은 1234임
	- 0x1234를 10진수로 변환하면 4660이므로, `./fd`를 실행할 때 인자로 4660을 준다.

![](Attachments/{72C6E3B3-C7E9-45AC-A77A-AA8411848AFA}.png)
