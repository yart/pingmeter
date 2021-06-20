# frozen_string_literal: true

require 'sinatra'
require_relative '../lib/db_client'

def page(&block)
  <<~HTML
    <!doctype html>
    <html lang="en">
      <head>
        <title>PingMeter</title>
        <style type="text/css">
        </style>
      </head>
      <body>
        <header>
          <h1>PingMeter</h1>
          <h2>by Art Jarocki</h2>
        </header>
        <section>
          #{block if block_given?}
        </section>
      </body>
    </html>
  HTML
end

get '/' do
  page do
    'Hello, world!!!'
  end
end

# /add?ip=1.2.3.4
get '/add' do
  system "docker-compose up -d ping add #{params[:ip]}"
end

# /remove?ip=1.2.3.4
get '/remove' do
  system "docker-compose run ping remove #{params[:ip]}"
end

# /statistic?ip=1.2.3.4&start=2021-06-20T20:31:49&finish=2021-06-20T20:32:00
get '/statistic' do
  system "docker-compose run ping statistic #{params[:ip]} #{params[:start]} #{params[:finish]}"
end
