# b2t.client

BTC to TPC client.

## setup

```bash
$ docker compose build
$ docker compose up -d

# 初回のみ
$ docker compose exec bitcoind bitcoin-cli -signet -rpcuser=hoge -rpcpassword=hoge createwallet default

# ログが見たい
$ docker compose logs -f
```

## usage

- ヘルスチェック  
  http://localhost:4567/health

- 実行  
  http://localhost:4567/b2t/execute?amount=xxx へ GET リクエスト
