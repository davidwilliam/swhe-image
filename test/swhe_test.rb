require "minitest/autorun"
require Dir.pwd + "/x"

class TestSWHE < Minitest::Test
  def setup
    @x = X::SWHE.new(2,64)
    @p1 = @x.p1
    @p2 = @x.p2
    @p3 = @x.p3

    @ce = @x.ce

    @q = @x.q
  end

  def test_hensel_encoding_decoding
    m1 = 31
    m2 = Rational(17,5)
    m3 = -28
    m4 = Rational(-9,4)

    m1_h = X::SWHE.hensel_encoding(m1, @p1)
    m2_h = X::SWHE.hensel_encoding(m2, @p1)
    m3_h = X::SWHE.hensel_encoding(m3, @p1)
    m4_h = X::SWHE.hensel_encoding(m4, @p1)

    assert_equal m1, X::SWHE.hensel_decoding(m1_h, @p1)
    assert_equal m2, X::SWHE.hensel_decoding(m2_h, @p1)
    assert_equal m3, X::SWHE.hensel_decoding(m3_h, @p1)
    assert_equal m4, X::SWHE.hensel_decoding(m4_h, @p1)
  end

  def test_random_packing_unpacking
    m1 = 31
    m2 = Rational(17,5)
    m3 = -28
    m4 = Rational(-9,4)

    mm1 = X::SWHE.random_packing(m1, @p2)
    mm2 = X::SWHE.random_packing(m2, @p2)
    mm3 = X::SWHE.random_packing(m3, @p2)
    mm4 = X::SWHE.random_packing(m4, @p2)

    assert_equal m1, X::SWHE.unpacking(mm1)
    assert_equal m2, X::SWHE.unpacking(mm2)
    assert_equal m3, X::SWHE.unpacking(mm3)
    assert_equal m4, X::SWHE.unpacking(mm4)
  end

  def test_hensel_sealing

    m1 = 31
    m2 = Rational(17,5)
    m3 = -28
    m4 = Rational(-9,4)

    mm1 = X::SWHE.random_packing(m1, @p2)
    mm2 = X::SWHE.random_packing(m2, @p2)
    mm3 = X::SWHE.random_packing(m3, @p2)
    mm4 = X::SWHE.random_packing(m4, @p2)

    mm1_h = X::SWHE.hensel_sealing(mm1, @p1, @q)
    mm2_h = X::SWHE.hensel_sealing(mm2, @p1, @q)
    mm3_h = X::SWHE.hensel_sealing(mm3, @p1, @q)
    mm4_h = X::SWHE.hensel_sealing(mm4, @p1, @q)

    mm1_r = X::SWHE.hensel_unsealing(mm1_h, @p1)
    mm2_r = X::SWHE.hensel_unsealing(mm2_h, @p1)
    mm3_r = X::SWHE.hensel_unsealing(mm3_h, @p1)
    mm4_r = X::SWHE.hensel_unsealing(mm4_h, @p1)

    assert_equal m1, X::SWHE.unpacking(mm1_r)
    assert_equal m2, X::SWHE.unpacking(mm2_r)
    assert_equal m3, X::SWHE.unpacking(mm3_r)
    assert_equal m4, X::SWHE.unpacking(mm4_r)
  end

  def test_encryption_decryption
    m1 = X::SWHE.random_number(8)
    m2 = X::SWHE.random_number(8)

    c1 = @x.encrypt(m1)
    c2 = @x.encrypt(m2)

    c1_d = @x.decrypt(c1)
    c2_d = @x.decrypt(c2)

    assert_equal m1, c1_d
    assert_equal m2, c2_d

    assert_equal X::Multivector2Dff, c1.class
    assert_equal X::Multivector2Dff, c2.class
  end

  def test_homomorphic_addition
    m1 = X::SWHE.random_number(8)
    m2 = X::SWHE.random_number(8)

    c1 = @x.encrypt(m1)
    c2 = @x.encrypt(m2)

    res = @x.add(c1,c2)

    res_d = @x.decrypt(res)

    assert_equal m1 + m2, res_d
  end

  def test_homomorphic_subtraction
    m1 = X::SWHE.random_number(8)
    m2 = X::SWHE.random_number(8)

    c1 = @x.encrypt(m1)
    c2 = @x.encrypt(m2)

    res = @x.sub(c1,c2)

    res_d = @x.decrypt(res)

    assert_equal m1 - m2, res_d
  end

  def test_homomorphic_scalar_multiplication
    m1 = X::SWHE.random_number(8)
    s = X::SWHE.random_number(8)

    c1 = @x.encrypt(m1)

    res = @x.smul(c1,s)

    res_d = @x.decrypt(res)

    assert_equal m1 * s, res_d
  end

  def test_homomorphic_scalar_division
    m1 = X::SWHE.random_number(8).to_r
    s = X::SWHE.random_number(8).to_r

    c1 = @x.encrypt(m1)

    res = @x.sdiv(c1,s)

    res_d = @x.decrypt(res)

    assert_equal m1 / s, res_d
  end

  def test_homomorphic_multiplication
    m1 = X::SWHE.random_number(8)
    m2 = X::SWHE.random_number(8)

    c1 = @x.encrypt(m1,true)
    c2 = @x.encrypt(m2,true)

    res = c1.gp(@ce).gp(c2)

    res_d = @x.decrypt(res)

    assert_equal m1 * m2, res_d
  end

end
