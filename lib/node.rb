require 'yaml'
require 'fileutils'
require 'digest/md5'

class Node
  NODE_STORAGE_LOCATION = "/tmp/nodes/"
  HASH_SALT = 'MD5 is a one-way hashing algorithm for creating digest signatures of strings'

  def self.load_node(uid)
    File.open(NODE_STORAGE_LOCATION + uid.to_s, 'r') { |file|
      YAML::load(file)
    }
  end

  attr_reader :uid, :balance
  def initialize(uid, balance = 0, time = nil)
    @log = ""
    @uid = sanitize_string uid
    @balance = sanitize_number balance
    @time = sanitize_string time
    @hash = Digest::MD5.hexdigest(uid + balance.to_s + HASH_SALT + Time.now.to_s)
    log "Node created with uid '#{uid}' and initial balance of #{balance} at #{Time.now}"
    log "Node hash is #{@hash}"
    save_node
  end

  def auth_node(auth_string)
    input = sanitize_string auth_string
    if input == @hash
      true
    elsif input == @time
      true
    else
      log "Node authentication failed with authentication string: #{input} at #{Time.now}"
      save_node
      false
    end
  end

  def credit_node(amount, reason = nil)
    if amount.to_i >= 0
      @balance = @balance + amount.to_i
      log "Credited node #{amount.to_i} units for a remaining #{@balance} units at #{Time.now}"
      log "Credit reason: #{reason}" if reason
      save_node
    end
  end

  def debit_node(amount, reason = nil)
    if @balance - amount.to_i >= 0
      @balance = @balance - amount.to_i
      log "Debited node #{amount.to_i} units for a remaining #{@balance} units at #{Time.now}"
      log "Debit reason: #{reason}" if reason
      save_node
    else
      raise RuntimeError, 'Negative node balance not allowed'
    end
  end

  def save_node
    File.open(NODE_STORAGE_LOCATION + @uid.to_s, 'w') { |file|
      file.puts YAML::dump(self)
    }
  end

  def destroy_node
    FileUtils.rm(NODE_STORAGE_LOCATION + @uid.to_s)
  end

  def log(msg)
    @log << msg + "\n"
  end

  def get_log
    @log
  end

  def sanitize_string(input)
    input.gsub(/[^0-9a-z :]/i, '')
  end

  def sanitize_number(input)
    input.gsub(/[^0-9]/i, '')
  end

end