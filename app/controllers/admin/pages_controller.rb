class Admin::PagesController < Admin::ApplicationController
  def top
    @models = ActiveRecord::Base.connection.tables.map(&:classify).map(&:safe_constantize).compact
    @table_names = @models.map(&:name).map(&:tableize)
  end
end
