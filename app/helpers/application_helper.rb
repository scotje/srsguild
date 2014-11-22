# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end
  
  def error_message_for_field(field_name)
    if flash[:errors] and flash[:errors][field_name]
			"<div class=\"field_error\">#{flash[:errors][field_name]}</div>\n"
    end
  end
  
  def center_buttons(options = {}, &block)
    render(:layout => 'shared/center_buttons', :locals => options, &block)
  end
  
  def is_guild_admin?(user)
    ((@_GUILD.owner == user) or (user.main_character and (user.main_character.guild == @_GUILD) and user.main_character.is_admin))
  end
  
  def character_classes
    [
      "Death Knight",
      "Druid",
      "Hunter",
      "Mage",
      "Paladin",
      "Priest",
      "Rogue",
      "Shaman",
      "Warlock",
      "Warrior"
    ]
  end
  
  def character_races
    [
      'Blood Elf',
      'Draenei',
      'Dwarf',
      'Gnome',
      'Goblin',
      'Human',
      'Night Elf',
      'Orc',
      'Tauren',
      'Troll',
      'Undead',
      'Worgen' 
    ]
  end
  
  def character_class_with_colorbox(cl, opts={})
    position = opts[:position] || 'before'

    if position == 'before'
      "<span class=\"#{cl.gsub(/[^\w]/, '').downcase}\">&#9608;</span> #{cl}"
    else
      "#{cl} <span class=\"#{cl.gsub(/[^\w]/, '').downcase}\">&#9608;</span>"
    end
  end
  
  def character_class_colorbox(cl)
    "<span class=\"#{cl.gsub(/[^\w]/, '').downcase}\">&#9608;</span>"
  end

  def options_for_realm_regions(selected = nil)
    html = String.new
    
    ["US", "EU"].each do |region|
      if region == selected
        html << "<option value=\"#{region}\" selected=\"selected\">#{region}</option>\n"
      else
        html << "<option value=\"#{region}\">#{region}</option>\n"
      end
    end
    
    return html
  end
  
  def options_for_realms_us(selected = nil)
    html = String.new
    
    ['Pacific', 'Mountain', 'Central', 'Eastern', 'Oceania', 'Latin America'].each do |tz|
      html << "<optgroup label=\"#{tz}\">\n"

      Realm.game('worldofwarcraft').region('us').subregion(tz).find(:all, :order => 'name ASC').each do |realm|
        if realm.name == selected
          html << "\t<option value=\"#{realm.name}\" selected=\"selected\">#{realm.name} (#{realm.realm_type.upcase})</option>\n"
        else
          html << "\t<option value=\"#{realm.name}\">#{realm.name} (#{realm.realm_type.upcase})</option>\n"
        end
      end 

      html << "</optgroup>\n\n"
    end
    
    return html
  end
  
  def options_for_realms_eu
  end
  
  def char_guild_name(char)
    if char.guild.nil?
			unless char.armory_guild.blank?
				"<h5 class=\"GuildName\">&lt;#{char.armory_guild}&gt; (Unconfirmed)</h5>\n"
			end
		else
		  guild_name(char.guild)
		end
  end
  
  def guild_name(guild)
    "<h5 class=\"GuildName\">&lt;" + link_to(guild.name, guild_url) + "&gt; (#{guild.realm})</h5>\n"
	end
end
