module ApplicationHelper
  include Pagy::Frontend
  
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

  # Override pagy_nav method
  def pagy_nav(pagy)
    html = %(<nav class="custom-pagy-nav" aria-label="pager">)
    html << '<ul class="pagination">'

    # Previous button
    if pagy.prev
      html << %(<li class="page-item">#{link_to 'Previous', url_for(page: pagy.prev), class: 'page-link', data: { turbo_stream: "" }}</li>)
    else
      html << '<li class="page-item disabled"><span class="page-link">Previous</span></li>'
    end

    # Page numbers
    pagy.series.each do |item|
      if item.is_a?(Integer)
        html << %(<li class="page-item #{'active' if item == pagy.page}">#{link_to item, url_for(page: item), class: 'page-link', data: { turbo_stream: "" }}</li>)
      elsif item.is_a?(String)
        html << %(<li class="page-item disabled"><span class="page-link">#{item}</span></li>)
      end
    end

    # Next button
    if pagy.next
      html << %(<li class="page-item">#{link_to 'Next', url_for(page: pagy.next), class: 'page-link', data: { turbo_stream: "" }}</li>)
    else
      html << '<li class="page-item disabled"><span class="page-link">Next</span></li>'
    end

    html << '</ul>'
    html << '</nav>'
    html.html_safe
  end

  def vc(component_class, **kwargs, &block)
    render component_class.new(**kwargs), &block
  end
  
end
