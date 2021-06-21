# frozen_string_literal: true

class DBClient
  ADDRESSES_TABLE_NAME = 'addresses'
  
  def initialize(**opts)
    dbms  = opts[:dbms] || :mysql
    @opts = {
      host:     opts[:host],
      port:     opts[:port],
      username: opts[:username],
      password: opts[:password]
    }
    @opts.merge!(symbolize_keys: true) if dbms == :mysql
  end
  
  def execute(query)
    host     = nil
    response = nil
    
    begin
      host = Mysql2::Client.new(@opts)
    rescue => e
      puts e.full_message
      host&.close
    end
    
    begin
      host.query('USE test_servers_com;')
      response = host.query(query)
    rescue => e
      puts e.full_message
    ensure
      host.close
    end unless host.nil?
    
    response
  end
  
  def create_table_for(ip)
    execute <<~SQL
      CREATE TABLE IF NOT EXISTS `#{ip}`
      (
        `id`          BIGINT(20) AUTO_INCREMENT PRIMARY KEY,
        `duration`    FLOAT(10)  NOT NULL,
        `measured_at` DATETIME   NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
    SQL
  end
  
  def create_addresses_table
    execute <<~SQL
      CREATE TABLE IF NOT EXISTS `#{ADDRESSES_TABLE_NAME}`
      (
        `id`         BIGINT(20)   AUTO_INCREMENT PRIMARY KEY,
        `address`    VARCHAR(255) NOT NULL,
        `deleted`    TINYINT(1)   NOT NULL DEFAULT 0,
        `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
        `updated_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        UNIQUE KEY `address` (`address`),
        INDEX      `deleted` (`deleted`)
      );
    SQL
  end
  
  def add_ip(ip)
    if execute("SELECT `id` FROM `#{ADDRESSES_TABLE_NAME}` WHERE `address` = '#{ip}';").to_a.empty?
      execute "INSERT IGNORE INTO `#{ADDRESSES_TABLE_NAME}` (`address`) VALUE('#{ip}');"
    else
      execute "UPDATE `#{ADDRESSES_TABLE_NAME}` SET `deleted` = 0 WHERE `address` = '#{ip}';"
    end
  end
  
  def delete_ip(ip)
    execute "UPDATE `#{ADDRESSES_TABLE_NAME}` SET `deleted` = 1 WHERE `address` = '#{ip}';"
  end
  
  def put_duration(**data)
    execute "INSERT INTO `#{data[:ip]}` (`duration`, `measured_at`) VALUE(#{data[:duration]}, '#{data[:measured_at]}')"
  end
  
  def deleted?(ip)
    execute("SELECT `id` FROM `#{ADDRESSES_TABLE_NAME}` WHERE `address` = '#{ip}' AND `deleted` = 0;").to_a.empty?
  end
  
  def ping_list(ip, *period)
    if execute("SELECT `id` FROM `#{ADDRESSES_TABLE_NAME}` WHERE `address` = '#{ip}';").to_a.empty?
      nil
    else
      execute("SELECT `duration` FROM `#{ip}` WHERE `measured_at` BETWEEN '#{period.first}' AND '#{period.last}';").to_a.map(&:values).flatten
    end
  end

end
