require 'date'

module WeeklySchedule

  VERSION = '0.0.5'

  def schedule(options = {})

    defaults = {
      :table_class => 'calendar',
      :month_name_class => 'monthName',
      :day_name_class => 'dayName',
      :day_class => 'day',
      :abbrev => (0..2),
      :first_day_of_week => 0,
      :show_today => true,
      :previous_text => nil,
      :next_text => nil,
      :only_workdays => false,
      :empty_message => 'Nothing to do this week.',
      :date_format => :short
    }
    options = defaults.merge options

    first = first_weekday(options)
    last = last_weekday(options, first)

    # Rotate to the correct day names
    if (options[:only_workdays])
      day_names = Date::DAYNAMES.dup[1..5]
    else
      day_names = Date::DAYNAMES.dup
      options[:first_day_of_week].times do
        day_names.push(day_names.shift)
      end
    end

    #if options.include?(:show)
      # options[:show] exists, the schedule is used as a task list
      # if no tasks exist, the message is displayed instead of the schedule

      #if options[:show].blank?
        # nothing to show? die!
      #  cal = %{#{options[:empty_message]}}
      #  return cal
      #end
    #end

    cal = %(<table class="#{options[:table_class]}" border="0" cellspacing="0" cellpadding="0">)
    cal << %(<thead><tr class="#{options[:day_name_class]}">)
    day_names.each do |d|
      day = first + day_names.index(d)
      unless d[options[:abbrev]].eql? d
        cal << "<th scope='col'><abbr title='#{d}'>#{d[options[:abbrev]]}</abbr>"
        cal << "<br/>#{l day, :format => options[:date_format]}"
        cal << "</th>"
      else
        cal << "<th scope='col'>#{d[options[:abbrev]]}"
        cal << "<br/>#{l day, :format => options[:date_format]}"
        cal << "</th>"
      end
    end

    cal << "</tr></thead><tbody><tr>"

    # This code generates all output for dates that are in the current week
    first.upto(last) do |cur|
      cell_text  ||= details(cur, options)
      cell_attrs ||= {}
      cell_attrs[:class] ||= options[:day_class]
      cell_attrs[:class] += " weekendDay" if [0, 6].include?(cur.wday)
      cell_attrs[:class] += " today" if (cur == (Time.respond_to?(:zone) ? Time.zone.now.to_date : Date.today)) and options[:show_today]
      cell_attrs = cell_attrs.map {|k, v| %(#{k}="#{v}") }.join(" ")
      cal << "<td #{cell_attrs}>#{cell_text}</td>"
    end

    cal << "</tr></tbody></table>"

    return cal
  end

  def first_weekday(options)
    options[:day] ||= Date.today
    # The week to display starts at the first day
    if (options[:only_workdays])
      if (options[:day].cwday > 5) # If today is not a weekday, we'll display the following week
        first = options[:day].monday + 7
      else
        first = options[:day].monday
      end
    else
      difference = options[:first_day_of_week] - options[:day].cwday
      if (difference > 0)
        # day is after first day of week
        first = (options[:day] - (7 - difference))
      else
        # day is before first day of week
        first = options[:day] + difference
      end
    end
  end

  def last_weekday(options, first)
    if (options[:only_workdays])
      last = first + 4
    else
      last = first + 6
    end
  end

  def details(date, options)
    if options[:show]
      # Place your code here
    else
      date.mday
    end
  end

end
