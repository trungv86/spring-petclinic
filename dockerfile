FROM openjdk:8u302
COPY ./target/spring-petclinic-2.5.0-SNAPSHOT.jar /usr/src/
WORKDIR /usr/src/
EXPOSE 8080
CMD ["java", "-jar", "spring-petclinic-2.5.0-SNAPSHOT.jar"]
