class AddGuildConfigs < ActiveRecord::Migration
  def self.up
    create_table :guild_configs, :force => true do |t|
      t.belongs_to :guild, :null => false
      t.column :m_join_code, :string
      t.column :c_default_start_time, :datetime
      t.timestamps
    end
  end

  def self.down
    drop_table :guild_configs
  end
end
