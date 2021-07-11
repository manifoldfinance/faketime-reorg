FROM openethereum/openethereum:v3.2.6 AS faketime
USER root
RUN apk add --update --no-cache \
       ca-certificates \
    && update-ca-certificates
    
RUN apk update && apk add coreutils build-base gcc abuild binutils git curl && rm -rf /var/cache/apk/*

# 9e27b2ed8b5bfdd5c57eb527d489960f5962845b
COPY libfaketime /libfaketime
WORKDIR /libfaketime
RUN make && make install


FROM openethereum/openethereum:v3.2.6

WORKDIR /
COPY --from=faketime /usr/local/lib/faketime/libfaketimeMT.so.1 /lib/faketime.so
COPY dev-key.json /home/openethereum/keys/DevChain/dev-key.json
COPY chain-spec.json /home/openethereum/chain-spec.json
COPY config.toml /home/openethereum/config.toml
RUN echo "" > /home/openethereum/password

ENV LD_PRELOAD="/lib/faketime.so"

ENTRYPOINT [ "/bin/openethereum", "--config", "/home/openethereum/config.toml" ]

# docker image build --tag manifoldfinance/openethereum-instantseal .
# docker container run --rm -it -p 8000:8000 -p 8001:8001 -p 8545:8545 -p 8180:8180 --name openethereum-instant-seal manifoldfinance/openethereum-instantseal
