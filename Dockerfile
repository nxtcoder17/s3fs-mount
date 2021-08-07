FROM alpine:latest
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
RUN cat /etc/apk/repositories
RUN apk add s3fs-fuse bash
COPY ./run.sh /
RUN chmod +x /run.sh
