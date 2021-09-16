FROM openjdk:8u302
COPY ./target/spring-petclinic-Build-*.jar /usr/src/
WORKDIR /usr/src/
EXPOSE 8082
ENTRYPOINT java -jar /usr/src/spring-petclinic-Build-*.jar
