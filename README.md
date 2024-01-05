## Verkle Trie Library in Noir

> This is a PoC (Proof of Contept) implementation of the [Verkle Tries](https://verkle.dev/).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![Nargo Test 🌌](https://github.com/distributed-lab/noir-verkle/actions/workflows/test.yml/badge.svg)](https://github.com/distributed-lab/noir-verkle/actions/workflows/test.yml)


## WIP

Currently in repository is realized [cryptography spec](https://github.com/crate-crypto/verkle-trie-ref#cryptography-modules) necessary for `Verkle Tries`,  however it is not tested and requires further adjustments prior to utilization.

Of such, several optimizations may be made like `GLV-endomorphism` for faster scalar multiplication and precomputed `MSM`.

Additionally, it is required to examine field arithmetics, considering `Noir` backed curve.

Considering that `Verkle Tries` are made on top of `Banderwagon` subgroup of the `Bandersnatch` curve with scalar field being equal to `BLS12_381`, we shall use latter in the underlaying proving system - also due to the fact that for now we don't have emulation functionality. 


## Installation

```toml
[dependencies]
crs = { tag = "main", git = "https://github.com/distributed-lab/noir-verkle", directory = "crates/crs"}
ecc = { tag = "main", git = "https://github.com/distributed-lab/noir-verkle", directory = "crates/ecc"}
ipa = { tag = "main", git = "https://github.com/distributed-lab/noir-verkle", directory = "crates/ipa"}
multipoint = { tag = "main", git = "https://github.com/distributed-lab/noir-verkle", directory = "crates/multipoint"}
polynomial = { tag = "main", git = "https://github.com/distributed-lab/noir-verkle", directory = "crates/polynomial"}
transcript = { tag = "main", git = "https://github.com/distributed-lab/noir-verkle", directory = "crates/transcript"}
```
## Packages

This library is split into six crates:
* `crs` - Common Reference String
* `ecc` - Bandersnatch and Banderwagon
* `ipa` - Inner product argument
* `multipoint` - Multipoint proofs
* `polynomial` - Barycentric interpolation
* `transcript` - Fiat-Shamir protocol


## Reference

### Articles

1. [Verkle Trees by John Kuzmaul](https://math.mit.edu/research/highschool/primes/materials/2018/Kuszmaul.pdf)
2. [Barycentric Lagrange Interpolation](https://people.maths.ox.ac.uk/trefethen/barycentric.pdf)
3. [Bandersnatch: a fast elliptic curve built over the BLS12-381 scalar field](https://eprint.iacr.org/2021/1152.pdf)
4. [GLV Decomposition for Multi-Scalar Multiplication (MSM)](https://hackmd.io/@drouyang/glv)
5. [Understanding The Wagon - From Bandersnatch to Banderwagon](https://hackmd.io/@6iQDuIePQjyYBqDChYw_jg/BJBNcv9fq)
6. [Bandersnatch Implementation Notes](https://hackmd.io/wliPP_RMT4emsucVuCqfHA?view)
7. [Efficient Batch Zero-Knowledge Arguments for Low Degree Polynomials, 2.2](https://eprint.iacr.org/2018/045.pdf)
8. [Faster batch forgery identification](https://eprint.iacr.org/2012/549.pdf)
9. [Inner Product Arguments](https://dankradfeist.de/ethereum/2021/07/27/inner-product-arguments.html)
10. [Proofs for Inner Pairing Products and Applications](https://eprint.iacr.org/2019/1177.pdf)
11. [Weak Fiat-Shamir Attacks on Modern Proof Systems](https://eprint.iacr.org/2023/691.pdf)
12. [PCS multiproofs using random evaluation](https://dankradfeist.de/ethereum/2021/06/18/pcs-multiproofs.html)
13. [Multipoint opening argument](https://zcash.github.io/halo2/design/proving-system/multipoint-opening.html#multipoint-opening-argument)

### Implementations

* [go-verkle](https://github.com/ethereum/go-verkle)
* [go-ipa](https://github.com/crate-crypto/go-ipa)
* [rust-verkle](https://github.com/crate-crypto/rust-verkle)
* [verkle-trie-ref](https://github.com/crate-crypto/verkle-trie-ref)

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/NikitaMasych/noir-verkle/blob/main/LICENSE) file for details.