use dep::polynomial::utils::allocate_slice;

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
