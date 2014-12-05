class AbstInt::Collection < BasicObject
  class NilClass
  end

  def initialize args
    @objects = args
  end

  def == *args
    self.method_missing :==, *args
  end

  def != *args
    self.method_missing :"!=", *args
  end

  def equal? *args
    self.method_missing :equal?, *args
  end

  def method_missing method_name, *args
    result = ::AbstInt::Collection::NilClass.new
    @objects.each do |object|
      if result.is_a? ::AbstInt::Collection::NilClass
        result = object.send(method_name, *args)
      else
        raise ::AbstInt::MultiResultError, "There are more results than one." unless result == object.send(method_name, *args)
      end
    end
    return result
  end
end