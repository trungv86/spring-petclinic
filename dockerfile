FROM openjdk:8u302
COPY ./target/spring-petclinic-Build-*.jar /usr/src/
WORKDIR /usr/src/
EXPOSE 8080
CMD ["java", "-jar", "spring-petclinic-Build-*.jar"]
