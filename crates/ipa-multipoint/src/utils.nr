use dep::std::unsafe::zeroed;

// This function is needed since in Noir it is abcent and 
// premature allocation is available only for arrays with compile time lenght and 
// we can't use a simple expressions with generics to overcome this in a variery of usecases 
// (like N*2 for weights and inverted weights in barycentric).
pub(crate) fn allocate_slice<T>(len: u64) -> [T] {
    let mut res: [T] = [];

    for _ in 0..len {
        res = res.push_back(zeroed());
    }

    res
}

pub(crate) fn halve<T>(x: [T]) -> ([T], [T]) {
    let mid = (x.len() / 2) as u64;

    let mut left = allocate_slice(mid);
    let mut right = allocate_slice(mid);

    for i in 0..mid {
        left[i] = x[i];
        right[i] = x[mid+i];
    }

    (left, right)
}

pub(crate) fn u64_to_u8(num: u64) -> [u8; 8] {
    let mut out: [u8; 8] = [0; 8];
    for i in 0..8 {
        out[i] = (num >> (56 - (i * 8))) as u8;
    }

    out
}