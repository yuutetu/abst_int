require "abst_int/set"

class AbstInt::OrSet
  class EmptyOrSetError < StandardError
  end

  def initialize coefficient = nil, be_variable = false
    @elements = []
    if coefficient.is_a? Fixnum
      self << (AbstInt::Set.new coefficient, be_variable)
    end
  end

  def + orset
    new_orset = AbstInt::OrSet.new
    orset.each do |set1|
      self.each do |set2|
        new_orset << (set1 + set2)
      end
    end
    return new_orset
  end

  def - orset
    self + orset * AbstInt::OrSet.new(-1)
  end

  def * orset
    new_orset = AbstInt::OrSet.new
    orset.each do |set1|
      self.each do |set2|
        new_orset << (set1 * set2)
      end
    end
    return new_orset
  end

  def % num
    current_mod = nil
    self.each do |set|
      mod = set % num
      if current_mod && current_mod != mod
        raise AbstInt::MultiResultError, "There are more results than one."
      end
      current_mod = mod
    end
    return current_mod || (raise EmptyOrSetError)
  end

  def to_s
    @elements.map{|element| element.to_s}.join("|")
  end

  protected
  def each &block
    @elements.each(&block)
  end

  def << set
    @elements << set
  end
end