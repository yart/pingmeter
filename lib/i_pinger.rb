# frozen_string_literal: true

class IPinger
  
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
          buffer << { ip: @ip, duration: ping ? @icmp.duration : -1, measured_at: DateTime.now }
        end
        
        sleep 1
      end
    end
    
    Thread.new do
      while !@client.deleted?(@ip) || !buffer.empty? do
        @client.put_duration(buffer.shift) unless buffer.empty?
        Thread.kill(pinger) if @client.deleted?(@ip)
      end
    end
  
  end
  
  def stop
    @client.delete_ip(@ip)
  end
  
  def statistic(period_start, period_end)
  
  end

end
