FROM tomcat
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar javaagent.jar
ENV JAVA_OPTS="-javaagent:javaagent.jar"
CMD ["catalina.sh", "run"]
