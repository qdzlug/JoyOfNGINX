FROM node:16
WORKDIR /app
RUN npm install @opentelemetry/api @opentelemetry/auto-instrumentations-node @opentelemetry/exporter-trace-otlp-http @opentelemetry/sdk-node express
COPY app.js .
EXPOSE 8000
CMD [ "node", "app.js" ]
