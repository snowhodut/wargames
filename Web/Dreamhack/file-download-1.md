## 📍file-download-1

```
File Download 취약점이 존재하는 웹 서비스입니다.  
flag.py를 다운로드 받으면 플래그를 획득할 수 있습니다.
```

![](../../Attachments/905DB45C-F68B-4359-B58C-5F9D1370884E.png)


아무거나 업로드해봤다.

단순히 flag.py를 넣으면 막아버린다.
![](../../Attachments/084EFD30-2048-4857-A08A-7EAE1C5B20F9.png)


#### 소스코드

**upload** 페이지는 `..`를 필터링한다.
`filename`에는 `..`를 넣을 수 없다.
![](../../Attachments/301B8A97-6355-41BF-AD85-F9A15D07AE7F.png)

**read** 페이지는 필터링이 없다.
다운로드되는 파일에 대해 아무런 검사도 하지 않으므로 파일 다운로드 공격에 취약하다.
![](../../Attachments/B0268DA4-CC09-415D-BFC0-7EE27FB802C4.png)



#### 해결

read 페이지에서 파일명을 `../flag.py`로 바꿔주면 해결!

![](../../Attachments/5681991A-357D-42CF-B7F7-16BA48485D56.png)
