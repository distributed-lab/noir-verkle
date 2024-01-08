use dep::std::collections::vec::Vec;
use dep::std::sha256::digest as sha256;

use crate::ecc::banderwagon::Element;
use crate::utils::u64_to_u8;

struct CRS<N>{
    G: [Element; N],
    Q: Element    
}

impl<N> CRS<N>{
    pub fn new(seed: [u8]) -> Self{
        let G = generate_random_points(seed);
        let Q = Element::generator();

        Self{G, Q}
    }
    
    pub fn commit(self, polynomial: Vec<Field>) -> Element{
        assert(polynomial.len() == N); // TODO: add meaningful message

        let mut scalars = [0; N];
        for i in 0..N{
            scalars[i] = polynomial.slice[i];
        }
        
        Element::msm(self.G, scalars)
    }
}

fn generate_random_points<N>(seed: [u8]) -> [Element; N] {
    let mut points = [Element::default(); N];
    let mut counter = 0;
    let mut iterator = N;

    for i in 0..iterator {
        let mut input = seed;
        let delta: [u8] = u64_to_u8(i);
        input = seed.append(delta);

        let digest = sha256(input);
        let point = Element::new(digest);

        if point.is_some() {
            points[counter] = point.unwrap();
            counter += 1;
        } else {
            iterator += 1;
        }
    }

    points
}
