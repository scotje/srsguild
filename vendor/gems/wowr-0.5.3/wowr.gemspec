--- !ruby/object:Gem::Specification 
name: wowr
version: !ruby/object:Gem::Version 
  hash: 13
  prerelease: false
  segments: 
  - 0
  - 5
  - 3
  version: 0.5.3
platform: ruby
authors: 
- Ben Humphreys
- Peter Wood
- Renaud Chaput
- Ken Preudhomme
autorequire: 
bindir: bin
cert_chain: []

date: 2009-04-04 00:00:00 -07:00
default_executable: 
dependencies: []

description: Wowr is a Ruby library for accessing data in the World of Warcraft Armory. It provides an object-oriented interface to the XML data provided by the armory, giving access to items, characters, guilds and arena teams. It is designed for both single users and larger guild or portal sites for many users.
email: peter+wowr@alastria.net
executables: []

extensions: []

extra_rdoc_files: 
- README
files: 
- VERSION.yml
- lib/wowr/calendar.rb
- lib/wowr/exceptions.rb
- lib/wowr/dungeon.rb
- lib/wowr/arena_team.rb
- lib/wowr/character.rb
- lib/wowr/achievements.rb
- lib/wowr/guild.rb
- lib/wowr/guild_bank.rb
- lib/wowr/general.rb
- lib/wowr/extensions.rb
- lib/wowr/item.rb
- lib/wowr.rb
- test/xml/dungeonStrings.xml
- test/xml/armory_search.xml
- test/xml/character-talents.xml
- test/xml/itemSearch.xml
- test/xml/character_info.xml
- test/xml/arena_team_single.xml
- test/xml/character-reputation.xml
- test/xml/example.xml
- test/xml/item-tooltip.xml
- test/xml/item_search.xml
- test/xml/character-sheet.xml
- test/xml/benedictt.xml
- test/xml/armory-search.xml
- test/xml/item-info.xml
- test/xml/arena_team_search.xml
- test/xml/character-skills.xml
- test/xml/character_search.xml
- test/xml/guild-info.xml
- test/xml/dungeons.xml
- test/wowr_item_test.rb
- test/wowr_dungeon_test.rb
- test/wowr_character_test.rb
- test/wowr_arena_team_test.rb
- test/wowr_guild_test.rb
- test/wowr_test.rb
- README
has_rdoc: true
homepage: http://wowr.rubyforge.org/
licenses: []

post_install_message: 
rdoc_options: 
- --inline-source
- --charset=UTF-8
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
requirements: []

rubyforge_project: wowr
rubygems_version: 1.3.7
signing_key: 
specification_version: 2
summary: A Ruby library for the World of Warcraft Armory
test_files: []

