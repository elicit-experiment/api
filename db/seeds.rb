# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

OauthApplication.create!([
                           { name: 'admin_public', uid: ENV.fetch('PUBLIC_CLIENT_ID', 'admin_public'), secret: ENV.fetch('PUBLIC_CLIENT_SECRET', 'czZCaGRSa3F0MzpnWDFmQmF0M2JW'), redirect_uri: '/admin' },
                           { name: 'webapp_public', uid: ENV.fetch('WEBAPP_CLIENT_ID', 'webapp_public'), secret: ENV.fetch('WEBAPP_CLIENT_SECRET', 'czZCaGRSa3F0MzpnWDFmQmF0M2JW'), redirect_uri: '/admin' }
                         ])

User.create!([
               { email: 'admin@elicit.com', username: 'admin', password: ENV.fetch('ADMIN_PASSWORD', 'password'), password_confirmation: ENV.fetch('ADMIN_PASSWORD', 'password'), role: 'admin', anonymous: false, sign_in_count: 0 },
               { email: 'pi@elicit.com', username: 'pi', password: ENV.fetch('ADMIN_PASSWORD', 'password'), password_confirmation: ENV.fetch('ADMIN_PASSWORD', 'password'), role: 'investigator', anonymous: false, sign_in_count: 0 },
               { email: 'subject1@elicit.com', username: 'subject1', password: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'),  password_confirmation: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'), role: 'registered_user', anonymous: false, sign_in_count: 0 },
               { email: 'subject2@elicit.com', username: 'subject2', password: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'),  password_confirmation: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'), role: 'registered_user', anonymous: false, sign_in_count: 0 },
               { email: 'subject3@elicit.com', username: 'subject3', password: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'),  password_confirmation: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'), role: 'registered_user', anonymous: false, sign_in_count: 0 },
               { email: 'subject4@elicit.com', username: 'subject4', password: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'),  password_confirmation: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'), role: 'registered_user', anonymous: false, sign_in_count: 0 },
               { email: 'subject5@elicit.com', username: 'subject5', password: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'),  password_confirmation: ENV.fetch('SUBJECT_PASSWORD_DEFAULT', 'abcd12_'), role: 'registered_user', anonymous: false, sign_in_count: 0 }
             ])
