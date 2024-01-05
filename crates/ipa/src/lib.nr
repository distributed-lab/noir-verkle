mod utils;

use dep::ecc::banderwagon::Element;
use dep::transcript::Transcript;
use dep::polynomial::{PrecomputedWeights, inner_product};
use dep::polynomial::utils::allocate_slice;
use dep::crs::CRS;

/*
These defitions origin prior to modifications is from github.com/ethereum/go-ipa.

The following are labels to be used in Fiat-Shamir during the
inner-product argument protocol.

The following is a short description on how they're used in the protocol:
1. Append the domain separator. (LABEL_DOMAIN_SEP)
2. Append the commitment to the polynomial. (LABEL_C)
3. Append the input point. (LABEL_INPUT_POINT)
4. Append the output point. (LABEL_OUTPUT_POINT)
5. Pull the re-scaling factor `w` to scale Q. (LABEL_W).
6. For each round of the IPA protocol:
   a. Append the resulting point C_L. (LABEL_L)
   b. Append the resulting point C_R. (LABEL_R)
   c. Pull the random scalar-field element `x`. (LABEL_X)
*/
global LABEL_DOMAIN_SEP = "IPA";
global LABEL_C = "C";
global LABEL_INPUT_POINT = "input point";
global LABEL_OUTPUT_POINT = "output point";
global LABEL_W = "w";
global LABEL_L = "L";
global LABEL_R = "R";
global LABEL_X = "X";

struct IPAConfig<N>{
    crs: CRS<N>,
    precomputed_weights: PrecomputedWeights,
    rounds: u64
}

struct IPAProof{
    L: [Element],
    R: [Element],
    a: Field
}

impl IPAProof{
    pub fn create<N>(
        transcript: Transcript, 
        config: IPAConfig<N>, 
        mut a: [Field], 
        commitment: Element, 
        point: Field,
    ) -> Self{
        transcript.domain_sep(LABEL_DOMAIN_SEP.as_bytes().as_slice());
        
        let mut b = IPAProof::compute_vector_b(config, point);
        let product = inner_product(a, b);

        transcript.append_point(commitment, LABEL_C.as_bytes().as_slice());
        transcript.append_scalar(point, LABEL_INPUT_POINT.as_bytes().as_slice());
        transcript.append_scalar(product, LABEL_OUTPUT_POINT.as_bytes().as_slice());

        let w = transcript.challenge_scalar(LABEL_W.as_bytes().as_slice());

        let q = config.crs.Q.mul(w);
        
        let mut L = allocate_slice(config.rounds);
        let mut R = allocate_slice(config.rounds);

        let mut G = config.crs.G.as_slice();

        for i in 0..config.rounds{
            let (mut a_L, a_R) = utils::halve(a);
            let (mut b_L, b_R) = utils::halve(b);
            let (mut G_L, G_R) = utils::halve(G);

            let z_L = inner_product(a_R, b_L);
            let z_R = inner_product(a_L, b_R);

            let C_L_1 = Element::msm(G_L, a_R);
            let C_L = Element::msm([C_L_1, q], [1, z_L]);

            let C_R_1 = Element::msm(G_R, a_L);
            let C_R = Element::msm([C_R_1, q], [1, z_R]);
            
            L[i] = C_L;
            R[i] = C_R;

            transcript.append_point(C_L, LABEL_L.as_bytes().as_slice());
            transcript.append_point(C_R, LABEL_R.as_bytes().as_slice());

            let x = transcript.challenge_scalar(LABEL_X.as_bytes().as_slice());
            let x_inv = 1 / x;

            for i in 0..a_L.len() {
                a_L[i] = a_L[i] + x * a_R[i];
                b_L[i] = b_L[i] + x_inv * b_R[i];
                G_L[i] = G_L[i].add(G_R[i].mul(x_inv));
            }

            a = a_L;
            b = b_L;
            G = G_L;
        }

        IPAProof{L: L, R: R, a: a[0]}
    }

    pub fn verify<N>(
        self,
        transcript: Transcript, 
        config: IPAConfig<N>, 
        commitment: Element, 
        point: Field,
        result: Field,
    ) -> bool{
        transcript.domain_sep(LABEL_DOMAIN_SEP.as_bytes().as_slice());
        
        assert(self.L.len() == self.R.len());
        assert(self.L.len() as u64 == config.rounds);

        let mut b = IPAProof::compute_vector_b(config, point);

        transcript.append_point(commitment, LABEL_C.as_bytes().as_slice());
        transcript.append_scalar(point, LABEL_INPUT_POINT.as_bytes().as_slice());
        transcript.append_scalar(result, LABEL_OUTPUT_POINT.as_bytes().as_slice());

        let w = transcript.challenge_scalar(LABEL_W.as_bytes().as_slice());
        let Q = config.crs.Q.mul(w);
        let mut commitment = commitment.add(Q.mul(result));

        let challenges = self.generate_challenges(transcript);
        
        for i in 0..challenges.len(){
            let x = challenges[i];
            let L = self.L[i];
            let R = self.R[i];
            
            commitment = Element::msm([commitment, L, R], [1, x, 1 / x]);
        }

        let mut G = config.crs.G.as_slice();
        for x in challenges {
            let (mut G_L, G_R) = utils::halve(G);
            let (mut b_L, b_R) = utils::halve(b);

            let x_inv = 1 / x;
            for i in 0..G_L.len() {
                G_L[i] = G_L[i].add(G_R[i].mul(x_inv));
                b_L[i] = b_L[i].add(b_R[i].mul(x_inv));
            }
            G = G_L;
            b = b_L;
        }

        assert(G.len() != 1);
        assert(b.len() != 1);

        let (lhs, rhs) = (G[0].mul(self.a), Q.mul(self.a * b[0]));
        let got = lhs.add(rhs);

        got.eq(commitment)
    }

    fn compute_vector_b<N>(config: IPAConfig<N>, point: Field) -> [Field]{
        let domain_size = config.crs.G.len() as u64;
        if point as u64 > domain_size - 1{
            config.precomputed_weights.compute_barycentric_coefficients(domain_size, point)   
        }
        let mut b = allocate_slice(domain_size);
        b[point] = 1;
        b        
    }

    fn generate_challenges(self, transcript: Transcript) -> [Field]{
        let amount = self.L.len() as u64;
        let mut result = allocate_slice(amount);
        for i in 0..amount{
            transcript.append_point(self.L[i], LABEL_C.as_bytes().as_slice());
            transcript.append_point(self.R[i], LABEL_C.as_bytes().as_slice());
            result[i] = transcript.challenge_scalar(LABEL_W.as_bytes().as_slice());
        }
        result
    }
}
