require './lib/reporter.rb'

case ARGV[0]
  when "run"
    reporter = Reporter.new
    reporter.main_routine
  else
    puts "run"
end
