---
sticker: emoji//274c
---
![](Attachments/6D2F1CE5-A692-4514-ACC4-76F7F71B12D1.png)

![](Attachments/A6FF0B3A-2003-4936-9078-5C0D134DA7DA.png)

진짜 동전의 무게는 10, 가짜 동전은 9이고 가짜 동전 100개를 찾으면 보상을 준다고 한다. 플래그인 듯.
N을 보내면 N+1번째 동전의 무게를 알려준다.
여러 개를 보내면 여러 개의 무게의 합을 알려준다.

60초의 시간 제한이 있고, 연결할 때마다 코인의 개수가 랜덤으로 달라지는 것 같다.

이럴 때는 아래 코드처럼 시작하는, 데이터를 원격으로 받아오는 요청을 보내면 된다.

```python
r = remote("pwnable.kr", 9007)
data = r.recvuntil("sec... -\n")
```

#### Exploit

진짜 동전의 무게는 10이므로, 진짜 동전만 있다면 무게의 합은 10의 배수이다.
전체 동전을 반으로 나눠 무게의 합이 10의 배수가 아닌 구간을 찾고 그 구간을 반으로 또 나눠 가짜 동전을 찾아보자.

##### 서버에 원격으로 접속해서 데이터를 가져오는 함수 ⬇️
100번 해야 하므로 접속한 뒤 데이터를 가져오는 부분은 반복문으로 작성한다.

```python
import re

def main():
	r = remote("pwnable.kr", 9007)
	data = r.recvuntil("sec... -\n")
	print data
	sleep(3)
	r.recv(1024)
	for i in range (0,100):
		data = r.recv(1024)
		arr = re.findall("\d+", data)    # re 모듈로 데이터에서 숫자만 가져오기
		N = int(arr[0])
		C = int(arr[1])
```

##### 무게의 합이 10의 배수인지 아닌지 확인하는 함수 ⬇️

```python
def check (start, end, weight):
	num = (end - start)
	if (10 * num == weight):
		return 1
	else:
		return 0
```

##### 반복문 마저 작성

```python
	for i in range (0,100):
		data = r.recv(1024)
		arr = re.findall("\d+", data)    # re 모듈로 데이터에서 숫자만 가져오기
		N = int(arr[0])
		C = int(arr[1])
		
		start = 0
		end = N
		while (start <= end):
			msg = ""
			mid = (start + end) / 2
			for j in range (start, mid + 1):
				msg += str(j) + " "
			msg += '\n'
			r.send(msg)
			dt = r.recv(100)
			if (dt.find("Correct") != -1):
				break
			weight = int(dt)
			checkres = check(start, mid+1, weight)
			if (checkres == 1):
				print("counterfeit not found")
				start = mid + 1
			elif (checkres == 0):
				print("counterfeit coin found")
				end = mid
		print("Done")
	while True:
		data = r.recvline()
		print data
		if (data.find("bye!") != -1):
			break
```


#### 최종 코드
```python
from pwn import *
import re
import time

def check (start, end, weight):
	num = (end - start)
	if (10 * num == weight):
		return 1
	else:
		return 0

def main():
	r = remote("pwnable.kr", 9007)
	data = r.recvuntil("sec... -\n")
	sleep(3)
	r.recv(1024)
	for i in range (0,100):
		data = r.recv(1024)
		data = data.decode('utf-8')
		arr = re.findall("\d+", data)    # re 모듈로 데이터에서 숫자만 가져오기
		N = int(arr[0])
		C = int(arr[1])
		
		start = 0
		end = N
		while (start <= end):
			msg = ""
			mid = (start + end) / 2
			for j in range (start, mid + 1):
				msg += str(j) + " "
			msg += '\n'
			r.send(msg)
			dt = r.recv(100)
			if (dt.find("Correct") != -1):
				break
			weight = int(dt)
			checkres = check(start, mid+1, weight)
			if (checkres == 1):
				print("counterfeit not found")
				start = mid + 1
			elif (checkres == 0):
				print("counterfeit coin found")
				end = mid
		print("Done")
	while True:
		data = r.recvline()
		if (data.find("bye!") != -1):
			break

if __name__ == "__main__":
	main()
```