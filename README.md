# 🥗AI 기반 식단 관리 서비스 개발

![image](https://github.com/user-attachments/assets/7ebfc416-2186-48ba-89e1-915a36b83f0a)



## 제출 자료


📄 프로젝트 기획안 : [건강이조 프로젝트 기획(안)_최종.pdf](https://github.com/user-attachments/files/17132807/_.pdf)

📄 User Story : [사용자스토리.pdf](https://github.com/user-attachments/files/17133060/default.pdf)

📄 API 명세서 : [API 명세서.pdf](https://github.com/user-attachments/files/17133014/API.pdf)

📄 발표자료 pdf : [최종 발표_건강이조_v0.4.pdf](https://github.com/user-attachments/files/17139851/_._v0.4.pdf)

📄 발표자료 ppt : [최종 발표_건강이조_v0.4.pptx](https://github.com/user-attachments/files/17139852/_._v0.4.pptx)

📄 시연 영상 : 

https://github.com/user-attachments/assets/1920fd28-629d-403c-b1e4-640a785e83b9




## 프로젝트 진행 기간
### 2024년 8월 5일 - 2024년 9월 27일




## 프로젝트 목표

- Target
   - 건강 관리에 관심이 많고 모바일 어플리케이션 사용에 익숙한 젊은 세대

- Goal
  - 건강한 식습관을 형성할 수 있도록 지원하는 식단 관리 서비스 개발을 목표로 합니다.
  - AI 기반 식단 기록 앱 개발을 통해 기존 식단관리 앱의 문제점을 해결합니다.



## 팀 소개

### 팀명 : 건강이조

|이름|이메일|역할|
|:---|:---|:---|
|추현영|encorechu24@gmail.com|모델 개발|
|권시은|5016sieun@naver.com|애플리케이션 개발|
|김승주|tmdwnabc@gmail.com|데이터베이스 관리|
|노석현|shtjrgus010@gmail.com|인프라 구축|
|이하은|gkdmsgkdms22@gmail.com|API 개발|
|이충원|cw3714@naver.com|모델 개발|



## ERD

![image](https://github.com/user-attachments/assets/0b4f8557-cf7e-4d1a-8a8c-4ee54e02bcf8)


## Solution KeyWords

|Keyworkds|Meaning|
|:---|:---|
|Fast|빠른 추론|
|Accurate|정확한 분석|
|Seamless|직관적인 인터페이스|
|Easy|쉬운 사용|
|Secure|안전한 사용자 정보 및 인프라 관리|
|Flexible|유연한 설계|
|Robust|견고한 설계|




## 주요 기능
### 1. **회원 관리**
   - 카카오 소셜 로그인을 통한 간편한 회원가입 및 로그인
   - 자체 JWT 기반의 보안 강화된 인증 시스템으로 보안 강화

### 2. **맞춤형 영양 추천**
   - 사용자의 신체 정보를 바탕으로 일일 권장 영양소 계산 및 추천

### 3. **AI 기반 음식 인식**
   - 단 한 장의 사진 업로드로 음식 자동 인식 및 영양 정보 제공
   - 빠르고 정확한 식단 기록 지원

### 4. **식단 기록 및 분석**
   - 일일 섭취량 자동 계산 및 기록
   - 직관적인 UI 구성으로 앱 사용성 향상
  
## Features

### 1. 자체 AI 모델 개발
   - 한식/일식/분식 카테고리의 특징이 뚜렷한 10가지 음식 클래스 선정
   - 경량화 모델 MobileNet 기반 전이학습
   - 제한된 애플리케이션 환경 내 빠른 추론 속도 확보를 위해 Mixed Precision 경량화 기법 적용
   - 하이퍼 파라미터 튜닝으로 99.86%의 테스트 정확도와 868ms의 latency 확보


![confusion_matrix](https://github.com/user-attachments/assets/5e3c75dc-9d89-4153-b119-01af151043f1)

  

### 2.  직관적인 UI 구성
   - 사용자의 편의성을 고려하여 입력 방식 간소화
   - 섭취 칼로리 정보 별 Progress Bar 색상 변화
     - 권장칼로리 초과 시 중첩 표시
    
       
       ![image](https://github.com/user-attachments/assets/023cf67a-7919-4cce-8852-abc88a6f03d4)

      
   - 간결한 하단 Navigation Bar 구성
   - 메타데이터 기반 식사 타입 지정


### 3. 로그 적재 시스템 구현
   - 로그 관리 자동화
  
### 4. 카카오톡 소셜 로그인 적용
   - OAuth 2.0 프로토콜을 사용하여 안전하고 신뢰성있는 인증 제공
  
### 5. 자체 JWT 발급
   - JWT를 통한 인증 및 인가로 보안 강화

### 6. 클라우드 인프라를 코들 관리하는 IaC 방식 도입
### 7. GitHub Actions를 활용한 배포 자동화로 지속적 통합 및 배포(CI/CD) 효율화


---

## 기술 스택



![image](https://github.com/user-attachments/assets/8d18faf0-3ff6-4081-9845-769437639007)



---


## 시스템 아키텍쳐
![image](https://github.com/user-attachments/assets/49243e81-350e-457c-afda-9915e23c91b2)

## CI/CD Workflow
![image](https://github.com/user-attachments/assets/1683a1c7-79a7-46bd-aecd-10b6ac73fcb0)


## 앱 UI 구성

### 시작화면


![image](https://github.com/user-attachments/assets/ce87087a-7782-4b82-ba16-391159997224)


---

### 회원가입 화면
- 회원가입 시 최초 1회 영양소 분석에 필수 요소인 개인정보를 입력받습니다.


![image](https://github.com/user-attachments/assets/aa982dff-7077-45e2-b1d0-0460dde72172)


---

### 메인화면 / 분석화면 / 기록화면
- 입력받은 개인정보를 바탕으로 계산된 권장 칼로리를 제공합니다.
- 사진을 업로드하여 분석하고, 제공된 영양정보를 확인할 수 있습니다.
- 섭취한 음식을 기록하여 하루동안 먹은 음식을 한눈에 볼 수 있습니다.


![image](https://github.com/user-attachments/assets/dede00f7-22a3-4dfa-859e-4a317c99547e)




## 향후 계획
+ AI Model Update
  + 한식, 일식, 분식 종류 추가
  + 중식, 양식 카테고리 확장
 
+ SSL 인증서 추가로 HTTPS 구현
  + HTTPS 도메인 활성화로 보안성 향상
 
+ 실서비스 배포
  + Google Play Stroe Beta Release
  + Full Release
