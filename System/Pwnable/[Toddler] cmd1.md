![](Attachments/{074744E8-64C9-4D11-B992-2CA155836C63}.png)

![](Attachments/{56E728FD-200C-495D-B3E5-A98FCC707139}.png)

cmd1.c부터 읽어보자.

```c
#include <stdio.h>
#include <string.h>

int filter(char* cmd){
        int r=0;
        r += strstr(cmd, "flag")!=0;
        r += strstr(cmd, "sh")!=0;
        r += strstr(cmd, "tmp")!=0;
        return r;
}
int main(int argc, char* argv[], char** envp){
        putenv("PATH=/thankyouverymuch");
        if(filter(argv[1])) return 0;
        system( argv[1] );
        return 0;
}
```

PATH 환경변수를 `/thankyouverymuch`로 설정해서 초기화한다.
이후 `system( argv[1] )` 호출 시, 커맨드를 `/thankyouverymuch`에서 찾게 된다.

인자값에서 flag, sh, tmp를 필터링하고, 하나라도 포함되어 있으면 종료된다.


### 해결

Linux에서 사용하는 명령어는 모두 `bin` 디렉토리에 존재한다.
하지만 `/bin/cat`, `/bin/ls`를 사용하는 대신 `cat`, `ls`만 입력해도 명령어를 사용할 수 있는데, 이는 PATH에 미리 `/bin`이라고 명시되어 있고 환경변수 PATH를 참조할 수 있기 때문이다.

이때 `cmd1.c`에서 `putenv`로 환경변수를 초기화하므로 명령어의 절대경로를 적어줄 수 있다.

또, 필터링을 하기 때문에 \* 와일드카드를 사용해 flag에 접근할 수 있다.

![](Attachments/{76DC905B-A567-4BAE-ACC8-DC1DEDEB003C}.png)

아니면 `export` 커맨드로 일시적으로 현재 세션에서만 유효한 환경변수를 설정하는 방법도 있다.

🚩