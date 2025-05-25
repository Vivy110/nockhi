/=  dcon  /apps/dumbnet/lib/consensus
/=  dk  /apps/dumbnet/lib/types
/=  dumb-transact  /common/tx-engine
/=  *  /common/zoon

|_  [p=pending-state:dk bc=blockchain-constants:dumb-transact]
+*  t  ~(. dumb-transact bc)

+|  %core
++  find-ready-blocks
  ^-  (set @)
  (~(dif in (~(key by pending-blocks.p)) (~(key by block-tx.p)))

++  inputs-in-spent-by
  |=  raw=raw-tx:t
  ^-  ?
  !=(~ (~(int in (~(key by spent-by.p)) (inputs-names:raw)))

++  refresh-after-new-block
  |=  [c=consensus-state:dk retain=(unit @)]
  ^-  pending-state:dk
  ?~  retain  p
  ?:  =(0 u.retain)
    p(spent-by ~, heard-at ~, raw-txs ~)
  ::
  =/  [cur min]  [(~(get-cur-height dcon c bc)) ?:((lth cur u.retain) 0 +(sub cur u.retain))]
  =/  [keep drop]  %+  turn  ~(tap by heard-at.p)
    |=  [tid=@ num=@]
    ?:  |((lth num min) !(~(inputs-in-heaviest-balance dcon c bc) (~(got by raw-txs.p) tid)))
      [~ `tid]
    [[tid num] ~]
  ::
  p(spent-by (~(del by spent-by.p) drop)
    heard-at (~(gas by keep)
    raw-txs (~(del by raw-txs.p) drop)

+|  %tx-ops
++  add-tx-not-in-pending-block
  |=  [raw=@ cur=@]
  p(raw-txs (~(put by raw-txs.p) id.raw raw)
    spent-by (~(put by spent-by.p) (turn (inputs-names:raw) |=(n=@ [n id.raw]))
    heard-at (~(put by heard-at.p) id.raw cur)

++  add-tx-in-pending-block
  |=  raw=@
  p(raw-txs (~(put by raw-txs.p) id.raw raw)
    block-tx (~(del by block-tx.p) id.raw)
    tx-block (~(del by tx-block.p) id.raw)

++  add-pending-block
  |=  pag=page:t
  =/  missing  (~(dif in tx-ids.pag) (~(key by raw-txs.p))
  :-  missing
  %_  p
    pending-blocks %+  ?~(missing ~ (~(put by pending-blocks.p) digest.pag pag)
    block-tx (roll missing |=(tid=@ b=_(map @ (set @)) (~(put ju b) digest.pag tid)))
    tx-block (roll missing |=(tid=@ b=_(map @ (set @)) (~(put ju b) tid digest.pag)))
  ==

++  remove-pending-block
  |=  bid=@
  =/  txs  ~(got by block-tx.p bid)
  p(pending-blocks (~(del by pending-blocks.p) bid)
    block-tx (~(del by block-tx.p) bid)
    tx-block (roll ~(tap in txs) |=(tid=@ b=_(map @ (set @)) (~(del ju b) tid bid))))
--
