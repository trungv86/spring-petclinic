FROM openjdk:8u302
COPY ./target/spring-petclinic-Build-*.jar /usr/src/
WORKDIR /usr/src/
EXPOSE 8080
CMD ["java", "-jar", "/usr/src/spring-petclinic-Build-*.jar"]
ENTRYPOINT java -jar /usr/src/spring-petclinic-Build-*.jar
