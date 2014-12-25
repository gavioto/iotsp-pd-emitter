examples
========

SensorReaderとしてのExample

### `in_literal.(rb|js)` ###

`This is test message` という文字列を `tmp/in_literal.sock` へ書き込むサンプル

`{"payload":"This is test message","time":"2014-12-24T05:06:34Z","tag":"to.kinesis.1"}` とフォーマット変換された後、送出されます

Ruby, node.js, Cと実装があります


### `in_unix.rb` ###

構造化データ `{title: "Sample", geo: [100, 200]}` を `tmp/in_unix.sock` へ書き込むサンプル

`{"title":"Sample","geo":[100,200],"time":"2014-12-24T05:07:55Z","tag":"to.kinesis.1"}`というフォーマット変換された後、送出されます


### `ti_sensortag_simplekey.js` ###

TI SensorTag (CC2541)と接続、ボタンの押下に反応しデータを送出するサンプル(`in_literal.sock`を使用しています)

BLE搭載PC、node.js 0.10.25以上の環境で動きます


EOT

