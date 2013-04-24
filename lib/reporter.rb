require '../lib/report.rb'
require 'fileutils'

class Reporter
  PENDING_REPORT_LOCATION = "/tmp/pending_reports/"

  def initialize

  end

  def main_routine
    while true
      run_report get_next_report_request
    end
  end

  def run_report(report)
    report.set_report_body do_report_sequence(report)
  end

  def do_report_sequence(report)
    #get_corp_history
    #get_pvp_stats
  end


  def get_next_report_request
    dir_list = Report.load_report(files_by_ctime)
    report_file = dir_list.first.split('/').last
    FileUtils.rm(dir_list.first)
    report_file
  end

  def files_by_ctime
    Dir[PENDING_REPORT_LOCATION  + "*"].sort_by{ |f| File.ctime(f) }
  end

end