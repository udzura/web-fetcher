FROM ruby:3.0.3-slim

RUN apt-get update && apt-get -y install git build-essential libxml2-dev libxslt-dev
RUN mkdir /app
ADD . /app

WORKDIR /app
RUN bundle config set --local path 'vendor/bundle'
RUN bundle install

ENTRYPOINT ["./fetch"]
