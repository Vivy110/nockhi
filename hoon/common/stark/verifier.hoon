/=  nock-common  /common/nock-common
/=  *           /common/zeke

=>  :*  stark-engine
        nock-common=nock-common
    ==
~%  %stark-verifier  ..stark-engine-jet-hook  ~

|%
+$  verify-result  [commitment=noun-digest:tip5 nonce=noun-digest:tip5]
+$  elem-list      (list [idx=@ trace-elems=(list belt) comp-elems=(list felt) deep-elem=felt])

++  verify
  |=  [=proof override=(unit (list term)) verifier-eny=@]
  ^-  ?
  (mule |.((verify-inner [proof override verifier-eny &]))()

++  verify-inner
  ~/  %verify-inner
  |=  [=proof override=(unit (list term)) verifier-eny=@ test-mode=?]
  ^-  verify-result
  ?>  =(~ hashes.proof)
  
  :: Puzzle extraction
  =^  puzzle  proof =^(c proof ~(pull proof-stream proof) ?>(?=(%puzzle -.c) c^proof))
  =/  [s f]  (puzzle-nock commitment.puzzle nonce.puzzle len.puzzle)
  
  :: Table configuration
  =/  table-names  (process-override override)
  =/  [base-widths full-widths]  (compute-table-widths override)
  
  :: Height validation
  =^  heights  proof =^(h proof ~(pull proof-stream proof) ?>(?=(%heights -.h) p.h^proof))
  ?>  =((lent heights) (lent core-table-names:nock-common))
  
  :: Constraint preprocessing
  =/  pre  (remove-unused-constraints:nock-common prep.stark-config table-names override)
  =/  clc  ~(. calc heights cd.pre)
  
  :: Proof length validation
  ?>  =(expected-num-proof-items:clc (lent objects.proof))
  
  :: Merkle roots extraction
  =^  base-root  proof extract-root(%m-root)
  =^  ext-root   proof extract-root(%m-root)
  
  :: Challenge processing
  =/  rng        ~(verifier-fiat-shamir proof-stream proof)
  =/  challenges (process-challenges rng)
  
  :: Terminal validation
  =^  terminals  proof =^(t proof ~(pull proof-stream proof) ?>(?=(%terms -.t) p.t^proof))
  ?>  (valid-terminals? terminals)
  
  :: Composition polynomial checks
  =/  [subj form prod]  (build-tree-data s f p.puzzle alf)
  ?>  (linking-checks subj form prod challenges terminal-map)
  
  :: FRI verification
  =^  [fri-indices merks deep-cosets fri-res]  proof (verify:fri:clc proof deep-root)
  ?>  fri-res
  
  :: Merkle proofs verification
  ?:  &(!test-mode !(verify-merk-proofs merks verifier-eny))  !!
  
  [commitment nonce]:puzzle

++  compute-table-widths
  |=  override=(unit (list term))
  ^-  [(list @) (list @)]
  ?~  override
    [core-table-base-widths-static:nock-common core-table-full-widths-static:nock-common]
  [(custom-base-widths override) (custom-full-widths override)]

++  process-challenges
  |=  rng=_rng
  =^  rd1  rng  (belts:rng num-chals-rd1:chal)
  =^  rd2  rng  (belts:rng num-chals-rd2:chal)
  (weld rd1 rd2)

++  extract-root
  |=  tag=@tas
  =^(root proof ~(pull proof-stream proof) ?>(?=(tag -.root) p.root^proof))

++  valid-terminals?
  |=  terminals=(list term)
  ^-  ?
  &(=(lent terminals) (lent all-terminal-names:nock-common)
      ~(chck bop terminals))

++  evaluate-composition
  |=  [evals=fpoly point=felt]
  ^-  felt
  (roll (gulf 0 (dec (lent evals))) |=(i=@ (fmul (snag i evals) (fpow point i)))

++  verify-merk-proofs
  ~/  %verify-merk-proofs
  |=  [ps=(list merk-data:merkle) eny=@]
  ^-  ?
  =/  rng  (seed-rng eny)
  (all (turn ps |=(m=merk-data:merkle (verify-merk-proof:merkle m))))

--
