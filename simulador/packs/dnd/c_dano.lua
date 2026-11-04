-- name: Dados de dano
-- icon: ............/.aaa..bbb.../.aWa..bWb.../.aaa..bbb.../............/...bb...aaa./..bWWb..aWa./...bb...aaa./............/.ffffffffff./............/............
-- Escolha o tipo (d4 a d12) e a quantidade; role tudo e some o dano.
local TYPES={4,6,8,10,12}
local ti,qty=2,2
local vals={}
local rolling,tick=0,0
local SHAPE={[4]={3,-90},[6]={4,45},[8]={4,0},[10]={5,-90},[12]={10,-90}}
local function lab() labels("@plus Dado","@minus Dado","@left Tipo","@right Tipo","@dice Rolar") repeat_pads("") end
function on_enter() lab() vals={} end
local function start() rolling=0.8 tick=0 sfx("roll") end
local function rr() for i=1,qty do vals[i]=math.random(1,TYPES[ti]) end end
function on_pad(d)
  if d=="ok" then if rolling<=0 then start() end return end
  if rolling>0 then return end
  if d=="up" then qty=math.min(8,qty+1) vals={} sfx("tick")
  elseif d=="down" then qty=math.max(1,qty-1) vals={} sfx("tick")
  elseif d=="right" then ti=ti%#TYPES+1 vals={} sfx("tick")
  elseif d=="left" then ti=(ti-2)%#TYPES+1 vals={} sfx("tick") end
end
function on_shake() if rolling<=0 then start() end end
function update(dt)
  if rolling>0 then
    rolling=rolling-dt tick=tick-dt
    if tick<=0 then tick=0.07 rr() end
    if rolling<=0 then rr() sfx("thunk") end
  end
end
local function die(cx,cy,r,v,t)
  local sh=SHAPE[t]
  poly(cx,cy+2,r,sh[1],sh[2],C.mute,true)
  poly(cx,cy,r,sh[1],sh[2],C.panel,true)
  poly(cx,cy,r,sh[1],sh[2],C.accent,false,2)
  if v then numtext(v,cx,cy+((t==4) and 4 or 0),C.fg,r>24 and 20 or 16) end
end
function draw()
  clear() decor()
  local t=TYPES[ti]
  text(qty.." x d"..t,W//2,34,C.fg,22,CENTER)
  local cols=qty<=3 and qty or (qty<=6 and 3 or 4)
  local rows=math.ceil(qty/cols)
  local r=math.min(math.floor((CW/cols)/2)-6,math.floor(150/rows/2)-4,30)
  local cw=CW//cols
  for i=1,qty do
    local c=(i-1)%cols local rw=(i-1)//cols
    local nrow=math.min(cols,qty-rw*cols)
    local gx=X0+(CW-nrow*cw)//2+c*cw+cw//2
    local gy=70+rw*(2*r+12)+r+((150-(rows*(2*r+12)))//2)
    die(gx,gy,r,vals[i],t)
  end
  if vals[1] and rolling<=0 then
    local s=0 for i=1,qty do s=s+(vals[i] or 0) end
    text("Dano total",W//2,236,C.mute,12,CENTER)
    numtext(s,W//2,266,C.accent,34)
  else
    text(rolling>0 and "rolando..." or "OK ou chacoalhe para rolar",W//2,262,C.mute,12,CENTER)
  end
end
