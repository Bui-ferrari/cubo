-- name: Rodadas
-- icon: ....ffff..../..ff....ff../.f...a....f./.f...a....f./f....a.....f/f....aaa...f/f..........f/.f........f./.f........f./..ff....ff../....ffff..../............
-- orient: fixed
-- DeBater: 3 turnos. Em cada turno um jogador fala (20 ou 30 s) e depois o outro; a plateia vota.
-- Jogador de cima = azul, jogador de baixo = vermelho. Antes do 3º turno: carta de KO.
-- Ganha quem somar mais votos nos 3 turnos.
local BLUE,RED=rgb(0x3E,0x7A,0xA7),rgb(0xD6,0x45,0x45)
local PC={BLUE,RED}
local PN={"Azul","Vermelho"}
local dur=tonumber(recall("dur",30)) or 30
local phase="setup"      -- setup, draw, wait, run, pause, vote, ko, drum, end
local turn,starter,seq=1,1,1
local t={dur,dur}
local done={false,false}
local votes={{0,0},{0,0},{0,0}}
local ang,ang0,total,T,el,lasttick=90,90,0,2.6,0,0
local drumt,drumtick=0,0
local function spk() return seq==1 and starter or 3-starter end
local function tot(i) return votes[1][i]+votes[2][i]+votes[3][i] end
local function lab()
  if phase=="setup" then labels("","","20 s","30 s","Sortear")
  elseif phase=="wait" then labels(spk()==1 and "Iniciar" or "",spk()==2 and "Iniciar" or "","","","")
  elseif phase=="run" then labels(spk()==1 and "@ok Terminei" or "",spk()==2 and "@ok Terminei" or "","","","Pausar")
  elseif phase=="pause" then labels("","","","","Continuar")
  elseif phase=="vote" then labels("@plus 1 voto azul","@plus 1 voto vermelho","@minus Azul","@minus Vermelho",turn==3 and "@ok Revelar" or "@ok Próximo")
  elseif phase=="ko" then labels("","","","","@ok Peguei")
  elseif phase=="end" then labels("","","","","Novo")
  else labels("","","","","") end
  repeat_pads("")
end
local function reset_turn() t={dur,dur} done={false,false} seq=1 end
local function newgame() turn=1 starter=1 votes={{0,0},{0,0},{0,0}} reset_turn() phase="setup" lab() end
function on_enter() newgame() end
local function start_draw()
  local target=(math.random(1,2)==1) and 1 or 2
  starter=target
  ang0=ang
  local goal=(target==1) and 270 or 90
  total=360*3+((goal-ang0)%360)
  el=0 lasttick=0 phase="draw" sfx("roll") lab()
end
local function finish_segment()
  done[spk()]=true
  play("a5:16 r:16 a5:16 r:16 a5:8",170,false)
  if seq==1 then seq=2 t[spk()]=dur phase="wait"
  else phase="vote" end
  lab()
end
local function after_vote()
  if turn==3 then phase="drum" drumt=0 drumtick=0 sfx("roll")
  else
    turn=turn+1 starter=3-starter reset_turn()
    phase=(turn==3) and "ko" or "wait"
  end
  lab()
end
function on_pad(d)
  if phase=="setup" then
    if d=="left" then dur=20 save("dur",dur) t={dur,dur} sfx("tick")
    elseif d=="right" then dur=30 save("dur",dur) t={dur,dur} sfx("tick")
    elseif d=="ok" then start_draw() end
  elseif phase=="wait" then
    if (d=="up" and spk()==1) or (d=="down" and spk()==2) then t[spk()]=dur phase="run" sfx("confirm") lab() end
  elseif phase=="run" then
    if (d=="up" and spk()==1) or (d=="down" and spk()==2) then finish_segment()
    elseif d=="ok" then phase="pause" sfx("tick") lab() end
  elseif phase=="pause" then
    if d=="ok" then phase="run" sfx("tick") lab() end
  elseif phase=="vote" then
    local v=votes[turn]
    if d=="up" then v[1]=math.min(99,v[1]+1) sfx("tick")
    elseif d=="down" then v[2]=math.min(99,v[2]+1) sfx("tick")
    elseif d=="left" then v[1]=math.max(0,v[1]-1) sfx("back")
    elseif d=="right" then v[2]=math.max(0,v[2]-1) sfx("back")
    elseif d=="ok" then sfx("confirm") after_vote() end
  elseif phase=="ko" then
    if d=="ok" then phase="wait" sfx("confirm") lab() end
  elseif phase=="end" then
    if d=="ok" then newgame() sfx("back") end
  end
end
function on_shake() if phase=="setup" then start_draw() end end
function update(dt)
  if phase=="draw" then
    el=el+dt
    local p=math.min(1,el/T)
    local e=1-(1-p)^3
    ang=ang0+total*e
    local step=math.floor(ang/40)
    if step~=lasttick then lasttick=step sfx("tick") end
    if p>=1 then ang=(starter==1) and 270 or 90 reset_turn() phase="wait" sfx("win") lab() end
  elseif phase=="run" then
    local i=spk()
    t[i]=t[i]-dt
    if t[i]<=0 then t[i]=0 finish_segment() end
  elseif phase=="drum" then
    drumt=drumt+dt drumtick=drumtick-dt
    if drumtick<=0 then drumtick=0.16 sfx("thunk") end
    if drumt>=3.6 then
      phase="end" lab()
      local a,b=tot(1),tot(2)
      sfx(a==b and "back" or "win")
    end
  end
