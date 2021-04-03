require_relative "investment"

class Investor
  def initialize(dob: nil, age: nil)
    @dob = dob
    @age = age
  end

  def invest(initial_amount = 0)
    @investment = Investment.new(initial_amount)
  end

  def invested(years = 1)
    investment.invested(years)
  end

  def returns(years = 1)
    {
      age: age + years,
      returns: investment.returns(years),
      adjusted_returns: investment.returns(years) / investment.inflation_rate ** years,
    }
  end

  def returns_per_year(years = 1)
    investment.returns_per_year(years).each_with_index.map do |returns, i|
      {
        age: age ? age + i + 1 : nil,
        returns: returns,
        adjusted_returns: returns / investment.inflation_rate ** years,
      }.compact
    end
  end

  def age_at_target(target)
    age + investment.time_to_reach(target)
  end

  def age
    return @age if @age
    return unless @dob

    today = Date.today
    age = today.year - @dob.year
    age -= 1 if today.month < @dob.month || today.month == @dob.month && today.mday < @dob.mday
    age
  end

  private

  def investment
    @investment || raise("No investment available")
  end
end
