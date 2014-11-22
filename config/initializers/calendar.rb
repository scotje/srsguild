module WeeklySchedule
  def details(date, options)
    if options[:show]

      raids = options[:show].select do |r|
        r.begins_at.strftime("%Y-%m-%d") == Time.parse(date.to_s).strftime("%Y-%m-%d")
      end

      raids = raids.sort_by{|r| r.begins_at}

      links = raids.map do |r|
        if options[:admin]
          "<p class=\"calendar_event\">#{admin_calendar_event_link(r)}</p>"
        else
          "<p class=\"calendar_event\">#{calendar_event_link(r)}</p>"
        end
      end

      links.join("\n")
    else
      date.mday
    end
  end
end
