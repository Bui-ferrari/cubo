-- name: Partida
-- icon: ............/..ffffffff../..fWWWWWWf../..fWWaaWWf../..fWaWWWWf../..fWaWWbWf../..fWaWWWWf../..fWWaaWWf../..fWWWWWWf../..ffffffff../............/............
-- layout: both
-- Dixit: rodízio de narrador, votação guiada, pontos automáticos e trilha até a meta (DEMONSTRAÇÃO).
local COL={rgb(0xD6,0x45,0x45),rgb(0x3E,0x7A,0xA7),rgb(0x4F,0xA7,0x60),rgb(0xF2,0xC2,0x30),rgb(0xD9,0x6B,0xB0),rgb(0xEC,0x66,0x3B)}
local NAME={"Vermelho","Azul","Verde","Amarelo","Rosa","Laranja"}
local WHITE=rgb(255,255,255)
local n=clamp(tonumber(recall("n",4)) or 4,3,6)
local meta=clamp(tonumber(recall("meta",30)) or 30,20,40)
local sc,prev,gain={0,0,0,0,0,0},{0,0,0,0,0,0},{0,0,0,0,0,0}
local phase="setup"      -- setup, round, vote, result, win
local round,first=1,1
local trail=false
local voters,vi={},1
local ans,vts={},{}
local note=""
local fx=0
local function narr() return ((first-1+round-1)%n)+1 end
local function lab()
  if phase=="setup" then labels("@plus Jogador","@minus Jogador","@minus Meta","@plus Meta","Começar")
  elseif phase=="round" then labels(trail and "Ver lista" or "Ver trilha","","","","@ok Contar votos")
  elseif phase=="vote" then labels("@plus 1 voto","@minus 1 voto","Errou","@ok Acertou","@right Próximo")
  elseif phase=="result" then
    local top=0 for p=1,n do if sc[p]>top then top=sc[p] end end
    labels("","","@reset Refazer","",top>=meta and "@ok Ver vencedor" or "@right Próxima rodada")
  else labels("","","","","Novo") end
  repeat_pads("")
end
local function newgame()
  sc={0,0,0,0,0,0} prev={0,0,0,0,0,0} gain={0,0,0,0,0,0}
  round=1 first=math.random(1,n) phase="setup" trail=false lab()
