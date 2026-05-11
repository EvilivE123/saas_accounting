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
end

puts "🎉 Database Seeding Complete!"

