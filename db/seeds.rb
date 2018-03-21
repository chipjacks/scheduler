# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
if User.first
  user = User.first
else
  user = FactoryBot.create_list(:user, 5).first
end
puts user.email, user.password
if Appointment.first
  nil
else
  FactoryBot.create_list(:appointment, 5, user: user)
end