## 📍command-injection-1

```
특정 Host에 ping 패킷을 보내는 서비스입니다.  
Command Injection을 통해 플래그를 획득하세요. 플래그는 `flag.py`에 있습니다.
```

![](Attachments/{8AE60DD5-7FEC-4E54-B1D4-130026742FBF}.png)


#### 소스코드

ping 페이지에서, 이용자가 입력한 특정 Host에 ping 패킷을 보내는 기능을 제공한다.
![](Attachments/{93C1B35F-A517-42BE-98D8-6CC70B3EBA81}.png)


#### 취약점

`cmd` 변수는 이용자로부터 입력받은 `host` 값을 포함한다.
하지만 이용자의 입력을 그대로 명령어로 실행하기 때문에 이용자가 악의적인 공격 코드를 주입할 수 있다.


#### 해결

명령어 구분자 `;`를 이용한 익스플로잇을 시도했는데, 형식에 대한 조건이 있었다.
![](Attachments/{C65AECF7-4D5A-494B-A31F-D84BED228F7D}.png)

개발자 도구로 확인해보면 `input` 태그의 `pattern` 속성이 설정되어 있음을 알 수 있다.
![](Attachments/{34E0F11E-6999-43BE-B848-DB995DFF70A7}.png)
허용된 정규 표현식은 영어, 숫자, 글자수 5~20자이다.

그러나 서버 단에서 일어나는 검증이 아니고 클라이언트 단에서 일어나는 검증이므로 필터링 우회가 가능하다.
개발자 도구를 사용해 `pattern` 속성을 제거한다.
다시 시도하면 FLAG가 보인다.

![](Attachments/{66C84D71-B89F-465D-A581-274C882F7FE3}%201.png)