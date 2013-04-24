require './lib/banker.rb'

case ARGV[0]
  when "init"
    banker = Banker.new ARGV[1], ARGV[2].to_i
    puts banker.get_log
  when "run"
    banker = Banker.load_banker ARGV[1]
    banker.main_routine
    puts banker.get_log
  else
    puts "init name amount or run name"
end