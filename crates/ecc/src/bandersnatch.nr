use crate::utils::rem;

// Computes Legendre symbol: result is one of {1, 0, -1}.
pub(crate) fn legendre(a: Field) -> Field {
    // Base field of the BLS12_381:
    let p = 52435875175126190479447740508185965837690552500527637822603658699938581184513;
    let e = (p - 1) / 2;

    // TODO: change this
    rem(a.pow_32(e) as u64, p as u64) as Field
}

mod affine {
    use dep::std::ec::tecurve::affine::{Point, Curve};
    use dep::std::ec::sqrt;

    // Bandersnatch is a curve defined in a paper: https://eprint.iacr.org/2021/1152.pdf
    pub(crate) fn bandersnatch() -> Curve {
        // See section 3.2 for parameters
        Curve::new(
            -5,
            138827208126141220649022263972958607803 / 171449701953573178309673572579671231137,
            // G
            Point::new(
                0x29c132cc2c0b34c5743711777bbe42f32b79c022ad998465e1e71866a252ae18,
                0x2a6c669eda123e0f157d8b50badcd586358cad81eee464605e3167b6cc974166
            )
        )
    }

    /*
        Assuming Twisted Edwards representation:

        ax^2 + y^2 = 1 + dx^2y^2
        y^2 - dx^2y^2 = 1 - ax^2
        y^2(1 - dx^2) = 1 - ax^2
        y^2 = (1 - ax^2) / (1 - dx^2)
    */
    pub(crate) fn compute_y(x: Field, y_parity: bool) -> Field {
        let curve = bandersnatch();

        let x_square = x * x;

        let numerator = 1 - curve.a * x_square; // (1 - ax^2)
        let denominator = 1 / (1 - curve.d * x_square); // 1 / (1 - dx^2)

        let root = sqrt(numerator / denominator);

        if y_parity {
            root
        };

        -root
    }
}

mod curvegroup {
    use dep::std::ec::tecurve::curvegroup::Curve;
    use crate::bandersnatch::affine::bandersnatch as AffineBandersnatch;

    pub(crate) fn bandersnatch() -> Curve {
        AffineBandersnatch().into_group()
    }
}
