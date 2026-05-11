# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)

    ActiveRecord::Base.transaction do
      # 1. Provision Organization
      organization = Organization.create!(
        name: params[:user][:organization_name],
        base_currency: params[:user][:base_currency] || 'INR'
      )

      # ----------------------------------------------------
      # NEW: 1.5 Scaffold the Default Chart of Accounts
      # ----------------------------------------------------
      Accounts::SeedService.new(organization).call      
      
      # 2. Assign Context & Elevated Role
      resource.organization = organization
      resource.role = :org_admin
      # 3. Save User
      resource.save!
    end

    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  rescue ActiveRecord::RecordInvalid => e
    clean_up_passwords resource
    set_minimum_password_length
    respond_with resource
  end
end