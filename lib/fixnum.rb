# stack level too deep
# class Fixnum
#   def mul_with_abst_int num
#     return num * self if (num.is_a? AbstInt) || (num.is_a? AbstInt::Integer)
#     self.mul_without_abst_int num
#   end

#   alias :mul_without_abst_int :*
#   alias :* :mul_with_abst_int
# end