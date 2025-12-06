# rdp-video-pjt (RDP 화면 녹화 프로젝트)

여러 개의 Widnow 원격 접속(RDP) 접속 시 사용자가 작업한 내용을 녹화하고 특정 시간에 웹서버로 녹화 파일을 전송하여 웹 서버에서 녹화 파일을 재생하는 기능을 구현하기 위한 프로젝트

## 프로젝트 환경

- RDP 서버 : Window Server
- 영상 녹화: ffmpeg / Window Scheduler / Batch
- DB : SQLite
- Backend : Python / Flask
- Frontend : TypeScript / React

## 기능

1. RDP 접속 화면 녹화 기능

- 사용자 로그인 시 ffmpeg 실행 batch로 화면 녹화 시작
- 사용자 로그오프 시 ffmpeg 실행 batch로 화면 녹화 저장 및 종료
- 사용자 멀티 RDP 접속 시 ffmpeg 실행

2. 녹화 파일 전송 기능

- 녹화된 파일 특정 시점에 녹화 영상 재생 서비스 서버로 전송 기능
- 전송 전 녹화 파일 사용자 요청 시 서비스 서버로 전송 기능

3. 녹화 영상 재생 서비스

- 전송 완료된 녹화 파일 정보 확인 기능
- 전송 전인 녹화 파일 정보 확인 기능
- 영상 재생 기능 (서버 선택 - 날짜 선택 - 파일 리스트 - 영상 재생)
