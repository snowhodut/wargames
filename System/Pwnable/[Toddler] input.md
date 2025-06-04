---
sticker: emoji//274c
---
![](Attachments/A49BB709-E2C2-44C1-8663-4DEC017985C0.png)

`input.c`를 읽어보자.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <arpa/inet.h>

int main(int argc, char* argv[], char* envp[]){
        printf("Welcome to pwnable.kr\n");
        printf("Let's see if you know how to give input to program\n");
        printf("Just give me correct inputs then you will get the flag :)\n");

        // argv
        if(argc != 100) return 0;
        if(strcmp(argv['A'],"\x00")) return 0;
        if(strcmp(argv['B'],"\x20\x0a\x0d")) return 0;   // 854560
        printf("Stage 1 clear!\n");

        // stdio
        char buf[4];
        read(0, buf, 4);
        if(memcmp(buf, "\x00\x0a\x00\xff", 4)) return 0;  //FF000A00
        read(2, buf, 4);
        if(memcmp(buf, "\x00\x0a\x02\xff", 4)) return 0;  //FF020A00
        printf("Stage 2 clear!\n");

        // env
        if(strcmp("\xca\xfe\xba\xbe", getenv("\xde\xad\xbe\xef"))) return 0;
        printf("Stage 3 clear!\n");

        // file
        FILE* fp = fopen("\x0a", "r");
        if(!fp) return 0;
        if( fread(buf, 4, 1, fp)!=1 ) return 0;
        if( memcmp(buf, "\x00\x00\x00\x00", 4) ) return 0;
        fclose(fp);
        printf("Stage 4 clear!\n");

        // network
        int sd, cd;
        struct sockaddr_in saddr, caddr;
        sd = socket(AF_INET, SOCK_STREAM, 0);
        if(sd == -1){
                printf("socket error, tell admin\n");
                return 0;
        }
        saddr.sin_family = AF_INET;
        saddr.sin_addr.s_addr = INADDR_ANY;
        saddr.sin_port = htons( atoi(argv['C']) );
        if(bind(sd, (struct sockaddr*)&saddr, sizeof(saddr)) < 0){
                printf("bind error, use another port\n");
                return 1;
        }
        listen(sd, 1);
        int c = sizeof(struct sockaddr_in);
        cd = accept(sd, (struct sockaddr *)&caddr, (socklen_t*)&c);
        if(cd < 0){
                printf("accept error, tell admin\n");
                return 0;
        }
        if( recv(cd, buf, 4, 0) != 4 ) return 0;
        if(memcmp(buf, "\xde\xad\xbe\xef", 4)) return 0;
        printf("Stage 5 clear!\n");

        // here's your flag
        system("/bin/cat flag");
        return 0;
}
```

길다...
한 단계씩 살펴보자.

#### Stage 1
```c
if(argc != 100) return 0;
if(strcmp(argv['A'],"\x00")) return 0;
if(strcmp(argv['B'],"\x20\x0a\x0d")) return 0;   // 854560
printf("Stage 1 clear!\n");
```
- `argc` = 프로그램에 전달된 인자의 개수, 100이 아니면 종료
- `argv['A']`가 null 문자와 같지 않으면 종료
	- `A`는 아스키에서 65이므로, `argv[65]`와 같음
- `argv['B']`가 `"\x20\x0a\x0d"`와 같지 않으면 종료
	- 마찬가지로 `argv[66]`와 같음

인자를 100개 주되 65번째는 null, 66번째는 0x0d0a20으로 주어야 하는 것 같다.


#### Stage 2
```c
// stdio
char buf[4];
read(0, buf, 4);
if(memcmp(buf, "\x00\x0a\x00\xff", 4)) return 0;  //FF000A00
read(2, buf, 4);
if(memcmp(buf, "\x00\x0a\x02\xff", 4)) return 0;  //FF020A00
printf("Stage 2 clear!\n");
```
-  File Descriptor
	- 0: 표준 입력(stdin)
	- 1: 표준 출력(stdout)
	- 2: 표준 오류(stderr)
- `memcmp`: 두 메모리 블록을 비교해서 두 블록이 같으면 0을 반환하는 함수

stdin으로 `\x00\x0a\x00\xff`를 주고, stderr로 `\x00\x0a\x02\xff` 주기


#### Stage 3
```c
// env
if(strcmp("\xca\xfe\xba\xbe", getenv("\xde\xad\xbe\xef"))) return 0;
printf("Stage 3 clear!\n");
```
- 환경변수 `\xde\xad\xbe\xef`에 있는 값은 `\xca\xfe\xba\xbe`여야 함


#### Stage 4
```c
// file
FILE* fp = fopen("\x0a", "r");
if(!fp) return 0;
if( fread(buf, 4, 1, fp)!=1 ) return 0;
if( memcmp(buf, "\x00\x00\x00\x00", 4) ) return 0;
fclose(fp);
printf("Stage 4 clear!\n");
```
- `fopen`: 파일을 열기 위해 사용되는 함수
	- `\x0a`: 파일 이름
	- `"r"`: 파일을 읽기 모드로 열기
- `if(!fp) return 0;`: 파일 포인터 `fp`가 NULL이면(파일 열기가 실패함) 종료
- `if( fread(buf, 4, 1, fp)!=1 ) return 0;`: 열린 파일에서 데이터를 읽는 함수
	- `buf`: 데이터를 저장할 버퍼
	- `4`: 읽을 바이트 수
	- `1`: 읽을 요소의 수 (4바이트를 1번 읽음)
	- `fread`가 1을 반환하지 않으면, 즉 4바이트가 성공적으로 읽히지 않았으면 종료
- `if( memcmp(buf, "\x00\x00\x00\x00", 4) ) return 0;`
	- `memcmp`: 두 메모리 블록을 비교하는 함수
	- `buf`: 파일에서 읽은 데이터가 저장된 버퍼
	- 버퍼에 있는 값과 `\x00\x00\x00\x00`를 비교하고, 값이 다르면 프로그램 종료

`\x0a` 파일에서 가져온 첫 4바이트 값이 `\x00\x00\x00\x00`여야 한다.


#### Stage 5
```c
// network
int sd, cd;
struct sockaddr_in saddr, caddr;
sd = socket(AF_INET, SOCK_STREAM, 0);
if(sd == -1){
	printf("socket error, tell admin\n");
	return 0;
}
saddr.sin_family = AF_INET;
saddr.sin_addr.s_addr = INADDR_ANY;
saddr.sin_port = htons( atoi(argv['C']) );
if(bind(sd, (struct sockaddr*)&saddr, sizeof(saddr)) < 0){
	printf("bind error, use another port\n");
	return 1;
}
listen(sd, 1);
int c = sizeof(struct sockaddr_in);
cd = accept(sd, (struct sockaddr *)&caddr, (socklen_t*)&c);
if(cd < 0){
	printf("accept error, tell admin\n");
	return 0;
}
if( recv(cd, buf, 4, 0) != 4 ) return 0;
if(memcmp(buf, "\xde\xad\xbe\xef", 4)) return 0;
printf("Stage 5 clear!\n");
```
- 네트워크 소켓 프로그래밍
- `saddr.sin_port = htons( atoi(argv['C']) );`
	- 포트 번호를 `argv['C']`, 즉 `argv[67]`로 줌
	- `htons`를 사용해 네트워크 바이트 순서로 변환함
- `if( recv(cd, buf, 4, 0) != 4 ) return 0;`
	- `recv`: 클라이언트로부터 4바이트를 수신해 `buf`에 저장
- `if(memcmp(buf, "\xde\xad\xbe\xef", 4)) return 0;`
	- 수신한 데이터 `buf`가 `\xde\xad\xbe\xef`와 동일해야 함


### Exploit code

```python
from pwn import *
import os

