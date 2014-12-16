require "abst_int/term"
require "abst_int/calculus_model/nfa"

class AbstInt::Set
  def initialize coefficient = nil, be_variable = false
    @elements = []
    if coefficient.is_a? Fixnum
      self  << (AbstInt::Term.new coefficient, be_variable)
    end
  end

  def + set
    cloned_self = self.dup
    set.each do |term|
      cloned_self << term
    end
    return cloned_self
  end

  def - set
    self + set * AbstInt::Set.new(-1)
  end

  def * set
    result = AbstInt::Set.new
    cloned_self = self.dup
    cloned_self.each do |self_term|
      set.each do |term|
        result << (self_term * term)
      end
    end
    return result
  end

  def % num
    @elements.inject(0){|result, term| [result, term % num].max }
  end

  def star
    result = AbstInt::Set.new
    self.each do |term|
      result << term.star
    end
    return result
  end

  def to_s
    @elements.map{|element| element.to_s}.join("+")
  end

  def generate_nfa nfa
    self.each do |term|
      # 各termごとの設定
      nfa = term.generate_nfa nfa, self
    end
    unless nfa.exists_initial?
      nfa.add_initial self
      nfa.add_final self
    end
    return nfa
  end

  def include? set
    # setの変数に0を代入して計算
    set_offset = set.calc 0
    # その値がselfに含まれているか確認
    input_string = set_offset < 0 ? "b" * (- set_offset) : "a" * set_offset
    return false unless self.to_nfa.to_dfa.accept? input_string
    # 含まれているならば、変数項の係数の包含関係をチェック
    set.each do |term|
      next unless term.variable_exists?
      include_check = false
      self.each do |self_term|
        next unless self_term.variable_exists?
        include_check = include_check || self_term.include?(term)
      end
      return false unless include_check
    end
    return true
  end

  def expand set
    return self if self.include? set
    return nil unless self.check_lank == 1 && set.check_lank == 0
    set_offset = set.calc 0
    if self.calc(-1) == set_offset
      new_set = AbstInt::Set.new
      new_set << AbstInt::Term.new(set_offset)
      self.each do |term|
        new_set << term if term.variable_exists?
      end
      return new_set
    else
      return nil
    end
  end

  def check_lank
    lank = 0
    self.each do |term|
      lank += 1 if term.variable_exists?
    end
    return lank
  end

  protected
  def each &block
    @elements.each(&block)
  end

  def << term
    new_elements = []
    added_flag = false
    @elements.each do |element|
      if (element =~ term) && (not added_flag)
        new_elements << (element + term)
        added_flag = true
      else
        new_elements << element
      end
    end
    new_elements << term unless added_flag
    @elements = new_elements
    return nil
  end

  def to_nfa
    nfa = AbstInt::CalculusModel::Nfa.new
    nfa = self.generate_nfa nfa
    return nfa
  end

  def calc num
    @elements.inject(0){|sum, x| sum + (x.calc num)}
  end
end