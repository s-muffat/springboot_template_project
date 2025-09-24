# Multi-stage build for Spring Boot application
FROM maven:3.9.6-openjdk-21-slim AS build

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies (for better caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM amazoncorretto:21

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Create directories for logging
RUN mkdir -p /var/log/application && \
    mkdir -p /app/logs && \
    chown -R appuser:appuser /var/log/application && \
    chown -R appuser:appuser /app/logs

# Set working directory
WORKDIR /app

# Copy the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Change ownership to appuser
RUN chown appuser:appuser app.jar

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]

# JVM optimization options (can be overridden)
CMD ["-Djava.security.egd=file:/dev/./urandom", \
     "-Xms256m", \
     "-Xmx512m", \
     "-XX:+UseG1GC", \
     "-XX:MaxGCPauseMillis=200"]