## 📍xss-2

```
여러 기능과 입력받은 URL을 확인하는 봇이 구현된 서비스입니다.  
XSS 취약점을 이용해 플래그를 획득하세요. 플래그는 flag.txt, FLAG 변수에 있습니다.
```

xss-1과 비슷하지만, 이번에는 vuln 페이지가 이용자의 입력값을 그대로 return하지 않고 `render_template` 함수를 사용한다.

![](Attachments/29032E3C-6FFC-4AF9-AF1E-8D9A98CA9F8C.png)

`render_template` 함수는 Flask 웹 프레임워크에서 제공하는 함수로,
전달된 템플릿 변수가 기록될 때 HTML 엔티티코드로 변환해 저장되기 때문에 XSS가 발생하지 않게 된다.


#### 취약점

xss-1과 달리 vuln 페이지에 존재하는 innerHTML을 통해 script 태그로 XSS를 발생시킬 수 없다.
(innerHTML은 코드 인젝션을 막기 위해 script 태그를 일반 텍스트로 인식한다.)

따라서 다른 태그를 사용한다.

```javascript
<img src="XSS-2" onerror="location.href = '/memo?memo=' + document.cookie;" />
```

`img` 태그에서 이미지를 가져올 수 없는 경우 `onerror`에 연결된 함수가 실행되는 것을 이용한다.


위 코드를 vuln 페이지의 param에 입력하면 이미지 로딩에 실패한 화면이 나타난다.
![](Attachments/3E2D637E-AF53-4D1F-BC5D-55D5A1D1DD43.png)
작동하는 코드임을 알 수 있으므로, flag 페이지의 페이로드에 입력하고 memo 페이지를 확인한다.

![](Attachments/6471AC1D-5409-47E4-867F-685B8BA7A2AD.png)