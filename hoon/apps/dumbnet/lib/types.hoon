/=  *   /common/zoon
/=  zeke  /common/zeke
/=  dt  /common/tx-engine
/=  sp  /common/stark/prover

|%
+|  %state
+$  kernel-state
  $:  c=consensus-state
      p=pending-state
      a=admin-state
      m=mining-state
      d=derived-state
      constants=blockchain-constants:dt
  ==

+$  consensus-state
  $:  balance=(map @ (map @ @))            :: block-id → nname → nnote
      txs=(map @ (map @ @))               :: block-id → tx-id → tx
      blocks=(map @ @)                    :: block-id → local-page
      heaviest-block=(unit @)
      min-timestamps=(map @ @)
      epoch-start=(map @ @)
      targets=(map @ @)
      btc-data=(unit @)
      genesis-seal=@
  ==

+$  pending-state
  $:  pending-blocks=(map @ @)
      block-tx=(map @ (set @))            :: block-id → {tx-id}
      tx-block=(map @ (set @))            :: tx-id → {block-id}
      raw-txs=(map @ @)
      spent-by=(map @ @)
      heard-at=(map @ @)
  ==

+$  admin-state
  $:  desk-hash=(unit @)
      init=? 
      retain=@                             :: 0=drop all, ~=keep forever
  ==

+$  derived-state
  $:  heaviest-chain=(map @ @)            :: height → block-id
  ==

+$  mining-state
  $:  mining=?
      pubkeys=(set @)
      shares=(map @ @)
      candidate-block=@
      candidate-acc=@
      next-nonce=@
  ==

+|  %io
+$  command
  $%  [%pow prf=@ dig=@ bc=@ nonce=@]
      [%set-key p=@]
      [%set-keys p=(list [@ @ (list @)])]
      [%enable p=?]
      [%timer]
      [%born]
      [%genesis p=[@ @ @]]
      [%set-seal p=[@ @]]
      [%btc p=(unit @)]
      [%test p=@]
  ==

+$  effect
  $%  [%gossip p=@]
      [%request p=$%([%block $@(~ [%height @] [%elders @ @])] [%tx @])]
      [%track p=$%([%add @ @] [%remove @])]
      [%seen p=$%([%block @] [%tx @])]
      [%mine @ @ @]
      [%lie p=$%([%peer @ @] [%block @ @])]
      [%span @ (list [@ $@([%n @] [%s @])])]
      [%exit @]
  ==

+$  pok     [@ @ @ @]  :: eny our now cause
--
