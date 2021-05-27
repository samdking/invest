class Target
  def initialize(investor, years: nil, age: nil, salary: nil)
    @investor = investor
    @years = years || age - investor.age
    @salary = salary
  end

  def positive?
    actual_salary >= @salary
  end

  def actual_salary
    (returns * 0.04).round(2)
  end

  def regular_payment(frequency: Frequency::MONTHLY, max_guesses: 20)
    regular_amount = @investor.regular_amount
    total = @investor.returns(@years)[:returns]
    iterations = 0
    target = @salary * 25

    while total.round(1) != target.round(1)
      iterations += 1
      diff = ((target - total).to_f / target)
      break if diff.abs < 0.005
      regular_amount += diff * regular_amount
      regular = @investor.amend_regular(regular_amount.round(2), frequency)
      total = @investor.returns(@years)[:returns]
      raise "Could not calculate regular payments" if iterations >= max_guesses
    end

    regular
  end

  private

  def returns
    @returns ||= @investor.returns(@years)[:returns]
  end
end