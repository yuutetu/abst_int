require "abst_int/version"
require "abst_int/set"
require "abst_int/term"

class AbstInt

  class MultiResultError < StandardError
  end

  attr_reader :terms

  def initialize num = nil
    @terms = AbstInt::Set.new(AbstInt::Term.new(AbstInt::Variable.new))
  end

  def + abst_int
    terms = nil
    case abst_int
    when Integer
      terms = AbstInt::Set.new(AbstInt::Term.new(abst_int))
    when AbstInt::Term
      terms = AbstInt::Set.new(abst_int)
    when AbstInt
      terms = abst_int.terms
    end

    cloned_self = self.clone
    terms.each do |term|
      cloned_self.terms << term
    end
    return cloned_self
  end

  def - abst_int
    self + abst_int * (-1)
  end

  def * abst_int
    abst_int = AbstInt::Term.new abst_int if Integer === abst_int
    return @terms.inject(AbstInt.empty){|result, term| result + (term * abst_int)}
  end

  def / abst_int
    raise "not implement"
  end

  def % num
    @terms.inject(0){|result, term| [result, term % num].max }
  end

  # for debug
  def to_s
    @terms.to_s
  end

  def initialize_copy abst_int
    @terms = abst_int.terms.dup
  end

  def self.empty
    abst_int = AbstInt.new
    abst_int.terms = AbstInt::Set.new
    return abst_int
  end

  def terms= terms
    binding.pry unless AbstInt::Set === terms
    @terms = terms
  end
end
