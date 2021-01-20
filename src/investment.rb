require_relative "./frequency"

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

  # def returns(years = 1)
  #   (years * @regular.frequency).times.reduce(initial) do |sum, iteration|
  #     if @regular.within_limit?(iteration)
  #       total_after_regular_payment(sum)
  #     else
  #       add_interest(sum, @rate / @regular.frequency)
  #     end
  #   end.round(2)
  # end

  def returns(years = 1)
    years.times.reduce(initial) do |sum, iteration|
      if @regular.within_limit?(iteration)
        @regular.frequency.times.reduce(sum) do |sum, value|
          total_after_regular_payment(sum)
        end
      else
        add_interest(sum, @rate)
      end
    end.round(2)
  end

  def more_accurate_returns(years = 1)
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

    years = 1

    loop do
      running_total = total_after_regular_payment(running_total)
      return years.to_f / @regular.frequency if running_total >= total
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

  def total_after_regular_payment(total)
    add_interest(total + @regular.amount, @rate / @regular.frequency)
  end

  def add_interest(amount, rate)
    amount * (1 + rate / 100)
  end
end
