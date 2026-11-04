-- name: Regra dos 50
-- icon: ............/.ffffffffff./.f........f./.f.aaaaaa.f./.f........f./.f.aaaa...f./.f........f./.f.aaaaaaaf./.f........f./.ffffffffff./............/............
-- Conta lances sem captura nem lance de peão (limite 50) e repetições da posição (limite 3).
local moves,reps=0,0
local alerted={false,false}
local function lab()
  labels("@plus Lance","@plus Repetição","@minus Lance","@minus Repet.","Zerar") repeat_pads("")
end
function on_enter() lab() end
local function check(k,hit)
  if hit and not alerted[k] then alerted[k]=true play("a5:16 r:16 a5:16 r:16 a5:8",170,false)
  elseif not hit then alerted[k]=false end
end
function on_pad(d)
  if d=="up" then moves=math.min(99,moves+1) sfx("tick") check(1,moves>=50)
  elseif d=="down" then reps=math.min(9,reps+1) sfx("tick") check(2,reps>=3)
  elseif d=="left" then moves=math.max(0,moves-1) sfx("back") check(1,moves>=50)
  elseif d=="right" then reps=math.max(0,reps-1) sfx("back") check(2,reps>=3)
  elseif d=="ok" then moves=0 reps=0 alerted={false,false} sfx("confirm") end
end
function on_shake() end
local function meter(y,label,n,lim,hint)
  local hit=n>=lim
  text(label,W//2,y,C.mute,11,CENTER)
  numtext(n,W//2-18,y+44,hit and C.accent or C.fg,44)
  text("/"..lim,W//2+34,y+36,C.mute,16,CENTER)
  local bw=CW-24
  rect(X0+12,y+78,bw,10,C.panel,5)
  if n>0 then rect(X0+12,y+78,math.floor(bw*math.min(1,n/lim)),10,hit and C.accent or C.fg,5) end
  text(hit and hint or "",W//2,y+94,C.accent,11,CENTER)
end
function draw()
  clear() decor()
  meter(34,"lances sem captura nem peão",moves,50,"pode pedir empate")
  meter(166,"repetições da posição",reps,3,"pode pedir empate")
end
