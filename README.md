# README
Discordと接続し、TTSを行うBOTと周辺サービスです。  

Things you may want to cover:

* Ruby version  
3.1  

* System dependencies  
DiscordでTTSBotを動かすにあたって、Discordrbのvoiceに関する前提ソフトウェアがあります。  
ffmpeg  
libopus  
libsodium  
また、デフォルトはvoicevoxを使いますので、voicevoxがセットアップされている必要があります。 

* Configuration  
env.sampleを参照

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions  
docker build -t kikisenbot:development .
docker-compose up -d

* ...
