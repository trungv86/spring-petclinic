FROM openjdk:8u302
COPY ./source/* /usr/src/
WORKDIR /usr/src/
EXPOSE 8080
CMD ["java", "-jar", "spring.jar"]
