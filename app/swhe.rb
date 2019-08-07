module X
  class SWHE
    attr_accessor :k1, :k2, :k1_h, :k2_h,
                  :k1_h_inverse, :k2_h_inverse,
                  :p1, :p2, :p3, :q,
                  :ce

    def initialize(gamma,lambda)

      @p1 = self.class.random_prime(gamma * lambda)
      @p2 = self.class.random_prime(gamma * lambda + 1)
      @p3 = self.class.random_prime(gamma * lambda + 1)
      @q = @p1 * @p2 * @p3

      valid_k1 = false
      while valid_k1 == false
        begin
          k1_ = self.class.random_number(lambda)
          @k1 = self.class.random_packing(k1_,@p2)
          @k1_h = self.class.hensel_sealing(@k1, @p1, @q)

          @k1_h_inverse = @k1_h.inverse

          valid_k1 = true
        rescue => e
        end
      end

      valid_k2 = false
      while valid_k2 == false
        begin
          k2_ = self.class.random_number(lambda)
          @k2 = self.class.random_packing(k1_,@p2)
          @k2_h = self.class.hensel_sealing(@k2, @p1, @q)

          @k2_h_inverse = @k2_h.inverse

          valid_k2 = true
        rescue => e
        end
      end

      @ce = encrypted_isomorphic_multivector
    end

    def self.random_number(bits)
      OpenSSL::BN::rand(bits).to_i
    end

    def self.random_prime(bits)
      OpenSSL::BN::generate_prime(bits).to_i
    end

    def self.hensel_encoding(n, p)
      Xp.new([p], n.numerator, n.denominator).to_i
    end

    def self.hensel_decoding(n, p)
      Xp.new([p], n.numerator, n.denominator).to_r
    end

    def self.random_packing(m,p2,iso=false)
      p2_bits = p2.bit_length

      rs = Array.new(4){ SWHE.random_number(p2_bits / 8 + 4) }

      d1 = Rational(rs[0],rs[1])
      d2 = Rational(rs[2],rs[3])

      data = Array.new(3){
        [0,1].sample == 1 ? 1 * SWHE.random_number(p2_bits / 8 + 4) : (-1) * SWHE.random_number(p2_bits / 8 + 4)
      }

      data << (m - data.inject(:+))

      m_data = [
        (data[0] + d1),
        (data[1] - d1),
        (data[2] + d2),
        (data[3] - d2)
      ]

      m_data

      mm = Multivector2D.new m_data

      if iso
        e = Multivector2D.new [
          Rational(1,2),
          Rational(1,2),
          Rational(1,2),
          Rational(-1,2)
        ]
        mme = mm.gp(e)
        return mme
      else
        return mm
      end
    end

    def self.unpacking(mm)
      mm.number
    end

    def self.hensel_sealing(mm,p1,q)
      mm_h = Multivector2Dff.new mm.data.map{|m| hensel_encoding(m, p1) }, q
    end

    def self.hensel_unsealing(mm_h,p1)
      mm = Multivector2D.new mm_h.data.map{|m| hensel_decoding(m, p1) }
    end

    def encrypted_isomorphic_multivector
      one = self.class.random_packing(1,p2,true)
      one_h = self.class.hensel_sealing(one,p1,q)

      k2_h_inverse.gp(one_h).gp(k1_h_inverse)
    end

    def gp_encrypt(mm)
      k1_h.gp(mm).gp(k2_h)
    end

    def gp_decrypt(mm)
      k1_h_inverse.gp(mm).gp(k2_h_inverse)
    end

    def encrypt(m,iso=true)
      mm = self.class.random_packing(m,p2,iso)
      one = self.class.random_packing(1,p2,iso)

      mm_h = self.class.hensel_sealing(mm,p1,q)
      one_h = self.class.hensel_sealing(one,p1,q)

      c = gp_encrypt(one_h.gp(mm_h).gp(one_h))
      c
    end

    def decrypt(c)
      mm_h = gp_decrypt(c)
      mm = self.class.hensel_unsealing(mm_h,p1)
      m = self.class.unpacking(mm)
      m
    end

    def add(c1,c2)
      c1 + c2
    end

    def sub(c1,c2)
      c1 - c2
    end

    def smul(c1,s)
      c1.scalar_mul(s)
    end

    def sdiv(c1,s)
      c1.scalar_div(s)
    end

    def mul(c1,c2)
      c1.gp(c2)
    end

  end
end