end
local function fmt(s) s=math.max(0,math.ceil(s)) return string.format("%d:%02d",s//60,s%60) end
local function say(a,b)
  text(a,W//2,138,C.mute,11,CENTER,180) text(b or "",W//2,124,C.mute,11,CENTER,180)
  text(a,W//2,183,C.mute,11,CENTER) text(b or "",W//2,197,C.mute,11,CENTER)
end
local function arrow()
  local cx,cy,L=W//2,160,30
  local a=math.rad(ang)
  local dx,dy=math.cos(a),math.sin(a)
  line(cx-dx*L,cy-dy*L,cx+dx*(L-8),cy+dy*(L-8),C.accent,5)
  local px,py=-dy,dx
  tri(cx+dx*(L+4),cy+dy*(L+4),cx+dx*(L-12)+px*11,cy+dy*(L-12)+py*11,cx+dx*(L-12)-px*11,cy+dy*(L-12)-py*11,C.accent)
end
-- número grande + legenda dentro da caixa do jogador i (cima = girado)
local function content(i,cy,str,col,hint,hcol,size)
  size=size or 40
  local isnum=tonumber(str)~=nil and not tostring(str):find(":")
  if i==1 then
    if isnum then numtext(str,W//2,cy+8,col,size,180) else text(str,W//2,cy+8,col,size,CENTER,180) end
    if hint~="" then text(hint,W//2,cy-26,hcol,10,CENTER,180) end
  else
    if isnum then numtext(str,W//2,cy-8,col,size) else text(str,W//2,cy-size//2-8,col,size,CENTER) end
    if hint~="" then text(hint,W//2,cy+22,hcol,10,CENTER) end
  end
end
local function box(i)
  local cy=(i==1) and 80 or 240
  local who=(phase=="wait" or phase=="run" or phase=="pause") and spk()==i
  if phase=="vote" then
    rect(X0,cy-34,CW,68,PC[i],14)
    local w=rgb(255,255,255)
    content(i,cy,votes[turn][i],w,"votos no turno · total "..tot(i),w)
  elseif phase=="drum" then
    rect(X0,cy-34,CW,68,PC[i],14)
    local w=rgb(255,255,255)
    local j=(drumt*10)%2<1 and 2 or 0
    local s=(math.floor(drumt*8)%3==0) and "?" or ((math.floor(drumt*8)%3==1) and "??" or "???")
    content(i,cy,s,w,"contando votos...",w)
  elseif phase=="end" then
    local a,b=tot(1),tot(2)
    local win=(a>b and 1) or (b>a and 2) or 0
    local mine=(win==i)
    local w=rgb(255,255,255)
    if win==0 then rect(X0,cy-34,CW,68,PC[i],14)
    elseif mine then rect(X0,cy-34,CW,68,PC[i],14) frame(X0-3,cy-37,CW+6,74,C.fg,16,3)
    else rect(X0,cy-34,CW,68,C.panel,14) end
    local detail=votes[1][i].." + "..votes[2][i].." + "..votes[3][i]
    content(i,cy,tot(i),mine and w or C.mute,(win==0) and ("empate · "..detail) or (mine and ("VENCEU · "..detail) or detail),mine and w or C.mute)
  else
    local lit=who
    local col=lit and C.accent or (done[i] and C.mute or C.fg)
    rect(X0,cy-34,CW,68,lit and C.panel or C.bg,14)
    frame(X0,cy-34,CW,68,lit and C.accent or PC[i],14,lit and 3 or 2)
    local shown=(phase=="setup" or phase=="draw") and dur or t[i]
    local hint=""
    if phase=="wait" and who then hint="aperte o botão"
    elseif phase=="run" and who then hint="falando"
    elseif phase=="pause" and who then hint="em pausa"
    elseif done[i] and (phase=="wait" or phase=="run" or phase=="pause") then hint="já falou" end
    content(i,cy,fmt(shown),col,hint,lit and C.accent or C.mute)
  end
end
function draw()
  clear() decor()
  box(1) box(2)
  if phase=="draw" then arrow()
  else
    for k=1,3 do
      local x=W//2+(k-2)*30
      if phase~="setup" and (k==turn) and phase~="end" then circle(x,160,9,C.accent) else ring(x,160,7,C.mute,2) end
    end
  end
  if phase=="setup" then say("OK sorteia","quem começa")
  elseif phase=="ko" then say("Pegue uma carta de KO","antes do 3º turno")
  elseif phase=="vote" then say("Votação do","turno "..turn)
  elseif phase=="drum" then say("Quem venceu?","")
  elseif phase=="end" then say("Fim dos turnos","")
  elseif phase=="wait" or phase=="run" or phase=="pause" then say("Turno "..turn.." de 3") end
end
