require "abst_int/version"
require "abst_int/or_set"
require "abst_int/integer"

class AbstInt

  class MultiResultError < StandardError
  end

  attr_reader :terms

  def initialize terms = AbstInt::OrSet.new(1, true)
    @terms = terms
  end

  def + abst_int_or_int
    terms = to_set abst_int_or_int
    return AbstInt.new(self.terms + terms)
  end

  def - abst_int_or_int
    terms = to_set abst_int_or_int
    return AbstInt.new(self.terms - terms)
  end

  def * abst_int_or_int
    terms = to_set abst_int_or_int
    return AbstInt.new(self.terms * terms)
  end

  def / abst_int_or_int
    raise "not implement"
  end

  def % num
    return self.terms % num
  end

  def | abst_int_or_int
    terms = to_set abst_int_or_int
    return AbstInt.new(self.terms | terms)
  end

  def & abst_int_or_int
    terms = to_set abst_int_or_int
    return AbstInt.new(self.terms & terms)
  end

  def not
    return AbstInt.new(self.terms.not)
  end

  def to_s
    @terms.to_s
  end

  def object
    AbstInt::Integer.new self
  end

  private
  def to_set abst_int_or_int
    case abst_int_or_int
    when ::Integer
      terms = AbstInt::OrSet.new(abst_int_or_int)
    when AbstInt
      terms = abst_int_or_int.terms
    when AbstInt::Integer
      terms = abst_int_or_int._terms
    end
    return terms
  end
end

class Fixnum
  def mul_with_abst_int num
    return num * self if (num.is_a? AbstInt) || (num.is_a? AbstInt::Integer)
    self.mul_without_abst_int num
  end

  alias :mul_without_abst_int :*
  alias :* :mul_with_abst_int
end
