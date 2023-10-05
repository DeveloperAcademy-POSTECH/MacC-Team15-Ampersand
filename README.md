  <h1 align="center">gridy</h1>
  <h5 align="center">그리드 시스템을 활용한 직관적인 플래닝 툴</h5>
<div align="center">
  <img width="300" src="https://github.com/DeveloperAcademy-POSTECH/MC3-Team15-RockStars/assets/57654681/0129599d-f9b5-48a1-9225-08aa27e8a6bb">
</div>

#### TEAM Ampers& 
<div align="center">
  <img src="https://github.com/DeveloperAcademy-POSTECH/MC3-Team15-RockStars/assets/57654681/2d95a1c4-3918-4b92-8125-7dc3d9bdf036" width="500">
</div>

| [LiLy](https://github.com/abovocado) | [ZENA](https://github.com/dayo2n) | [Flynn](https://github.com/dev-minseo) | [Royce](https://github.com/Jin-s-work) | [Henry](https://github.com/OreobrO) | [GaOn](https://github.com/xnoag) |
|:--:|:--:|:--:|:--:|:--:|:--:|
| <img src="https://avatars.githubusercontent.com/u/102544840?v=4" width="150"> | <img src="https://avatars.githubusercontent.com/u/57654681?v=4" width="150"> | <img src="https://avatars.githubusercontent.com/u/128036442?v=4" width="150"> | <img src="https://avatars.githubusercontent.com/u/61958748?v=4" width="150"> | <img src="https://avatars.githubusercontent.com/u/120009346?v=4" width="150" > | <img src="https://avatars.githubusercontent.com/u/125735850?v=4" width="150"> |

---

# 팀 개발자들을 위한 Git, Code Convention

## 네이밍
- 이슈</br>
  `[이슈 종류] 이슈 핵심 내용`</br>
  `[fix] 애플로그인 탈퇴시 발생하는 버그 해결`</br>

- 브랜치</br>
  `브랜치 종류/이슈 번호-개발할 기능 이름`</br>
  `feature/1-login-view`</br>
  
- 커밋</br>
  `[종류][이슈 번호] 이슈 핵심 내용`</br>
  `[fix][#11][#12] 애플로그인 탈퇴시 발생하는 버그 해결`</br>
  
- PR</br>
  `[커밋 종류][이슈 번호] 커밋 내용`</br>
  `[feat][#1] 로그인 화면 개발`</br>

## 내용
- 이슈, PR은 템플릿을 따릅니다
- 커밋
  한 줄로 간결하게 작성하고 작성해야 하는 내용이 길어지면 한 줄 개행 후 상세 내용을 작성합니다
  ```markdown
  [fix][#11] 버튼이 동작하지 않는 버그 해결
  
  - 화면을 나갔다가 다시 들어오면 버튼이 비활성화되었음
  - 어쩌구저쩌구 원인으로 인해 발생
  - 어떻게 해서 저렇게 하는 방법으로 해결
  ```

## 생성

한 이슈당 브랜치 하나 1:1

  1. Create a branch를 눌러 origin에서 먼저 생성
  2. 또는 local에서 먼저 생성해서 작업 후 push origin 후에 톱니바퀴⚙️를 눌러 이슈와 연결
      

## 삭제

- Git flow에 해당하지 않는 브랜치는 머지 후 삭제합니다
- [Exception] 해당하는 이슈 내 태스크가 완료되지 않았지만 기타 사유로 일단 머지하는 경우

## Code Review 코드 리뷰

### 방식에 대하여
- 두 명 + α 이상 리뷰: beta, 이렇게 진행해보고 추후 필요하면 변경합니다


### 코드리뷰 약어
- **IMO** in my opinion
- **LGTM** look good to me
- **FYI f**or your information
- **ASAP** as soon as possible
- **TL;DR** Too Long. Didn't Read
  *보통 문장 앞 부분에 긴 글을 요약할 때*

📢 추가 내용은 ampersand의 notion 문서를 확인하세요</br>
[Git Convention](https://www.notion.so/wimkr/Git-Convention-3d31aeaf601a4a0183614e353b07700f?pvs=4)</br>
[Code Convention](https://www.notion.so/wimkr/Code-Convention-af1e8c41e01346cc9d986626e6292be3?pvs=4)</br>
