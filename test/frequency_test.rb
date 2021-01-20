require "test/unit"
require_relative '../src/frequency'

class FrequencyTest < Test::Unit::TestCase
  include Test::Unit::Assertions

  def test_payments_for_year
    frequency = Frequency.new(100, Frequency::MONTHLY)

    assert_equal 12, frequency.payments_for_year(1).size
    assert_equal 12, frequency.payments_for_year(2).size
  end

  def test_payments_for_year_with_limit
    frequency = Frequency.new(100, Frequency::MONTHLY, 23)

    assert_equal 12, frequency.payments_for_year(1).size
    assert_equal 11, frequency.payments_for_year(2).size
  end

  def test_yearly_payments_for_year
    frequency = Frequency.new(100, Frequency::YEARLY, 5)

    assert_equal 1, frequency.payments_for_year(1).size
    assert_equal 1, frequency.payments_for_year(2).size
    assert_equal 1, frequency.payments_for_year(3).size
    assert_equal 1, frequency.payments_for_year(4).size
    assert_equal 1, frequency.payments_for_year(5).size
    assert_equal 0, frequency.payments_for_year(6).size
  end

  def test_quarterly_payments_with_limit
    frequency = Frequency.new(100, Frequency::QUARTERLY, 3)

    assert_equal 3, frequency.payments_for_year(1).size
  end

  def test_no_monthly_payments_in_second_year_when_limited_to_6
    frequency = Frequency.new(1_000, Frequency::MONTHLY, 6)

    assert_equal 0, frequency.payments_for_year(2).size
  end
end
