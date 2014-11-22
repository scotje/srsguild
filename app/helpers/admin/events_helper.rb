module Admin::EventsHelper

  def admin_calendar_event_link(event)
    return link_to(event.begins_at.strftime("%H:%M"), admin_event_url(event), :title => event.title)
  end
end