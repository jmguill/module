require './lib/report.rb'
require './lib/node.rb'
require 'fileutils'

class Reporter
  PENDING_REPORT_LOCATION = "/tmp/pending_reports/"

  def initialize
    @log = ""
  end

  def main_routine
    log 'Reporter starting.'
    while true
      report = get_next_report_request
      if report
        run_report report
        sleep 2
      else
        sleep 1
      end
    end
  end

  def run_report(report)
    report_body, report_result = do_report_sequence(report)
    log "Report #{report.report_id} result: #{report_result.to_s}."
    report.set_report_body report_body, report_result
    update_node report
  end

  def update_node(report)
    node = Node.load_node(report.owner)
    begin
      node.debit_node report.cost, 'Ran successful report' if report.result == :success
      log "Debited node #{node} #{report.cost} units."
    rescue RuntimeError
      return nil
    end
    node.append_report(report.target, report.report_id, Time.now)
  end

  def do_report_sequence(report)
    #get_corp_history
    #get_pvp_stats

    report = "This is a report for character #{report.target} commissioned by node #{report.owner} and cost #{report.cost} units"
    return report, :success
  end


  def get_next_report_request
    dir_list = files_by_ctime
    if dir_list.size == 0
      nil
    else
      report_file = dir_list.first.split('/').last
      report = Report.load_report(report_file, :pending)
      FileUtils.rm(dir_list.first)
      log "Fetching report #{report.report_id} out of #{dir_list.size} total reports."
      report
    end
  end

  def files_by_ctime
    Dir[PENDING_REPORT_LOCATION  + '*'].sort_by{ |f| File.ctime(f) }
  end

  def log(msg)
    #@log << msg + "\n"
    puts msg
  end

end