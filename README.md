# DE31-final-team5
# Playdata_DE31-final-foodimageapp
## 프로젝트 목표
- AI 기반 식단 기록 앱 개발을 통한 기존 식단관리 앱의 문제점 해결

## 주요 기능
1. **회원 관리**
   - 카카오 소셜 로그인을 통한 간편한 회원가입 및 로그인
   - JWT 토큰 기반의 보안 강화된 인증 시스템

2. **맞춤형 영양 추천**
   - 사용자의 신체 정보를 바탕으로 일일 권장 영양소 계산 및 추천

3. **AI 기반 음식 인식**
   - 사진 한 장으로 음식 자동 인식 및 영양 정보 제공
   - 빠르고 정확한 식단 기록 지원

4. **식단 기록 및 분석**
   - 일일 섭취량 자동 계산 및 기록
   - 직관적인 UI를 통한 쉬운 식단 관리 및 분석
     
## 기술 스택
**AI Model**: MobileNetv3-large (경량화 모델)\
**Frontend**: <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128"><g fill="#3FB6D3"><path d="M12.3 64.2L76.3 0h39.4L32.1 83.6zM76.3 128h39.4L81.6 93.9l34.1-34.8H76.3L42.2 93.5z"/></g><path fill="#27AACD" d="M81.6 93.9l-20-20-19.4 19.6 19.4 19.6z"/><path fill="#19599A" d="M115.7 128L81.6 93.9l-20 19.2L76.3 128z"/><linearGradient id="flutter-original-a" gradientUnits="userSpaceOnUse" x1="59.365" y1="116.36" x2="86.825" y2="99.399"><stop offset="0" stop-color="#1b4e94"/><stop offset=".63" stop-color="#1a5497"/><stop offset="1" stop-color="#195a9b"/></linearGradient><path fill="url(#flutter-original-a)" d="M61.6 113.1l30.8-8.4-10.8-10.8z"/></svg>
**Backend**: FastAPI, SQLAlchemy\
**Database**: PostgreSQL\
**Cloud**: AWS 
**CI/CD**: GitHub Actions, Terraform

## 시스템 아키텍쳐
![image](https://github.com/user-attachments/assets/49243e81-350e-457c-afda-9915e23c91b2)

## CI/CD Workflow
![image](https://github.com/user-attachments/assets/1683a1c7-79a7-46bd-aecd-10b6ac73fcb0)


## 향후 계획
