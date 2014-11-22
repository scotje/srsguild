module EventsHelper

  def calendar_event_link(event)
    "<a href=\"#\" id=\"event_link_#{event.id}\" onclick=\"return false;\">#{event.begins_at.strftime("%H:%M")}</a>\n"
  end
  
  def calendar_signup_role_options
    [
      ['', ''],
      ['Tank', 'tank'],
      ['Healer', 'healer'],
      ['Melee DPS', 'melee_dps'],
      ['Ranged DPS', 'range_dps']
    ]
  end
  
  def printable_role_preference(pref)
    return case pref
      when 'tank' then "Tank"
      when 'healer' then "Healer"
      when 'melee_dps' then "Melee DPS"
      when 'range_dps' then "Ranged DPS"
      else "--"
    end
  end
  
  def p_truncated_at(str, len)
    if str.blank?
			return "<p>--</p>"
		else
			if str.length > len
				"<p title=\"#{html_escape(str)}\">#{html_escape(str[0,len])}...</p>"
			else
				"<p>#{html_escape(str)}</p>"
			end
		end
  end
  
  def show_signups_link(str)
		return link_to_function(str, nil) do |page|
	    page[:calendar_all_signups].show
	    page[:event_past_notice].hide
	  end
  end
end
