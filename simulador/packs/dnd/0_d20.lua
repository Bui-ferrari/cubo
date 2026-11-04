-- name: D20 do herói
-- icon: ............/.....ff...../....ffff..../...ffWWff.../..ffWaaWff../.ffWaaaaWff./.ffWaaaaWff./..ffWaaWff../...ffWWff.../....ffff..../.....ff...../............
-- layout: both
-- Rola 1 d20 (ou 2, com vantagem/desvantagem), soma o modificador. 20 natural = crítico, 1 natural = falha.
local mod=tonumber(recall("d20mod",3)) or 3
local mode=0        -- 0 normal, 1 vantagem, -1 desvantagem
local a,b=nil,nil
local rolling,tick=0,0
local function lab()
  labels(mode==1 and "@ok Vantagem" or "Vantagem",mode==-1 and "@ok Desvantagem" or "Desvantagem","@minus Mod","@plus Mod","@dice Rolar")
  repeat_pads("left right")
end
function on_enter() lab() end
local function start() rolling=0.9 tick=0 sfx("roll") end
function on_pad(d)
  if d=="ok" then if rolling<=0 then start() end return end
  if rolling>0 then return end
  if d=="up" then mode=(mode==1) and 0 or 1 a,b=nil,nil sfx("tick") lab()
  elseif d=="down" then mode=(mode==-1) and 0 or -1 a,b=nil,nil sfx("tick") lab()
  elseif d=="left" then mod=clamp(mod-1,-5,15) save("d20mod",mod) sfx("tick")
  elseif d=="right" then mod=clamp(mod+1,-5,15) save("d20mod",mod) sfx("tick") end
end
function on_shake() if rolling<=0 then start() end end
function update(dt)
  if rolling>0 then
    rolling=rolling-dt tick=tick-dt
    if tick<=0 then tick=0.07 a=math.random(1,20) b=math.random(1,20) end
    if rolling<=0 then
      a=math.random(1,20) b=math.random(1,20) sfx("thunk")
      local pick=(mode==1) and math.max(a,b) or ((mode==-1) and math.min(a,b) or a)
      if pick==20 then sfx("win") elseif pick==1 then sfx("back") end
    end
  end
end
local function chosen() if mode==1 then return math.max(a,b) elseif mode==-1 then return math.min(a,b) end return a end
local function die(cx,cy,r,v,dim,hit)
  poly(cx,cy+3,r,6,-90,C.mute,true)
  poly(cx,cy,r,6,-90,dim and C.bg or C.panel,true)
  local col=hit==20 and C.ok or (hit==1 and C.bad or (dim and C.mute or C.accent))
  poly(cx,cy,r,6,-90,col,false,3)
  if v then numtext(v,cx,cy,dim and C.mute or C.fg,r>40 and 34 or 22) end
end
function draw()
  clear() decor()
  local land=landscape()
  local cx=W//2
  text("Modificador "..(mod>=0 and "+" or "")..mod,cx,land and Y0 or 34,C.fg,16,CENTER)
  text(mode==1 and "VANTAGEM" or (mode==-1 and "DESVANTAGEM" or "d20 normal"),cx,(land and Y0 or 34)+24,mode==0 and C.mute or C.accent,12,CENTER)
  local done=a and rolling<=0
  local pick=done and chosen() or nil
  -- zona dos dados: vertical = faixa central; horizontal = lado esquerdo
  local dx,dy,r1,r2,off
  if land then dx=X0+86 dy=Y0+CH//2+22 r1=50 r2=38 off=44
  else dx=cx dy=152 r1=52 r2=40 off=46 end
  if mode==0 then
    die(dx,dy,r1,a,false,pick)
  else
    local pa=done and (a==pick)
    local pb=done and (b==pick)
    die(dx-off,dy-2,r2,a,done and not pa,done and pa and pick or nil)
    die(dx+off,dy-2,r2,b,done and pa and pb==false,done and pb and pick or nil)
  end
  -- resultado: vertical = embaixo; horizontal = lado direito
  local rx=land and (X1-52) or cx
  local ty=land and (Y0+64) or 222
  if done then
    local tot=pick+mod
    text("Total",rx,ty,C.mute,12,CENTER)
    numtext(tot,rx,ty+(land and 40 or 32),C.accent,36)
    local ey=ty+(land and 76 or 64)
    if pick==20 then text("CRÍTICO!",rx,ey,C.ok,land and 14 or 16,CENTER)
    elseif pick==1 then text(land and "FALHA" or "FALHA CRÍTICA",rx,ey,C.bad,16,CENTER)
    else text(pick.." "..(mod>=0 and "+" or "-").." "..math.abs(mod),rx,ey-(land and 0 or 5),C.mute,12,CENTER) end
  else
    if land then
      text(rolling>0 and "rolando..." or "OK ou chacoalhe",rx,Y0+CH//2+10,C.mute,12,CENTER)
      if rolling<=0 then text("para rolar",rx,Y0+CH//2+26,C.mute,12,CENTER) end
    else text(rolling>0 and "rolando..." or "OK ou chacoalhe para rolar",cx,262,C.mute,12,CENTER) end
  end
end