end
function on_enter() newgame() end
local function start_vote()
  voters={}
  for p=1,n do if p~=narr() then voters[#voters+1]=p end end
  vi=1
  for p=1,6 do ans[p]=false vts[p]=0 end
  phase="vote" lab()
end
local function compute()
  local nr=narr()
  local c=0
  for p=1,n do if p~=nr and ans[p] then c=c+1 end end
  for p=1,6 do prev[p]=sc[p] gain[p]=0 end
  if c==0 or c==n-1 then
    for p=1,n do if p~=nr then gain[p]=2 end end
    note="Todos ou ninguém acertou: narrador 0, outros +2"
  else
    gain[nr]=3
    for p=1,n do if p~=nr and ans[p] then gain[p]=3 end end
    note="Narrador +3 e quem acertou +3"
  end
  for p=1,n do if p~=nr then gain[p]=gain[p]+math.min(3,vts[p]) end end
  for p=1,n do sc[p]=sc[p]+gain[p] end
  phase="result" lab() sfx("win")
end
function on_pad(d)
  if phase=="setup" then
    if d=="up" then n=math.min(6,n+1) save("n",n) sfx("tick")
    elseif d=="down" then n=math.max(3,n-1) save("n",n) sfx("tick")
    elseif d=="left" then meta=math.max(20,meta-5) save("meta",meta) sfx("tick")
    elseif d=="right" then meta=math.min(40,meta+5) save("meta",meta) sfx("tick")
    elseif d=="ok" then first=math.random(1,n) phase="round" sfx("roll") lab() end
  elseif phase=="round" then
    if d=="up" then trail=not trail sfx("tick") lab()
    elseif d=="ok" then sfx("confirm") start_vote() end
  elseif phase=="vote" then
    local p=voters[vi]
    if d=="up" then vts[p]=math.min(n-2,vts[p]+1) sfx("tick")
    elseif d=="down" then vts[p]=math.max(0,vts[p]-1) sfx("back")
    elseif d=="left" then ans[p]=false sfx("back")
    elseif d=="right" then ans[p]=true sfx("confirm")
    elseif d=="ok" then
      if vi<#voters then vi=vi+1 sfx("tick") else compute() end
    end
  elseif phase=="result" then
    if d=="left" then for p=1,6 do sc[p]=prev[p] end phase="vote" vi=1 sfx("back") lab()
    elseif d=="ok" then
      local top=0 for p=1,n do if sc[p]>top then top=sc[p] end end
      if top>=meta then phase="win" fx=0 sfx("win") lab()
      else round=round+1 phase="round" sfx("confirm") lab() end
    end
  elseif phase=="win" then
    if d=="ok" then newgame() sfx("back") end
  end
end
function update(dt) fx=fx+dt end
-- uma linha de jogador: bolinha, nome, barra de progresso, pontos (e ganho)
local function row(p,x,y,w,h,showgain,mark)
  local cy=y+h//2
  if mark then frame(x,y,w,h-2,C.accent,8,2) end
  circle(x+14,cy,8,COL[p])
  text(NAME[p],x+28,cy-6,C.fg,12)
  local bw=math.min(50,w-138)
  if bw>=16 then
    rect(x+100,cy-4,bw,8,C.panel,3)
    local f=math.floor(bw*math.min(1,sc[p]/meta))
    if f>0 then rect(x+100,cy-4,f,8,COL[p],3) end
    numtext(sc[p],x+w-20,cy,C.fg,16)
  else
    numtext(sc[p],x+w-(showgain and 46 or 20),cy,C.fg,16)
  end
  if showgain and gain[p]>0 then text("+"..gain[p],x+w-2,cy-6,C.accent,12,RIGHT) end
end
local function list(y0,h,showgain,x,w)
  x=x or X0 w=w or CW
  for p=1,n do row(p,x,y0+(p-1)*h,w,h,showgain,(phase=="round" and p==narr())) end
end
local function track(y0)
  local cw=24
  local cols=portrait() and 7 or 11
  local x0=X0+(CW-cols*cw)//2
  for i=0,meta do
    local cx,cy=x0+(i%cols)*cw,y0+(i//cols)*cw
    local fin=(i==meta)
    rect(cx+1,cy+1,cw-2,cw-2,fin and C.accent or C.panel,4)
    if i%5==0 then text(i,cx+cw//2,cy+7,fin and C.bg or C.mute,9,CENTER) end
  end
  for p=1,n do
    local s=math.min(meta,sc[p])
    local cx,cy=x0+(s%cols)*cw,y0+(s//cols)*cw
    local k=p-1
    circle(cx+5+(k%3)*7,cy+7+(k//3)*10,3,COL[p])
  end
end
local function token(p,x,y,r) circle(x,y+2,r,C.mute) circle(x,y,r,COL[p]) ring(x,y,r,WHITE,2) end
local function badge(p,x,y,r) circle(x,y,r,WHITE) circle(x,y,r-5,COL[p]) end
local function lines(s,size,cx,y,maxw,c)
  for _,l in ipairs(wrap(s,size,maxw)) do text(l,cx,y,c,size,CENTER) y=y+size+3 end
end
function draw()
  clear() decor()
  local P=portrait()
  local cx=X0+CW//2
  if phase=="setup" then
    if P then
      text("Dixit",cx,32,C.accent,18,CENTER)
      text("Quantos jogam?",cx,62,C.mute,12,CENTER)
      numtext(n,cx,104,C.fg,40)
      for p=1,n do token(p,cx+(p-1-(n-1)/2)*30,160,12) end
      text("Meta",cx,198,C.mute,12,CENTER)
      numtext(meta,cx,228,C.fg,28)
      text("pontos",cx,250,C.mute,11,CENTER)
    else
      local lx,rx=X0+70,X0+CW-64
      text("Dixit",cx,Y0+2,C.accent,16,CENTER)
      text("Quantos jogam?",lx,Y0+34,C.mute,12,CENTER)
      numtext(n,lx,Y0+78,C.fg,40)
      for p=1,n do token(p,lx+(p-1-(n-1)/2)*21,Y0+132,9) end
      text("Meta",rx,Y0+34,C.mute,12,CENTER)
      numtext(meta,rx,Y0+78,C.fg,32)
      text("pontos",rx,Y0+102,C.mute,11,CENTER)
    end
  elseif phase=="round" then
    local nr=narr()
    if P then
      text("Rodada "..round,cx,30,C.mute,12,CENTER)
      rect(X0,48,CW,52,COL[nr],14)
      badge(nr,X0+30,74,15)
      text("Narrador",X0+54,58,WHITE,10)
      text(NAME[nr],X0+54,72,WHITE,22)
      if trail then track(120) else list(110,26,false) end
      text("depois das cartas: contar votos",cx,274,C.mute,10,CENTER)
    else
      text("Rodada "..round,cx,Y0+2,C.mute,12,CENTER)
      if trail then
        rect(X0,Y0+20,CW,40,COL[nr],12)
        badge(nr,X0+24,Y0+40,12)
        text("Narrador "..NAME[nr],X0+46,Y0+32,WHITE,16)
        track(Y0+70)
      else
        rect(X0,Y0+20,124,64,COL[nr],14)
        badge(nr,X0+24,Y0+52,13)
        text("Narrador",X0+44,Y0+34,WHITE,10)
        text(NAME[nr],X0+44,Y0+50,WHITE,16)
        lines("depois das cartas: contar votos",10,X0+62,Y0+96,124,C.mute)
        list(Y0+20,24,false,X0+136,132)
      end
    end
  elseif phase=="vote" then
    local p,nr=voters[vi],narr()
    local yes=ans[p]
    if P then
      text("Votação · narrador "..NAME[nr],cx,30,C.mute,11,CENTER)
      rect(X0,48,CW,56,COL[p],14)
      badge(p,X0+30,76,15)
      text("Carta de",X0+54,58,WHITE,10)
      text(NAME[p],X0+54,72,WHITE,22)
      text("Acertou o narrador?",cx,120,C.mute,12,CENTER)
      rect(X0+34,138,CW-68,34,yes and C.ok or C.panel,14)
      text(yes and "SIM" or "NÃO",cx,148,yes and WHITE or C.mute,18,CENTER)
      text("Votos na carta dele",cx,190,C.mute,12,CENTER)
      numtext(vts[p],cx,232,C.fg,36)
      text(vi.." de "..#voters,cx,274,C.mute,11,CENTER)
    else
      local rx=X0+CW-60
      text("Votação · narrador "..NAME[nr],cx,Y0+2,C.mute,11,CENTER)
      rect(X0,Y0+20,140,52,COL[p],14)
      badge(p,X0+26,Y0+46,13)
      text("Carta de",X0+48,Y0+30,WHITE,10)
      text(NAME[p],X0+48,Y0+44,WHITE,18)
      text("Acertou o narrador?",X0+70,Y0+84,C.mute,11,CENTER)
      rect(X0+10,Y0+104,120,34,yes and C.ok or C.panel,14)
      text(yes and "SIM" or "NÃO",X0+70,Y0+112,yes and WHITE or C.mute,18,CENTER)
      lines("Votos na carta dele",11,rx,Y0+30,116,C.mute)
      numtext(vts[p],rx,Y0+96,C.fg,44)
      text(vi.." de "..#voters,rx,Y1-14,C.mute,11,CENTER)
    end
  elseif phase=="result" then
    if P then
      text("Pontos da rodada "..round,cx,30,C.mute,12,CENTER)
      list(52,28,true)
      text(note,cx,236,C.mute,10,CENTER)
      text("erro? use Refazer",cx,274,C.mute,10,CENTER)
    else
      local rx=X0+CW-44
      text("Pontos da rodada "..round,cx,Y0+2,C.mute,12,CENTER)
      list(Y0+22,26,true,X0,176)
      lines(note,10,rx,Y0+30,86,C.mute)
      lines("erro? use Refazer",10,rx,Y1-30,86,C.mute)
    end
  else
    local top=0 for p=1,n do if sc[p]>top then top=sc[p] end end
    local win={}
    for p=1,n do if sc[p]==top then win[#win+1]=p end end
    local names={} for _,p in ipairs(win) do names[#names+1]=NAME[p] end
    local pulse=(math.floor(fx*4)%2==0)
    local by,bh=P and 48 or Y0+20,P and 64 or 52
    text("Fim da partida",cx,P and 30 or Y0+2,C.mute,12,CENTER)
    local bw=CW//#win
    for k,p in ipairs(win) do rect(X0+(k-1)*bw,by,bw,bh,COL[p],(#win==1) and 14 or 4) end
    frame(X0,by,CW,bh,pulse and WHITE or C.accent,14,3)
    text(table.concat(names," e "),cx,by+10,WHITE,#win>2 and 14 or 20,CENTER)
    text(#win>1 and "EMPATE" or "VENCEU",cx,by+bh-26,WHITE,14,CENTER)
    if P then list(124,28,false)
    else
      for p=1,n do row(p,X0+((p-1)//3)*138,Y0+82+((p-1)%3)*26,130,26,false,false) end
    end
  end
end
