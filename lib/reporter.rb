require './lib/report.rb'
require './lib/node.rb'
require 'fileutils'

class Reporter
  PENDING_REPORT_LOCATION = "/tmp/pending_reports/"

  def initialize
    @log = ""
  end

  def main_routine
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
    report.set_report_body report_body, report_result
    update_node report
  end

  def update_node(report)
    node = Node.load_node(report.owner)
    begin
      node.debit_node report.cost, 'Ran successful report' if report.result == :success
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
      report
    end
  end

  def files_by_ctime
    Dir[PENDING_REPORT_LOCATION  + '*'].sort_by{ |f| File.ctime(f) }
  end

  def log(msg)
    @log << msg + "\n"
  end

end