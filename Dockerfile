# 1단계: 빌드 스테이지
FROM gradle:8.5-jdk17 AS build

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 캐싱 유도를 위한 빌드 스크립트만 복사
COPY build.gradle settings.gradle ./

# 의존성만 먼저 다운로드
RUN gradle dependencies --no-daemon || return 0

# 전체 프로젝트 복사
COPY . .

# Spring Boot JAR 빌드 (테스트 생략)
RUN gradle bootJar --no-daemon -x test

# 2단계: 런타임 스테이지 (경량 JDK만 포함)
FROM eclipse-temurin:17-jdk-alpine

# 빌드된 JAR 복사
COPY --from=build /app/build/libs/*.jar app.jar

# 앱 실행
ENTRYPOINT ["java", "-jar", "/app.jar"]
