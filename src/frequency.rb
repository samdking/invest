class Frequency
  MONTHLY = 12
  QUARTERLY = 4
  YEARLY = 1

  attr_reader :frequency, :amount, :limit

  def initialize(amount = 0, frequency = YEARLY, limit = nil)
      @amount = amount
      @frequency = frequency
      @limit = limit
  end

  def monthly?; @frequency == MONTHLY; end
  def quarterly?; @frequency == QUARTERLY; end
  def yearly?; @frequency == YEARLY; end

  def frequency_text
    self.class.constants.find { |k| self.class.const_get(k) == frequency }&.downcase&.capitalize
  end

  def total(years)
    time = years * @frequency

    (@limit ? [time, @limit].min : time) * @amount
  end

  def payments_for_year(year)
    payments = frequency

    if @limit
      payments = [@limit - (year-1) * frequency, payments].min
    end

    payments.times
  end
end
