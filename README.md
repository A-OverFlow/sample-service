# 서비스 실행 방법

## 사전 준비

- docker 설치
  - 이 문서는 아래 docker 버전 기준으로 작성됨
  - `docker -v` : Docker version 28.0.4
  - `docker compose version` : Docker Compose version v2.34.0-desktop.1
- [docker-compose.yml](docker-compose.yml) 파일에서 사용하는 networks 생성
  - 생성하지 않을 시 다음과 같은 에러 발생할 수 있음 (network sample-network declared as external, but could not be found)
  - `docker network create [네트워크 이름]` 

## 로컬 개발 환경

### 애플리케이션(프로세스) + 데이터 베이스(컨테이너)

- 애플리케이션
    - [application.yml](src/main/resources/application.yml)
    - yml 파일에는 환경 변수를 받도록 설정되어 있지만, 신경쓰지 말고 **기본값**만 확인
    - 데이터 베이스를 먼저 실행한 뒤에 애플리케이션을 실행
- 데이터 베이스 (컨테이너)
    - [docker-compose.yml](docker-compose.yml)
        - [.env](.env) 파일에 작성된 환경 변수를 주입 받음
        - [.env](.env) 파일의 DB 관련 **환경 변수**와 [application.yml](src/main/resources/application.yml) 파일의 DB **기본값**이 매칭되는 지
          확인
    - DB 컨테이너 실행
        - `docker compose up -d db`
            - [docker-compose.yml](docker-compose.yml) 파일에 정의된 db 컨테이너만 실행시키는 명령

### 애플리케이션(컨테이너) + 데이터 베이스(컨테이너)

- [.env](.env) 파일의 환경 변수와 [application.yml](src/main/resources/application.yml) 파일이 주입받는 환경 변수 확인
- [.env](.env) 파일의 환경 변수와 [docker-compose.yml](docker-compose.yml) 파일이 주입받는 환경 변수 확인
- `docker compose up -d --build` 명령 실행
    - --build : Dockerfile을 항상 빌드하기 위한 옵션 (현재 코드 반영)
    - 자동으로 [docker-compose.override.yml](docker-compose.override.yml) 파일 덮어씌워 짐 (로컬 개발 환경 설정)
    - 인텔리제이 기능으로 [docker-compose.yml](docker-compose.yml) 파일 실행할
      경우 [docker-compose.override.yml](docker-compose.override.yml) 파일이 덮어씌워 지지 않을 수 있음

### 테스트

- 애플리케이션 또는 컨테이너 로그에 에러 없는 지 확인
- DB 컨테이너 접속 확인
- API 호출 확인 (GET /demo)

## 개발 서버 배포

- [ci.yml](.github/workflows/ci.yml) : dev 브랜치에 PR이 생성되거나 코드가 머지될 경우 동작
- [cd-dev.yml](.github/workflows/cd-dev.yml) : dev 브랜치에 코드가 머지될 경우 동작

### 개발 서버에 적용되는 환경 변수

- 프로젝트에 포함되어 있는 [.env](.env) 파일은 **로컬 개발 환경 전용**
- 개발 서버에 적용되는 환경 변수는 깃허브 시크릿 & 변수로 관리
    - [깃허브 액션 시크릿](https://github.com/A-OverFlow/sample-service/settings/secrets/actions)
    - [깃허브 액션 변수](https://github.com/A-OverFlow/sample-service/settings/variables/actions)

### 테스트

