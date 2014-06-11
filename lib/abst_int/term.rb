require "abst_int/variable"

class AbstInt::Term
  attr_accessor :variables, :coefficient

  def initialize variable_or_number = nil
    @coefficient = 1
    @variables = []
    @coefficient = variable_or_number if (not variable_or_number.nil?) && Fixnum === variable_or_number
    self << variable_or_number        if (not variable_or_number.nil?) && AbstInt::Variable === variable_or_number
  end

  def << variable
    @variables << variable
    @variables.sort!
  end

  # like terms check
  def =~ term
    return false unless @variables.length == term.variables.length
    @variables.each_with_index do |variable, i|
      return false unless variable.id == term.variables[i].id
    end
    return true
  end

  # collect like terms
  def + term
    raise "this is not like terms." unless self =~ term
    cloned_term = self.clone
    cloned_term.coefficient += term.coefficient
    return cloned_term
  end

  def * abst_int_or_term
    if AbstInt === abst_int_or_term
      abst_int = abst_int_or_term
      return abst_int.terms.inject(AbstInt.empty){|result, term| result + (self * term)}
    end
    cloned_term = self.clone
    term = abst_int_or_term
    cloned_term.coefficient *= term.coefficient
    term.variables.each do |variable|
      cloned_term << variable
    end
    return cloned_term
  end

  def % num
    if @variables.empty?
      return (@coefficient % num)
    else
      raise AbstInt::MultiResultError, "There are more results than one." if @coefficient % num != 0
      return 0
    end
  end

  # for debug
  def to_s
    "#{@coefficient}#{@variables.map{|var| var.to_s}.join}"
  end

  def initialize_copy term
    @variables = []
    term.variables.each do |variable|
      @variables << variable.dup
    end
  end

  # def * abst_int
  #   return abst_int * self if abst_int.class == AbstInt
  #   return @terms.map{|term| term * abst_int }
  # end
end