/=  dk  /apps/dumbnet/lib/types
/=  dumb-transact  /common/tx-engine
/=  *  /common/zoon

|_  [d=derived-state:dk =blockchain-constants:dumb-transact]
+*  t  ~(. dumb-transact blockchain-constants)

++  update
  |=  [c=consensus-state:dk pag=page:t]
  ^-  derived-state:dk
  =/  [parent height]  ?:  =(~ heaviest-block.c)
    [digest.pag height.pag]  :: Genesis block
  [digest:(need heaviest-block.c) height:(need heaviest-block.c)]
  |-
  ?:  =(parent (~(get by heaviest-chain.d) height))
    d  :: Chain sudah valid
  =.  heaviest-chain.d  (~(put by heaviest-chain.d) height parent)
  ?:  =(height *page-number:t)
    d  :: Genesis block
  %=  $
    parent  digest:(~(got by blocks.c) parent)
    height  (dec height)
  ==
--
