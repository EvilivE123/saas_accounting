module Accounts
  class SeedService
    def initialize(organization)
      @organization = organization
    end

    # The default hierarchical structure for the 5 Accounting Pillars
    # using standard numbering conventions (1000s, 2000s, etc.)
    DEFAULT_CHART_OF_ACCOUNTS = [
      {
        name: 'Assets', code: '1000', account_type: :asset,
        children: [
          { name: 'Current Assets', code: '1100', account_type: :asset,
            children: [
              { name: 'Cash', code: '1110', account_type: :asset },
              { name: 'Accounts Receivable', code: '1120', account_type: :asset }
            ]
          },
          { name: 'Fixed Assets', code: '1200', account_type: :asset }
        ]
      },
      {
        name: 'Liabilities', code: '2000', account_type: :liability,
        children: [
          { name: 'Current Liabilities', code: '2100', account_type: :liability,
            children: [
              { name: 'Accounts Payable', code: '2110', account_type: :liability }
            ]
          }
        ]
      },
      {
        name: 'Equity', code: '3000', account_type: :equity,
        children: [
          { name: 'Retained Earnings', code: '3100', account_type: :equity },
          { name: 'Owner Contribution', code: '3200', account_type: :equity }
        ]
      },
      {
        name: 'Revenue', code: '4000', account_type: :revenue,
        children: [
          { name: 'Sales Revenue', code: '4100', account_type: :revenue },
          { name: 'Service Revenue', code: '4200', account_type: :revenue }
        ]
      },
      {
        name: 'Expenses', code: '5000', account_type: :expense,
        children: [
          { name: 'Operating Expenses', code: '5100', account_type: :expense,
            children: [
              { name: 'Rent Expense', code: '5110', account_type: :expense },
              { name: 'Utilities Expense', code: '5120', account_type: :expense },
              { name: 'Salaries Expense', code: '5130', account_type: :expense }
            ]
          }
        ]
      }
    ].freeze
  
        # The public execution method
    def call
      ActiveRecord::Base.transaction do
        build_account_tree(DEFAULT_CHART_OF_ACCOUNTS)
      end
    end

    private

    # Recursively builds the parent/child account relationships
    def build_account_tree(account_nodes, parent_account = nil)
      account_nodes.each do |node_data|
        
        # We explicitly build off the organization's association.
        # The Tenantable concern (Phase 1) will also ensure the tenant scope is respected.
        account = @organization.accounts.create!(
          name: node_data[:name],
          code: node_data[:code],
          account_type: node_data[:account_type],
          parent: parent_account
        )

        # If this node has children, recurse and pass the newly created account as the parent
        if node_data[:children].present?
          build_account_tree(node_data[:children], account)
        end
      end
    end
  end
end
