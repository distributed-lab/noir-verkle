## Verkle Trie Library in Noir

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

This is a PoC (Proof of Contept) implementation of the Verkle Tries.

## WIP

Currently in repository is realized [cryptography spec](https://github.com/crate-crypto/verkle-trie-ref#cryptography-modules) necessary for Verkle Tries,  however it is not tested and requires further adjustments prior to utilization.

Of such, several optimizations may be made like GLV-endomorphism for faster scalar multiplication and precomputed MSM.

Additionally, it is required to examine field arithmetics, considering Noir backed curve.

Considering that Verkle Tries are made on top of `Banderwagon` subgroup of the `Bandersnatch` curve with scalar field being equal to `BLS12_381`, we shall use latter in the underlaying proving system - also due to the fact that for now we don't have emulation functionality. 

## Reference Implementations

Go:

* [github.com/ethereum/go-verkle](github.com/ethereum/go-verkle)
* [github.com/crate-crypto/go-ipa](github.com/crate-crypto/go-ipa)


Rust:
* [github.com/crate-crypto/rust-verkle](github.com/crate-crypto/rust-verkle)
* [github.com/crate-crypto/banderwagon](github.com/crate-crypto/banderwagon)

Python:

* [https://github.com/crate-crypto/verkle-trie-ref](https://github.com/crate-crypto/verkle-trie-ref)

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/NikitaMasych/noir-verkle/blob/main/LICENSE) file for details.