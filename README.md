# 한솔 방수공사 웹사이트

## 이미지 추가 방법
1. 각 공사 폴더에 이미지 파일 넣기
   - `images/rooftop/` → 옥상 방수공사
   - `images/parking/` → 지하주차장 방수공사
   - `images/preaction/` → 프리액션밸브공사
   - `images/other/` → 기타공사

2. `index.html` 열어서 `DATA` 객체에 항목 추가

## 파일 구조
```
한솔-website/
├── index.html          ← 메인 파일 (내용 수정 여기서)
└── images/
    ├── rooftop/        ← 옥상 방수공사 이미지
    ├── parking/        ← 지하주차장 방수공사 이미지
    ├── preaction/      ← 프리액션밸브공사 이미지
    └── other/          ← 기타공사 이미지
```

## GitHub Pages 배포
1. GitHub에 새 repository 생성
2. 이 폴더 안의 모든 파일 업로드
3. Settings → Pages → Branch: main, / (root) → Save
