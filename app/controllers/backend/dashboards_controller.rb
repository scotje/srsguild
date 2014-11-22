class Backend::DashboardsController < Backend::BackendController
  
  def show
    @real_account_stats = Account.find_by_sql("SELECT COUNT(DISTINCT id) AS total_accounts, COUNT( DISTINCT IF( created_at > DATE_ADD( UTC_TIMESTAMP( ) , INTERVAL -24 HOUR ) , id, NULL ) ) AS new_last_24, COUNT( DISTINCT IF( created_at > DATE_ADD( UTC_TIMESTAMP( ) , INTERVAL -1 MONTH ) , id, NULL ) ) AS new_last_month, COUNT( DISTINCT IF( created_at > DATE_ADD( UTC_TIMESTAMP( ) , INTERVAL -1 QUARTER ) , id, NULL ) ) AS new_this_quarter FROM  `accounts` WHERE email NOT LIKE '%\@srsguild.com'").first
    @real_guild_stats = Guild.find_by_sql("SELECT COUNT(DISTINCT guilds.id) AS total_guilds, COUNT( DISTINCT IF( guilds.created_at > DATE_ADD( UTC_TIMESTAMP( ) , INTERVAL -24 HOUR ) , guilds.id, NULL ) ) AS new_last_24, COUNT( DISTINCT IF( guilds.created_at > DATE_ADD( UTC_TIMESTAMP( ) , INTERVAL -1 MONTH ) , guilds.id, NULL ) ) AS new_last_month, COUNT( DISTINCT IF( guilds.created_at > DATE_ADD( UTC_TIMESTAMP( ) , INTERVAL -1 QUARTER ) , guilds.id, NULL ) ) AS new_this_quarter, COUNT(DISTINCT accounts.id)/COUNT(DISTINCT guilds.id) AS avg_accounts_per_guild, COUNT(DISTINCT characters.id)/COUNT(DISTINCT guilds.id) AS avg_chars_per_guild FROM (guilds INNER JOIN (characters LEFT JOIN accounts ON characters.account_id = accounts.id) ON guilds.id = characters.guild_id) WHERE accounts.email NOT LIKE '%\@srsguild.com'").first
    @real_char_stats = Character.find_by_sql("SELECT COUNT(DISTINCT characters.id)/COUNT(DISTINCT accounts.id) AS avg_chars_per_account FROM characters LEFT JOIN accounts ON (characters.account_id = accounts.id) WHERE accounts.email NOT LIKE '%\@srsguild.com'").first
    
    # SELECT COUNT( DISTINCT IF( created_at > DATE_ADD( UTC_TIMESTAMP( ) , INTERVAL -24 HOUR ) , id, NULL ) ) AS new_last_24, COUNT( DISTINCT IF( created_at > DATE_ADD( UTC_TIMESTAMP( ) , INTERVAL -1
    # MONTH ) , id, NULL ) ) AS new_last_month, COUNT( DISTINCT IF( created_at > DATE_ADD( UTC_TIMESTAMP( ) , INTERVAL -1QUARTER ) , id, NULL ) ) AS new_this_quarter
    # FROM  `accounts` 
    # WHERE 1
  end
end
