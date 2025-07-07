FROM debian:12-slim

RUN apt-get update &&  \
    apt-get install -y curl libhamlib-utils

COPY cloudlogbashcat.sh .

CMD ["./cloudlogbashcat.sh"]