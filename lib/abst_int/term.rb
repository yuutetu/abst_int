require "abst_int/variable"

class AbstInt::Term

  def initialize coefficient = nil, be_variable = false
    @coefficient = coefficient || 1
    @variables = []
    self << AbstInt::Variable.new if be_variable
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

  protected
  def coefficient
    @coefficient
  end

  def coefficient= coefficient
    @coefficient = coefficient
  end

  def variables
    @variables
  end

  def variables= variables
    @variables = variables
  end
end