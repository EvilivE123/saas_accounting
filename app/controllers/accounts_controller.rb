class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  before_action :authorize_admin!, except: [:index, :show]

  def index
    # Group accounts by type for a structured view
    @accounts = Current.organization.accounts.order(:code).group_by(&:account_type)
  end

  def show
  end

  def new
    @account = Current.organization.accounts.build
  end

  def edit
  end

  def create
    @account = Current.organization.accounts.build(account_params)

    respond_to do |format|
      if @account.save
        format.html { redirect_to accounts_path, notice: 'Account was successfully created.' }
        format.json { render_json_success('Account created.', @account, :created) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render_json_error(@account.errors.full_messages) }
      end
    end
  end

  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to accounts_path, notice: 'Account was successfully updated.' }
        format.json { render_json_success('Account updated.', @account) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render_json_error(@account.errors.full_messages) }
      end
    end
  end

  def destroy
    # Active Record will prevent destruction if `restrict_with_error` is triggered by child journal items
    if @account.destroy
      respond_to do |format|
        format.html { redirect_to accounts_path, notice: 'Account was successfully deleted.' }
        format.json { render_json_success('Account deleted.') }
      end
    else
      respond_to do |format|
        format.html { redirect_to accounts_path, alert: @account.errors.full_messages.join(", ") }
        format.json { render_json_error(@account.errors.full_messages) }
      end
    end
  end

  private

  def set_account
    @account = Current.organization.accounts.find(params[:id])
  end

  def account_params
    params.require(:account).permit(:name, :code, :account_type, :description, :parent_id, :is_active)
  end

  def authorize_admin!
    unless current_user.org_admin? || current_user.system_admin?
      respond_to do |format|
        format.html { redirect_to accounts_path, alert: 'You are not authorized to modify the Chart of Accounts.' }
        format.json { render_json_error('Unauthorized', :forbidden) }
      end
    end
  end
end
