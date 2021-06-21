require 'sinatra'
require 'sinatra/reloader' if development?
require_relative 'investor'
require_relative 'target'

def cors_origin
  case settings.environment
  when :production
    review_app = ENV['FE_APP_NAME'] ? "#{ENV['FE_APP_NAME']}--" : ''

    "https://#{review_app}retirable-fe.netlify.app"
  when :development
    '*'
  end
end

post '/invest' do
  response.headers['Access-Control-Allow-Origin'] = cors_origin
  content_type :json

  if params[:dob_dd]
    dob = Date.new(params[:dob_yyyy].to_i, params[:dob_mm].to_i, params[:dob_dd].to_i)
  end

  if params[:age]
    age = params[:age].to_i
  end

  investor = Investor.new(dob: dob, age: age)

  investment = investor.invest((params[:initial] || 0).to_i)

  if params[:regular_amount]
    regular = investment.regular = Frequency.new(
      params[:regular_amount].to_i,
      params[:regular_frequency].to_i,
      limit: params[:regular_limit] ? params[:regular_limit].to_i : nil,
      increase_annually: params[:regular_inflation] == '1'
    )
  end

  rate = (params[:rate] || 8).to_i

  investment.rate = rate

  if params[:inflation]
    investment.inflation = params[:inflation].to_f
  end

  if params[:years]
    years = params[:years].to_i
  elsif params[:time_to_reach]
    years = investment.time_to_reach(params[:time_to_reach].to_i)
  elsif params[:target_salary] && params[:target_salary] != ''
    years = investment.time_to_reach(params[:target_salary].to_f * 25)
  else
    years = 5
  end

  unless params[:target_age].nil? || params[:target_age].empty?
    regular_target = Target.new(investor,
      years: params[:years],
      age: params[:target_age]&.to_i,
      salary: params[:target_salary]&.to_f,
      inflation: params[:inflation]&.to_f
    ).regular_payment
  end

  {
    investment: {
      age: investor.age,
      target_age: params[:target_age],
      initial: investment.initial,
      rate: rate,
      invested: investment.invested_per_year(years),
      regular: regular && {
        amount: regular.amount,
        frequency: regular.frequency_text,
        iterations: regular.limit,
      }.compact,
      time_to_reach: params[:time_to_reach] && years,
      returns: investor.returns_per_year(years),
      total_returns: investor.returns(years)[:returns],
      total_invested: investor.invested(years).round(2),
      annual_salary: (investor.returns(years)[:returns] * 0.04).round(2),
      adjusted_annual_salary: (investor.returns(years)[:adjusted_returns] * 0.04).round(2),
      inflation: params[:inflation],
      regular_target: regular_target && {
        amount: regular_target.amount,
        frequency: regular_target.frequency_text,
      }.compact
    }.compact
  }.to_json
end
