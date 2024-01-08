use dep::std::ec::tecurve::curvegroup::{Point, Curve};
use dep::std::ec::tecurve::affine::Point as AffinePoint;
use dep::std::field::bytes32_to_field;
use dep::std::option;
use dep::std::{
    cmp::Eq,
    default::Default,
    ops::{Add, Sub}
};

use crate::ecc::bandersnatch::{curvegroup::bandersnatch, affine::compute_y, legendre};

global COMPRESSED_SIZE = 32; // 32 bytes for X coordinate, since Y parity is only positive
global UNCOMPRESSED_SIZE = 64; // 32 bytes for each X and Y coordinates

// Element of the Banderwagon prime order subgroup of Bandersnatch.
// Provides additional safety mechanics.
struct Element {
    inner: Point
}

impl Add for Element{
    fn add(self, other: Element) -> Element{ 
        Element{inner: bandersnatch().add(self.inner, other.inner)}
    }
}

impl Sub for Element{
    fn sub(self, other: Element) -> Element{ 
        Element{inner: bandersnatch().add(self.inner, other.inner.negate())}
    }
}

impl Eq for Element{
    // Equality check for Banderwagon has to test the equivalence class 
    // {(x, y), (-x, -y)}, thus check: x1*y2 == x2*y2.
    fn eq(self, other: Element) -> bool{
        let (x1, y1) = (self.inner.x, self.inner.y);
        let (x2, y2) = (other.inner.x, other.inner.y);

        if (x1 == 0) & (y1 == 0){
            false
        }

        if (x2 == 0) & (y2 == 0){
            false
        }

        x1 * y2 == y1 * x2
    }
}

impl Default for Element{
    fn default() -> Element{
        Element{inner: Point::zero()}
    }
}

impl Element {
    // Element from big-endian bytes.
    pub fn new(bytes: [u8; COMPRESSED_SIZE]) -> Option<Self>{
        let x = bytes32_to_field(bytes);

        if !Element::subgroup_check(x){
            Option::none()
        }

        let y = compute_y(x, true);

        let point = AffinePoint{x, y}.into_group();

        Option::some(Self{inner: point})
    }

    // Check that 1 - ax^2 is a square using Legendre symbol.
    fn subgroup_check(x: Field) -> bool{
        let value = 1 - bandersnatch().a * x * x;
        legendre(value) == 1
    }
    
    // Uncompressed serialization.
    pub fn serialize(self) -> [u8; COMPRESSED_SIZE]{
        let point = self.inner.into_affine();        
        let mut affineX = point.x;

        affineX *= point.y.sgn0() as Field;
        
        let serialised = affineX.to_be_bytes(COMPRESSED_SIZE);
        let mut result = [0; COMPRESSED_SIZE];

        for i in 0..serialised.len(){
            result[i] = serialised[i];
        }
        
        result
    }

    pub fn generator() -> Self{
        Self{inner: bandersnatch().gen}
    }

    // TODO: refactor to trait, once non-homogeneous operands are supported.
    fn mul(self, n: Field) -> Self{ 
        Self{inner: bandersnatch().mul(n, self.inner)}
    }

    pub fn msm<N>(elements: [Self; N], scalars: [Field; N]) -> Self{
        let mut points: [Point; N] = [Point::zero(); N];
        for i in 0..N{
            points[i] = elements[i].inner;
        }
        Self{inner: bandersnatch().msm(scalars, points)}
    }
}
