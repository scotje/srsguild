class Admin::DashboardsController < Admin::AdminController

  def show
    @near_events = @_GUILD.calendar_events.find(:all, :conditions => ["begins_at < ?", Time.new], :order => "begins_at DESC", :limit => 5, :include => [:calendar_event_attendances, :calendar_event_signups]).reverse
    @near_events << "now"
    @near_events += @_GUILD.calendar_events.find(:all, :conditions => ["begins_at > ?", Time.new], :order => "begins_at ASC", :limit => 5, :include => [:calendar_event_attendances, :calendar_event_signups])
  end
end
