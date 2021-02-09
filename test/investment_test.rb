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
    investment = Investment.new

    regular = investment.regular(500)
    assert_true regular.monthly?
    assert_equal 6_000, investment.returns

    regular = investment.regular(500, Frequency::YEARLY)
    assert_true regular.yearly?
    assert_equal 500, investment.returns

    regular = investment.regular(500, Frequency::QUARTERLY)
    assert_true regular.quarterly?
    assert_equal 2_000, investment.returns
  end

  def test_regular_withdrawals
    investment = Investment.new(100_000)

    regular = investment.regular(-1_000)
    assert_equal 4_000, investment.returns(8)
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

    assert_equal 1_337.5, investment.returns
    assert_equal 2_636.88, investment.returns(2)
  end

  def test_amount_invested_over_time
    investment = Investment.new(10_000)
    assert_equal 10_000, investment.invested
    assert_equal 10_000, investment.invested(5)
  end

  def test_amount_invested_over_time_with_regular_payments
    investment = Investment.new(10_000)

    investment.regular(10_000, Frequency::YEARLY)
    assert_equal 50_000, investment.invested(4)

    investment.regular(1_000)
    assert_equal 34_000, investment.invested(2)
  end

  def test_time_to_reach_total
    investment = Investment.new(10_000)

    investment.rate(8)
    investment.regular(700)

    assert_equal 13, investment.time_to_reach(200_000)
    assert_equal 215_581.02, investment.returns(13)

    assert_equal 22, investment.time_to_reach(500_000)
    assert_equal 540_388.41, investment.returns(22)
  end

  def test_raises_error_when_growth_is_nil
    investment = Investment.new

    assert_raise InfiniteError do
      investment.time_to_reach(100)
    end
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

  def test_returns_with_limited_number_of_regular_payments
    investment = Investment.new

    investment.regular(1_000, Frequency::MONTHLY, 6)
    assert_equal 6_000, investment.returns(2)

    investment.rate(5)
    investment.regular(1_000, Frequency::MONTHLY, 12)
    assert_equal 12_941.25, investment.returns(2)
  end

  def test_amount_invested_with_limited_regular_payments
    investment = Investment.new

    investment.rate(5)

    investment.regular(5_000, Frequency::YEARLY, 5)
    assert_equal 25_000, investment.invested(10)

    investment.regular(1_000, Frequency::MONTHLY, 6)
    assert_equal 6_000, investment.invested
  end

  def test_calculate_rate_of_return
    investment = Investment.new

    investment.regular(100)

    assert_equal 1200, investment.returns
    assert_equal 18.5, investment.rate_of_return(1320, 1)
    assert_equal 7.7, investment.rate_of_return(1250, 1)

    assert_equal 2400, investment.returns(2)
    assert_equal 22.7, investment.rate_of_return(3000, 2)
  end
end
