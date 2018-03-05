# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# This will create plans in your Stripe account. Check that you don't have duplicates
# or comment out/remove if you want to manage plans manually.
# https://stripe.com/docs/api#plan_object
plans = Plan.create([
  {name: 'Basic', amount: 900, currency: 'usd', interval: 'month', active: true},
  {name: 'Pro', amount: 1500, currency: 'usd', interval: 'month', active: true}
])
puts "CREATED PLANS #{plans.pluck(:name).join(', ')}"

accounts = Account.create([
  {name: 'Limestone', subdomain: 'limestone', plan_id: Plan.last.id, current_period_end: 5.years.from_now, trialing: false, past_due: false, unpaid: false, cancelled: false}
])
puts "CREATES ACCOUNTS #{accounts.pluck(:name).join(', ')}"

admin_user = CreateAdminService.call
puts 'CREATED ADMIN USER: ' << admin_user.email
