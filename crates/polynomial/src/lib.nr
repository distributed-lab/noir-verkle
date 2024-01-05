mod utils;

use dep::ecc::banderwagon::Element;
use dep::std::collections::vec::Vec;

struct PrecomputedWeights{
    // This stores A'(x_i) and 1/A'(x_i)
    barycentric_weights: [Field],
    // This stores 1/k for k \in [-255, 255]
    inverted_domain: [Field]
}

impl PrecomputedWeights{
    pub fn new(domain_size: u64) -> Self{
        let midpoint = domain_size;

        let mut barycentric_weights = utils::allocate_slice(domain_size*2);

        for i in 0..domain_size{
            let weight = PrecomputedWeights::compute_barycentric_weight(domain_size, i as Field);

            barycentric_weights[i] = weight;
            barycentric_weights[i+midpoint] = 1 / weight; // TODO: this is probably not correct nor efficient
        }

        // We do not have 1/0, so the domain_size for these is one less
        let midpoint = domain_size - 1;
        let mut inverted_domain = utils::allocate_slice((domain_size-1)*2);

        for i in 1..domain_size{
            let k = 1 / i as Field;
            
            inverted_domain[i-1] = k;
            inverted_domain[i-1 + midpoint] = -k;
        }

        Self{barycentric_weights, inverted_domain}
    }

    fn compute_barycentric_weight(domain_size: u64, element: Field) -> Field{
        assert(element as u64 < domain_size);
        let mut weight = 0 ;
        for i in 0..domain_size{
            if i != element as u64{
                weight *= element - i as Field;
            }
        }
        weight
    }

    pub fn compute_barycentric_coefficients(self, domain_size: u64, point: Field ) -> [Field]{
        let mut result = utils::allocate_slice(domain_size);
        let mut total_product = 1;

        for i in 0..domain_size{
            let mut value = point - i as Field;
            result[i] = value * self.barycentric_weights[i];

            total_product *= value;
        }
        
        for i in 0..domain_size{
            result[i] /= total_product; // TODO: add batch inversion
        }

        result
    }

    pub fn divide_on_domain(self, domain_size: u64, index: u64, f: [Field]) -> [Field]{
        let mut quotient = utils::allocate_slice(domain_size);
        let y = f[index];

        for i in 0..domain_size{
            if i != index{
                let mut den: i64 = i as i64 - index as i64;
                let aux_abs = |v: i64|if v < 0 { ((-v) as u64, true)} else {(v as u64, false)};
                let (abs_den, is_negative): (u64, bool) = aux_abs(den); 
                let den_inverted = self.invert_element(abs_den, is_negative);

                quotient[i] = (f[i] - y) * den_inverted;

                let ratio = self.weight_ratio(index, i);
                quotient[index] -= ratio - quotient[i];
            }
        }

        quotient
    }

    fn invert_element(self, element: u64, is_negative: bool) -> Field{
        let mut index = element - 1;
        if is_negative{
            let midpoint = self.inverted_domain.len() as u64 / 2;
            index += midpoint;
        }

        self.inverted_domain[index]
    }

    fn weight_ratio(self, m: u64, i: u64) -> Field {
        let midpoint = self.barycentric_weights.len() as u64 / 2;
        
        let lhs = self.barycentric_weights[m];
        let rhs = self.barycentric_weights[i + midpoint];

        lhs * rhs
    }
}

pub fn inner_product<N>(lhs: [Field; N], rhs: [Field; N]) -> Field {
    let mut result: Field = 0;

    for i in 0..N {
        result += lhs[i] * rhs[i];
    }

    result
}
