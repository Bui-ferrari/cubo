-- name: Vida 1x1
-- icon: ............/.rrrr..rrrr./rrrrrrrrrrrr/rrrrrrrrrrrr/rrrrrrrrrrrr/.rrrrrrrrrr./..rrrrrrrr../...rrrrrr.../....rrrr..../.....rr...../............/............
-- Duelo de dois: azul em cima, vermelho embaixo. Cima/baixo aplicam o passo no jogador daquele lado.
local BLUE,RED=rgb(0x3E,0x7A,0xA7),rgb(0xD6,0x45,0x45)
local PC={BLUE,RED}
local NAME={"azul","vermelho"}
local P={20,20}
local delta={0,0}      -- soma recente (aparece ao lado e some)
local dt={0,0}
local step=1           -- 1 ou 5
local op=-1            -- -1 dano, +1 cura
local armed=0          -- segundos restantes da confirmação de "Novo jogo"
local function sgn(n) return (n>0 and "+" or "−")..math.abs(n) end
local function lab()
  local ic=(op<0) and "@minus " or "@plus "
  labels(ic..step.." azul",ic..step.." vermelho","Passo "..(step==1 and 5 or 1),op<0 and "@plus Curar" or "@minus Dano",armed>0 and "@ok Confirmar?" or "Novo jogo")
  repeat_pads("")
end
local function store() save("v",P[1]..","..P[2]) end
function on_enter()
  local s=recall("v","")
  if s~="" then local i=1 for v in s:gmatch("-?%d+") do P[i]=tonumber(v) i=i+1 if i>2 then break end end end
  lab()
end
local function apply(i)
  local d=op*step
  P[i]=clamp(P[i]+d,-99,999)
  delta[i]=delta[i]+d dt[i]=2.2
  sfx(d<0 and "back" or "tick") store()
end
function on_pad(d)
  if d=="up" then apply(1)
  elseif d=="down" then apply(2)
  elseif d=="left" then step=(step==1) and 5 or 1 sfx("tick") lab()
  elseif d=="right" then op=-op sfx("tick") lab()
  elseif d=="ok" then
    if armed>0 then P={20,20} delta={0,0} dt={0,0} armed=0 store() sfx("confirm") else armed=3 sfx("tick") end
    lab()
  end
end
function update(dt_)
  for i=1,2 do if dt[i]>0 then dt[i]=dt[i]-dt_ if dt[i]<=0 then delta[i]=0 end end end
  if armed>0 then armed=armed-dt_ if armed<=0 then armed=0 lab() end end
end
local function box(i)
  local cy=(i==1) and 80 or 240
  local rot=(i==1) and 180 or 0
  local dead=P[i]<=0
  rect(X0,cy-34,CW,68,PC[i],14)
  if dead then frame(X0-2,cy-36,CW+4,72,C.fg,16,3) end
  local w=rgb(255,255,255)
  numtext(P[i],W//2,cy+(i==1 and 8 or -8),w,40,rot)
  -- mudança recente, do lado do jogador
  if delta[i]~=0 then
    local x=(i==1) and (X0+34) or (X1-34)
    text(sgn(delta[i]),x,cy+(i==1 and 0 or -9),w,20,CENTER,rot)
  end
  local hint=dead and "derrotado" or NAME[i]
  text(hint,W//2,cy+(i==1 and -26 or 22),w,10,CENTER,rot)
end
function draw()
  clear() decor()
  box(1) box(2)
  rect(W//2-40,H//2-14,80,28,C.panel,14)
  text((op<0 and "Dano " or "Cura ")..step,W//2,H//2-8,op<0 and C.bad or C.ok,14,CENTER)
end
