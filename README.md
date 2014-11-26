IoT DataTransfer Backend Service Comm. Library (Emitter)
========================================================


What is *Emitter*
---------------

これはセンサー制御機器と[IoT DataTransfer Backend Service](http://URL)とのデータ送受信を容易にする通信ライブラリです

センサー制御機器にインストールし、プロセス(daemon)として立ち上げて使用します

このライブラリは[IoT DataTransfer Backend Service](http://URL)へのAPIコールを肩代わりしてくれる他、通信が不安定な環境を想定した機能が実装済です

これを利用すれば、データ伝送にまつわるコーディングは不要となり、センサー制御のプログラム開発に集中することが出来ます

### Index ###

* [セットアップ](#quick-start)
* [開発](#development)
* [運用](#running-operation)

### Specification ###

* クラウドAPIコール フォーマッティング
  * HTTP(S) REST
* メッセージスプール/再送
  * 成功/失敗時のコールバック
* プロセス(daemon)制御
  * ログサイズ抑制


Quick start
-----------

### Requirements: ###

* Linux (Ubuntu 14.04 recommended)
* Ruby 1.9 or higher (1.9 and [rbenv](#setup-rbenv) recommended, [apt](#ruby-setup-by-apt) OK)
  * gems are bundler

### Installation: ###

```
$ cd /opt
$ sudo git clone https://ssl.plathome.co.jp/git/iotsp/emitter.git
$ sudo chown -R $USER /opt/emitter
$ cd /opt/emitter
$ bundle install --path vendor/bundle --without development
$ bundle rake install
```

#### Boot on console ####

```
$ cd /opt/emitter
$ RUN_ENV=development bundle exec rake boot
```

STOP is `Ctrl+C`

#### Operation ####

On other console ...

Send message:

```
$ ruby -rsocket -e 'UNIXSocket.open("/opt/emitter/tmp/in_literal.sock"){|s|s.write "hello"}'
Another console => 2014-11-26 15:05:23 +0900 p0001.u.10021.DUID: {"data":"hello"}
```

It's so good !


Development
===========

開発する必要のあるものは3つです

1. センサーからデータを読み出し、_Emitter_へデータをwriteするプログラム(SensorReader)
2. *Emitter*の送受信結果から起動されるプログラム(Callback)
  1. 送信成功時のcallback
  2. 〃失敗時のcallback

callbackにおいて不要なものは、`config/fluent.rb`で無効にする、`/dev/null`へリダイレクトする等して対応してください

※オフライン開発(= クラウド側サービスが不要)が可能です。[`RUN_ENV`](#run_env)を参照ください

API (write to *Emitter*)
----------------------

*Emitter*を起動すると、2つのUNIX Domain socketが作成されます
「*Emitter*へwrite」とは、即ち、このUNIX Domain socketへwriteするという意味です

SensorReaderは、このAPIを使って開発するのが一般的な方法となります

* [`./tmp/in_unix.sock`](#in_unix.sock)
* [`./tmp/in_literal.sock`](#in_literal.sock)

### ./tmp/in\_unix.sock ###

`in_unix.sock`は複雑な構造データの送信に適しています

MessagePackを使用する必要がある等、利用環境を選ぶため、より簡単な送信を行いたい場合は、[`in_literal.sock`](#in_literal.sock)の使用を検討してください

Wire protocol

```
format: MessagePack

message:
  [tag, time, record]
  or
  [tag, [time, record], [time, record], ...]
```

* tag = [tag](http://URL)
* time = UNIX epoch time
* record: MessagePackで表現可能な構造データを格納できます

同ファイルはreadしても、何もデータはありません。書込結果は[callback](#callback)にて確認してください

e.g.) `example/in_unix.rb`

```
require "msgpack"
require "socket"

record = {"title"=> "Sample", "geo" => [100, 200] }
packed = ["p0001.u.10021.y", Time.now.to_i, record].to_msgpack # [tag, time, record]
UNIXSocket.open("./tmp/in_unix.sock"){|s|s.write packed}

console => 2014-11-26 16:29:45 +0900 p0001.u.10021.y: {"title":"Sample","geo":[100,200]}
```

### ./tmp/in\_literal.sock ###

`in_literal.sock`は簡易的なコーディングに適しています

`in_unix.sock`で設定が必要だったパラメータは、それぞれ下記のようになります

* tag = `config/{pfconf,localconf}.json`もしくは環境変数から自動生成
* time = write時間を自動採用
* record = `{"data": writeデータ}`で固定 (キー名(`data`)は`config/fluent.rb`で変更可能)

e.g.) `example/in_literal.rb`

```
require "socket"

data = "This is test message"
UNIXSocket.open("./tmp/in_literal.sock"){|s|s.write data}

console => 2014-11-26 16:30:29 +0900 p0001.u.10021.HOGE-FOOBAR: {"data":"This is test message"}
```

API (callback from *Emitter*)
---------------------------

*Emitter*は、*Emitter*自身のログから特定の文字列に反応して、割り当てられたcallbackプログラムを起動します

これにより、送受信の結果を知ることができ、また他の機器へ通知することが可能です

### callbackプログラム 仕様 ###

callbackは下記仕様を満たすことができるプログラム言語で記述することが可能です

* シェルに対してexitcodeを返すことができる

*Emitter*からcallbackをexecする際の仕様:

* 特定文字列への反応毎に実行されます。即ち、送信でretryが発生した時は、retry毎に実行されます (NOTE1)
* *Emitter*で反応した時のログデータは、JSON形式データのファイルとして渡されます(後述)
* 反応する特定文字列は、`config/fluent.rb`で指定済です。[out\_http\_alt Plugin](http://URL)の出力ログに依存しています。変更は非推奨です
* execされるプログラムは、`config/fluent.rb`で指定されています。変更可能です。execの仕様は[Fluentd out\_exec plugin](http://docs.fluentd.org/ja/articles/out_exec)となります。パラメータは`config/fluentd.rb`内`out_http_alt_fail.fluentlog`並びに`out_http_alt_success.fluentlog`を確認ください
* exitcodeが0以外の場合はexec失敗となります。通常はretryされます。retryの仕様は[Fluentd BufferPlugin](http://docs.fluentd.org/ja/articles/buffer-plugin-overview)となります。パラメータは`config/fluentd.rb`内`out_http_alt_fail.fluentlog`並びに`out_http_alt_success.fluentlog`を確認ください  (NOTE2)

* NOTE1: retryを無効(`retry_limit 0`)にすることで本動作を抑制することができます。その際の挙動はNOTE2を確認ください
* NOTE2: Retry制限を超えた場合、バッファリングデータは破棄されます。それまでに伝送、もしくはバッファリングデータの保護を行う必要があります

#### JSONファイルフォーマット ####

* format: JSON(UTF-8)
* レコードセパレータ: "\n"

```
{ message: MESSAGE, time, TIME, tag: TAG }\n
Or
{ message: MESSAGE, time, TIME, tag: TAG }\n
{ message: MESSAGE, time, TIME, tag: TAG }\n
```

* message : エラーメッセージ
* time : エラー発生時刻(iso8601)
* tag : ログ種別

e.g.)

```
{"message":"out_http_alt: Send success, chunk_id:dummy, in_chunk_cnt:0","tag":"fluent.info","time":"2014-11-26T17:00:25+09:00"}
```

e.g.) alt: 複数のJSONデータが1ファイルに格納される場合

```
{"message":"out_http_alt: Retry. Due to HTTP status was 500. chunk_id:dummy, in_chunk_cnt:0, chunk_id:dummy, in_chunk_cnt:0","tag":"fluent.warn","time":"2014-11-26T17:01:31+09:00"}
{"message":"out_http_alt: Retry. Due to HTTP status was 500. chunk_id:dummy, in_chunk_cnt:0, chunk_id:dummy, in_chunk_cnt:0","tag":"fluent.warn","time":"2014-11-26T17:01:32+09:00"}
```

Debug method
------------

#### Send ####

UNIX Domain Socketにwriteすると、Fluentdを起動したターミナルに下記のように表示され、それぞれ以下のような意味となります

```
2014-11-14 19:55:58 +0900 pfid.u.10021.DUID-DUMMY: {"data":"hoge"}
------------------------ |-----------------------|----------------|
   Fluentdでの受信日時     tag                     送信されるJSON
                    
```

#### callback ####

rakeコマンド内の各タスクにて、擬似的な送信エラーを起こすことができ、それをトリガーにcallbackをexecできます

```
$ bundle exec rake raise_error:network:timeout
```

raise可能なエラーは`bundle exec rake -T`をご覧ください


More examples
-------------

in\_literal.c:

```
#include <sys/socket.h>
#include <sys/un.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define SEND_DATA "This is test message from client\n"
char *socket_path = "/opt/emitter/tmp/in_literal.sock";

int main(int argc, char *argv[]) {
  struct sockaddr_un addr;
  char buf[100];
  int fd,rc;

  if ( (fd = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
    perror("socket error");
    exit(-1);
  }

  memset(&addr, 0, sizeof(addr));
  addr.sun_family = AF_UNIX;
  strncpy(addr.sun_path, socket_path, sizeof(addr.sun_path)-1);

  if (connect(fd, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
    perror("connect error");
    exit(-1);
  }

  rc = write(fd, SEND_DATA, sizeof(SEND_DATA));
  close(fd);

  return 0;
}
```

callback.rb:

```
require "pp"
require "json"

open(ARGV[0]).read.force_encoding('utf-8').split("\n").each do |r|
  pp "this is #{$0} exec result"
  pp JSON.parse(r)
end

exit 0
```


Running operation
===================

<span id="run_env">RUN\_ENV</span>
--------

*Emitter*は環境変数`RUN_ENV`で読み込む設定ファイルを変更します

主にオフライン開発用として使用します

* `RUN_ENV` = (nil) or development

e.g. )

```
$ bundle exec rake boot
  #=> load `config/fluent.rb for production
$ RUN_ENV=development bundle exec rake boot
  #=> load `config/fluent_development.rb for development
```

Parameters w/ boot
------------------

*Emitter*の動作環境は下記によって定義されます

* 環境変数 `IOTSP_EMITTER_*`
* `config/localconf.json`
* `config/pfconf.json`

同じ項目があった場合は、上位のものが優先されます (= 環境変数が最大優先)

### parameters ###

* duid (`IOTSP_EMITTER_DUID`): デバイスUID

下記は特に理由のない限り変更は不要です

* pfid (`IOTSP_EMITTER_PFID`): プラットフォームID
* wpver : ワイヤプロトコルバージョン
* endpoint : APIエンドポイントURI

Daemonize
---------

当ライブラリは[supervisord](http://supervisord.org/)にてdaemon化します

設定は`vendor/supervisord\_emitter.conf`です


Appendix
========

rbenv setup
-----------

```
$ sudo apt-get install git libssl-dev autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev devscripts
$ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
$ git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
$ echo 'export PATH="~/.rbenv/bin:$PATH"' >> ~/.bash_profile
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
$ source ~/.bash_profile
$ rbenv install 1.9.3-p547
$ rbenv shell 1.9.3-p547
$ gem install bundle --no-rdoc --no-ri
$ rbenv rehash
```

ruby setup by apt
-----------------

```
$ sudo apt-get install ruby1.9.3 ruby-dev build-essential curl git
$ sudo gem install bundle rake --no-rdoc --no-ri
```

EoT

