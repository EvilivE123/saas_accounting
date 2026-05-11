class OrganizationsController < ApplicationController
  # Note: No ID lookup is required because we implicitly trust the Current context
  
  def show
    @organization = Current.organization
  end

  def edit
    @organization = Current.organization
  end

  def update
    @organization = Current.organization
    
    if @organization.update(organization_params)
      redirect_to organization_path, notice: 'Organization settings were successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :base_currency, :fiscal_year_start)
  end
end