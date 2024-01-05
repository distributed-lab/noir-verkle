use dep::ipa::{IPAProof, IPAConfig};
use dep::ecc::banderwagon::Element;
use dep::transcript::Transcript;
use dep::polynomial::utils::allocate_slice;

/*
These defitions origin prior to modifications is from github.com/ethereum/go-ipa.

The following are unexported labels to be used in Fiat-Shamir during the
multiproof protocol.

The following is a short description on how they're used in the protocol:
 1. Append the domain separator. (LABEL_DOMAIN_SEP)
 2. For each opening, we append to the transcript:
    a. The polynomial commitment (LABEL_C).
    b. The evaluation point (LABEL_Z).
    c. The evaluation result (LABEL_Y).
 3. Pull a scalar-field element from the transcript to be used for
    the random linear combination of openings. (LABEL_R)
 4. Append point D which is sum(r^i * (f_i(x)-y_i)/(x-z_i)). (LABEL_D)
 5. Pull a random scalar-field to be used as a random evaluation point. (LABEL_T)
 5. Append point E which is sum(r^i * f_i(x)/(t-z_i)). (LABEL_E)
 7. Create the IPA proof for (E-D) at point `t`. See the `ipa` package for the FS description.
*/

//global LABEL_C = "C";
global LABEL_Z = "z";
global LABEL_Y = "y";
//global LABEL_R = "r";
global LABEL_D = "D";
global LABEL_T = "t";
global LABEL_E = "E";
global LABEL_DOMAIN_SEP_MULTIPROOF = "multiproof";

struct ProverQuery {
    commitment: Element,
    poly: [Field], 
    point: Field,
    result: Field,
}

struct VerifierQuery {
    commitment: Element,
    point: Field,
    result: Field,
}

struct MultiProof{
    IPA: IPAProof,
    D: Element
}

impl MultiProof{
    fn create<N>(
        transcript: Transcript,
        config: IPAConfig<N>,
        queries: [ProverQuery],
    ) -> Self{
        transcript.domain_sep(LABEL_DOMAIN_SEP_MULTIPROOF.as_bytes().as_slice());

        for query in queries{
            transcript.append_point(query.commitment, LABEL_C.as_bytes().as_slice());
            transcript.append_scalar(query.point, LABEL_Z.as_bytes().as_slice());
            transcript.append_scalar(query.result, LABEL_Y.as_bytes().as_slice());
        }
        let r = transcript.challenge_scalar(LABEL_R.as_bytes().as_slice());
        
        let grouped_fs = MultiProof::group_prover_queries_by_point(queries, r);
        
        let mut g_x: [Field; N] = [0; N];
        
        for i in 0..N{
            let f = grouped_fs[i];
            if f.len() != 0{
                let quotient = config.precomputed_weights.divide_on_domain(N, i, f);
                for j in 0..N{
                    g_x[j] += quotient[j];
                }
            }
        }

        let D = Element::msm(config.crs.G, g_x); // TODO: use precomputed for CRS msm
        transcript.append_point(D, LABEL_D.as_bytes().as_slice());
        let t = transcript.challenge_scalar(LABEL_T.as_bytes().as_slice());

        let mut den_inv: [Field] = [];
        for z in 0..N{
            let f = grouped_fs[z];
            if f.len() != 0 {
                let den = t - z as Field;
                den_inv = den_inv.push_back(1 / den);
            }
        }

        let mut den_inv_index = 0;
        let mut h_x: [Field; N] = [0; N];
        for i in 0..N{
            let f = grouped_fs[i];
            if f.len() != 0{
                for j in 0..N{
                    h_x[j] += (f[j] * den_inv[den_inv_index]);
                }
                den_inv_index += 1;
            }
        }

        let mut a: [Field; N] = [0; N];
        for i in 0..N{
            a[i] = h_x[i] - g_x[i];
        }

        let E = Element::msm(config.crs.G, h_x);
        transcript.append_point(E, LABEL_E.as_bytes().as_slice());

        let commitment = E.sub(D);

        let proof = IPAProof::create(transcript, config, a.as_slice(), commitment, t);

        MultiProof{IPA: proof, D}
    }

    fn verify<N>(
        self,
        transcript: Transcript,
        config: IPAConfig<N>,
        queries: [VerifierQuery]
    ) -> bool{
        transcript.domain_sep(LABEL_DOMAIN_SEP_MULTIPROOF.as_bytes().as_slice());
        
        for query in queries{
            transcript.append_point(query.commitment, LABEL_C.as_bytes().as_slice());
            transcript.append_scalar(query.point, LABEL_Z.as_bytes().as_slice());
            transcript.append_scalar(query.result, LABEL_Y.as_bytes().as_slice());
        }
        let r = transcript.challenge_scalar(LABEL_R.as_bytes().as_slice());

        transcript.append_point(self.D, LABEL_D.as_bytes().as_slice());
	    let t = transcript.challenge_scalar(LABEL_T.as_bytes().as_slice());

        let mut grouped: [Field; N] = [0; N];
        let mut r_pow = 1;

        for i in 0..N{
            grouped[queries[i].point] += queries[i].result * r_pow;
            r_pow *= r;
        }

        let mut helper_scalars_den: [Field; N] = [0; N];
        for i in 0..N{
            helper_scalars_den[i] = 1 / (t - i);
        }

        let mut g_2_t = 0;
        for i in 0..N{
            if grouped[i] != 0{
                g_2_t += grouped[i] * helper_scalars_den[i];
            }
        }

        let mut r_pow = 1;
        let scalars = helper_scalars_den.map(|s| {let res = s * r_pow; r_pow *= r; res}).as_slice();
        let commitments = queries.map(|query: VerifierQuery| query.commitment);
        let E = Element::msm(commitments, scalars);
        transcript.append_point(E, LABEL_E.as_bytes().as_slice());

        let commitment = E.sub(self.D);

        self.IPA.verify(transcript, config, commitment, t, g_2_t)
    }

    // We want to group all of the polynomials which are evaluated at the same point together.
    fn group_prover_queries_by_point(queries: [ProverQuery], r: Field) -> [[Field]]{
        [[]] // TODO: implement
    }
}
