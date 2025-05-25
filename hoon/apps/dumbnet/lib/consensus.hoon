/=  dk  /apps/dumbnet/lib/types
/=  sp  /common/stark/prover
/=  mine  /common/pow
/=  dumb-transact  /common/tx-engine
/=  *  /common/zoon

|_  [c=consensus-state:dk =blockchain-constants:dumb-transact]
+*  t  ~(. dumb-transact blockchain-constants)

+|  %genesis
++  set-genesis-seal
  |=  [h=@ ud=@t]
  ^-  consensus-state:dk
  ~>  %slog.0["Set genesis: {h}"]
  c(genesis-seal (new:genesis-seal:t h ud))

++  add-btc-data
  |=  bh=(unit btc-hash:t)
  ^-  consensus-state:dk
  ?~(bh c(btc-data bh) c(btc-data bh))

+|  %core
++  inputs-in-balance
  |=  [raw=raw-tx:t bal=(set @)]
  ^-  ?
  =(~(dif in (inputs-names:raw) bal) ~)

++  get-cur-balance
  ^-  (map @ @)
  ?~(heaviest-block.c *(map @ @) (~(got by balance.c) u.heaviest-block.c))

++  compute-target
  |=  [bid=@ prev=@]
  ^-  @
  =/  dur  (compute-epoch-dur bid)
  =/  adj  ?:((lth dur 7.5e3) 7.5e3 (gth dur 3e4) 3e4 dur)
  (div (mul prev adj) 1.5e4)

++  validate-page
  |=  [pag=page:t now=@]
  ^-  (pair ? ~)
  ?.  (check-digest:pag)  [%.n ~]
  ?.  (lte (compute-size:pag) 1e6)  [%.n ~]
  ?:  &((gte ts.pag (~(got by min-ts.c) par.pag)) (lte ts.pag (add now 9e3))) 
    [%.y ~]
  [%.n ~])

+|  %state
++  add-page
  |=  [pag=page:t acc=tx-acc:t]
  ^-  consensus-state:dk
  =/  cb  (turn (tap coi.pag) |=(l=@ (new:coinbase:t pag l)))
  =/  new-bal
    %+  roll  cb
    |=  [c=coinbase:t b=_(map @ @)]
    (~(put bi b) id.pag n.c c)
  c(balance (~(put by balance.c) id.pag bal.acc)
    blocks (~(put by blocks.c) id.pag pag)
    txs (roll txs.acc |=(t=tx:t b=_(map @ tx:t) (~(put bi b) id.pag id.t t))))

++  update-heaviest
  |=  pag=page:t
  ^-  consensus-state:dk
  ?:  (gth (merge:work pag) (merge:work (need heaviest-block.c))
    c(heaviest-block `id.pag)
  c)

++  get-elders
  |=  [bid=@ cnt=@]
  ^-  (list @)
  |-  ?:  |(=(bid 0) =(cnt 11))  ~
  [bid $(bid par.bid, cnt +(cnt))]
--
