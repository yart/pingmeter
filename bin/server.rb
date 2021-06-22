# frozen_string_literal: true

require 'json'
require 'sinatra'

set :bind, '0.0.0.0'

get '/' do
  erb <<~HTML, layout: :layout
    <h2>How to use it:</h2>
    <ul>
      <li>
        <p>You can add an IP-address to PingMeter using follows form or just put to the browser search-string
        something like: <code>http://pingmeter.online/add?ip=1.2.3.4</code>. Then the application will start
        gather statistic of the IP-address you add on.</p>
        <form action="/add" method="get">
          <div>
            <span>IP:</span>
            <input type="text" name="ip">
            <input type="submit" value="add">
          </div>
        </form>
      </li>
      <li>
        <p>If you don't wish to gather statistic for any IP-address you also can use follows form or simply
        put to the browser's search-string something like: <code>http://pingmeter.online/remove?ip=1.2.3.4</code></p>
        <form action="/remove" method="get">
          <div>
            <span>IP:</span>
            <input type="text" name="ip">
            <input type="submit" value="remove">
          </div>
        </form>
      </li>
      <li>
        <p>You can get gathered statistics about your IP-address using this form. Also you can just put to
        the browser's search-string something like:
        <code>http://pingmeter.online/statistic?ip=1.2.3.4&start=2021-06-20T20:31:49&finish=2021-06-20T20:32:00</code></p>
        <form action="/statistic" method="get">
          <div><span>IP:</span> <input type="text" name="ip"></div>
          <div>
            <span>Period:</span> <input type="datetime-local" name="start"> </div>
          <div>
            <span></span> <input type="datetime-local" name="finish">
            <input type="submit" value="get">
          </div>
        </form>
      </li>
    </ul>
  HTML
end

# /add?ip=1.2.3.4
get '/add' do
  `ruby bin/ping.rb add #{params[:ip]}`
  erb <<~HTML, layout: :layout
    <p><%= params[:ip] %> was successfully added and started to ping.</p>
    <br>
    <a href='/'>Back</a>
  HTML
end

# /remove?ip=1.2.3.4
get '/remove' do
  `ruby bin/ping.rb remove #{params[:ip]}`
  erb <<~HTML, layout: :layout
    <p><%= params[:ip] %> was removed from list. Ping was stopped.</p>
    <br>
    <a href='/'>Back</a>
  HTML
end

# /statistic?ip=1.2.3.4&start=2021-06-20T20:31:49&finish=2021-06-20T20:32:00
get '/statistic' do
  content_type :json
  "#{`ruby bin/ping.rb statistic #{params[:ip]} #{params[:start].gsub(/%3A/, ':')} #{params[:finish].gsub(/%3A/, ':')}`}"
end

template :layout do
  <<~HTML
    <!doctype html>
    <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>PingMeter</title>
        <style>
          html {
            box-sizing: border-box;
            font-family: sans-serif;
            font-size: 18px;
          }
          body, li, form, section {
            display: flex;
            flex-direction: column;
          }
          body, li {
            align-items: center;
          }
          ul {
            padding-left: 20px;
          }
          li {
            margin-bottom: 1em;
          }
          section {
            align-items: center;
            min-width: 400px;
            max-width: 700px;
          }
          form {
            width: 400px;
          }
          form input[type="text"], form input[type="datetime-local"] {
            padding: 2px 1px;
            width: 200px;
          }
          form div span {
            display: inline-block;
            width: 60px;
          }
          form input[type="submit"] {
            width: 60px;
          }
          a {
            display: inline-block;
          }
        </style>
      </head>
      </body>
        <header>
          <h1>PingMeter</h1>
        </header>
        <section>
          <%= yield %>
        </section>
      </body>
    </html>
  HTML
end
