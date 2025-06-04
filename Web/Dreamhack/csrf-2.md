## 📍csrf-2

```
여러 기능과 입력받은 URL을 확인하는 봇이 구현된 서비스입니다.
CSRF 취약점을 이용해 플래그를 획득하세요.
```

/change_password 페이지, /login 페이지가 추가됐다.


#### 소스코드

`username`이 `admin`인 경우 index.html에 FLAG 값이 출력된다.

**vuln** 페이지는 "frame", "script", "on" 세 가지 키워드를 필터링해 XSS 공격을 막는다.

**flag** 페이지는 POST 요청을 보내면 `param` 파라미터 값을 가져온 뒤 `session_id`를 생성하고, 생성한 `session_id`를 키로 사용하여 `admin` 값을 `session_storage` 딕셔너리에 저장한다.
![](Attachments/A235DD06-4187-4A7C-831A-2A83EC12A5A8.png)

**login** 페이지는 POST 요청을 보내면, username과 password 파라미터 값을 가져와서 pw와 비교한다.
로그인이 성공한 경우, 사용자를 index 페이지로 리다이렉션하도록 새로운 응답 객체(resp)를 만든다.
나중에 사용자를 식별할 때 사용할 `session_id`를 만들고 `session_id`로  `session_storage`에 `username`을 저장한다.
![](Attachments/69AAAFDA-DF55-480F-B512-955BACED74DA.png)

**change_password** 페이지는 `pw` 파라미터의 값을 가져와서 `pw` 변수에 저장한다.
또 브라우저 쿠키에서 `sessionid` 파라미터 값을 `session_id` 변수에 저장한다.
`session_id`를 사용해 로그인한 사용자를 확인하고, `session_storage`에 없으면 please login 메시지를 띄운다.
`users[username] = pw` ➡️ 세션을 통해 확인된 이용자의 비밀번호를 새로운 비밀번호 `pw`로 변경한다.
![](Attachments/94F6A958-2A39-49F0-8DB0-336D861D4FB8.png)


#### 취약점

vuln 페이지는 이용자의 입력값을 그대로 출력하므로 CSRF 공격을 수행할 수 있다.


#### 해결

flag 페이지에서 `admin`의 `session_id`가 저장되므로, flag 페이지에서 `admin`의 비밀번호를 변경하기 위해서는 change_password 페이지를 접근해야 한다.
flag 페이지를 방문하는 이용자가 change_password 페이지로 요청을 전송하도록 CSRF 공격 코드를 작성한다.

```html
<img src="/change_password?pw=admin" />
```

flag 페이지에서 공격 코드를 전송한다.
login 페이지에서 조작한 pw 값으로 `admin`에 로그인하면 FLAG가 출력된다.

![](Attachments/9E9D25F5-D34D-46EE-A96E-C3EEFAC10E8D.png)

