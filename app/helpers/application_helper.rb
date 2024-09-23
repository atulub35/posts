module ApplicationHelper
  def time_ago(time, zone=nil)
    return '' if zone.blank?
    now  = Time.now
    time = time.in_time_zone(zone) if zone
    now = now.in_time_zone(zone) if zone
    diff = (now - time)
    case diff
    when 0 .. 1.hour
      "#{(diff/60).to_i} minutes ago"
    when 1.hour .. 1.day
      "#{pluralize((diff/(60*60)).to_i, 'hour')} ago"
    when 1.day .. 1.month
      days  = (diff/(60*60*24)).to_i
      "#{pluralize(days,'day')} ago"
    when 1.month .. 1.year
      "#{pluralize((diff/(60*60*24*30)).to_i,'month')} ago"
    else
      full_date_time(time, zone)
    end
  end

  def full_date_time(time, zone=nil)
    time = time.in_time_zone(zone) if zone
    "#{us_date_format(time)} #{time.strftime('%I:%M %p')}"
  end

end
