require "test/unit"
require "date"
require "timecop"

require_relative '../src/investor'
require_relative '../src/investment'

class InvestorTest < Test::Unit::TestCase
  def test_age_is_correct_when_dob_set
    investor = Investor.new(dob: Date.new(1988, 2, 2))

    Timecop.freeze(Date.new(2021, 1, 22)) do
      assert_equal 32, investor.age
    end

    Timecop.freeze(Date.new(2021, 2, 2)) do
      assert_equal 33, investor.age
    end
  end

  def test_age_is_nil_when_no_dob_set
    investor = Investor.new

    assert_nil investor.age
  end

  def test_investor_can_create_an_investment
    investor = Investor.new

    assert_kind_of Investment, investor.invest
  end

  def test_investor_can_create_an_investment_with_an_initial_amount
    investor = Investor.new

    investment = investor.invest(10_000)

    assert_equal 10_000, investment.invested
  end

  def test_investor_returns
    investor = Investor.new(dob: Date.new(1990, 1, 1))
    investment = investor.invest
    investment.regular(1_000, Frequency::YEARLY)

    Timecop.freeze(Date.new(2020, 1, 1)) do
      assert_equal({ age: 40, returns: 10_000 }, investor.returns(10))
    end
  end

  def test_investor_returns_per_year
    investor = Investor.new(dob: Date.new(1990, 1, 1))
    investment = investor.invest
    investment.regular(1_000, Frequency::YEARLY)

    Timecop.freeze(Date.new(2020, 1, 1)) do
      assert_equal [
        { age: 31, returns: 1_000 },
        { age: 32, returns: 2_000 }
      ], investor.returns_per_year(2)
    end
  end

  def test_age_at_target_returns
    investor = Investor.new(dob: Date.new(1990, 1, 1))

    investment = investor.invest(10_000)
    investment.rate(8)
    investment.regular(500)

    assert_equal 41, investor.age_at_target(100_000)
  end

  def test_returns_when_no_investment_raises_error
    investor = Investor.new

    assert_raise "No investment available" do
      investor.returns
    end
  end
end