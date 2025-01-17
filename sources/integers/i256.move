module razor_libs::i256 {
    /// @dev Maximum I256 value as a u256.
    const MAX_I256_AS_U256: u256 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    const MAX_U256: u256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /// @dev u64 with the first bit set. An `I64` is negative if this bit is set.
    const U256_WITH_FIRST_BIT_SET: u256 = 1 << 255;

    /// When both `U256` equal.
    const EQUAL: u8 = 0;

    /// When `a` is less than `b`.
    const LESS_THAN: u8 = 1;

    /// When `b` is greater than `b`.
    const GREATER_THAN: u8 = 2;

    // ERRORS

    /// @dev When trying to convert from a u64 > MAX_I64_AS_U64 to an I64.
    const ERROR_CONVERSION_FROM_U256_OVERFLOW: u64 = 0;
    
    /// @dev When trying to convert from an negative I64 to a u64.
    const ERR0R_CONVERSION_TO_U256_UNDERFLOW: u64 = 1;

    struct I256 has copy, drop, store {
        bits: u256
    }

    public fun from_raw(x: u256): I256 {
      I256 { bits: x }
    }

    public fun from(x: u256): I256 {
        assert!(x <= MAX_I256_AS_U256, ERROR_CONVERSION_FROM_U256_OVERFLOW);
        I256 { bits: x }
    }

    public fun neg_from(x: u256): I256 {
        let ret = from(x);
        if (ret.bits > 0) *&mut ret.bits = MAX_U256 - ret.bits + 1;
        ret
    }

    public fun bits(x: I256): u256 {
        x.bits
    }

    public fun as_u256(x: I256): u256 {
        assert!(is_positive(x), ERR0R_CONVERSION_TO_U256_UNDERFLOW);
        x.bits
    }

    public fun as_u64(x: I256): u64 {
        assert!(is_positive(x), ERR0R_CONVERSION_TO_U256_UNDERFLOW);
        (x.bits as u64)
    }

    public fun truncate_to_u8(x: I256): u8 {
        ((x.bits & 0xFF) as u8)
    }

    public fun zero(): I256 {
        I256 { bits: 0 }
    }

    public fun one(): I256 {
      I256 { bits: 1 }
    }

    public fun max(): I256 {
        I256 { bits: MAX_I256_AS_U256 }
    }

    public fun is_neg(x: I256): bool {
        (x.bits & U256_WITH_FIRST_BIT_SET) != 0
    }

    public fun is_zero(x: I256): bool {
        x.bits == 0
    }

    public fun is_positive(x: I256): bool {
        U256_WITH_FIRST_BIT_SET > x.bits
    }

    public fun flip(x: I256): I256 {
        if (is_neg(x)) { abs(x) } else { neg_from(x.bits) } 
    }

    public fun abs(x: I256): I256 {
        if (is_neg(x)) from((x.bits ^ MAX_U256) + 1) else x 
    }

    /// @notice Compare `a` and `b`.
    public fun compare(a: I256, b: I256): u8 {
        if (a.bits == b.bits) return EQUAL;
        if (is_positive(a)) {
            // A is positive
            if (is_positive(b)) {
                // A and B are positive
                return if (a.bits > b.bits) GREATER_THAN else LESS_THAN
            } else {
                // B is negative
                return GREATER_THAN
            }
        } else {
            // A is negative
            if (is_positive(b)) {
                // A is negative and B is positive
                return LESS_THAN
            } else {
                // A is negative and B is negative
                return if (abs(a).bits > abs(b).bits) LESS_THAN else GREATER_THAN
            }
        }
    }

    public fun add(a: I256, b: I256): I256 {
        if (is_positive(a)) {
            // A is posiyive
            if (is_positive(b)) {
                // A and B are posistive;
                from(a.bits + b.bits)
            } else {
                // A is positive but B is negative
                let b_abs = abs(b);
                if (a.bits >= b_abs.bits) return from(a.bits - b_abs.bits);
                return neg_from(b_abs.bits - a.bits)
            }
        } else {
            // A is negative
            if (is_positive(b)) {
                // A is negative and B is positive
                let a_abs = abs(a);
                if (b.bits >= a_abs.bits) return from(b.bits - a_abs.bits);
                return neg_from(a_abs.bits - b.bits)
            } else {
                // A and B are negative
                neg_from(abs(a).bits + abs(b).bits)
            }
        }
    }

    /// @notice Subtract `a - b`.
    public fun sub(a: I256, b: I256): I256 {
        if (is_positive(a)) {
            // A is positive
            if (is_positive(b)) {
                // B is positive
                if (a.bits >= b.bits) return from(a.bits - b.bits); // Return positive
                return neg_from(b.bits - a.bits) // Return negative
            } else {
                // B is negative
                return from(a.bits + abs(b).bits) // Return positive
            }
        } else {
            // A is negative
            if (is_positive(b)) {
                // B is positive
                return neg_from(abs(a).bits + b.bits) // Return negative
            } else {
                // B is negative
                let a_abs = abs(a);
                let b_abs = abs(b);
                if (b_abs.bits >= a_abs.bits) return from(b_abs.bits - a_abs.bits); // Return positive
                return neg_from(a_abs.bits - b_abs.bits) // Return negative
            }
        }
    }

    /// @notice Multiply `a * b`.
    public fun mul(a: I256, b: I256): I256 {
        if (is_positive(a)) {
            // A is positive
            if (is_positive(b)) {
                // B is positive
                return from(a.bits * b.bits)// Return positive
            } else {
                // B is negative
                return neg_from(a.bits * abs(b).bits) // Return negative
            }
        } else {
            // A is negative
            if (is_positive(b)) {
                // B is positive
                return neg_from(abs(a).bits * b.bits) // Return negative
            } else {
                // B is negative
                return from(abs(a).bits * abs(b).bits ) // Return positive
            }
        }
    }

    /// @notice Divide `a / b`.
    public fun div(a: I256, b: I256): I256 {
        if (is_positive(a)) {
            // A is positive
            if (is_positive(b)) {
                // B is positive
                return from(a.bits / b.bits) // Return positive
            } else {
                // B is negative
                return neg_from(a.bits / abs(b).bits ) // Return negative
            }
        } else {
            // A is negative
            if (is_positive(b)) {
                // B is positive
                return neg_from(abs(a).bits / b.bits) // Return negative
            } else {
                // B is negative
                return from(abs(a).bits / abs(b).bits ) // Return positive
            }
        }    
    }

    public fun mod(a: I256, b: I256): I256 {
        let a_abs = abs(a);
        let b_abs = abs(b);

        let result = a_abs.bits % b_abs.bits;

       if (is_neg(a) && result != 0)   neg_from(result) else from(result)
    }

    public fun shr(a: I256, rhs: u8): I256 { 

     I256 {
        bits: if (is_positive(a)) {
        a.bits >> rhs
       } else {
         let mask = (1 << ((256 - (rhs as u16)) as u8)) - 1;
         (a.bits >> rhs) | (mask << ((256 - (rhs as u16)) as u8))
        }
     } 
    }     

    public fun shl(a: I256, rhs: u8): I256 {
        I256 {
            bits: a.bits << rhs
        } 
    }

    public fun or(a: I256, b: I256): I256 {
      I256 {
        bits: a.bits | b.bits
      } 
    }

    public fun and(a: I256, b: I256): I256 {
      I256 {
        bits: a.bits & b.bits
      } 
    }

    #[test]
    fun test_compare() {
        assert!(compare(from(123), from(123)) == EQUAL, 0);
        assert!(compare(neg_from(123), neg_from(123)) == EQUAL, 0);
        assert!(compare(from(234), from(123)) == GREATER_THAN, 0);
        assert!(compare(from(123), from(234)) == LESS_THAN, 0);
        assert!(compare(neg_from(234), neg_from(123)) == LESS_THAN, 0);
        assert!(compare(neg_from(123), neg_from(234)) == GREATER_THAN, 0);
        assert!(compare(from(123), neg_from(234)) == GREATER_THAN, 0);
        assert!(compare(neg_from(123), from(234)) == LESS_THAN, 0);
        assert!(compare(from(234), neg_from(123)) == GREATER_THAN, 0);
        assert!(compare(neg_from(234), from(123)) == LESS_THAN, 0);
    }

    #[test]
    fun test_add() {
        assert!(add(from(123), from(234)) == from(357), 0);
        assert!(add(from(123), neg_from(234)) == neg_from(111), 0);
        assert!(add(from(234), neg_from(123)) == from(111), 0);
        assert!(add(neg_from(123), from(234)) == from(111), 0);
        assert!(add(neg_from(123), neg_from(234)) == neg_from(357), 0);
        assert!(add(neg_from(234), neg_from(123)) == neg_from(357), 0);

        assert!(add(from(123), neg_from(123)) == zero(), 0);
        assert!(add(neg_from(123), from(123)) == zero(), 0);
    }

    #[test]
    fun test_sub() {
        assert!(sub(from(123), from(234)) == neg_from(111), 0);
        assert!(sub(from(234), from(123)) == from(111), 0);
        assert!(sub(from(123), neg_from(234)) == from(357), 0);
        assert!(sub(neg_from(123), from(234)) == neg_from(357), 0);
        assert!(sub(neg_from(123), neg_from(234)) == from(111), 0);
        assert!(sub(neg_from(234), neg_from(123)) == neg_from(111), 0);

        assert!(sub(from(123), from(123)) == zero(), 0);
        assert!(sub(neg_from(123), neg_from(123)) == zero(), 0);
    }

    #[test]
    fun test_mul() {
        assert!(mul(from(123), from(234)) == from(28782), 0);
        assert!(mul(from(123), neg_from(234)) == neg_from(28782), 0);
        assert!(mul(neg_from(123), from(234)) == neg_from(28782), 0);
        assert!(mul(neg_from(123), neg_from(234)) == from(28782), 0);
    }

    #[test]
    fun test_div() {
        assert!(div(from(28781), from(123)) == from(233), 0);
        assert!(div(from(28781), neg_from(123)) == neg_from(233), 0);
        assert!(div(neg_from(28781), from(123)) == neg_from(233), 0);
        assert!(div(neg_from(28781), neg_from(123)) == from(233), 0);
    }
}
