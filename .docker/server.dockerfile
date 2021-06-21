FROM ruby:2.7.1-alpine

RUN apk --no-cache add \
    build-base \
    libstdc++ \
    openssl-dev \
    tzdata

COPY --from=sndbx/libmysqlclient /usr/local/mysql /usr/local/mysql

RUN gem install bundler

ENV PATH $PATH
ENV PINGDIR=/usr/src/app/
RUN bundle config --global frozen 1 && \
    mkdir -p $PINGDIR

WORKDIR $PINGDIR
COPY ./Gemfile $PINGDIR
COPY ./Gemfile.lock $PINGDIR
RUN bundle install
COPY . $PINGDIR

EXPOSE 4567