# stage 1 & 5
argvs = ['A']*100
argvs[ord('A')] = '\x00'
argvs[ord('B')] = '\x20\x0a\x0d'
argvs[ord('C')] = '4444'

# stage 2
r1, w1 = os.pipe()
r2, w2 = os.pipe()
os.write(w1, '\x00\x0a\x00\xff')
os.write(w2, '\x00\x0a\x02\xff')

# stage 4
with open('\x0a', 'w') as f:
	f.write('\x00\x00\x00\x00')

p = process(executable='/home/input2/input',
		   argv = argvs,
		   stdin = r1, stderr = r2,
		   # stage 3
		   env = {'\xde\xad\xbe\xef':'\xca\xfe\xba\xbe'})

# stage 5
conn = remote('localhost', 4444)
conn.sendline('\xde\xad\xbe\xef')

p.interactive()
```

- `ord()`
	- 주어진 문자의 ASCII 값을 반환하는 함수
	- 하나의 문자열 인자 ➡️ 해당 문자의 정수값 반환
- `pipe()`
	- os 모듈에서 제공하는 함수로, 총 2개의 파일 디스크립터를 반환함
	- 하나는 왼쪽 프로세스가 자신의 결과값을 write하는 파일(쓰기용), 다른 하나는 오른쪽에서 read하는 파일(읽기용)


실행하긴 했는데
![](Attachments/1B3BE44E-3BD8-4CDD-832F-AEEDB53C8347.png)
이상한 에러가 떠서 플래그를 못 얻었다...