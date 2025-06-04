![](Attachments/D541431D-F42C-4EA7-ADC9-ECF400436A0F.png)



### MD5 hash collsion(해시 충돌)
- 두 개의 서로 다른 입력값이 동일한 MD5 해시값을 생성하는 상황
- MD5는 128비트 해시 함수를 제공하지만, 해시 함수의 특성상 입력값의 수가 해시값의 개수보다 많아 충돌이 발생할 수 있음

`$ cat col.c`

```c
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
```
- password 길이로 20바이트를 입력해야 함
- `check_password`
	- 포인터 형변환
		- 내가 입력한 문자열 p의 타입을 int로 바꾸고 ip에 저장함
		- char* 1바이트 4개를 int\*로 변환하므로, 내가 입력한 20바이트/4바이트=5
	- 이후 반복문을 통해서 5등분한 값을 모두 더하고 res로 반환함

454,507,296
#### 풀이
- argv[1]으로, 0x21DD09EC=568134124 값을 5등분해서 파이썬의 리틀 엔디안 방식으로 넣어준다.
	- 0x06C5CEC8 * 4 + 0x06C5CECC
- `./col python -c 'print "\xc8\xce\xc5\x06"*4 + "\xcc\xce\xc5\x06"'`

![](Attachments/14904862-C081-41A3-B318-2A47D275ACB6.png)
