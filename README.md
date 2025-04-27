# 구조 설명

```text
/프로젝트 루트
├── .github/
│   └── workflows/
│       ├── cd-dev.yml                   # 개발 환경 배포 자동화 (CD) 워크플로 파일
│       └── ci.yml                       # 빌드/테스트 자동화 (CI) 워크플로 파일
├── docker-compose.override.yml          # (로컬 환경) Docker Compose 추가 설정
├── docker-compose.yml                   # (개발 환경) Docker Compose 설정
├── .env                                 # (로컬 환경) Docker Compose 에서 사용할 환경 변수 파일
├── Dockerfile                           # Spring Boot 앱을 컨테이너 이미지로 만드는 빌드 스크립트
├── .dockerignore                        # Docker 빌드 시 제외할 파일 목록
├── src/
│   └── main/
│       └── resources/
│           └── application.yml           # Spring Boot 애플리케이션 환경 설정 파일
```

## 특징

### Docker Compose

- [docker-compose.yml](docker-compose.yml)
    - 배포 서버에서 실행될 파일
- [docker-compose.override.yml](docker-compose.override.yml)
    - 로컬 환경에서 `docker compose up` 명령을 사용하면 자동으로 덮어씌워 짐
- [.env](.env)
    - 로컬 환경에서만 사용되는 환경 변수 파일.
    - 서버로 배포되는 .env 파일은 깃허브 액션에서 깃허브 시크릿을 통하여 생성된다.

### Application

- [application.yml](src/main/resources/application.yml)
    - 스프링 부트 환경 설정 파일은 하나로 관리 된다.

### GitHub actions secrets and variables

- https://github.com/A-OverFlow/sample-service/settings/secrets/actions
- 서버 배포를 위해 필요한 환경 변수들을 깃허브 시크릿으로 관리한다.
- 주로 사용하는 환경 변수
    - Environment secrets: 민감한 정보
    - Organization secrets : 조직 레벨에서 사용할 수 있는 공통 시크릿
    - Environment variables : 환경을 구분하여 관리하는 변수

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

- API 호출 확인 (GET /demo)
- DB 접속 확인 및 테이블에 저장되는 데이터 확인
- 애플리케이션 또는 컨테이너 로그에 에러 없는 지 확인

## 개발 서버 배포

- [ci.yml](.github/workflows/ci.yml)
    - dev 브랜치에 PR이 생성되거나 코드가 머지될 경우 동작 (파일 내부 동작 확인 추천)
- [cd-dev.yml](.github/workflows/cd-dev.yml)
    - dev 브랜치에 코드가 머지될 경우 동작 (파일 내부 동작 확인 추천)

### 개발 서버에 적용되는 환경 변수

- 프로젝트에 포함되어 있는 [.env](.env) 파일은 **로컬 개발 환경 전용** (사용하지 않음)
- 개발 서버에 적용되는 .env 환경 변수는 깃허브 시크릿 & 변수로 관리 및 생성
    - [깃허브 액션 시크릿](https://github.com/A-OverFlow/sample-service/settings/secrets/actions)
    - [깃허브 액션 변수](https://github.com/A-OverFlow/sample-service/settings/variables/actions)

### 개발 서버 (EC2) 디렉토리 구조

```text
/home/ec2-user/deploy/     # 배포 디렉토리 (secrets.DEV_DEPLOY_PATH)
└── sample-service         # 저장소(서비스) 이름 
    ├── .env               # 깃허브 액션에서 생성한 환경 변수 파일
    └── docker-compose.yml # 프로젝트에서 복사한 compose 파일
```

### 테스트 (25.04.26 기준)

- API 호출
    - http://dev.mumulbo.com:9999/demo
    - API 호출한 시간 응답 (내부적으로는 호출 시간을 DB에 저장)
- 깃허브 액션
    - [깃허브 액션](https://github.com/A-OverFlow/sample-service/actions) 에서 workflow 정상 확인
- EC2
    - `docker ps` : 실행중인 컨테이너 확인
    - `tree ~/deploy/ -a` : 배포 디렉토리 구조 확인
    - `cat /home/ec2-user/deploy/sample-service/.env` : 현재 서비스에 적용중인 환경 변수 확인