class Frequency
  MONTHLY = 12
  QUARTERLY = 4
  YEARLY = 1

  attr_reader :frequency, :amount, :limit, :increase_annually

  def initialize(amount = 0, frequency = MONTHLY, limit: nil, increase_annually: true)
    @amount = amount
    @frequency = frequency
    @limit = limit
    @increase_annually = increase_annually
  end

  def monthly?; @frequency == MONTHLY; end
  def quarterly?; @frequency == QUARTERLY; end
  def yearly?; @frequency == YEARLY; end

  def frequency_text
    self.class.constants.find { |k| self.class.const_get(k) == frequency }&.downcase&.capitalize
  end

  def payments_for_year(year)
    payments = frequency

    if @limit
      payments = [@limit - (year-1) * frequency, payments].min
    end

    payments.times
  end
end
