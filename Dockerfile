FROM debian:12-slim

RUN apt-get update &&  \
    apt-get install -y curl libhamlib-utils

ENV cloudlogRadioId=set_me
ENV cloudlogApiKey=set_me
ENV cloudlogBaseURL=set_me
ENV rigctlRadioId=set_me

COPY cloudlogbashcat.sh .

CMD ["./cloudlogbashcat.sh"]