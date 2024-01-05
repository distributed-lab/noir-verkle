## Verkle Trie Library in Noir

> This is a PoC (Proof of Contept) implementation of the Verkle Tries.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![Nargo Test 🌌](https://github.com/distributed-lab/noir-verkle/actions/workflows/test.yml/badge.svg)](https://github.com/distributed-lab/noir-verkle/actions/workflows/test.yml)


## WIP

Currently in repository is realized [cryptography spec](https://github.com/crate-crypto/verkle-trie-ref#cryptography-modules) necessary for Verkle Tries,  however it is not tested and requires further adjustments prior to utilization.

Of such, several optimizations may be made like GLV-endomorphism for faster scalar multiplication and precomputed MSM.

Additionally, it is required to examine field arithmetics, considering Noir backed curve.

Considering that Verkle Tries are made on top of Banderwagon subgroup of the Bandersnatch curve with scalar field being equal to BLS12_381, we shall use latter in the underlaying proving system - also due to the fact that for now we don't have emulation functionality. 


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


## Reference Implementations

* [go-verkle](github.com/ethereum/go-verkle)
* [go-ipa](github.com/crate-crypto/go-ipa)
* [rust-verkle](github.com/crate-crypto/rust-verkle)
* [verkle-trie-ref](https://github.com/crate-crypto/verkle-trie-ref)

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/NikitaMasych/noir-verkle/blob/main/LICENSE) file for details.