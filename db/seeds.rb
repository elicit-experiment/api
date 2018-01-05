# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

OauthApplication.create!([
{ :name => 'admin_public', :uid => 'admin_public', :secret => 'czZCaGRSa3F0MzpnWDFmQmF0M2JW', :redirect_uri => '/admin'}
])

User.create!([
{ :email => 'admin@elicit.dk',    :username => "admin",    :password => 'password', :password_confirmation => 'password', :role => 'admin', :anonymous => false, :sign_in_count => 0 },
{ :email => 'subject1@elicit.dk', :username => "subject1", :password => 'abcd12_',  :password_confirmation => 'abcd12_', :role => 'registered_user', :anonymous => false, :sign_in_count => 0 },
{ :email => 'subject2@elicit.dk', :username => "subject2", :password => 'abcd12_',  :password_confirmation => 'abcd12_', :role => 'registered_user', :anonymous => false, :sign_in_count => 0 },
{ :email => 'subject3@elicit.dk', :username => "subject3", :password => 'abcd12_',  :password_confirmation => 'abcd12_', :role => 'registered_user', :anonymous => false, :sign_in_count => 0 },
{ :email => 'subject4@elicit.dk', :username => "subject4", :password => 'abcd12_',  :password_confirmation => 'abcd12_', :role => 'registered_user', :anonymous => false, :sign_in_count => 0 },
{ :email => 'subject5@elicit.dk', :username => "subject5", :password => 'abcd12_',  :password_confirmation => 'abcd12_', :role => 'registered_user', :anonymous => false, :sign_in_count => 0 },
])

