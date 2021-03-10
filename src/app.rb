require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'investor'

post '/invest' do
  if params[:dob_dd]
    dob = Date.new(params[:dob_yyyy].to_i, params[:dob_mm].to_i, params[:dob_dd].to_i)
  end

  if params[:age]
    age = params[:age].to_i
  end

  investor = Investor.new(dob: dob, age: age)

  investment = investor.invest((params[:initial] || 0).to_i)

  if params[:regular_amount]
    regular = investment.regular(
      params[:regular_amount].to_i,
      params[:regular_frequency].to_i,
      params[:regular_limit] ? params[:regular_limit].to_i : nil,
    )
  end

  investment.rate((params[:rate] || 8).to_i)

  if params[:time_to_reach]
    years = investment.time_to_reach(params[:time_to_reach].to_i)
  elsif params[:target_salary]
    years = investment.time_to_reach(params[:target_salary].to_f * 25)
  elsif params[:years]
    years = params[:years].to_i
  else
    years = 5
  end

  {
    investment: {
      age: investor.age,
      initial: investment.initial,
      invested: investment.invested(years),
      regular: regular && {
        amount: regular.amount,
        frequency: regular.frequency_text,
        iterations: regular.limit,
      }.compact,
      time_to_reach: params[:time_to_reach] && years,
      returns: investor.returns_per_year(years),
    }.compact
  }.to_json
end
