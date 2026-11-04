-- name: Sorteio de cor
-- icon: ............/....ffff..../..ffWWWWff../.ffWWaaWWff./.fWWWaaWWWf./.fWWaaaaWWf./.fWWWaaWWWf./.ffWWaaWWff./..ffWWWWff../....ffff..../............/............
-- A seta gira e aponta quem joga de brancas. Em cima = lado das pretas, embaixo = lado das brancas.
local ang,ang0,total,T,el,lasttick=90,90,0,2.6,0,0
local phase="idle"     -- idle, spin, done
local white=0          -- 1 = lado de cima, 2 = lado de baixo
local function lab()
  if phase=="spin" then labels("","","","","") else labels("","","","","Sortear") end
  repeat_pads("")
end
function on_enter() phase="idle" lab() end
local function start()
  if phase=="spin" then return end
  white=math.random(1,2)
  ang0=ang
  local goal=(white==1) and 270 or 90
  total=360*3+((goal-ang0)%360)
  el=0 lasttick=0 phase="spin" sfx("roll") lab()
end
function on_pad(d) if d=="ok" then start() end end
function on_shake() start() end
function update(dt)
  if phase~="spin" then return end
  el=el+dt
  local p=math.min(1,el/T)
  local e=1-(1-p)^3
  ang=ang0+total*e
  local step=math.floor(ang/40)
  if step~=lasttick then lasttick=step sfx("tick") end
  if p>=1 then ang=(white==1) and 270 or 90 phase="done" sfx("win") lab() end
end
local WH,BK=rgb(0xF0,0xF0,0xF0),rgb(0x0B,0x0B,0x0B)
local function box(i)
  local cy=(i==1) and 80 or 240
  local isw=(phase=="done") and (white==i)
  local fill,fg=C.panel,C.fg
  local label="?"
  if phase=="done" then
    if isw then fill,fg,label=WH,rgb(0x15,0x15,0x15),"BRANCAS" else fill,fg,label=BK,rgb(255,255,255),"PRETAS" end
  end
  rect(X0,cy-34,CW,68,fill,14)
  frame(X0,cy-34,CW,68,(phase=="done" and isw) and C.accent or C.mute,14,(phase=="done" and isw) and 4 or 1)
  if i==1 then text(label,W//2,cy,fg,30,CENTER,180) else text(label,W//2,cy-15,fg,30,CENTER) end
end
local function arrow()
  local cx,cy,L=W//2,160,30
  local a=math.rad(ang)
  local dx,dy=math.cos(a),math.sin(a)
  line(cx-dx*L,cy-dy*L,cx+dx*(L-8),cy+dy*(L-8),C.accent,5)
  local px,py=-dy,dx
  tri(cx+dx*(L+4),cy+dy*(L+4),cx+dx*(L-12)+px*11,cy+dy*(L-12)+py*11,cx+dx*(L-12)-px*11,cy+dy*(L-12)-py*11,C.accent)
end
function draw()
  clear() decor()
  box(1) box(2)
  arrow()
end
