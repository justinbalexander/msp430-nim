import msp430

template sfrb*(nam: untyped, loc: untyped) =
  const nam*: SFRb = SFRb(cast[ptr uint8](loc))

template sfrw*(nam: untyped, loc: untyped) =
  const nam*: SFRw = SFRw(cast[ptr uint16](loc))

template sfra*(nam: untyped, loc: untyped) =
  const nam*: SFRa = SFRa(cast[ptr uint16](loc))

template const_sfrb*(nam,loc) = sfrb(nam,loc)
template const_sfrw*(nam,loc) = sfrw(nam,loc)
template const_sfra*(nam,loc) = sfra(nam,loc)
