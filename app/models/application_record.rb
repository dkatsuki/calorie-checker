class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def self.search(params = nil)
    self.all
  end

  def get_association_class(association_name)
    association_reflection = self.class.reflect_on_all_associations.find do |association_reflection|
      association_reflection.name == association_name
    end

    association_reflection&.plural_name.classify.safe_constantize
  end
end
