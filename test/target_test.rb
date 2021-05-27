require "test/unit"
require_relative "../src/target"
require_relative "../src/investor"
require_relative "../src/frequency"

class TargetTest < Test::Unit::TestCase
  include Test::Unit::Assertions

  def test_it_can_be_instantiated
    Target.new(Investor.new, salary: 20_000, years: 10)
  end

  def test_a_positive_target
    investor = Investor.new(age: 30)

    investor.invest(10_000, rate: 10, regular: Frequency.new(200))

    assert Target.new(investor, salary: 20_000, age: 60).positive?
  end

  def test_a_negative_target
    investor = Investor.new(age: 30)

    investor.invest(10_000, rate: 10, regular: Frequency.new(200))

    refute Target.new(investor, salary: 20_000, age: 50).positive?
  end

  def test_actual_salary
    investor = Investor.new(age: 30)

    investor.invest(10_000, rate: 10, regular: Frequency.new(500))

    assert_equal 17181.57, Target.new(investor, salary: 20_000, age: 50).actual_salary
  end

  def test_regular_payment
    investor = Investor.new(age: 30)

    investment = investor.invest(10_000)
    investment.rate = 10
    investment.regular = Frequency.new(500)

    regular_payment = Target.new(investor, salary: 20_000, age: 50).regular_payment

    assert_equal Frequency::MONTHLY, regular_payment.frequency
    assert_equal 596.59, regular_payment.amount
  end
end