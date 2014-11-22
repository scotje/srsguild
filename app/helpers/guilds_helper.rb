module GuildsHelper
  def roster_breakdown_chart(guild)
    # Death Knight	 196	 30	 59	 0.77	 0.12	 0.23	 #C41F3B	 Red
    # Druid	 255	 125	 10	 1.00	 0.49	 0.04	 #FF7D0A	 Orange
    # Hunter	 171	 212	 115	 0.67	 0.83	 0.45	 #ABD473	 Green
    # Mage	 105	 204	 240	 0.41	 0.80	 0.94	 #69CCF0	 Light blue
    # Paladin	 245	 140	 186	 0.96	 0.55	 0.73	 #F58CBA	 Pink
    # Priest	 255	 255	 255	 1.00	 1.00	 1.00	 #FFFFFF	 White
    # Rogue	 255	 245	 105	 1.00	 0.96	 0.41	 #FFF569	 Yellow
    # Shaman	 36	 89	 255	 0.14	 0.35	 1.00	 #2459FF	 Blue
    # Warlock	 148	 130	 201	 0.58	 0.51	 0.79	 #9482C9	 Purple
    # Warrior	 199	 156	 110	 0.78	 0.61	 0.43	 #C79C6E	 Tan
    
    data_labels = ['Death Knight', 'Druid', 'Hunter', 'Mage', 'Paladin', 'Priest', 'Rogue', 'Shaman', 'Warlock', 'Warrior']
    
    main_data = Array.new
    alt_data = Array.new
    max_sum = 0

    data_labels.each do |char_class|
      main_data << guild.class_count(char_class, true)
      alt_data << guild.class_count(char_class, false)
      
      sum = guild.class_count(char_class, true) + guild.class_count(char_class, false)
      
      max_sum = sum if sum > max_sum
    end
    
    max_sum = 12 if max_sum < 12
    
    main_colors =   ['C41F3B', 'FF7D0A', 'ABD473', '69CCF0', 'F58CBA', 'b3b3b3', 'FFF569', '2459FF', '9482C9', 'C79C6E']
    total_colors =  ['eb8092', 'ffc592', 'e9f4db', 'e5f6fc', 'facadf', 'd5d5d5', 'fffccf', 'acc0ff', 'd1c9e8', 'e3ceb8']

    
    
    return "<img src=\"http://chart.apis.google.com/chart?chxr=0,0,#{max_sum}&chxt=x,y&chbh=20,5&chs=700x300&cht=bhs&chco=#{main_colors.join('|')},#{total_colors.join('|')}&chds=0,#{max_sum},0,#{max_sum}&chd=t:#{main_data.join(',')}|#{alt_data.join(',')}&chma=|0,5&chtt=Class+Breakdown&chxl=1:|#{data_labels.reverse.join('|').gsub(' ', '+')}\" width=\"700\" height=\"300\" alt=\"Class Breakdown\" />"
    
  end
  
end
