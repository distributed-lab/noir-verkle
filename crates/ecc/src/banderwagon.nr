use dep::std::ec::tecurve::curvegroup::{Point, Curve};
use dep::std::ec::tecurve::affine::Point as AffinePoint;
use dep::std::field::bytes32_to_field;
use dep::std::option;

use crate::bandersnatch::curvegroup::bandersnatch;
use crate::bandersnatch::affine::compute_y;
use crate::bandersnatch::legendre;

global COMPRESSED_SIZE = 32; // 32 bytes for X coordinate, since Y parity is only positive
global UNCOMPRESSED_SIZE = 64; // 32 bytes for each X and Y coordinates

// Element of the Banderwagon prime order subgroup of Bandersnatch.
// Provides additional safety mechanics.
struct Element {
    inner: Point
}

impl Element {
    // Element from big-endian bytes
    pub fn new(bytes: [u8; COMPRESSED_SIZE]) -> Option<Self>{
        let x = bytes32_to_field(bytes);

        if !Element::subgroup_check(x){
            Option::none()
        }

        let y = compute_y(x, true);

        let point = AffinePoint{x, y}.into_group();

        Option::some(Self{inner: point})
    }

    // Check that 1 - ax^2 is a square using Legendre symbol
    fn subgroup_check(x: Field) -> bool{
        let value = 1 - bandersnatch().a * x * x;
        legendre(value) == 1
    }

    // Equality check for Banderwagon has to test the equivalence class 
    // {(x, y), (-x, -y)}, thus check: x1*y2 == x2*y2.
    pub fn eq(self, other: Self) -> bool{
        let x1 = self.inner.x;
        let y1 = self.inner.y;

        let x2 = other.inner.x;
        let y2 = other.inner.y;

        if (x1 == 0) & (y1 == 0){
            false
        }

        if (x2 == 0) & (y2 == 0){
            false
        }

        x1 * y2 == y1 * x2
    }
    
    pub fn generator() -> Self{
        Self{inner: bandersnatch().gen}
    }

    pub fn zero() -> Self{
        Self{inner: Point::zero()}
    }

    pub fn negate(self) -> Self{
        Self{inner: self.inner.negate()}
    }

    pub fn add(self, rhs: Self) -> Self{
        Self{inner: bandersnatch().add(self.inner, rhs.inner)}
    }

    pub fn sub(self, rhs: Self) -> Self{
        self.add(rhs.negate())
    }

    pub fn mul(e: Self, n: Field) -> Self{
        Self{inner: bandersnatch().mul(n, e.inner)}
    }

    pub fn msm<N>(elements: [Self; N], scalars: [Field; N]) -> Self{
        let mut points: [Point; N] = [Point::zero(); N];
        for i in 0..N{
            points[i] = elements[i].inner;
        }
        Self{inner: bandersnatch().msm(scalars, points)}
    }
}
