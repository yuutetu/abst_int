class AbstInt::Set
  include Enumerable
  # for debug
  attr_reader :elements

  def initialize term = nil
    @elements = []
    @elements << term unless term.nil?
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

  def each &block
    @elements.each &block
  end

  # for debug
  def to_s
    @elements.map{|element| element.to_s}.join("+")
  end

  def initialize_copy set
    @elements = []
    set.elements.each do |element|
      @elements << element.dup
    end
  end
end