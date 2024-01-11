use dep::ipa_multipoint::ipa::IPAConfig;
use dep::ipa_multipoint::crs::CRS;
use dep::ipa_multipoint::polynomial::PrecomputedWeights;

use crate::committer::TrieCommitterTrait;
use crate::utils::log2;

struct Committer<VECTOR_WIDTH>{
    ipa_config: IPAConfig<VECTOR_WIDTH>,
    transcript_genesis_label: [u8],
}

impl<VECTOR_WIDTH> TrieCommitterTrait for Committer<VECTOR_WIDTH>{

}

impl<VECTOR_WIDTH> Committer<VECTOR_WIDTH>{
    pub fn new(crs_seed: str, transcript_genesis_label: str) -> Self{
        let crs = CRS::new(crs_seed.as_bytes().as_slice());
        let precomputed_weights = PrecomputedWeights::new(VECTOR_WIDTH);
        let rounds = Committer::compute_rounds(VECTOR_WIDTH);
        let ipa_config = IPAConfig{crs, precomputed_weights, rounds};

        let transcript_genesis_label = transcript_genesis_label.as_bytes().as_slice();

        Self{ipa_config, transcript_genesis_label}
    }

    fn compute_rounds(width: u64) -> u64 {
        assert(width != 0);

        let is_pow2 = (width & (width - 1)) == 0;

        assert(is_pow2);

        log2(width)
    }
}
