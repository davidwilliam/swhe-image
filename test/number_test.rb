require "minitest/autorun"
require Dir.pwd + "/x"

class TestNumber < Minitest::Test
  def setup
    @x = X::SWHE.new(2,64)
    @p1 = @x.p1
    @p2 = @x.p2
    @p3 = @x.p3

    @q = @x.q
  end

  def test_number
    # numbers
    ns = (0..10).to_a
    ns_h = ns.map{|n| X::SWHE.hensel_encoding(n,@x.p1)}

    # encrypted numbers
    cns = ns.map{|n| @x.encrypt(n)}

    # sample number
    m1 = 532

    # ten
    cten = cns[2].scalar_mul(ns_h[5])

    # hundred
    chundred = cten.scalar_mul(ns_h[10])

    # building the number
    res = chundred.scalar_mul(ns_h[5]).add(cten.scalar_mul(ns_h[3])).add(cns[2])

    assert_equal m1, @x.decrypt(res)
  end
end
