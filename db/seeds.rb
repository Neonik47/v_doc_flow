# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
admin = User.create({name: "Администратор", role: "admin", email: "admin@admin.admin", password: "123e456y", status: "enabled" })
names = %w(Иванов Петриков Сидорчук Тополев Котов Мясников Косичкина Петрова Громова Федорова Олейник)


User::Defines::ROLES.each do |role, rus|
  user = User.create(
    {name: names.sample + " (#{rus})", role: role, email: "#{role}@user.user",
    password: "12345678", status: "enabled" }
  )
end
