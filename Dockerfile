FROM golang:1.16-alpine

WORKDIR /app

# Download the GO modules
COPY ./test-app/go.mod ./
COPY ./test-app/go.sum ./
RUN go mod download

COPY ./test-app/cmd/ops-test-app/main.go ./

RUN go build -o /docker-test-app

EXPOSE 8080

CMD [ "/docker-test-app" ]