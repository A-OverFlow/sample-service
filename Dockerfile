# 1단계: 빌드 스테이지
FROM gradle:8.6-jdk17 AS builder

# 작업 디렉터리 설정 (Gradle 이미지 기본 사용자: gradle)
WORKDIR /home/gradle/app

# 빌드 캐시 최적화를 위해 필요한 파일만 먼저 복사
COPY build.gradle settings.gradle ./

# 의존성 사전 다운로드 (테스트 제외)
RUN gradle build -x test --no-daemon || true

# 전체 소스 복사
COPY . .

# 애플리케이션 빌드
RUN gradle clean bootJar --no-daemon

# 2단계: 실행 스테이지
FROM eclipse-temurin:17-jdk-alpine

# JAR 파일 복사
COPY --from=builder /home/gradle/app/build/libs/*.jar /app/app.jar

# 포트 오픈
EXPOSE 8080

# 실행 명령
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
