Rails.application.routes.draw do
  # 1. This tells Devise to use YOUR controller instead of the default
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }

  # 2. Authenticated State Routing
  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
    
    # Financial Operations
    resources :journal_entries, only: [:index, :new, :create, :show]
    
    # API endpoints for dynamic frontend widgets
    # General Ledger Access
    resources :general_ledgers, only: [:index, :show]

    # Reporting Routes
    resources :reports, only: [] do
      collection do
        get :trial_balance
        get :profit_and_loss
        get :balance_sheet
      end
    end

    resources :accounts

    # Singular resource because it relates to Current.organization
    resource :organization, only: [:show, :edit, :update], path: 'settings'
  end


  # 3. Unauthenticated State Routing
  devise_scope :user do
    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end

# =========================================================
  # CATCH-ALL ROUTE (Must be the very last route in the file)
  # =========================================================
  # Redirects any unmatched/random URL string back to the root path
  match '*unmatched', to: redirect('/'), via: :all
end