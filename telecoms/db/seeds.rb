# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
user_list = [
  [  'Example Jo' ,'xavierj@tcd.ie','password',true],
  [ "Jibin xavier", 'jibinxavier96@gmail.com','password' ,false],
  
]
 
user_list.each do |name, email,password,admin|
   kp= Gibberish::RSA.generate_keypair()
  User.create( name: name, email: email,password:password ,admin: admin,public_key:kp.public_key.to_s,private_key:kp.private_key.to_s)
end

1.times do |n|
   kp= Gibberish::RSA.generate_keypair()
  name  = Faker::Name.name
  email = "example-#{n+1}@example.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,public_key:kp.public_key.to_s,private_key:kp.private_key.to_s)
end