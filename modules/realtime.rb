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
    new_start = Time.mktime(time_now.year, time_now.mon, time_now.day, time_now.hour, 0, 0)
    new_end = time_now

    puts "New Start: #{new_start}"
    puts "New End:   #{new_end}"

    config['start_date'] = new_start
    config['end_date']   = new_end

    dir = config['write_directory'].split('/')
    dir.pop

    config['write_directory'] = dir.join('/') +"/#{new_start.year}_#{new_start.mon}_#{new_start.day}_#{new_start.hour}"

    File.open(yaml_file, 'wb') do |out|
      out.write(config.to_yaml)
    end
  end
end
