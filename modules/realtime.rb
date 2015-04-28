#
# A realtime module to incorporate Mikel's additions & formalize the monkey-patching
#
# Right now it works up to the hour
#
require 'yaml'

def updateYAML(yaml_file, outfile)
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

  File.open(outfile, 'wb') do |out|
    out.write(config.to_yaml)
  end

end

if __FILE__ == $0
  puts "running realtime module"

  updateYAML('/Users/jenningsanderson/Dropbox/AAG/analysis_windows/boulder.yml',
             '/Users/jenningsanderson/Dropbox/AAG/analysis_windows/boulder_2.yml')


end
