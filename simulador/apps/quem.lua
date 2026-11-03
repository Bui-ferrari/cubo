-- name: Quem começa
-- icon: ............/.....aa...../....aaaa..../...aaaaaa.../.....aa...../.....aa...../.....aa...../.....aa...../.....aa...../.....aa...../............/............
-- A seta gira e aponta para o lado do jogador que começa.
local players=4
local SEATS={[2]={"n","s"},[3]={"s","e","w"},[4]={"n","e","s","w"}}
local ANG={n=-90,e=0,s=90,w=180}
local ang=-90
local from,to,t,dur=-90,-90,0,0
local winner=nil
local function lab() labels("Girar","+ jogador","","- jogador","Girar","","") end
function on_enter() repeat_pads("") lab() end
local function spin()
  if t<dur then return end
  local seats=SEATS[players]
  winner=seats[math.random(#seats)]
  from=ang%360
  local delta=(ANG[winner]-from)%360
  to=from+360*3+delta dur=3.2 t=0
  sfx("roll")
end
function on_pad(d)
  if d=="n" then spin()
  elseif t>=dur and d=="e" then players=math.min(4,players+1) winner=nil sfx("tick")
  elseif t>=dur and d=="w" then players=math.max(2,players-1) winner=nil sfx("tick") end
end
function on_chord(c) if c=="ne" then spin() end end
function on_shake() spin() end
local last_tick=0
function update(dt)
  if t<dur then
    t=t+dt
    local k=math.min(1,t/dur)
    local e=1-(1-k)^3
    ang=from+(to-from)*e
    local seg=math.floor(ang/45)
    if seg~=last_tick then last_tick=seg sfx("tick") end
    if t>=dur then ang=to winner_flash=0 sfx("win") end
  end
end
function draw()
  clear() decor()
  text("Quem começa?",W//2,34,C.fg,20,CENTER)
  local seats=SEATS[players]
  for _,s in ipairs(seats) do
    local a=ANG[s]*math.pi/180
    local x,y=W//2+math.floor(math.cos(a)*92),H//2+math.floor(math.sin(a)*100)
    local on=(winner==s and t>=dur)
    circle(x,y,on and 20 or 14,on and C.accent or C.panel)
    if not on then ring(x,y,14,C.mute,2) end
  end
  local a=ang*math.pi/180
  local ca,sa=math.cos(a),math.sin(a)
  local L=62
  local tx,ty=W//2+ca*L,H//2+sa*L
  line(W//2,H//2,W//2+ca*(L-14),H//2+sa*(L-14),C.fg,8)
  tri(tx,ty,tx-ca*20-sa*12,ty-sa*20+ca*12,tx-ca*20+sa*12,ty-sa*20-ca*12,C.accent)
  circle(W//2,H//2,12,C.fg) circle(W//2,H//2,5,C.bg)
  text(players.." jogadores",W//2,H//2+120,C.mute,12,CENTER)
  if winner and t>=dur then text("começa aqui!",W//2,H//2+138,C.accent,14,CENTER) end
end
