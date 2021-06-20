FROM ruby:2.7.1-alpine

ENV PINGDIR=/usr/src/app/
RUN mkdir -p $PINGDIR \
  && apk --no-cache add git \
  && git clone https://github.com/yart/pingmeter.git $PINGDIR \
  && gem install bundler

ENV PATH $PATH
RUN bundle config --global frozen 1

WORKDIR $PINGDIR
#COPY ./Gemfile $PINGDIR
#COPY ./Gemfile.lock $PINGDIR
RUN touch $PINGDIR/Gemfile.lock
RUN bundle install
#COPY . $PINGDIR

EXPOSE 4567
