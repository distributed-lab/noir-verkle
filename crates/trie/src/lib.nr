mod storage;
mod committer;
mod utils;
mod models;

use dep::ipa_multipoint::ecc::banderwagon::Element;
use dep::ipa_multipoint::multipoint::MultiProof;
use dep::std::option::Option;

use crate::storage::{TrieStorageTrait, memory::Storage as MemStorage};
use crate::committer::{TrieCommitterTrait, multipoint::Committer as MultipointCommitter};

global NODE_WIDTH = 256;
global CRS_SEED = "eth_verkle_oct_2021";
global TRANSCRIPT_GENESIS_LABEL = "vt";

// Following constants size is denominated in bytes:
global STEM_SIZE = 31;
global LEAF_KEY_SIZE = 32;
global LEAF_VALUE_SIZE = 32;

type Stem = [u8; STEM_SIZE];
type Key = [u8; LEAF_KEY_SIZE];
type Value = [u8; LEAF_VALUE_SIZE];

trait TrieTrait{ 
    fn insert(self, k: Key, v: Value) -> bool;
    fn update(self, k: Key, v: Value) -> bool;
    fn verify(self, k: Key, v: Value, proof: MultiProof) -> bool;
    fn prove(self, k: Key, v: Value) -> Option<MultiProof>;
}

struct VerkleTrie<Storage, Committer>{
    storage: Storage,
    committer: Committer
}

impl TrieTrait for VerkleTrie<MemStorage, MultipointCommitter<NODE_WIDTH>>{
    fn insert(self, k: Key, v: Value) -> bool{
        false
    }

    fn update(self, k: Key, v: Value) -> bool{
        false
    }

    fn verify(self, k: Key, v: Value, proof: MultiProof) -> bool{
        false
    }

    fn prove(self, k: Key, v: Value) -> Option<MultiProof>{
        Option::none()
    }
}

impl VerkleTrie<MemStorage, MultipointCommitter<NODE_WIDTH>>{
    fn new() -> Self{
        let committer = MultipointCommitter::new(CRS_SEED, TRANSCRIPT_GENESIS_LABEL);
        let storage = MemStorage::new();
        Self{committer, storage}
    }
}
