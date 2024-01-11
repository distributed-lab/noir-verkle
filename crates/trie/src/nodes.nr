use dep::ipa_multipoint::ecc::banderwagon::Element;

struct InternalNode{
    commitment: Element,
    depth: u8,
}

impl InternalNode{
}

struct LeafNode{
    stem: [u8],
    values: [[u8]],
    commitment: Element,
    C1: Element,
    C2: Element,
    depth: u8,
}

struct ZeroNode{

}
