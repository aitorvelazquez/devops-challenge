FROM golang:1.16-alpine

WORKDIR /app

# Downloading the GO modules
COPY ./test-app/go.mod ./
COPY ./test-app/go.sum ./
RUN go mod download

COPY ./test-app/cmd/ops-test-app/main.go ./

RUN go build -o /test-app

EXPOSE 8080

CMD [ "/test-app" ]
