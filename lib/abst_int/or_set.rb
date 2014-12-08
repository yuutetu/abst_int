require "abst_int/set"
require "abst_int/calculus_model/nfa"
require "abst_int/collection"

class AbstInt::OrSet
  def initialize coefficient = nil, be_variable = false
    @elements = []
    if coefficient.is_a? Fixnum
      self << (AbstInt::Set.new coefficient, be_variable)
    end
  end

  def + orset
    return self if orset.nil?
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
    current_mod = []
    self.each do |set|
      mod = set % num
      current_mod << mod
    end
    return AbstInt::Collection.new(current_mod)
  end

  def | orset
    return self if orset.is_a? NilClass
    cloned_self = self.dup
    orset.each do |set|
      cloned_self << set
    end
    return cloned_self
  end

  def & orset
    # t = Time.now
    left_dfa = (self.to_nfa.to_dfa)
    # p "[generate first dfa]", Time.now - t
    # t = Time.now
    right_dfa = (orset.to_nfa.to_dfa)
    # p "[generate second dfa]", Time.now - t
    # t = Time.now
    result = left_dfa & right_dfa
    # p "[intersection]", Time.now - t
    # t = Time.now
    result = result.to_orset
    # p "[generate semilinear set]", Time.now - t
    return result
  end

  def not
    return self.to_nfa.to_dfa.not.to_orset
  end

  def star
    new_orset = AbstInt::OrSet.new
    self.each do |set|
      new_orset << set.star
    end
    return new_orset
  end

  def to_s
    @elements.map{|element| element.to_s}.join("|")
  end

  protected
  def to_nfa
    nfa = AbstInt::CalculusModel::Nfa.new
    self.each do |set|
      nfa = set.generate_nfa nfa
    end
    return nfa
  end

  def each &block
    @elements.each(&block)
  end

  def << set
    # p "[<< enter]", self.to_s, set.to_s
    expanded = false
    @elements.each { |self_set|
      next if expanded
      expanded_set = self_set.expand(set) || set.expand(self_set)
      next if expanded_set.nil?
      expanded = true
      @elements = @elements - [self_set]
      self << expanded_set
    }
    @elements << set unless expanded
    # p "[<< exit]", self.to_s
  end
end