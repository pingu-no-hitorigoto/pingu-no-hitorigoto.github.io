# require 'tzinfo';
require 'active_support/values/time_zone';

module Jekyll
  module ZonedFilter
    def zoned(date, tz = @context.registers[:site].config['timezone'])
      # puts date
      # puts tz
      tz = ActiveSupport::TimeZone.new(tz)
      # puts tz.utc_offset
      date = tz.utc_to_local(time(date))
      # tz = TZInfo::Timezone.get(tz)
      # puts tz
      # date = tz.to_local(time(date))
    end
  end
end

Liquid::Template.register_filter(Jekyll::ZonedFilter)