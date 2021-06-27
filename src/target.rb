class InfiniteError < StandardError; end

class Target
  def initialize(investor, years: nil, age: nil, salary: nil, inflation: 0)
    @investor = investor
    @years = years || (age ? age - investor.age : nil)
    @salary = salary
    @inflation_rate = 1 + inflation.to_f / 100
  end

  def gross_salary(years = @years)
    @salary * @inflation_rate ** years
  end

  def positive?
    actual_salary >= gross_salary
  end

  def actual_salary
    (returns * 0.04).round(2)
  end

  def regular_payment(frequency: Frequency::MONTHLY, max_guesses: 20)
    regular_amount = @investor.regular_amount
    total = @investor.investment.returns(@years)
    iterations = 0
    target = gross_salary * 25

    while total.round(1) != target.round(1)
      iterations += 1
      diff = ((target - total).to_f / target)
      break if diff.abs < 0.005
      regular_amount += diff * regular_amount
      investment = @investor.investment.dup
      regular = investment.regular = Frequency.new(regular_amount.round(2), frequency)
      total = investment.returns(@years)
      raise "Could not calculate regular payments for £#{@salary} over #{@years} years" if iterations >= max_guesses
    end

    regular
  end

  def time_to_reach
    years = 0

    raise InfiniteError if @investor.investment.no_growth_possible?

    loop do
      years += 1
      returns = @investor.returns(years)
      return years if returns[:returns] >= gross_salary(years) * 25
    end
  end

  def age_at_total
    years = 0

    raise InfiniteError if @investor.investment.no_growth_possible?

    loop do
      years += 1
      returns = @investor.returns(years)
      return returns[:age] if returns[:returns] >= gross_salary(years) * 25
    end
  end

  private

  def returns
    @returns ||= @investor.returns(@years)[:returns]
  end
end