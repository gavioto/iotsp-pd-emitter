PD Emitter - IoT Network Stack
==============================

What is *PD Emitter*
------------------

これはセンサー制御機器とクラウド間のデータ送受信を容易にする通信ミドルウェアです

センサー制御機器にインストールし、プロセス(daemon)として立ち上げて使用します

```
    +----------+    +------------------+
    | センサー |----| センサー制御機器 |---- (ネットワーク/クラウド)
    +----------+    +------------------+
                         ^
                         |
                      PD Emitterのインストール対象
```

このライブラリは様々なクラウドサービスのAPIコールを肩代わりしてくれる他、通信が不安定な環境においても確実にデータ伝送を実現する機能が実装済です

これにより、データ伝送にまつわるコーディングは不要となり、センサー制御のプログラム開発に集中することが出来ます

対応クラウドサービス
--------------------

* Amazon Web Services
    * [Amazon Kinesis](#amazon-kinesis)
* Generic HTTP REST API

### Index ###

* [特徴](#features)
* [Quick Start](#quick-start)
* [設定](#configuring)
* [開発](#development)
* [運用](#running-operation)

Demos

* Examples
   * [Any Languages](#any-languages)
   * [Structured Data](#structured-data)
* [Amazon Kinesis](#amazon-kinesis)

Appendix

* [Ruby setup by rbenv](#ruby-setup-by-rbenv)
* [Ruby setup by apt](#ruby-setup-by-apt)

Features
--------

* メッセージの蓄積/再送
    * 送受信成功/失敗時のコールバックプログラムの起動
* プロセス(daemon)制御※
    * 死活監視API
    * ログサイズ抑制
* プラガブルアーキテクチャ

※プロセス制御にsupervisordを使用の場合

Quick start
-----------

### Requirements ###

* Linux (Ubuntu 14.04 recommended)
* Ruby 1.9 or higher (1.9 w/ [apt](#ruby-setup-by-apt) recommended, [rbenv](#ruby-setup-by-rbenv) ready)
    * gems are bundler

### Installation ###

```
$ cd /opt
$ sudo git clone https://github.com/plathome/pd-emitter.git
$ sudo chown -R YOU /opt/pd-emitter
$ cd /opt/pd-emitter
### if using rbenv, run `rbenv local 1.9.3-p547 ; rbenv rehash`
$ bundle install --path vendor/bundle --without development
```

`/opt` is example.

#### Start ####

```
$ cd /opt/pd-emitter
$ bundle exec rake start
```

STOP is `Ctrl+C`

See [Daemonize](#daemonize) if you want daemon.

#### Try DEMO !! ####

Run on the other console and see "rake start" console.

Send message:

```
$ cd /opt/pd-emitter
$ bundle exec ruby -rsocket -e 'UNIXSocket.open("tmp/in.sock"){|s|s.write "hello"}'
```

Callback:

```
$ cd /opt/pd-emitter
$ bundle exec bin/debug_log-injector -l warn -m "AnyError"
$ bundle exec bin/debug_log-injector -l info -m "AnySuccess"
```

Configuring
-----------

!!! This section is WIP. !!!

Development
-----------

センサー制御機器での開発で必要なことは大きく２つです

1. *PD Emitter*の設定
2. プログラム開発
    * センサーからデータを読み出し、 *PD Emitter* へデータをwriteするプログラム(SensorReader)
    * *PD Emitter* の送受信結果から起動されるプログラム(Callback)※
        1. 送信成功時用
        2. 〃失敗時用

※callbackの開発は任意です

### プログラム開発 ###

SensorReaderの実装は、主に以下の流れとなります

1. センサーからのデータ読み出し
2. *PD Emitter* へのデータ書き込み

センサーからのデータ読み出しは、個々に実装願います

*PD Emitter* へのデータ書き込み方法はUNIX Domain Socketを推奨しています

※in\_unix\_unimsgを使用する場合ならば、プレーンな文字列をUNIX Domain socketに書き込むだけです

Operation
---------

### RUN\_ENV 環境変数 ###

*PD Emitter *は環境変数`RUN_ENV`で読み込む設定ファイルを変更します※

※`rake start`を通じた起動の場合

e.g. )

```
$ bundle exec rake start
  #=> load `config/fluent.rb` for production
$ RUN_ENV=development bundle exec rake start
  #=> load `config/fluent_development.rb` for development
```

### Daemonize ###

*PD Emitter *のdaemon化は[Supervisord](http://supervisord.org)を推奨します

supervisord用configは`vendor/supervisord_pd-emitter.conf`を利用してください

Install:

```
$ sudo apt-get install supervisor
$ cd /opt/pd-emitter
$ sudo cp vendor/supervisord_pd-emitter.conf /etc/supervisor/conf.d/pd-emitter.conf
$ sudo supervisorctl reload
$ sudo supervisorctl status
```

Operation:

```
Log:
  $ sudo supervisorctl tail -f main:pd-emitter
Restart(Reload):
  $ sudo supervisorctl restart main:pd-emitter
```

#### rbenv使用時 ####

rbenvを使用している場合、`bundle`コマンドが見つからず、起動が出来ません

```
$ sudo supervisorctl status
main:pd-emitter                     FATAL      can't find command 'bundle'
```

`rbenv shims`で見つけることのできる`bundle`コマンドを、command =に指定するようにしてください

```
$ rbenv shims | grep bundle$
/home/USERNAME/.rbenv/shims/bundle
```

supervisord\_pd-emitter.conf:

```
command = /home/USERNAME/.rbenv/shims/bundle exec rake start
```

### `bin/debug_log-injector`コマンド ###

`bin/debug_log-injector` は、callbackプログラムの開発用です

ログに特定の文字列を書き込み、callbackの動作を検証することが出来ます

`bundle exec ruby bin/debug_log-injector --help`をご覧ください


Demos
=====

Examples
--------

### Any Languages ###

!!! This section is WIP. !!!

PD Emitterは、UNIX Domain Socketによる待受/通信を行うため、センサー制御プログラムの開発言語を選びません


### Structured Data ###

!!! This section is WIP. !!!

PD Emitterは構造化データに対応しています

Amazon Kinesis
--------------

!!! This section is WIP. !!!

Amazon Kinesisへのデータ送信デモ (要AWSアカウント)

### AWS上での準備 ###

1. アカウント操作
    1. AWSアカウントの作成
    2. AWSユーザの作成
    3. ユーザへのPermissionの割り当て
    4. ユーザのAPIアクセス用AccessKeyの発行
2. Kinesis Streamの作成

以上はAWSのマニュアルを参照ください

### *PD Emitter* の準備 ###

まず、 [*PD Emitter* のセットアップ](#quick-start)を完了させてください

その後、下記でAmazon Kinesisデータ送信デモの環境がインストールされます


以上で、config/conf.d/にkinesis.(rb|json)が、 *PD Emitter* のアプリrootにkinesis\_demo/が作成されます (不要になったら削除可能)

インストール後のメッセージに従って、Gemfileの更新と`bundle install`の実行、`config/conf.d/kinesis.json`の編集を行ってください

### デモの実行 ###

*PD Emitter* を `bundle exec rake start` で起動させた後、別のターミナルから `bundle exec ruby kinesis_demo/put.rb` を実行してみてください

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