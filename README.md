Emitter - IoT Data Transmitter Lib.
===================================

What is *Emitter*
---------------

これはセンサー制御機器とクラウド間のデータ送受信を容易にする通信ライブラリです

センサー制御機器にインストールし、プロセス(daemon)として立ち上げて使用します

```
    +----------+    +------------------+
    | センサー |----| センサー制御機器 |---- (ネットワーク/クラウド)
    +----------+    +------------------+
                         ^
                         |
                      インストール対象
```

このライブラリは様々なクラウドサービスのAPIコールを肩代わりしてくれる他、通信が不安定な環境においても確実にデータ伝送を実現する機能が実装済です

これにより、データ伝送にまつわるコーディングは不要となり、センサー制御のプログラム開発に集中することが出来ます

[Amazon Kinesisへのデータ送信デモ](#amazon-kinesis)を同梱しており、AWSアカウントがあればすぐに体験いただくことができます

### Index ###

* [特徴](#features)
* [Quick Start](#quick-start)
* [設定](#configuring)
* [開発](#development)
* [運用](#running-operation)

* 同梱の[Amazon Kinesisデータ送信デモ](#amazon-kinesis)について

* Appendix
    * [Ruby setup by rbenv](#ruby-setup-by-rbenv)
    * [Ruby setup by apt](#ruby-setup-by-apt)

Features
--------

* メッセージスプール/再送
    * 成功/失敗時のコールバック
* プロセス(daemon)制御※
    * ログサイズ抑制
* プラガブルアーキテクチャ
    * Cloud API

※プロセス制御にsupervisordを使用の場合

Quick start
-----------

### Requirements ###

* Linux (Ubuntu 14.04 recommended)
* Ruby 1.9 or higher (1.9 and [rbenv](#ruby-setup-by-rbenv) recommended, [apt](#ruby-setup-by-apt) OK)
    * gems are bundler

### Installation ###

```
$ cd /opt
$ sudo git clone https://ssl.plathome.co.jp/git/git/iotsp/emitter.git
$ sudo chown -R YOU /opt/emitter
$ cd /opt/emitter
### if using rbenv, run `rbenv local 1.9.3-p547 ; rbenv rehash`
$ bundle install --path vendor/bundle --without development
$ bundle exec rake install:demo install:examples
```

#### Start (on console) ####

```
$ cd /opt/emitter
$ RUN_ENV=development bundle exec rake start
```

STOP is `Ctrl+C`

#### Try it !! ####

On other console ...

Send message:

```
$ bundle exec ruby -rsocket -e 'UNIXSocket.open("/opt/emitter/tmp/in_unix_unimsg.sock"){|s|s.write "hello"}'
Another console:
2014-11-26 15:05:23 +0900 test.msg: {"data":"hello"}
```

It's so good !

Configuring
-----------

設定は3つの項目を行います

1. センサー制御アプリからのデータ入力の設定
2. データ出力の設定
3. データ送信結果に応じたcallbackの設定 (任意)

1と2は必須です。3は必要に応じて設定します

以下、`install:demo`でインストールされる設定サンプル

`config/conf.d/demo.rb`:

```
# REQUIRE: entrypoint(input) from App
source {
  type :unix_unimsg
  path "./tmp/in_demo.sock"
  key :data
  tag "test.msg"
}

# REQUIRE: emit to the network/Cloud
match("test.msg.**") {
  type :stdout
}

# OPTION: callback from emit result
match("fluentlog") {
  type :grep
  regexp1 "tag fluent.warn"
  regexp2 "message AnyError"
  add_tag_prefix :out_fail
}
```

この設定で、Quick StartのTry Itのような動作となります

また`bin/emitter-logger`を下記の通り実行すると、callbackプログラムが実行されます

`$ bundle exec bin/emitter-logger -l warn -m AnyError`

*Emitter* は[Fluentd](http://fluentd.org)を使用しています。そのため[FluentdのPlugin](http://www.fluentd.org/plugins)をすべて活用可能です

Development
-----------

センサー制御機器での開発で必要なことは大きく２つです

1. Emitterの設定
2. プログラム開発
    * センサーからデータを読み出し、 *Emitter* へデータをwriteするプログラム(SensorReader)
    * *Emitter* の送受信結果から起動されるプログラム(Callback)※
        1. 送信成功時用
        2. 〃失敗時用

※callbackの開発は任意です

### プログラム開発 ###

SensorReaderの実装は、主に以下の流れとなります

1. センサーからのデータ読み出し
2. *Emitter* へのデータ書き込み

*Emitter* へのデータ書き込み方法は *Emitter* の設定状況によりますが、UNIX Domain Socketを推奨しています

unix\_unimsgを使用する場合ならば、[Quick start](#quick-start)に書いてあるとおり、単純な文字列をUNIX Domain socketに書き込むだけです

Running operation
-----------------

### RUN\_ENV 環境変数 ###

*Emitter *は環境変数`RUN_ENV`で読み込む設定ファイルを変更します

主にオフライン開発用として使用します

* `RUN_ENV` = (nil) or development

e.g. )

```
$ bundle exec rake start
  #=> load `config/fluent.rb` for production
$ RUN_ENV=development bundle exec rake start
  #=> load `config/fluent_development.rb` for development
```

### Daemonize ###

*Emitter *のdaemon化は[Supervisord](http://supervisord.org/)を推奨します

supervisord用configは`vendor/supervisord_emitter.conf`を利用してください

Install:

```
$ sudo apt-get install supervisor
$ cd /opt/emitter
$ sudo cp vendor/supervisord_emitter.conf /etc/supervisor/conf.d/emitter.conf
$ sudo supervisorctl reload
$ sudo supervisorctl status
```

Running operation:

```
$ sudo supervisorctl tail -f main:emitter
$ sudo supervisorctl restart main:emitter
```

#### rbenv使用時 ####

rbenvを使用している場合、`bundle`コマンドが見つからず、起動が出来ません

```
$ sudo supervisorctl status
main:fluentd                     FATAL      can't find command 'bundle'
```

`rbenv shims`で見つけることのできる`bundle`コマンドを、command =に指定するようにしてください

```
$ rbenv shims | grep bundle$
/home/USERNAME/.rbenv/shims/bundle
```

```
command = /home/USERNAME/.rbenv/shims/bundle exec fluentd -c config/fluent.rb --suppress-repeated-stacktrace
```

### `bin/emitter-logger`コマンド ###

`bin/emitter-logger` は、callbackプログラムの開発用です

ログに特定の文字列を書き込み、callbackの動作を検証することが出来ます

Amazon Kinesis
--------------

Amazon Kinesisへのデータ送信デモを同梱しています

AWSのアカウントがあれば、Kinesisへのデータ送信をすぐに体験していただけます

### AWS上での準備 ###

1. アカウント操作
    1. AWSアカウントの作成
    2. AWSユーザの作成
    3. ユーザへのPermissionの割り当て
    4. ユーザのAPIアクセス用AccessKeyの発行
2. Kinesis Streamの作成

以上はAWSのマニュアルを参照ください

### *Emitter* の準備 ###

まず、 [*Emitter* のセットアップ](#quick-start)を完了させてください

その後、下記でAmazon Kinesisデータ送信デモの環境がインストールされます

```
$ bundle exec rake install:kinesis_demo
```

以上で、config/conf.d/にkinesis.(rb|json)が、 *Emitter* のアプリrootにkinesis\_demo/が作成されます (不要になったら削除可能)

インストール後のメッセージに従って、Gemfileの更新と`bundle install`の実行、`config/conf.d/kinesis.json`の編集を行ってください

### デモの実行 ###

*Emitter* を `bundle exec rake start` で起動させた後、別のターミナルから `bundle exec ruby kinesis_demo/put.rb` を実行してみてください

`{"data"=>"This is test message for Amazon Kinesis, "time"=> ...}` というJSONデータがKinesisへ送信されます

送信されたデータは `bundle exec ruby kinesis_demo/get.rb` で確認できます


Appendix
========

Ruby setup by rbenv
-------------------

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

Ruby setup by apt
-----------------

```
$ sudo apt-get install ruby1.9.3 ruby-dev build-essential curl git
$ sudo gem install bundle rake --no-rdoc --no-ri
```

EoT