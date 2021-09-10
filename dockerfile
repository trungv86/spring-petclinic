FROM openjdk:8u302
COPY ./target/*.jar /usr/src/
WORKDIR /usr/src/
EXPOSE 8080
CMD ["java", "-jar", "*.jar"]
