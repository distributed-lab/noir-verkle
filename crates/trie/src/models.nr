use dep::ipa_multipoint::ecc::banderwagon::Element;
use dep::std::default::Default;
use dep::std::option::Option;

use crate::Stem;

struct StemMeta{
    c1: Element,
    hash_c1: Field,

    c2: Element,
    hash_c2: Field,
    
    commitment: Element,
    hash_commitment: Field
}

struct BranchMeta{
    commitment: Element,
    hash_commitment: Field
}

impl Default for BranchMeta{
    fn default() -> Self{
        Self{commitment: Element::default(), hash_commitment: 0}
    }
}

// Following definitions shall be enums, 
// however Noir does not yet support them, 
// therefore we utilize Option trait.
struct Meta{
    stem: Option<StemMeta>,
    branch: Option<BranchMeta>
}

struct BranchChild{
    stem: Option<Stem>,
    branch: Option<BranchMeta>,
}
