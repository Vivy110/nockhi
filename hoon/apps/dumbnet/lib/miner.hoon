/=  dk  /apps/dumbnet/lib/types
/=  sp  /common/stark/prover
/=  dumb-transact  /common/tx-engine
/=  *  /common/zoon

|_  [m=mining-state:dk =blockchain-constants:dumb-transact]
+*  t  ~(. dumb-transact blockchain-constants)

+|  %admin
++  set-mining
  |=  mine=?
  m(mining mine)

++  set-pubkeys
  |=  pks=(list lock:t)
  m(pubkeys (~(sy in ~) pks))  ;; Optimasi set dengan sy

++  set-shares
  |=  shr=(list [lock:t @])
  =/  s  (~(my by ~) shr)  ;; Optimasi map dengan my
  ?.  (validate:shares:t s)  ~|('invalid shares' !!)
  m(shares s)

+|  %candidate-block
++  set-pow
  |=  prf=proof:sp
  m(pow.candidate-block `prf)

++  set-digest
  m(digest.candidate-block (compute-digest:page:t candidate-block.m))

++  update-timestamp
  |=  now=@da
  ?:  |(=(*page:t candidate-block.m) !mining.m)  m
  ?:  (gte timestamp.candidate-block.m (time-in-secs:page:t (sub now update-candidate-timestamp-interval:t)))  m
  =.  timestamp.candidate-block.m  (time-in-secs:page:t now)
  ~>  %slog.0["Timestamp updated: {(scot %da now)}"]
  m

++  heard-new-tx
  |=  raw=raw-tx:t
  ~>  %slog.3["Heard TX: {(to-b58:hash:t id.raw)}"]
  ?:  (~(has in pubkeys.m) ~)  m  ;; Cek pubkey kosong
  =/  tx  (mole |.((new:tx:t raw height.candidate-block.m))
  ?~  tx  m
  =/  new-acc  (process:tx-acc:t candidate-acc.m u.tx height.candidate-block.m)
  ?~  new-acc  m
  =.  tx-ids.candidate-block.m  (~(put in tx-ids.candidate-block.m) id.raw)
  =/  [old new]  [fees.candidate-acc.m fees.u.new-acc]
  ?:  =(new old)  m
  ?>  (gth new old)
  =.  coinbase.candidate-block.m  (new:coinbase-split:t (add (roll ~(val by coinbase.candidate-block.m) add new) shares.m)
  m

++  heard-new-block
  |=  [c=consensus-state:dk p=pending-state:dk now=@da]
  ?~  heaviest-block.c  ~>  %slog.0["No genesis"]  m
  ?:  =(u.heaviest-block.c parent.candidate-block.m)  ~>  %slog.0["Same block"]  m
  ?:  (~(has in pubkeys.m) ~)  ~>  %slog.0["No pubkeys"]  m
  ~>  %slog.0["New parent: {(to-b58:hash:t u.heaviest-block.c)}"]
  =/  new-parent  (~(got by blocks.c) u.heaviest-block.c)
  =.  candidate-block.m  (new-candidate:page:t new-parent now (~(got by targets.c) u.heaviest-block.c shares.m)
  =.  candidate-acc.m  (new:tx-acc:t (~(get by balance.c) u.heaviest-block.c)
  (roll ~(val by raw-txs.p) heard-new-tx)
--
