-- name: Dados
-- icon: ............/.aaaaaaaaaa./.affaaaaffa./.affaaaaffa./.aaaaaaaaaa./.aaaaffaaaa./.aaaaffaaaa./.aaaaaaaaaa./.affaaaaffa./.affaaaaffa./.aaaaaaaaaa./............
local TYPES={2,3,4,6,8,10,12,20,100}
local ti,qty=4,2
local vals={}
local rolling,tick=0,0
local PIPS={[1]={{.5,.5}},[2]={{.25,.25},{.75,.75}},[3]={{.25,.25},{.5,.5},{.75,.75}},[4]={{.25,.25},{.75,.25},{.25,.75},{.75,.75}},
[5]={{.25,.25},{.75,.25},{.5,.5},{.25,.75},{.75,.75}},[6]={{.25,.25},{.75,.25},{.25,.5},{.75,.5},{.25,.75},{.75,.75}}}
-- silhueta de cada dado: lados, rotação (graus), raio relativo, deslocamento do número
local SHAPE={[3]={3,90,.62,-.12},[4]={3,-90,.62,.14},[8]={4,0,.58,0},[10]={5,-90,.54,.04},[12]={10,-90,.5,0},[20]={6,-90,.52,0}}

local function roll_values() for i=1,qty do vals[i]=math.random(1,TYPES[ti]) end end
function on_enter()
  labels("Dado +","+ dado","Dado -","- dado","Rolar")
  split_pads(true) labels_split("Dado -","Dado +","Rolar","Rolar")
  repeat_pads("")
  roll_values()
end
local function start_roll() rolling=0.9 tick=0 sfx("roll") end
function on_pad(d)
  if rolling>0 then return end
  if d=="n" or d=="nr" then ti=ti%#TYPES+1 sfx("tick") roll_values()
  elseif d=="s" then ti=(ti-2)%#TYPES+1 sfx("tick") roll_values()
  elseif d=="nl" then ti=(ti-2)%#TYPES+1 sfx("tick") roll_values()
  elseif d=="sl" or d=="sr" then start_roll()
  elseif d=="e" then if qty<6 then qty=qty+1 sfx("tick") roll_values() end
  elseif d=="w" then if qty>1 then qty=qty-1 sfx("tick") roll_values() end end
end
function on_chord(c) if c=="ne" and rolling<=0 then start_roll() end end
function on_shake() if rolling<=0 then start_roll() end end
function update(dt)
  if rolling>0 then
    rolling=rolling-dt tick=tick-dt
    if tick<=0 then tick=0.07 roll_values() end
    if rolling<=0 then roll_values() sfx("thunk") end
  end
end
local function die(x,y,s,v,t)
  if rolling>0 then x=x+math.random(-3,3) y=y+math.random(-3,3) end
  local cx,cy=x+s//2,y+s//2
  local big=s>70
  local fs=big and 30 or 20
  if t==6 then
    rect(x,y+3,s,s,C.mute,s//6)
    rect(x,y,s,s,C.panel,s//6)
    frame(x,y,s,s,C.accent,s//6,3)
    for _,p in ipairs(PIPS[v]) do circle(x+math.floor(p[1]*s),y+math.floor(p[2]*s),s//9,C.fg) end
  elseif t==2 then
    circle(cx,cy+3,s//2,C.mute) circle(cx,cy,s//2,C.panel) ring(cx,cy,s//2,C.accent,3) ring(cx,cy,s//2-7,C.accent2,2)
    text(v==1 and "CARA" or "COROA",cx,cy-(big and 9 or 6),C.fg,big and 18 or 12,CENTER)
  elseif t==100 then
    circle(cx,cy+3,s//2,C.mute) circle(cx,cy,s//2,C.panel) ring(cx,cy,s//2,C.accent,3)
    text(v,cx,cy-fs//2-1,C.fg,fs,CENTER) text("%",cx,cy+s//2-16,C.mute,10,CENTER)
  else
    local sh=SHAPE[t]
    local r=math.floor(s*sh[3])
    poly(cx,cy+3,r,sh[1],sh[2],C.mute,true)
    poly(cx,cy,r,sh[1],sh[2],C.panel,true)
    poly(cx,cy,r,sh[1],sh[2],C.accent,false,3)
    text(v,cx,cy+math.floor(s*sh[4])-fs//2-1,C.fg,fs,CENTER)
  end
end
function draw()
  clear() decor()
  local t=TYPES[ti]
  text(t==2 and "Moeda" or ("d"..t),W//2,34,C.fg,24,CENTER)
  text("x"..qty,W//2,60,C.mute,16,CENTER)
  local cols=qty==1 and 1 or (qty<=4 and 2 or 3)
  local rows=math.ceil(qty/cols)
  local s=math.min(CW//cols-12,196//rows-12,100)
  local gw=cols*(s+12)-12
  local gx=X0+(CW-gw)//2
  local gy=92+(190-(rows*(s+12)-12))//2
  for i=1,qty do
    local c=(i-1)%cols local r=(i-1)//cols
    die(gx+c*(s+12),gy+r*(s+12),s,vals[i] or 1,t)
  end
  if rolling<=0 and qty>1 and t~=2 then
    local sum=0 for i=1,qty do sum=sum+(vals[i] or 0) end
    text("Total "..sum,W//2,272,C.accent,20,CENTER)
  else
    text(rolling>0 and "rolando..." or "chacoalhe ou toque em Rolar",W//2,276,C.mute,11,CENTER)
  end
end
