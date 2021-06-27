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

    investment.regular = Frequency.new(500)
    assert_equal 6_000, investment.returns

    investment.regular = Frequency.new(500, Frequency::YEARLY)
    assert_equal 500, investment.returns

    investment.regular = Frequency.new(500, Frequency::QUARTERLY)
    assert_equal 2_000, investment.returns
  end

  def test_regular_withdrawals
    investment = Investment.new(100_000)

    investment.regular = Frequency.new(-1_000)

    assert_equal 4_000, investment.returns(8)
  end

  def test_returns_over_time
    investment = Investment.new
    investment.regular = Frequency.new(500)

    assert_equal 6_000, investment.returns
    assert_equal 24_000, investment.returns(4)
  end

  def test_effect_of_rate_on_returns
    investment = Investment.new(500)

    investment.rate = 5
    assert_equal 525, investment.returns

    investment.rate = 8
    assert_equal 540, investment.returns
  end

  def test_returns_when_specifying_rate_as_argument
    investment = Investment.new(500)

    assert_equal 525, investment.returns(1, at_rate: 5)
    assert_equal 540, investment.returns(1, at_rate: 8)
  end

  def test_negative_rate_of_return
    investment = Investment.new(10_000)

    investment.rate = -1
    assert_equal 9_900, investment.returns
  end

  def test_rate_of_return_with_regular_payments
    investment = Investment.new(100)
    investment.regular = Frequency.new(100)
    investment.rate = 5

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

    investment.regular = Frequency.new(10_000, Frequency::YEARLY)
    assert_equal 50_000, investment.invested(4)

    investment.regular = Frequency.new(1_000)
    assert_equal 34_000, investment.invested(2)
  end

  def test_returns_per_year
    investment = Investment.new(3_000)

    investment.rate = 8
    investment.regular = Frequency.new(100)

    returns_per_year = investment.returns_per_year(18)

    assert_true returns_per_year.size == 18
    assert_equal investment.returns, returns_per_year.first
    assert_equal investment.returns(10), returns_per_year[9]
    assert_equal investment.returns(18), returns_per_year.last
  end

  def test_invested_per_year
    investment = Investment.new(3_000)

    investment.regular = Frequency.new(100)

    invested_per_year = investment.invested_per_year(18)

    assert_equal 4_200, invested_per_year[0]
  end

  def test_returns_with_limited_number_of_regular_payments
    investment = Investment.new

    investment.regular = Frequency.new(1_000, Frequency::MONTHLY, limit: 6)
    assert_equal 6_000, investment.returns(2)

    investment.rate = 5
    investment.regular = Frequency.new(1_000, Frequency::MONTHLY, limit: 12)
    assert_equal 12_941.25, investment.returns(2)
  end

  def test_amount_invested_with_limited_regular_payments
    investment = Investment.new

    investment.regular = Frequency.new(5_000, Frequency::YEARLY, limit: 5)
    assert_equal 25_000, investment.invested(10)

    investment.regular = Frequency.new(1_000, Frequency::MONTHLY, limit: 6)
    assert_equal 6_000, investment.invested
  end

  def test_calculate_rate_of_return
    investment = Investment.new

    investment.regular = Frequency.new(100)

    assert_equal 1200, investment.returns
    assert_equal 18.5, investment.rate_of_return(1320, 1)
    assert_equal 7.7, investment.rate_of_return(1250, 1)

    assert_equal 2400, investment.returns(2)
    assert_equal 22.7, investment.rate_of_return(3000, 2)
  end

  def test_calculate_long_rate_of_return
    investment = Investment.new
    investment.regular = Frequency.new(100)

    assert_equal 6.1, investment.rate_of_return(7000, 5)
  end

  def test_amount_invested_with_inflation_increasing_annually
    investment = Investment.new

    investment.inflation = 5
    investment.regular = Frequency.new(500, Frequency::MONTHLY)

    assert_equal 6_000, investment.invested(1) # 6000 invested
    assert_equal 12_300, investment.invested(2) # 6300 invested
    assert_equal 18_915, investment.invested(3) # 6615 invested
    assert_equal 25_860.75, investment.invested(4) # 6,945.75 invested
    assert_equal 33_153.79, investment.invested(5) # 7,293.0375 invested
  end

  def test_amount_invested_with_inflation_not_increasing_annually
    investment = Investment.new

    investment.inflation = 5
    investment.regular = Frequency.new(500, Frequency::MONTHLY, increase_annually: false)

    assert_equal 6_000, investment.invested(1)
    assert_equal 12_000, investment.invested(2)
    assert_equal 18_000, investment.invested(3)
    assert_equal 24_000, investment.invested(4)
  end

  def test_amount_invested_with_inflation_and_limited_regular_payments
    investment = Investment.new

    investment.inflation = 5

    investment.regular = Frequency.new(5_000, Frequency::YEARLY, limit: 5)
    assert_equal 27_628.16, investment.invested(10)

    investment.regular = Frequency.new(1_000, Frequency::MONTHLY, limit: 18)
    assert_equal 18_300, investment.invested(2)
  end

  def test_inflation_on_returns
    investment = Investment.new

    investment.inflation = 5

    investment.regular = Frequency.new(1_000, Frequency::MONTHLY)

    investment.returns(10)
  end
end
