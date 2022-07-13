require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/json'
require 'bitcoin'
require 'tapyrus'
require 'net/http'
require 'dotenv'

Dotenv.load
Bitcoin.chain_params = :signet
Tapyrus.chain_params = :prod

def bitcoinRPC
  bitcoin_rpc_config = { schema: ENV['bitcoind_rpc_schema'], host: ENV['bitcoind_rpc_host'], port: ENV['bitcoind_rpc_port'],
                         user: ENV['bitcoind_rpc_user'], password: ENV['bitcoind_rpc_password'] }
  Bitcoin::RPC::BitcoinCoreClient.new(bitcoin_rpc_config)
end

def tapyrusRPC
  tapyrus_rpc_config = { schema: ENV['tapyrusd_rpc_schema'], host: ENV['tapyrusd_rpc_host'], port: ENV['tapyrusd_rpc_port'],
                         user: ENV['tapyrusd_rpc_user'], password: ENV['tapyrusd_rpc_password'] }
  Tapyrus::RPC::TapyrusCoreClient.new(tapyrus_rpc_config)
end

configure do
  set :bind, '0.0.0.0'
end

get '/' do
  "Hi there! I'm client :)"
end

get '/health' do
  data = {
    bitcoin: {
      chain: bitcoinRPC.getblockchaininfo['chain'],
      blockcount: bitcoinRPC.getblockcount
    },
    tapyrus: {
      chain: tapyrusRPC.getblockchaininfo['chain'],
      blockcount: tapyrusRPC.getblockcount
    }
  }
  json data
end

get '/b2t/listunspent' do
  data = {
    bitcoin: bitcoinRPC.listunspent,
    tapyrus: tapyrusRPC.listunspent
  }
  json data
rescue RuntimeError => e
  bitcoinRPC.loadwallet('default')
  retry
end

get '/b2t/bitcoin/getnewaddress' do
  bitcoinRPC.getnewaddress
rescue RuntimeError => e
  bitcoinRPC.loadwallet('default')
  retry
end

get '/b2t/tapyrus/getnewaddress' do
  tapyrusRPC.getnewaddress
end

get '/b2t/execute' do
  amount = params['amount']

  # 新規送金先アドレスを受け取り
  uri = URI("http://#{ENV['server_host']}:8910/b2t/bitcoin/getnewaddress")
  res = Net::HTTP.get_response(uri)
  payment_address = res.body

  # payment transaction
  begin
    payment_txid = bitcoinRPC.sendtoaddress(payment_address, amount)
  rescue RuntimeError => e
    bitcoinRPC.loadwallet('default')
    retry
  end

  # receipt address
  receipt_address = tapyrusRPC.getnewaddress

  # send request to server
  uri = URI("http://#{ENV['server_host']}:8910/b2t/execute?payment_txid=#{payment_txid}&receipt_address=#{receipt_address}&amount=#{amount}")
  res = Net::HTTP.get_response(uri)
  receipt_txid = res.body

  # response
  data = {
    payment_txid: payment_txid,
    receipt_txid: receipt_txid
  }
  json data
end
