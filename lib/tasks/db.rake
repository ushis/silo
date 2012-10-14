namespace :db do

  task clean: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      DELETE FROM businesses
      WHERE businesses.id NOT IN (
        SELECT DISTINCT bp.business_id
        FROM businesses_partners bp
      )
    SQL
  end
end
