require 'digest/md5'

class Report
  FINISHED_REPORT_LOCATION = "/tmp/finished_reports/"
  PENDING_REPORT_LOCATION = "/tmp/pending_reports/"
  HASH_SALT = 'MD5 is a one-way hashing algorithm'

  def self.load_report(report_id)
    File.open(REPORT_LOCATION + report_id, 'r') { |file|
      YAML::load(file)
    }
  end

  attr_reader :owner, :target, :creation, :completed, :report_id
  def initialize(uid, target)
    @owner = uid
    @target = sanitize_string target
    @report_body = nil
    @creation = Time.now
    @completed = nil
    @report_id =  Digest::MD5.hexdigest(@owner + HASH_SALT + @creation.to_s)
    save_report(PENDING_REPORT_LOCATION)
  end

  def set_report_body(report_body)
    @report_body = report_body
    @completed = Time.now
    save_report(FINISHED_REPORT_LOCATION)
  end

  def get_report
    if @report_body
      @report_body
    else
      nil
    end
  end

  def save_report(prefix)
    File.open(prefix+ @report_id, 'w') { |file|
      file.puts YAML::dump(self)
    }
  end

  def sanitize_string(input)
    if input.class == String
      input.gsub(/[^0-9a-z ]/i, '')
    else
      input
    end
  end

end