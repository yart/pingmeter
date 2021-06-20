# frozen_string_literal: true

require 'date'
require 'net/ping'
require 'mysql2'
require 'yaml'
require_relative '../lib/db_client'
require_relative '../lib/i_pinger'

db_config_filename = '../db_config.yaml'
default_db_config  = { host: 'db', port: '3306', username: 'root', password: 'example' }
db_config          = File.exist?(db_config_filename) ? YAML.load(File.read(db_config_filename), symbolize_names: true) : default_db_config
pinger             = IPinger.new(ip: ARGV[1], db_client: DBClient.new(db_config))

case ARGV.first
when 'add'
  pinger.ping
when 'remove'
  pinger.stop
when 'statistic'
  pinger.statistic(ARGV[2], ARGV[3])
end
