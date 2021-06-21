# frozen_string_literal: true

class IPinger
  TIME_FORMAT = "%Y-%m-%d %H:%M:%S"
  
  def initialize(ip:, db_client:)
    @ip     = ip
    @icmp   = Net::Ping::ICMP.new(@ip)
    @client = db_client
    
    @client.create_table_for(@ip)
    @client.create_addresses_table
  end
  
  def ping
    @client.add_ip(@ip)
    
    buffer = []
    
    pinger = Thread.new do
      loop do
        begin
          ping = @icmp.ping
        ensure
          buffer << { ip: @ip, duration: ping ? @icmp.duration : -1, measured_at: DateTime.now.strftime(TIME_FORMAT) }
        end
        
        sleep 1
      end
    end
    
    keeper = Thread.new do
      while !@client.deleted?(@ip) || !buffer.empty? do
        @client.put_duration(**buffer.shift) unless buffer.empty?
        Thread.kill(pinger) if @client.deleted?(@ip)
        sleep 0.2
      end
    end
    
    pinger.alive?
    
    pinger.join
    keeper.join
  end
  
  def stop
    @client.delete_ip(@ip)
  end
  
  def statistic(*period)
    list = @client.ping_list(@ip, *period.map { |el| DateTime.parse(el).strftime(TIME_FORMAT) })
    
    return { status: 'error', message: 'Such IP was not found' }.to_json if list.nil?
    
    list_size = list.size
    negatives = list.select { |el| el.negative? }
    list.delete_if { |el| el.negative? }
    
    negative_count = negatives.nil? ? 0 : negatives.count
    fails          = (negative_count / list_size * 100).round
    
    return { status: 'error', message: "Such IP has no statistics because #{negative_count} packets was transmitted and 0 received back so 100% packet was loss." }.to_json if fails == 100
    
    { status: 'ok',
      data:   {
        mean:                 list.mean,
        min:                  list.min,
        max:                  list.max,
        median:               list.median,
        'standard deviation': list.standard_deviation,
        'fails percent':      "#{fails}%"
      }
    }.to_json
  end

end
