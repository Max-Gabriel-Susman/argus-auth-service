FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y golang ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o authserver

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/*
    
RUN useradd -m -s /usr/sbin/nologin authuser

WORKDIR /app

COPY --from=builder /app/authserver /app/

RUN chown authuser:authuser /app/authserver && chmod 755 /app/authserver

USER authuser

EXPOSE 8000

CMD ["./authserver"]