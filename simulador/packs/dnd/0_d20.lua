-- name: D20 do herói
-- icon: ............/.....ff...../....ffff..../...ffWWff.../..ffWaaWff../.ffWaaaaWff./.ffWaaaaWff./..ffWaaWff../...ffWWff.../....ffff..../.....ff...../............
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
  text("Modificador "..(mod>=0 and "+" or "")..mod,W//2,34,C.fg,16,CENTER)
  text(mode==1 and "VANTAGEM" or (mode==-1 and "DESVANTAGEM" or "d20 normal"),W//2,58,mode==0 and C.mute or C.accent,12,CENTER)
  local done=a and rolling<=0
  local pick=done and chosen() or nil
  if mode==0 then
    die(W//2,152,52,a,false,pick)
  else
    local pa=done and (a==pick)
    local pb=done and (b==pick)
    die(W//2-46,150,40,a,done and not pa,done and pa and pick or nil)
    die(W//2+46,150,40,b,done and pa and pb==false,done and pb and pick or nil)
  end
  if done then
    local tot=pick+mod
    text("Total",W//2,222,C.mute,12,CENTER)
    numtext(tot,W//2,254,C.accent,36)
    if pick==20 then text("CRÍTICO!",W//2,286,C.ok,16,CENTER)
    elseif pick==1 then text("FALHA CRÍTICA",W//2,286,C.bad,16,CENTER)
    else text(pick.." "..(mod>=0 and "+" or "-").." "..math.abs(mod),W//2,281,C.mute,12,CENTER) end
  else
    text(rolling>0 and "rolando..." or "OK ou chacoalhe para rolar",W//2,262,C.mute,12,CENTER)
  end
end
