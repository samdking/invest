require_relative "./frequency"

class InfiniteError < StandardError; end

class Investment
  attr_reader :initial, :rate

  def initialize(initial = 0)
    @initial = initial
    @regular = Frequency.new
    @rate = 0
  end

  def regular(amount, frequency = Frequency::MONTHLY, limit = nil)
    @regular = Frequency.new(amount, frequency, limit)
  end

  def returns(years = 1)
    (1..years).reduce(initial) do |starting, year|
      add_interest(starting, @rate) + @regular.payments_for_year(year).map do |i|
        add_interest(@regular.amount, @rate / @regular.frequency * (i + 1))
      end.sum
    end.round(2)
  end

  def rate(percentage)
    @rate = percentage.to_f
  end

  def time_to_reach(total)
    running_total = initial

    return 0 if running_total >= total

    raise InfiniteError if no_growth_possible?

    years = 1

    loop do
      running_total = add_interest(running_total, @rate) + @regular.payments_for_year(years).map do |i|
        add_interest(@regular.amount, @rate / @regular.frequency * (i + 1))
      end.sum

      return years if running_total >= total
      years += 1
    end
  end

  def invested(years = 1)
    initial + @regular.total(years)
  end

  def returns_per_year(years = 1)
    (1..years).map do |year|
      returns(year)
    end
  end

  private

  def add_interest(amount, rate)
    amount * (1 + rate / 100)
  end

  def no_growth_possible?
    @regular.amount.zero? && (@rate <= 0 || initial <= 0)
  end
end
