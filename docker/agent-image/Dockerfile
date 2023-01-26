FROM nginx:1.23.1
RUN apt-get update ; apt-get install unzip
ADD https://github.com/nginx/agent/releases/download/v2.22.0/nginx-agent-2.22.0.bullseye_amd64.deb /opt
RUN cd /opt ; dpkg -i nginx-agent-2.22.0.bullseye_amd64.deb 
