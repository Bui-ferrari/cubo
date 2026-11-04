-- name: Relógio de xadrez
-- icon: ....ffff..../..ff....ff../.f...a....f./.f...a....f./f....a.....f/f....aaa...f/f..........f/.f........f./.f........f./..ff....ff../....ffff..../............
-- Em cima = pretas, embaixo = brancas. As brancas começam. Cada jogador aperta o botão do seu lado para passar a vez.
-- Fischer: ganha o acréscimo ao jogar. Atraso: o relógio espera o acréscimo antes de descontar.
local PRESETS={{"Bullet",60,0},{"Blitz",180,2},{"Rápida",600,0},{"Rápida",900,10},{"Clássica",5400,30}}
local pi=tonumber(recall("xp",2)) or 2
local mode=recall("xm","fischer")
local phase="setup"          -- setup, ready, run, pause, flag
local t={0,0}                -- 1 = pretas (cima), 2 = brancas (baixo)
local moves={0,0}
local active=2
local dly=0
local flagged=0
local lastsec=-1
local WH,BK=rgb(0xF0,0xF0,0xF0),rgb(0x0B,0x0B,0x0B)
local WT,BT=rgb(0x15,0x15,0x15),rgb(255,255,255)
local RED=rgb(0xC8,0x32,0x32)
local function fmt(s)
  if s<10 then return string.format("%.1f",math.max(0,s)) end
  s=math.ceil(s)
  if s>=6000 then return string.format("%d:%02d",s//3600,(s%3600)//60) end
  return string.format("%d:%02d",s//60,s%60)
end
local function pname(i)
  local p=PRESETS[i]
  local m=p[2]//60
  local base=(p[2]%60==0) and (m.." min") or (p[2].." s")
  return p[1].." "..(p[2]>=60 and (m) or p[2])..(p[3]>0 and ("+"..p[3]) or "")
end
local function reset_clock()
  t={PRESETS[pi][2],PRESETS[pi][2]} moves={0,0} active=2 flagged=0 lastsec=-1
  dly=(mode=="atraso") and PRESETS[pi][3] or 0
end
local function mlabel() return (PRESETS[pi][3]==0) and "sem acréscimo" or ((mode=="atraso") and "atraso" or "Fischer") end
local function lab()
  if phase=="setup" then
    labels("Modo "..((mode=="atraso") and "atraso" or "Fischer"),"","Anterior","Próximo","Iniciar")
  elseif phase=="ready" then
    labels("","@play Brancas jogam","Ajustes","","")
  elseif phase=="run" then
    labels(active==1 and "@ok Passar" or "",active==2 and "@ok Passar" or "","","","Pausar")
  elseif phase=="pause" then
    labels("","","Ajustes","","Continuar")
  else labels("","","","","Novo") end
  repeat_pads("")
end
function on_enter() phase="setup" reset_clock() lab() end
local function pass()
  local a=active
  moves[a]=moves[a]+1
  if mode=="fischer" then t[a]=t[a]+PRESETS[pi][3] end
  active=3-a
  dly=(mode=="atraso") and PRESETS[pi][3] or 0
  lastsec=-1
  sfx("tick") lab()
end
function on_pad(d)
  if phase=="setup" then
    if d=="left" then pi=(pi-2)%#PRESETS+1 save("xp",pi) reset_clock() sfx("tick")
    elseif d=="right" then pi=pi%#PRESETS+1 save("xp",pi) reset_clock() sfx("tick")
    elseif d=="up" then mode=(mode=="fischer") and "atraso" or "fischer" save("xm",mode) reset_clock() sfx("tick") lab()
    elseif d=="ok" then reset_clock() phase="ready" sfx("confirm") lab() end
  elseif phase=="ready" then
    if d=="down" then phase="run" sfx("confirm") lab()
    elseif d=="left" then phase="setup" sfx("back") lab() end
  elseif phase=="run" then
    if (d=="up" and active==1) or (d=="down" and active==2) then pass()
    elseif d=="ok" then phase="pause" sfx("tick") lab() end
  elseif phase=="pause" then
    if d=="ok" then phase="run" sfx("tick") lab()
    elseif d=="left" then phase="setup" sfx("back") lab() end
  elseif phase=="flag" then
    if d=="ok" then phase="setup" reset_clock() sfx("back") lab() end
  end
end
function on_shake() end
function update(dt)
  if phase~="run" then return end
  local a=active
  if dly>0 then dly=dly-dt return end
  t[a]=t[a]-dt
  local s=math.ceil(t[a])
  if t[a]<=10 and s~=lastsec and t[a]>0 then lastsec=s sfx("tick") end
  if t[a]<=0 then
    t[a]=0 flagged=a phase="flag"
    play("a5:16 r:16 a5:16 r:16 a5:16 r:16 a5:8",170,false)
    lab()
  end
end
-- número/texto do jogador i (1 = cima, girado) com legenda
local function content(i,cy,str,col,hint,hcol)
  if i==1 then
    text(str,W//2,cy+8,col,40,CENTER,180)
    if hint~="" then text(hint,W//2,cy-26,hcol,10,CENTER,180) end
  else
    text(str,W//2,cy-28,col,40,CENTER)
    if hint~="" then text(hint,W//2,cy+22,hcol,10,CENTER) end
  end
end
local function box(i)
  local cy=(i==1) and 80 or 240
  local isw=(i==2)
  local fill,fg=(isw and WH or BK),(isw and WT or BT)
  local on=(phase=="run" or phase=="pause") and active==i
  local hint=""
  local blink=((millis()//250)%2==0)
  local str
  if phase=="setup" then
    str=fmt(PRESETS[pi][2])
    hint=(isw and "brancas" or "pretas")
  elseif phase=="flag" then
    if flagged==i then fill,fg=RED,BT str="0.0" hint="BANDEIRA CAIU"
    else str=fmt(t[i]) hint="venceu no tempo" end
  else
    str=fmt(t[i])
    hint="lances "..moves[i]
    if on and dly>0 then hint="atraso "..math.ceil(dly).." s" end
    if on and t[i]<=10 and blink then fill,fg=RED,BT end
    if phase=="ready" and isw then hint="aperte para começar" end
  end
  rect(X0,cy-34,CW,68,fill,14)
  if on then frame(X0-2,cy-36,CW+4,72,C.accent,16,4) else frame(X0,cy-34,CW,68,C.mute,14,1) end
  content(i,cy,str,fg,hint,fg)
end
function draw()
  clear() decor()
  box(1) box(2)
  -- seta no meio aponta quem está com o relógio rodando
  if phase=="run" or phase=="pause" then
    local up=(active==1)
    if up then tri(W//2,128,W//2-14,152,W//2+14,152,C.accent) else tri(W//2,192,W//2-14,168,W//2+14,168,C.accent) end
  end
  local name=pname(pi)
  local sub=(PRESETS[pi][3]==0) and "sem acréscimo" or ((mode=="atraso") and "atraso" or "Fischer")
  if phase=="setup" then
    text(name,W//2,128,C.fg,14,CENTER,180) text(sub,W//2,144,C.mute,11,CENTER,180)
    text(name,W//2,172,C.fg,14,CENTER) text(sub,W//2,188,C.mute,11,CENTER)
  elseif phase=="pause" then
    text("PAUSA",W//2+60,160,C.accent,16,CENTER,180) text("PAUSA",W//2-60,152,C.accent,16,CENTER)
  elseif phase=="ready" then
    text(name.." · "..sub,W//2,138,C.mute,11,CENTER,180)
    text(name.." · "..sub,W//2,183,C.mute,11,CENTER)
  elseif phase=="flag" then
    text("fim de jogo",W//2,138,C.mute,11,CENTER,180) text("fim de jogo",W//2,183,C.mute,11,CENTER)
  end
end
