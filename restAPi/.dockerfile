# Base image with OpenJDK
FROM maven:3.8.6-openjdk-17 AS build

# Set working directory
WORKDIR /app

# Copy pom.xml and entire project directory
COPY restAPi/pom.xml .
COPY restAPi/. .

# Install dependencies using Maven
RUN mvn clean install

# Copy compiled JAR file (adjust based on your project structure)
COPY target/*.jar app.jar

# Expose port where your SpringBoot application listens (adjust if needed)
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "app.jar"]
