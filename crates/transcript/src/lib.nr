use dep::ecc::banderwagon::{Element, COMPRESSED_SIZE};
use dep::std::sha256::digest as sha256;
use dep::std::field::bytes32_to_field;

// Fiat-Shamir transcript protocol
struct Transcript{
    // TODO: rewrite with running hash
    _state: [u8] // here are stored unhashed bytes, this field shall not be accessed externally
}

impl Transcript{
    pub fn new(label: [u8]) -> Self{
        Self{_state: label}        
    }

    pub fn append_scalar(self, scalar: Field, label: [u8]){
        let message = scalar.to_le_bytes(COMPRESSED_SIZE); // TODO: fix ambiguity
        self.append_message(message, label);
    }

    pub fn append_point(self, point: Element, label: [u8]){
        let message: [u8] = point.serialize();
        self.append_message(message, label);
    }

    pub fn domain_sep(mut self, label: [u8]){
        self._state = self._state.append(label);
    }

    pub fn challenge_scalar(self, label: [u8]) -> Field{
        self.domain_sep(label);
        let hash = sha256(self._state);
        let scalar = bytes32_to_field(hash);
        self.append_scalar(scalar, label);
        scalar
    }

    fn append_message(mut self, message: [u8], label: [u8]){
        self._state = self._state.append(label);
        self._state = self._state.append(message);
    }
}
