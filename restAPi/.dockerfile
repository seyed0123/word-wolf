# Use an official OpenJDK runtime image
FROM openjdk:17-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the pre-built jar file into the container
COPY restAPi/target/restAPi-0.0.1-SNAPSHOT.jar app.jar

# Expose the port your Spring Boot application will run on
EXPOSE 8080

# Set the entry point to run the jar
ENTRYPOINT ["java", "-jar", "app.jar"]
