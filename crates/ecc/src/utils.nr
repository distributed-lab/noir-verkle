// rem calculates remainder of the division of a by b
pub(crate) fn rem(a: u64, b: u64) -> u64 {
    assert(b != 0);

    let q = a / b;

    a - q * b
}
