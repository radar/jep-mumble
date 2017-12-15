#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "mumble"

account = Mumble::Account.new(name: "Culture Amp", email: "ryanbigg@cultureamp.com")

survey = Mumble::Survey.new(account: account, name: "Engagement Survey")

# locations
melbourne = Mumble::Segment.new(name: "Melbourne")
sf = Mumble::Segment.new(name: "SF")

# genders
male = Mumble::Segment.new(name: "Male")
female = Mumble::Segment.new(name: "Female")

# teams
jep = Mumble::Segment.new(name: "JEP")
a_u = Mumble::Segment.new(name: "A & U")
effectiveness = Mumble::Segment.new(name: "Effectiveness")
cse = Mumble::Segment.new(name: "CSE")

user1 = Mumble::User.new(segments: [melbourne, jep, male])
user2 = Mumble::User.new(segments: [melbourne, a_u, female])
user3 = Mumble::User.new(segments: [melbourne, effectiveness, female])
user4 = Mumble::User.new(segments: [sf, cse, female])

response1 = Mumble::Response.new(user: user1)
response2 = Mumble::Response.new(user: user2)
response3 = Mumble::Response.new(user: user3)
response4 = Mumble::Response.new(user: user4)

survey.add_response(response1)
survey.add_response(response2)
survey.add_response(response3)
survey.add_response(response4)

check = ->(responses, response) { responses.include?(response) }
query_1_responses = survey.responses.for_segments(melbourne)
puts "QUERY 1"
puts "Q1 includes R1: #{check.(query_1_responses, response1)}"
puts "Q1 includes R2: #{check.(query_1_responses, response2)}"
puts "Q1 includes R3: #{check.(query_1_responses, response3)}"
puts "Q1 includes R4: #{check.(query_1_responses, response4)}"

puts "-" * 50

query_2_responses = survey.responses.for_segments(melbourne, female)
puts "QUERY 2"

puts "Q2 includes R1: #{check.(query_2_responses, response1)}"
puts "Q2 includes R2: #{check.(query_2_responses, response2)}"
puts "Q2 includes R3: #{check.(query_2_responses, response3)}"
puts "Q2 includes R4: #{check.(query_2_responses, response4)}"
