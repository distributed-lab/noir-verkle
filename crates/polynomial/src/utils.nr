use dep::std::unsafe::zeroed;

// This function is needed since in Noir it is abcent and 
// premature allocation is available only for arrays with compile time lenght and 
// we can't use a simple expressions with generics to overcome this in a variery of usecases 
// (like N*2 for weights and inverted weights in barycentric).
pub fn allocate_slice<T>(len: u64) -> [T] {
    let mut res: [T] = [];

    for _ in 0..len {
        res = res.push_back(zeroed());
    }

    res
}
