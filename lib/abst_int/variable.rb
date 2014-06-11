class AbstInt::Variable
  attr_reader :id
  @@id = 0

  def initialize
    @id = @@id
    @@id += 1
  end

  def <=> variable
    return nil unless variable.instance_of? AbstInt::Variable
    return (@id <=> variable.id)
  end

  def to_s
    "x_#{@id}"
  end
end