FROM ubuntu:22.04

RUN apt install -y curl \
    && apt install -y jq \
    && apt clean

COPY entrypoint.bash .

ENTRYPOINT ["./entrypoint.bash"]