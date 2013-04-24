require './lib/node.rb'

class Banker
  BANKER_LOCATION = "/tmp/banker/"
  MINIMUM_DEPOSIT_AMOUNT = 10000000

  def self.load_banker(banker = "default")
    File.open(BANKER_LOCATION + banker, 'r') { |file|
      YAML::load(file)
    }
  end

  def initialize(banker = "default", min_deposit = MINIMUM_DEPOSIT_AMOUNT)
    @log = ""
    @banker = sanitize_string banker
    @min_deposit = min_deposit.to_i
    @last_activity = Time.now
    log "Banker #{@banker} initialized at #{@last_activity}"
    save_banker
  end

  def main_routine
    log "Banker started main routine at #{Time.now}"
    handle_deposits get_deposits
    log "Banker finished main routine at #{Time.now}"
    save_banker
  end

  def handle_deposits(deposits)
    ignored_deposits = 0
    handled_deposits = 0
    log "Handling #{deposits.size} deposits"
    deposits.each { |deposit|
      if deposit[:amount] >= @min_deposit
        handle_deposit deposit
        handled_deposits = handled_deposits + 1
      else
        ignored_deposits = ignored_deposits + deposit[:amount].to_i
      end
    }
    log "Ignored #{deposits.size - handled_deposits} deposits totalling #{ignored_deposits}"
  end

  def handle_deposit(deposit)
    if File.exists? Node::NODE_STORAGE_LOCATION + deposit[:user]
      credit_node_routine deposit
    else
      new_node_routine deposit
    end
  end

  def credit_node_routine(deposit)
    node = Node.load_node deposit[:user]
    node.credit_node deposit[:amount], 'Automated banker deposit'
    log "Credited node #{deposit[:user]} for remaining balance of #{node.balance} at #{Time.now}"
  end

  def new_node_routine(deposit)
    new_node = Node.new deposit[:user], deposit[:amount], deposit[:time]
    log "Created new node for #{new_node.uid} based on transaction at #{new_node.time} with initial balance #{new_node.balance} at #{Time.now}"
  end

  def get_deposits
    #get_journal
    [{:user => "tom", :time => "00:20", :amount => 20000000},
     {:user => "joker", :time => "10:10", :amount => 1},
     {:user => "legit", :time => "20:20", :amount => 10000000}]
  end

  def get_journal
    get_xml
  end

  def get_xml

  end

  def save_banker
    File.open(BANKER_LOCATION + @banker, 'w') { |file|
      file.puts YAML::dump(self)
    }
  end

  def log(msg)
    @log << msg + "\n"
  end

  def get_log
    @log
  end

  def sanitize_string(input)
    if input.class == String
      input.gsub(/[^0-9a-z :]/i, '') if input.class == String
    else
      input
    end
  end
end