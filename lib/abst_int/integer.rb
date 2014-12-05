require "abst_int"

class AbstInt::Integer
  def initialize abst_int
    @abst_int = abst_int
  end

  def + abst_int_or_int
    @abst_int + abst_int_or_int
  end

  def - abst_int_or_int
    @abst_int - abst_int_or_int
  end

  def * abst_int_or_int
    @abst_int * abst_int_or_int
  end

  def / abst_int_or_int
    @abst_int / abst_int_or_int
  end

  def % num
    @abst_int % num
  end

  def to_s
    @abst_int.to_s
  end

  def _terms
    @abst_int.terms
  end
end