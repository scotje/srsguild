xml.instruct!
xml.realms do
  @realms.each do |r|
    xml.realm do
      xml.region r.region
      xml.subregion r.subregion
      xml.name r.name
      xml.realm_type r.realm_type
    end
  end
end