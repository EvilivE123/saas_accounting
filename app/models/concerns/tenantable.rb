module Tenantable
  extend ActiveSupport::Concern

  included do
    # Automatically filter queries to the current organization
    default_scope { where(organization_id: Current.organization.id) if Current.organization.present? }
    
    # Automatically assign the organization upon record creation
    before_validation :set_tenant_on_create, on: :create
  end

  private

  def set_tenant_on_create
    self.organization_id ||= Current.organization.id if Current.organization.present?
  end
end