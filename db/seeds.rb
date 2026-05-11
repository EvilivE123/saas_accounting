puts "🌱 Bootstrapping Database..."

ActiveRecord::Base.transaction do
  # -------------------------------------------------------------------
  # 1. Create the Default Organization
  # -------------------------------------------------------------------
  org = Organization.find_or_create_by!(name: "Sample Indian Organization") do |o|
    o.base_currency = "INR"
    o.fiscal_year_start = Date.new(Date.current.year, 1, 1)
  end
  puts "✅ Organization Verified: #{org.name}"

  # -------------------------------------------------------------------
  # 2. Generate Chart of Accounts
  # Uses the service object we built in Phase 2
  # -------------------------------------------------------------------
  if org.accounts.empty?
    puts "📊 Generating Standard Chart of Accounts..."
    Accounts::SeedService.new(org).call
    puts "✅ Chart of Accounts Generated (#{org.accounts.count} accounts)"
  else
    puts "✅ Chart of Accounts already exists."
  end

  # -------------------------------------------------------------------
  # 3. Create the Default Admin User
  # -------------------------------------------------------------------
  admin_email = "sampleorg@example.com"
  admin_password = "password123"

  user = User.find_or_initialize_by(email: admin_email)
  if user.new_record?
    user.password = admin_password
    user.password_confirmation = admin_password
    user.organization = org
    
    # Assuming Devise and standard role enums are used:
    # user.role = :org_admin 
    
    user.save!
    puts "👤 Admin User Created!"
    puts "   -> Email: #{admin_email}"
    puts "   -> Password: #{admin_password}"
  else
    puts "👤 Admin User already exists (Email: #{admin_email})."
  end

  # -------------------------------------------------------------------
  # 4. Generate 50 Realistic Sample Transactions
  # -------------------------------------------------------------------
  if org.journal_entries.empty?
    puts "📈 Generating 50 Sample Journal Entries..."
    
    # Fetch foundational accounts by the codes established in our Seed Service
    cash = org.accounts.find_by(code: '1110')
    ar = org.accounts.find_by(code: '1120')
    ap = org.accounts.find_by(code: '2110')
    sales = org.accounts.find_by(code: '4100')
    rent = org.accounts.find_by(code: '5110')
    utilities = org.accounts.find_by(code: '5120')
    salary = org.accounts.find_by(code: '5130')

    # Define logical transaction templates
    templates = [
      { desc: "Cash Sale to Walk-in Customer", debit: cash, credit: sales, min: 50, max: 1200 },
      { desc: "Invoiced Client Services", debit: ar, credit: sales, min: 1000, max: 8000 },
      { desc: "Payment Received on Invoice", debit: cash, credit: ar, min: 500, max: 4000 },
      { desc: "Monthly Office Rent", debit: rent, credit: cash, min: 2500, max: 2500 },
      { desc: "Bi-weekly Payroll", debit: salary, credit: cash, min: 3500, max: 5500 },
      { desc: "Received Electric Bill", debit: utilities, credit: ap, min: 150, max: 450 },
      { desc: "Paid Vendor for Utilities", debit: ap, credit: cash, min: 150, max: 450 }
    ]

    50.times do |i|
      template = templates.sample
      # Generate a realistic monetary amount with decimals
      amount = rand(template[:min]..template[:max]) + rand.round(2)
      
      # Randomize dates over the last 180 days to populate charts effectively
      entry_date = Date.current - rand(0..180).days

      # Build the entry
      entry = org.journal_entries.build(
        user: user,
        entry_date: entry_date,
        description: "#{template[:desc]} - REF#{1000 + i}"
      )

      # Build the balanced items
      entry.journal_items.build(account: template[:debit], debit: amount, credit: 0)
      entry.journal_items.build(account: template[:credit], debit: 0, credit: amount)

      entry.save!

      # CRITICAL: Instantly post to the ledger to update account_balances
      Ledger::PostingService.new(entry).call
    end
    
    puts "✅ 50 Sample Journal Entries Created & Posted!"
  else
    puts "✅ Journal Entries already exist. Skipping sample data generation."
  end
end

puts "🎉 Database Seeding Complete!"

