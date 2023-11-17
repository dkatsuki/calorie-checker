class Staffs::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      resource.approved = false
    end
  end
end
