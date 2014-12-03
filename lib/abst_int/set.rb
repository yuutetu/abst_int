require "abst_int/term"

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

  def to_s
    @elements.map{|element| element.to_s}.join("+")
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
end