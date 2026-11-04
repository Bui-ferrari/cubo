-- name: Partida
-- icon: ............/..ffffffff../..fWWWWWWf../..fWWaaWWf../..fWaWWWWf../..fWaWWbWf../..fWaWWWWf../..fWWaaWWf../..fWWWWWWf../..ffffffff../............/............
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
local function row(p,y,h,showgain,mark)
  local cy=y+h//2
  if mark then frame(X0,y,CW,h-2,C.accent,8,2) end
  circle(X0+14,cy,8,COL[p])
  text(NAME[p],X0+28,cy-6,C.fg,12)
  rect(X0+100,cy-4,50,8,C.panel,3)
  local w=math.floor(50*math.min(1,sc[p]/meta))
  if w>0 then rect(X0+100,cy-4,w,8,COL[p],3) end
  numtext(sc[p],X0+168,cy,C.fg,16)
  if showgain and gain[p]>0 then text("+"..gain[p],X1-2,cy-6,C.accent,12,RIGHT) end
end
local function list(y0,h,showgain)
  for p=1,n do row(p,y0+(p-1)*h,h,showgain,(phase=="round" and p==narr())) end
end
local function track()
  local cw=24
  local x0=(W-7*cw)//2
  local y0=120
  for i=0,meta do
    local cx,cy=x0+(i%7)*cw,y0+(i//7)*cw
    local fin=(i==meta)
    rect(cx+1,cy+1,cw-2,cw-2,fin and C.accent or C.panel,4)
    if i%5==0 then text(i,cx+cw//2,cy+7,fin and C.bg or C.mute,9,CENTER) end
  end
  for p=1,n do
    local s=math.min(meta,sc[p])
    local cx,cy=x0+(s%7)*cw,y0+(s//7)*cw
    local k=p-1
    circle(cx+5+(k%3)*7,cy+7+(k//3)*10,3,COL[p])
  end
end
local function token(p,x,y,r) circle(x,y+2,r,C.mute) circle(x,y,r,COL[p]) ring(x,y,r,WHITE,2) end
local function badge(p,x,y,r) circle(x,y,r,WHITE) circle(x,y,r-5,COL[p]) end
function draw()
  clear() decor()
  if phase=="setup" then
    text("Dixit",W//2,32,C.accent,18,CENTER)
    text("Quantos jogam?",W//2,62,C.mute,12,CENTER)
    numtext(n,W//2,104,C.fg,40)
    for p=1,n do token(p,W//2+(p-1-(n-1)/2)*30,160,12) end
    text("Meta",W//2,198,C.mute,12,CENTER)
    numtext(meta,W//2,228,C.fg,28)
    text("pontos",W//2,250,C.mute,11,CENTER)
  elseif phase=="round" then
    local nr=narr()
    text("Rodada "..round,W//2,30,C.mute,12,CENTER)
    rect(X0,48,CW,52,COL[nr],14)
    badge(nr,X0+30,74,15)
    text("Narrador",X0+54,58,WHITE,10)
    text(NAME[nr],X0+54,72,WHITE,22)
    if trail then track() else list(110,26,false) end
    text("depois das cartas: contar votos",W//2,274,C.mute,10,CENTER)
  elseif phase=="vote" then
    local p,nr=voters[vi],narr()
    text("Votação · narrador "..NAME[nr],W//2,30,C.mute,11,CENTER)
    rect(X0,48,CW,56,COL[p],14)
    badge(p,X0+30,76,15)
    text("Carta de",X0+54,58,WHITE,10)
    text(NAME[p],X0+54,72,WHITE,22)
    text("Acertou o narrador?",W//2,120,C.mute,12,CENTER)
    local yes=ans[p]
    rect(X0+34,138,CW-68,34,yes and C.ok or C.panel,14)
    text(yes and "SIM" or "NÃO",W//2,148,yes and WHITE or C.mute,18,CENTER)
    text("Votos na carta dele",W//2,190,C.mute,12,CENTER)
    numtext(vts[p],W//2,232,C.fg,36)
    text(vi.." de "..#voters,W//2,274,C.mute,11,CENTER)
  elseif phase=="result" then
    text("Pontos da rodada "..round,W//2,30,C.mute,12,CENTER)
    list(52,28,true)
    text(note,W//2,236,C.mute,10,CENTER)
    text("erro? use Refazer",W//2,274,C.mute,10,CENTER)
  else
    local top=0 for p=1,n do if sc[p]>top then top=sc[p] end end
    local win={}
    for p=1,n do if sc[p]==top then win[#win+1]=p end end
    local names={} for _,p in ipairs(win) do names[#names+1]=NAME[p] end
    text("Fim da partida",W//2,30,C.mute,12,CENTER)
    local bw=CW//#win
    for k,p in ipairs(win) do rect(X0+(k-1)*bw,48,bw,64,COL[p],(#win==1) and 14 or 4) end
    local pulse=(math.floor(fx*4)%2==0)
    frame(X0,48,CW,64,pulse and WHITE or C.accent,14,3)
    text(table.concat(names," e "),W//2,58,WHITE,#win>2 and 14 or 20,CENTER)
    text(#win>1 and "EMPATE" or "VENCEU",W//2,86,WHITE,14,CENTER)
    list(124,28,false)
  end
end
