require "abst_int/version"
require "abst_int/set"
require "abst_int/term"

class AbstInt

  class MultiResultError < StandardError
  end

  attr_reader :terms

  def initialize terms = AbstInt::Set.new(1, true)
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

  def / abst_int
    raise "not implement"
  end

  def % num
    return self.terms % num
  end

  def to_s
    @terms.to_s
  end

  private
  def to_set abst_int_or_int
    case abst_int_or_int
    when Integer
      terms = AbstInt::Set.new(abst_int_or_int)
    when AbstInt
      terms = abst_int_or_int.terms
    end
    return terms
  end
end
