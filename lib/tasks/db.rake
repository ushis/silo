namespace :db do

  task clean: :environment do
    Rails.application.eager_load!
    destroy_orphaned_tags
  end

  # Destroys all orphaned tags and sweeps the related caches.
  def destroy_orphaned_tags
    sweeper = TagSweeper.send(:new)
    sweeper.send(:controller=, ActionController::Base.new)

    klasses = ActiveRecord::Base.descendants.select do |klass|
      klass.respond_to?(:acts_as_tag?) && klass.acts_as_tag?
    end

    klasses.each do |klass|
      relation = klass

      klass.reflect_on_all_associations(:has_and_belongs_to_many).each do |ref|
        relation = relation.where <<-SQL
          #{klass.table_name}.id NOT IN (
            SELECT DISTINCT join_table.#{ref.foreign_key}
            FROM #{ref.options[:join_table]} join_table
          )
        SQL
      end

      ActiveRecord::Base.connection.transaction do
        relation.each do |record|
          puts "Destroy #{klass.name}: #{record.to_s}"

          if record.destroy
            sweeper.expire_caches_for(record)
          end
        end
      end
    end
  end
end
