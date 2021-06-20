# frozen_string_literal: true

require 'json'
require 'sinatra'

module Server
  class Server
    def initialize(args)
      Site.run!
    end
  end
  
  class Site < Sinatra::Base
    set :bind, '0.0.0.0'
    set :static, true
    set :public_dir, File.expand_path(__dir__)
    
    get '/' do
      <<~HTML
        <!doctype html>
          <head lang="en">
            <meta charset="utf-8">
            <title>PingMeter</title>
          </head>
          </body>
            <header>
              <h1>PingMeter</h1>
            </header>
            <section>
            <p>How to use it:</p>
              <ul>
                <li>to add an IP to the list put: /add?ip=1.2.3.4</li>
                <li>to remove an IP from the list put: /remove?ip=1.2.3.4</li>
                <li>to get statistic of an IP put: /statistic?ip=1.2.3.4&start=2021-06-20T20:31:49&finish=2021-06-20T20:32:00</li>
              </ul>
            </section>
          </body>
        </head>
      HTML
    end
    
    # /add?ip=1.2.3.4
    get '/add' do
      system "docker-compose up -d --rm ping ruby bin/ping.rb add #{params[:ip]}"
      "<p>#{params[:ip]} was successfully added and started to ping.</p>\n" +
      "<br>\n" +
      "<a href='/'>Back</a>"
    end
    
    # /remove?ip=1.2.3.4
    get '/remove' do
      system "docker-compose run --rm ping ruby bin/ping.rb remove #{params[:ip]}"
      "<p>#{params[:ip]} was removed from list. Ping was stopped.</p>\n" +
      "<br>\n" +
      "<a href='/'>Back</a>"
    end
    
    # /statistic?ip=1.2.3.4&start=2021-06-20T20:31:49&finish=2021-06-20T20:32:00
    get '/statistic' do
      system "docker-compose run --rm ping ruby bin/ping.rb statistic #{params[:ip]} #{params[:start]} #{params[:finish]}"
      "#{ JSON({ json: 'json' }) }"
    end
  
  end
end

Server::Server.new(ARGV)
