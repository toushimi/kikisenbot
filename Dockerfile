FROM ruby:latest
ENV APP_HOME /kikisenbot

RUN apt-get update && apt-get install -y \
      libopus-dev libopus0 \
      libsodium-dev libsodium23 \
      wget \
      chromium \
      xz-utils && \
      apt-get clean && rm -rf /var/lib/apt/lists/*
RUN wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz \
      && tar Jxf ./ffmpeg-release-amd64-static.tar.xz \
      && mv ./ffmpeg*amd64-static/ffmpeg /usr/local/bin/ \
      && mv ./ffmpeg*amd64-static/ffprobe /usr/local/bin/ \
      && rm -f ./ffmpeg-release-amd64-static.tar.xz \
      && rm -rf /ffmpeg-*

WORKDIR $APP_HOME
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock

RUN bundle install

ADD . $APP_HOME

