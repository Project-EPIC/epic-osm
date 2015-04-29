#
# A realtime module to incorporate Mikel's additions & formalize the monkey-patching
#
# Right now it works up to the hour
#
require 'yaml'

module Realtime
  def updateYAML(yaml_file)
    config = YAML.load(File.read(yaml_file))

    step = config['realtime_step']

    time_now = Time.now()
    new_end = Time.mktime(time_now.year, time_now.mon, time_now.day, time_now.hour, 0, 0)
    new_start_time = time_now - (step * 60 * 60)
    new_start = Time.mktime(new_start_time.year, new_start_time.mon, new_start_time.day, new_start_time.hour, 0, 0)

    puts "New Start: #{new_start}"
    puts "New End:   #{new_end}"

    config['start_date'] = new_start
    config['end_date']   = new_end

    dir = config['write_directory'].split('/')
    dir.pop

    config['write_directory'] = dir.join('/') +"/#{time_now.year}_#{time_now.mon}_#{time_now.day}_#{time_now.hour}"

    File.open(yaml_file, 'wb') do |out|
      out.write(config.to_yaml)
    end
  end
end
