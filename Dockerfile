FROM alpine:latest
RUN apk add s3fs-fuse \
  --repository "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" \
  --repository "http://dl-cdn.alpinelinux.org/alpine/edge/main" 
RUN apk add bash
COPY ./run.sh ./run-in-sidecar.sh /
RUN chmod +x /run.sh 
RUN chmod +x /run-in-sidecar.sh
ENTRYPOINT ["/run.sh"]
