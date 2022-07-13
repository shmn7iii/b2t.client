# b2t.client

BTC to TPC client.

```mermaid
sequenceDiagram
  autonumber
  actor User
  User ->> Client: GET /b2t/execute
  Client ->> Server: GET /b2t/bitcoin/getnewaddress
  Server ->> Client: Return new Bitcoin address
  Client -->> Client: Create payment transaction
  Client -->> Client: Get new Tapyrus address
  Client ->> Server: GET /b2t/execute
  Server -->> Server: Create receipt transaction
  Server ->> Client: Return receipt transaction id
  Client ->> User: Return both transaction id
```

## setup

```bash
$ docker compose up -d
```

## usage

- ヘルスチェック  
  http://localhost:4567/health

- 実行  
  http://localhost:4567/b2t/execute?amount=xxx へ GET リクエスト
