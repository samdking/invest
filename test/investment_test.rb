require "test/unit"
require_relative '../src/investment'

class InvestmentTest < Test::Unit::TestCase
  include Test::Unit::Assertions

  def test_it_can_be_instantiated
    Investment.new
  end

  def test_it_can_have_an_initial_amount
    assert_equal 500, Investment.new(500).initial
  end

  def test_a_regular_amount
    regular = Investment.new.regular(500)

    assert_true regular.monthly?
    assert_equal 6_000, regular.yearly_total

    regular = Investment.new.regular(500, Frequency::YEARLY)

    assert_true regular.yearly?
    assert_equal 500, regular.yearly_total

    regular = Investment.new.regular(500, Frequency::QUARTERLY)

    assert_true regular.quarterly?
    assert_equal 2_000, regular.yearly_total
  end

  def test_returns_over_time
    investment = Investment.new
    investment.regular(500)

    assert_equal 6_000, investment.returns
    assert_equal 24_000, investment.returns(4)
  end

  def test_rate_of_return
    investment = Investment.new(500)

    investment.rate(5)
    assert_equal 525, investment.returns

    investment.rate(8)
    assert_equal 540, investment.returns
  end

  def test_negative_rate_of_return
    investment = Investment.new(10_000)

    investment.rate(-1)
    assert_equal 9_900, investment.returns
  end

  def test_rate_of_return_with_regular_payments
    investment = Investment.new(100)
    investment.regular(100)
    investment.rate(5)

    assert_equal 2_636.88, investment.returns(2)
  end

  def test_regular_amount_at_different_intervals
    investment = Investment.new

    investment.regular(1000, Frequency::YEARLY)
    assert_equal 2000, investment.returns(2)

    investment.regular(1000, Frequency::QUARTERLY)
    assert_equal 4000, investment.returns
  end

  def test_invested
    investment = Investment.new(10_000)
    assert_equal 10_000, investment.invested
    assert_equal 10_000, investment.invested(5)

    investment.regular(10_000, Frequency::YEARLY)
    assert_equal 50_000, investment.invested(4)

    investment.regular(1_000)
    assert_equal 34_000, investment.invested(2)
  end

  def test_time_to_reach_total
    investment = Investment.new(10_000)

    investment.rate(8)
    investment.regular(700)

    assert_equal 12.25, investment.time_to_reach(200_000)
    assert_equal 191_497.24, investment.returns(12)

    assert_in_delta 20.8, investment.time_to_reach(500_000), 0.1
    assert_equal 447_667.43, investment.returns(20)
  end

  def test_returns_per_year
    investment = Investment.new(3_000)

    investment.rate(8)
    investment.regular(100)

    returns_per_year = investment.returns_per_year(18)

    assert_true returns_per_year.size == 18
    assert_equal investment.returns, returns_per_year.first
    assert_equal investment.returns(10), returns_per_year[9]
    assert_equal investment.returns(18), returns_per_year.last
  end

  def test_limited_number_of_regular_payments
    investment = Investment.new

    investment.regular(1_000, Frequency::MONTHLY, 6)
    assert_equal 6_000, investment.returns(2)

    investment.rate(5)
    investment.regular(1_000, Frequency::MONTHLY, 12)
    assert_equal 12_941.25, investment.returns(2)
  end

  def test_invested_with_limited_regular_payments
    investment = Investment.new

    investment.rate(5)
    investment.regular(5_000, Frequency::YEARLY, 5)

    assert_equal 37_024.37, investment.returns(10)
    assert_equal 25_000, investment.invested(10)

    investment.regular(1_000, Frequency::MONTHLY, 6)
    assert_equal 6_000, investment.invested
  end
end
