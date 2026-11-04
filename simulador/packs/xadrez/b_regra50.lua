-- name: Regra dos 50
-- icon: ............/.ffffffffff./.f........f./.f.aaaaaa.f./.f........f./.f.aaaa...f./.f........f./.f.aaaaaaaf./.f........f./.ffffffffff./............/............
-- layout: both
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
local function meter(cx,y,w,label,n,lim,hint)
  local hit=n>=lim
  text(label,cx,y,C.mute,11,CENTER)
  numtext(n,cx-18,y+44,hit and C.accent or C.fg,44)
  text("/"..lim,cx+34,y+36,C.mute,16,CENTER)
  local bw=w-24
  rect(cx-bw//2,y+78,bw,10,C.panel,5)
  if n>0 then rect(cx-bw//2,y+78,math.floor(bw*math.min(1,n/lim)),10,hit and C.accent or C.fg,5) end
  text(hit and hint or "",cx,y+94,C.accent,11,CENTER)
end
function draw()
  clear() decor()
  if landscape() then
    local y=H//2-52
    meter(X0+CW//4,y,CW//2,"lances sem captura",moves,50,"pode pedir empate")
    meter(X0+CW*3//4,y,CW//2,"repetições",reps,3,"pode pedir empate")
  else
    meter(W//2,34,CW,"lances sem captura nem peão",moves,50,"pode pedir empate")
    meter(W//2,166,CW,"repetições da posição",reps,3,"pode pedir empate")
  end
end
