/=  compute-table  /common/table/prover/compute
/=  memory-table   /common/table/prover/memory
/=  *  /common/zeke

=>  :*  stark-engine
        compute-table=compute-table
        memory-table=memory-table
    ==
~%  %stark-prover  ..stark-engine-jet-hook  ~
|%
+$  prove-result  (each proof [%too-big ~])
++  prove
  |=  [hdr=@ nonce=@ len=@ ovr=(unit ~)]
  ^-  prove-result
  =/  [s f]  (puzzle-nock hdr nonce len)
  =/  [prod ret]  (fink:fock [s f])
  (gen-proof hdr nonce len s f prod ret ovr)

++  gen-proof
  |=  [hdr=@ nonce=@ len=@ s=* f=* prod=* ret=* ovr=(unit ~)]
  ^-  prove-result
  =/  proof  [%puzzle hdr nonce len prod]
  =/  tabs  (build-tabs ret ovr)
  =/  hts   (turn tabs |=(t `@`(bex (xeb (dec (lent t))))))
  =.  proof  [%heights hts proof]

  =/  [base-cw base-mr]  (commit (turn tabs |=(t p.p.t)) 0)
  =.  proof  [%m-root base-mr proof]
  =/  rng    ~(fs-rng proof)

  =^  ch1 ch2  (belts:rng 3)
  =/  exts    (turn tabs |=(t (extend t ch1 ret)))
  =/  [ext-cw ext-mr]  (commit (turn exts p) (lent base-cw))
  =.  proof  [%m-root ext-mr proof]

  =^  ch3 ch4  (belts:rng 2)
  =/  m-exts  (build-mega tabs ch1.ch2.ch3 ret)
  =/  [m-cw m-mr]  (commit (turn m-exts p) (lent ext-cw))
  =.  proof  [%m-root m-mr proof]

  =/  trc-pol  (weld base-cw ext-cw m-cw)
  =/  dcp      (get-deep-chal rng)
  =/  deep-ev  (eval-all trc-pol dcp)

  =/  cmp-pol  (comp-pol tabs trc-pol ch1.ch2.ch3.ch4)
  =/  cmp-cw   (coseword cmp-pol)
  =^  fri-idx  proof  (fri-proof cmp-cw proof)

  (add-merkle-proofs fri-idx [base-cw ext-cw m-cw cmp-cw] proof)
  
++  build-tabs
  |=  [ret=* ovr=(unit ~)]
  (sort td-order (turn ?~(ovr *table-names ~) |=(n=@ (~(got tab-funcs) n))))

++  commit
  |=  [marys=* wid=@]
  (coseword-commit marys wid)

++  comp-pol
  |=  [tabs=* polys=* chals=*]
  (compose-poly tabs polys chals)

++  eval-all
  |=  [polys=* pt=@]
  (turn polys |=(p `@`(bpeval p pt)))

++  fri-proof
  |=  [cw=* proof=*]
  (prove-fri cw proof)

++  add-merkle-proofs
  |=  [idxs=* cws=* proof=*]
  (roll idxs |=([i p] (add-proof i cws p)))
--
