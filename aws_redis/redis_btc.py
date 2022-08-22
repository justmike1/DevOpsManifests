import time
import requests as r
import redis

timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime())

redis = redis.Redis(
    host= 'localhost', #SSH port forwarding from AWS
    port= '6379')


def get_data(symbol, endpoint) -> str:
    res = r.get(
        url=f"https://api.binance.com/api/v3/ticker/{ endpoint }",
        params={"symbol": symbol }).json()
    print(res)
    return res


""" this is what requested but api.blockchain's routing is shit, so I used binance's, but it works anyways """
# def get_data(symbol, endpoint) -> str:
#     res = r.get(url=f"https://api.blockchain.com/v3/exchange/{ endpoint }/{ symbol }").json()
#     print(res)
#     return res
# get_data(symbol="BTC-USD", endpoint="tickers")


if __name__ == "__main__":
    while True:
        redis.set('timestamp', timestamp)
        redis.set('price', get_data("BTCUSDT", "price")['price'])
        time.sleep(360)

