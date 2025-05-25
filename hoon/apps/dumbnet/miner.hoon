/=  mine  /common/pow
/=  sp    /common/stark/prover
/=  *     /common/zoon
/=  *     /common/zeke
/=  *     /common/wrapper

=<  ((moat |) inner)
=>
|%
+$  effect    [%command %pow prf=proof:sp dig=@H block=@H nonce=@H]
+$  state     [%state version=%1]
+$  cause     [len=@ block=@H nonce=@H]
--
|%
++  moat  |=(^ state)  :: State statis
++  inner
  |_  k=state
  ++  load  |=(=state state)  :: Load langsung
  
  ++  peek
    |=  arg=*
    =/  pax  (soft path arg)
    ?~  pax  ~_  %leaf+"Path invalid: {(spud arg)}"
    ~_  %leaf+"Akses peek tidak valid: {(spud pax)}"
  
  ++  poke
    |=  [wir=wire eny=@ our=@ux now=@da dat=*]
    ^-  [(list effect) state]
    =/  cause  (soft cause dat)
    ?~  cause  ~>  %slog.[0 leaf+"Error cause: {(spud dat)}"]  [~ k]
    
    :: Generate proof dengan config optimisasi
    =/  [prf dig]  prove-block-inner:mine u.cause
    :_  k
    [%command %pow prf dig block.u.cause nonce.u.cause]~
  --
--
