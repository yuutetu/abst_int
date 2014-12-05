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

  def star
    cloned_term = AbstInt::Term.new
    cloned_term.coefficient = @coefficient
    cloned_term.variables = @variables
    cloned_term.variables = cloned_term.variables + [AbstInt::Variable.new] if @variables.empty? && @coefficient != 0
    return cloned_term
  end

  def generate_nfa nfa, set
    if @variables.empty?
      if @coefficient == 0
      elsif @coefficient < 0
        nfa.add_initial [self, @coefficient]
        nfa.add_final set
        state_proc = proc { |x| (x == 0) ? set : [self, x] }
        (@coefficient...0).each do |i|
          nfa.add_trans state_proc.call(i), 'b', state_proc.call(i+1)
        end
      else
        nfa.add_initial set
        nfa.add_final [self, @coefficient]
        state_proc = proc { |x| (x == 0) ? set : [self, x] }
        (0...@coefficient).each do |i|
          nfa.add_trans state_proc.call(i), 'a', state_proc.call(i+1)
        end
      end
    else
      state_proc = proc { |x| (x == 0 || x == @coefficient) ? set : [self, x] }
      alphabet = @coefficient < 0 ? 'b' : 'a'
      unsigned_coefficient = @coefficient < 0 ? -@coefficient : @coefficient
      @coefficient.times do |i|
        nfa.add_trans state_proc.call(i), alphabet, state_proc.call(i+1)
      end
    end
    return nfa
  end

  # for debug
  def to_s
    "#{@coefficient}#{@variables.map{|var| var.to_s}.join}"
  end

  def calc num
    return @variables.empty? ?  @coefficient : @coefficient * num
  end

  def variable_exists?
    return not(@variables.empty?)
  end

  # 一旦、変数ありterm同士の包含比較
  def include? term
    return false unless self.variable_exists? && term.variable_exists?
    return true if term.coefficient % self.coefficient == 0
    return false
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