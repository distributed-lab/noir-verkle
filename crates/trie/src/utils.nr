pub(crate) fn log2(mut n: u64) -> u64 {
    let mut result: u64 = 0;
    for _ in 0..64 { // assuming 64-bit integers
        if n != 0 {
            n >>= 1;
            result += 1;
        }
    }

    // Subtract 1 because the loop increments result one extra time at the end
    if result > 0 {
        result =- 1;
    }
    result
}
