/=  nock-common  /common/nock-common
/=  *  /common/zeke
::
=>  :*  stark-engine
        nock-common=nock-common
    ==
~%  %stark-verifier  ..stark-engine-jet-hook  ~
|%
+$  verify-result  [commitment=noun-digest:tip5 nonce=noun-digest:tip5]
+$  elem-list  (list [idx=@ trace-elems=(list belt) comp-elems=(list felt) deep-elem=felt])

++  verify
  |=  [=proof override=(unit (list term)) verifier-eny=@]
  ^-  ?
  =/  args  [proof override verifier-eny |]
  -:(mule |.((verify-inner args)))

++  verify-inner
  ~/  %verify-inner
  |=  [=proof override=(unit (list term)) verifier-eny=@ test-mode=?]
  ^-  verify-result
  ?>  =(~ hashes.proof)
  =^  puzzle  proof  =^(c proof ~(pull proof-stream proof) ?>(?=(%puzzle -.c) c^proof))
  =/  [s=* f=*]  (puzzle-nock commitment.puzzle nonce.puzzle len.puzzle)
  ?>  (based-noun p.puzzle)

  :: Optimized table handling
  =.  table-names  %-  sort  :_  t-order  ?~(override gen-table-names:nock-common u.override)
  =.  table-base-widths  (compute-base-widths override)
  =.  table-full-widths  (compute-full-widths override)

  =^  heights  proof  =^(h proof ~(pull proof-stream proof) ?>(?=(%heights -.h) p.h^proof))
  ?>  =((lent heights) (lent core-table-names:nock-common))

  =/  c  constraints
  =/  pre  prep.stark-config
  =.  pre  (remove-unused-constraints:nock-common pre table-names override)
  =/  clc  ~(. calc heights cd.pre)

  :: Streamlined proof size check
  =/  expected-num-proof-items  (add 12 (add (num-rounds:fri:clc) (mul 4 (num-spot-checks:fri:clc)))
  ?>  =(expected-num-proof-items (lent objects.proof))

  :: Consolidated Merkle root checks
  =^  base-root   proof  =^(b proof ~(pull proof-stream proof) ?>(?=(%m-root -.b) p.b^proof)
  =^  ext-root    proof  =^(e proof ~(pull proof-stream proof) ?>(?=(%m-root -.e) p.e^proof)
  =^  mega-ext-root proof  =^(m proof ~(pull proof-stream proof) ?>(?=(%m-root -.m) p.m^proof)

  :: Optimized Fiat-Shamir and challenge handling
  =/  rng  ~(verifier-fiat-shamir proof-stream proof)
  =^  chals-rd1  rng  (belts:rng num-chals-rd1:chal)
  =^  chals-rd2  rng  (belts:rng num-chals-rd2:chal)
  =/  chal-map  (bp-zip-chals-list:chal chal-names-basic:chal (weld chals-rd1 chals-rd2))

  :: Unified data building
  =/  subj-data  (build-tree-data:fock s alf)
  =/  form-data  (build-tree-data:fock f alf)
  =/  prod-data  (build-tree-data:fock p.puzzle alf)

  :: Terminal verification optimization
  =^  terminals  proof  =^(t proof ~(pull proof-stream proof) ?>(?=(%terms -.t) p.t^proof)
  ?.  (~(chck bop terminals))  ~&  "Invalid terminals"  !!

  :: Enhanced linking checks
  ?.  (linking-checks subj-data form-data prod-data j k l m z terminal-map)
    ~&  "Linking failed"  !!

  :: Composition polynomial optimizations
  =/  [extra-comp-weights extra-composition-chals]  (generate-extra-constraints rng total-extra-constraints)
  =^  extra-comp-bpoly  proof  =^(c proof ~(pull proof-stream proof) ?>(?=(%poly -.c) p.c^proof)
  ?>  =(extra-composition-eval (bpeval-lift extra-comp-bpoly extra-comp-eval-point))

  :: FRI verification streamlining
  =^  [fri-indices merks deep-cosets fri-res]  proof  (verify:fri:clc proof deep-root)
  ?.  fri-res  ~&  %fri-failed  !!

  :: Unified evaluation checks
  =/  eval-res  (verify-evaluations elems omega fri-domain-len:clc)
  ?>  =(eval-res %.y)

  [commitment nonce]:puzzle

++  compute-base-widths  ?~(override core-table-base-widths-static:nock-common (custom-table-base-widths-static:nock-common table-names))
++  compute-full-widths  ?~(override core-table-full-widths-static:nock-common (custom-table-full-widths-static:nock-common table-names))

++  linking-checks
  |=  [s=tree-data f=tree-data p=tree-data j k l m z mp=(map term belt)]
  ^-  ?
  :: Consolidated checks using unified comparison
  ?&  =(memory-checks s z mp)
      =(compute-checks s f mp)
      =(product-checks p mp)
      =(decode-checks mp)
  ==

++  verify-merk-proofs
  |=  [ps=(list merk-data:merkle) eny=@]
  ^-  ?
  =/  tog-eny  (new:tog:tip5 (mod eny p)^~)
  |-  
  ?~  ps  %.y
  =/  res  (verify-merk-proof:merkle i.ps)
  ?.  res  %.n  $(ps t.ps)
--
