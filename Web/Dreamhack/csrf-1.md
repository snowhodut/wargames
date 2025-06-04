## 📍csrf-1

```
여러 기능과 입력받은 URL을 확인하는 봇이 구현된 서비스입니다.
CSRF 취약점을 이용해 플래그를 획득하세요.
```

/, /vuln, /memo, /admin/notice_flag, /flag 4개의 페이지가 있다.


#### 소스코드

**vuln** 페이지는 이용자가 전달한 `param` 파라미터의 값을 출력하는데, 파라미터에 "frame", "script", "on" 세 가지의 악성 키워드가 있으면 "\*" 문자로 치환한다.
(XSS 공격을 막기 위함)
![](Attachments/{9F2DCAF8-11E0-4C90-9D66-25BA754B8277}.png)

**memo** 페이지는 이용자가 작성한 메모를 출력한다.

**admin/notice_flag** 페이지는 로컬호스트에서 접속하는 userid가 admin인 경우에만 memo에 flag를 작성해 보여준다.
페이지 자체는 모두가 접근 가능하고, userid 파라미터에 admin 값을 넣는 것도 가능하나, IP 주소는 조작할 수 없기 때문에 페이지에 단순히 접근하는 것만으로는 플래그를 획득할 수 없다.
![](Attachments/{B25322D2-2EDC-4536-9CC5-C419BB399306}.png)

**flag** 페이지는 전달된 URL에 임의 이용자가 접속하게 한다.
(Selenium 봇)
![](Attachments/{E23C1145-B2E5-4012-AB39-CB7A8788EC3B}.png)



#### 취약점

vuln 페이지에서 frame, script, on 세 가지의 악성 키워드는 필터링하므로 XSS 공격은 불가능하다.
그러나 키워드 이외의 꺽쇠(<>)를 포함한 다른 키워드와 태그는 사용할 수 있으므로 CSRF 공격은 가능하다.

공격 코드가 삽입된 vuln 페이지를 이용자가 방문할 경우, 의도하지 않은 페이지로 요청을 전송하는 시나리오를 작성한다.
플래그를 얻기 위해서는 /admin/notice_flag 페이지를 로컬호스트에서 접근해야 한다.
➡️ vuln 페이지를 방문하는 로컬호스트 이용자가 /admin/notice_flag 페이지로 요청을 전송하도록 한다.


#### CSRF 취약점 테스트

취약점이 발생하는 페이지에 img 태그를 사용해 작성한 공격 코드를 삽입한다.

```
http://host3.dreamhack.games:15693/vuln?param=%3Cimg%20src=1/%3E
```

![](Attachments/{08D93C7D-1200-49A0-9058-6A56B32BD365}.png)

코드에 의해 이미지가 vuln 페이지에 출력되었다.


#### 해결

/admin/notice_flag 에는 `userid`가 `admin`인지 검사하는 부분이 존재하기 때문에 해당 문자열을 포함한다.

```html
<img src="/admin/notice_flag?userid=admin" />
```

![](Attachments/{3A10A38A-096D-45AD-9D3C-A05BD078B475}.png)

memo 페이지에 가면 FLAG가 출력되어 있다.

![](Attachments/{F8FA4F27-EE58-4276-AC2E-00463BA6569D}.png)
