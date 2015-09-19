require 'rufus-scheduler'
require 'date'
require 'limitless_led'

# Date helper
class Date
  def dayname
     DAYNAMES[self.wday]
  end
end

# settings
@alarm_hour = 6 # hour value (0..23) of the time you wake up
@alarm_min = 40 # minute value (0..59) of the time you wake up
@light_modifier = 27 # change this to the max brightness value
@bridges = []

(0..2).to_a.each do |i|
    (2..30).to_a.each do |j|
        puts "bridge created: 192.168.#{i}.#{j}"
        @bridges.push(LimitlessLed::Bridge.new(host: "192.168.#{i}.#{j}", port: 8899))
    end
end

puts '-----------------------------------------'

# run forever
while true do
    begin
        d = Date.today
        t = Time.now

        puts "DATE/TIME:\t#{d.dayname} - #{t.hour}:#{t.min}:#{t.sec}"

        if (!d.saturday? && !d.sunday?) && (t.hour == @alarm_hour) && (t.min >= (@alarm_min - @light_modifier) && t.min <= @alarm_min)
            brightness = t.min - @light_modifier
            puts "STATUS:\t\tLights turned on to brightness: #{brightness}"
            @bridges.each do |bridge|
                3.times do
                    group = bridge.group(1)
                    group.color 'White'
                    group.brightness(brightness)
                end
            end
        else
            puts "STATUS:\t\tLights set turned off"
            @bridges.each do |bridge|
                3.times do
                    bridge.all_off
                end
            end
        end
    rescue Exception => e
        puts "ERROR:\t\t#{e.to_s}"
    end

    puts '-----------------------------------------'
    sleep 3
end
