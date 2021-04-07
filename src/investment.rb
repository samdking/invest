require_relative "./frequency"

class InfiniteError < StandardError; end

class Investment
  attr_reader :initial, :inflation_rate

  def initialize(initial = 0)
    @initial = initial
    @regular = Frequency.new
    @rate = 0
    @inflation_rate = 1
  end

  def inflation(percentage)
    @inflation_rate = 1 + percentage.to_f / 100
  end

  def regular(amount, frequency = Frequency::MONTHLY, limit: nil, increase_annually: true)
    @regular = Frequency.new(amount, frequency, limit, increase_annually)
  end

  def returns(years = 1, at_rate: @rate)
    (1..years).reduce(initial) do |starting, year|
      returns_for_year(starting, year, at_rate.to_f)
    end.round(2)
  end

  def rate(percentage)
    @rate = percentage.to_f
  end

  def time_to_reach(total)
    running_total = initial
    years = 0

    raise InfiniteError if no_growth_possible?

    loop do
      years += 1
      running_total = returns_for_year(running_total, years, @rate)
      break if running_total >= total * @inflation_rate ** years
    end

    years
  end

  def invested(years = 1)
    (1..years).reduce(initial) do |tally, year|
      invested_for_year(tally, year)
    end.round(2)
  end

  def returns_per_year(years = 1)
    array = []

    (1..years).reduce(initial) do |starting, year|
      returns_for_year(starting, year, @rate).tap do |returns|
        array << returns.round(2)
      end
    end

    array
  end

  def invested_per_year(years = 1)
    array = []

    (1..years).reduce(initial) do |tally, year|
      invested_for_year(tally, year).tap do |invested|
        array << invested.round(2)
      end
    end

    array
  end

  def rate_of_return(returns, years = 1, guess: 10, max_guesses: 20)
    rate = guess.to_f
    total = returns(years, at_rate: rate)
    iterations = 0

    while total.round(1) != returns.round(1)
      iterations += 1
      diff = ((returns - total).to_f / returns * 100) / years
      break if diff.abs < 0.005
      rate += diff
      total = returns(years, at_rate: rate)
      #puts "#{total} (#{rate.round(2)}%)"
      raise "Could not calculate rate of return" if iterations >= max_guesses
    end

    rate.round(1)
  end

  private

  def returns_for_year(starting, year, rate)
    inflation = @regular.increase_annually ? @inflation_rate : 1

    add_interest(starting, rate) + @regular.payments_for_year(year).sum do |i|
      amount = @regular.amount * inflation ** (year-1)
      add_interest(amount, rate / @regular.frequency * (i + 1))
    end
  end

  def invested_for_year(tally, year)
    inflation = @regular.increase_annually ? @inflation_rate : 1

    tally + @regular.payments_for_year(year).sum do
      @regular.amount * inflation ** (year-1)
    end
  end

  def add_interest(amount, rate)
    amount * (1 + rate / 100)
  end

  def no_growth_possible?
    @regular.amount.zero? && (@rate <= 0 || initial <= 0)
  end
end
