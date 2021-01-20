class Frequency
  MONTHLY = 12
  QUARTERLY = 4
  YEARLY = 1

  attr_reader :frequency, :amount

  def initialize(amount = 0, frequency = YEARLY, limit = nil)
      @amount = amount
      @frequency = frequency
      @limit = limit
  end

  def monthly?; @frequency == MONTHLY; end
  def quarterly?; @frequency == QUARTERLY; end
  def yearly?; @frequency == YEARLY; end

  def total(years)
    time = years * @frequency

    (@limit ? [time, @limit].min : time) * @amount
  end

  def yearly_total
    @amount * @frequency
  end

  def within_limit?(iteration)
    @limit.nil? || iteration < years_limit
  end

  def payments_for_year(year)
    return @frequency.times if @limit.nil?

    [@limit - (year-1) * frequency, frequency].min.times
  end

  private

  def years_limit
    @limit / @frequency
  end
end
