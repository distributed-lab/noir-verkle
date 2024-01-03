use dep::ecc::banderwagon::Element;
use dep::std::collections::vec::Vec;

struct LagrangeBasis{
    domain: Field,
    values: Vec<Field>
}

impl LagrangeBasis{
    fn new(values: Vec<Field>) -> Self{
        let domain = values.len();
        Self{domain, values}
    }
    
}
