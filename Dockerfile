# 1단계: 빌드 스테이지
FROM gradle:8.6-jdk17 AS builder

# 빌드 캐시 최적화
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
RUN chmod +x gradlew
RUN ./gradlew --no-daemon build -x test || return 0

# 전체 소스 복사
COPY . .

# gradlew가 덮어씌워졌으므로 다시 권한 부여
RUN chmod +x gradlew

# 애플리케이션 빌드
RUN ./gradlew --no-daemon clean bootJar

# 2단계: 실행 스테이지
FROM eclipse-temurin:17-jdk-alpine

# 빌드한 JAR 파일 복사
COPY --from=builder /home/gradle/build/libs/*.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
