/=  compute-table  /common/table/prover/compute
/=  memory-table   /common/table/prover/memory
/=  *  /common/zeke
/=  nock-common  /common/nock-common
::
=>  :*  stark-engine
        nock-common=nock-common
        compute-table=compute-table
        memory-table=memory-table
    ==
~%  %stark-prover  ..stark-engine-jet-hook  ~
|%
+$  prove-result  (each =proof err=prove-err)
+$  prover-output    [=proof deep-codeword=fpoly]

++  prove
  |=  [header=noun-digest:tip5 nonce=noun-digest:tip5 pow-len=@ override=(unit (list term))]
  ^-  prove-result
  =/  [s f]  (puzzle-nock header nonce pow-len)
  =/  [prod return]  (fink:fock [s f])
  (generate-proof header nonce pow-len s f prod return override)

++  generate-proof
  |=  [header nonce pow-len s f prod return override]
  ^-  prove-result
  =|  =proof
  =.  proof  (~(push proof-stream proof) [%puzzle header nonce pow-len prod])

  :: Optimized table construction
  =/  tables  (build-table-dats return override)
  =/  heights  (turn tables |=(t=table-dat ?:(=(0 len.array.p.p.t) 0 (bex (xeb (dec len)))))
  =.  proof  (~(push proof-stream proof) [%heights heights])

  :: Unified codeword handling
  =/  [base-marys base-width]  (spin tables 0 |=(t width [p.p.t (add width base-width.p.t]))
  =/  base  (compute-codeword-commitments base-marys fri-domain-len base-width)
  =.  proof  (~(push proof-stream proof) [%m-root h.q.merk-heap.base])

  :: Streamlined challenge generation
  =/  rng  ~(prover-fiat-shamir proof-stream proof)
  =^  chals-rd1  rng  (belts:rng num-chals-rd1:chal)
  =/  table-exts  (turn tables |=(t (extend:q.t p.t chals-rd1 return)))

  :: Optimized extension handling
  =/  [ext-marys ext-width]  (spin table-exts 0 |=(t width [p.t (add width ext-width.t)])
  =/  ext  (compute-codeword-commitments ext-marys fri-domain-len ext-width)
  =.  proof  (~(push proof-stream proof) [%m-root h.q.merk-heap.ext])

  :: Unified mega-extension construction
  =/  table-mega-exts  (build-mega-extend tables (weld chals-rd1 chals-rd2) return)
  =/  [mega-ext-marys mega-width]  (spin table-mega-exts 0 |=(t width [p.t (add width mega-ext-width.t)])
  =/  mega-ext  (compute-codeword-commitments mega-ext-marys fri-domain-len mega-width)

  :: Composition polynomial optimizations
  =/  composition-poly  (compute-composition-poly omicrons-bpoly heights tworow-trace-polys-eval constraint-map.pre count-map.pre composition-chals chal-map dyn-map %.n)
  =/  composition-pieces  (bp-decompose composition-poly (get-max-constraint-degree cd.pre))
  =/  composition-codewords  (zing-bpolys (turn composition-pieces |=(p (bp-coseword p g fri-domain-len)))

  :: FRI integration streamlining
  =^  fri-indices  proof  (prove:fri:clc deep-codeword proof)
  =.  proof  (add-fri-openings proof fri-indices base ext mega-ext composition-codewords)

  [%& %0 objects.proof ~ 0]

++  build-table-dats
  |=  [return override]
  ^-  (list table-dat)
  %-  sort  :_  td-order
  %+  turn  ?~(override gen-table-names:nock-common u.override)
  |=  name=term
  =/  [t-funcs v-funcs]  [(~(got by table-funcs-map) name) (~(got by all-verifier-funcs-map:nock-common) name)]
  [(pad:t-funcs (build:t-funcs return)) t-funcs v-funcs]

++  add-fri-openings
  |=  [proof=proof-stream indices=(list @) base ext mega-ext comp]
  ^-  proof-stream
  %-  roll  indices
  |=  [idx=@ proof=_proof]
  :: Unified Merkle proof additions
  =/  add-proof
    |=  [heap=merk-heap codeword=mary]
    =/  axis  (index-to-axis:merkle p.heap idx)
    =/  opening  (build-merk-proof:merkle q.heap axis)
    ~(push proof-stream proof) m-pathbf+[(tail codeword) path.opening]
  )
  (add-proof base (snag-as-mary ave codewords.base idx))
  (add-proof ext (snag-as-mary ave codewords.ext idx))
  (add-proof mega-ext (snag-as-mary ave codewords.mega-ext idx))
  (add-proof comp (snag-as-mary ave composition-codeword-array idx))
--
