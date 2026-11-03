-- name: Painel de jogo
-- icon: ............/.ffffffffff./.f..ffff..f./.ffffffffff./............/.bbbb..W.a..a/.bbbb..W.a..a/............/.oooo..W.aaaa/.oooo..W.a..a/.oooo..W.a..a/............
-- Tudo numa tela: tempo da partida, placar azul x laranja e os dois dados.
local BLUE,ORANGE=rgb(0x3E,0x7A,0xA7),rgb(0xEC,0x66,0x3B)
local DUR={20,30}
local di=1
local state="set"   -- set, run, pause, done
local left=DUR[di]*60
local sc={0,0}
local faces=6
local v={nil,nil}
local roll=0
local flash=0
local function fmt(s) s=math.max(0,math.ceil(s)) return string.format("%02d:%02d",s//60,s%60) end
local mode=1   -- 1 soma, 2 tira, 3 ajustes
local MN={"soma","tira","ajustes"}
local function lab()
  if mode==3 then labels("Zerar tudo","Tempo","Modo soma","Tempo "..DUR[di%#DUR+1].." min","d"..(faces==6 and 12 or 6))
  else labels("Rolar dados","Tempo","Modo "..MN[mode%3+1],mode==1 and "+1 azul" or "-1 azul",mode==1 and "+1 laranja" or "-1 laranja") end
end
function on_enter() repeat_pads("") lab() end
local function tempo()
  if state=="set" or state=="pause" then state="run" sfx("confirm")
  elseif state=="run" then state="pause" sfx("tick")
  else state="set" left=DUR[di]*60 stop_sound() sfx("tick") end
end
function on_pad(d)
  local k=(mode==2) and -1 or 1
  if d=="left" then mode=mode%3+1 sfx("tick") lab() return end
  if d=="down" then tempo() return end
  if mode==3 then
    if d=="up" then sc={0,0} v={nil,nil} state="set" left=DUR[di]*60 stop_sound() sfx("back")
    elseif d=="right" then if state=="set" then di=di%#DUR+1 left=DUR[di]*60 sfx("tick") lab() else sfx("back") end
    elseif d=="ok" then faces=(faces==6) and 12 or 6 v={nil,nil} sfx("tick") lab() end
    return
  end
  if d=="up" then if roll<=0 then roll=0.8 sfx("roll") end
  elseif d=="right" then sc[1]=clamp(sc[1]+k,0,99) sfx(k<0 and "back" or "tick")
  elseif d=="ok" then sc[2]=clamp(sc[2]+k,0,99) sfx(k<0 and "back" or "tick") end
end
function on_shake() if roll<=0 then roll=0.8 sfx("roll") end end
function update(dt)
  if state=="run" then
    left=left-dt
    if left<=0 then left=0 state="done" flash=0 play("a5:16 r:16 a5:16 r:16 a5:16 r:16 a5:8",170,true) end
  elseif state=="done" then flash=flash+dt end
  if roll>0 then
    roll=roll-dt
    v={math.random(1,faces),math.random(1,faces)}
    if roll<=0 then sfx("thunk") end
  end
end
local function die(cx,cy,col,val,win)
  local jit=roll>0 and math.random(-2,2) or 0
  if faces==6 then
    rect(cx-27+jit,cy-24,54,54,C.mute,12) rect(cx-27+jit,cy-27,54,54,col,12)
    if win then frame(cx-31+jit,cy-31,62,62,C.fg,14,3) end
  else
    poly(cx+jit,cy+3,30,10,-90,C.mute,true) poly(cx+jit,cy,30,10,-90,col,true)
    if win then poly(cx+jit,cy,34,10,-90,C.fg,false,3) end
  end
  if val then text(val,cx+jit,cy,rgb(255,255,255),28,CENTER) end
end
local function row(y,col,score,val,win)
  rect(X0,y,CW,74,col,16)
  text(score,X0+50,y+37,rgb(255,255,255),44,CENTER)
  die(X1-44,y+37,col==BLUE and rgb(0x2B,0x5A,0x80) or rgb(0xC4,0x4A,0x22),val,win)
end
function draw()
  clear() decor()
  local blink=(state=="done" and math.floor(flash*3)%2==0)
  rect(X0,26,CW,70,blink and C.accent or C.panel,16)
  text(fmt(left),W//2,46,blink and C.bg or C.fg,36,CENTER)
  local st=({set="Parado · "..DUR[di].." min",run="Rolando",pause="Pausado",done="Fim de jogo!"})[state]
  text(st,W//2,80,blink and C.bg or C.mute,12,CENTER)
  local w1,w2=false,false
  if v[1] and v[2] and roll<=0 then w1=v[1]>v[2] w2=v[2]>v[1] end
  row(104,BLUE,sc[1],v[1],w1)
  row(184,ORANGE,sc[2],v[2],w2)
  text("modo: "..MN[mode],W//2,274,mode==2 and C.bad or C.mute,11,CENTER)
end
