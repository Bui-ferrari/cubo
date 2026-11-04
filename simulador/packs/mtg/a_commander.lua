-- name: Commander 4
-- icon: ............/a....a....a./aa..aaa..aa./aaa.aaa.aaa./aaaaaaaaaaaa/aaaaaaaaaaaa/aaaaaaaaaaaa/.bbbbbbbbbb./............/............/............/............
-- Quatro jogadores, 40 de vida. OK troca o modo; cada jogador aperta o pad do seu lado.
-- Comandante: aperte o pad de quem ataca e depois o de quem recebe.
local COL={rgb(0x3E,0x7A,0xA7),rgb(0xD6,0x45,0x45),rgb(0x4F,0xA3,0x6B),rgb(0xE0,0xA8,0x2E)}
local NAME={"azul","vermelho","verde","amarelo"}
local SIDE={"up","right","down","left"}
local POS={{120,58,180},{192,160,-90},{120,262,0},{46,160,90}}
local CAP={{120,92,180},{158,160,-90},{120,228,0},{82,160,90}}
local life={40,40,40,40}
local pois={0,0,0,0}
local cmd={{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}   -- cmd[vítima][atacante]
local MODES={
  {n="Vida -1",k="life",v=-1,s1="VIDA",s2="-1",ic="@minus 1 "},
  {n="Vida +1",k="life",v=1,s1="VIDA",s2="+1",ic="@plus 1 "},
  {n="Vida -5",k="life",v=-5,s1="VIDA",s2="-5",ic="@minus 5 "},
  {n="Veneno +1",k="pois",v=1,s1="VENENO",s2="+1",ic="@plus veneno "},
  {n="Comandante",k="cmd",v=1,s1="CMDR",s2="+1",ic="Dano "},
  {n="Veneno -1",k="pois",v=-1,s1="VENENO",s2="-1",ic="@minus veneno "},
  {n="Cmdr -1",k="cmd",v=-1,s1="CMDR",s2="-1",ic="Desfaz "},
  {n="Novo jogo",k="reset",v=0,s1="NOVO",s2="40",ic="@reset 40 "},
}
local mode=1
local sel=0           -- atacante escolhido no modo Comandante
local function maxcmd(i) local m=0 for a=1,4 do if cmd[i][a]>m then m=cmd[i][a] end end return m end
local function dead(i) return life[i]<=0 or pois[i]>=10 or maxcmd(i)>=21 end
local function lab()
  local m=MODES[mode]
  local t={}
  for k=1,4 do
    if m.k=="cmd" then
      if sel==0 then t[k]=m.ic.."de "..NAME[k] elseif sel==k then t[k]="Cancelar" else t[k]=m.ic.."em "..NAME[k] end
    else t[k]=m.ic..NAME[k] end
  end
  labels(t[1],t[3],t[4],t[2],"Modo "..MODES[mode%#MODES+1].n)
  repeat_pads("")
end
local function store()
  local a={} for i=1,4 do a[#a+1]=life[i] end for i=1,4 do a[#a+1]=pois[i] end
  for i=1,4 do for j=1,4 do a[#a+1]=cmd[i][j] end end
  save("c",table.concat(a,","))
end
local function load()
  local s=recall("c","") if s=="" then return end
  local a={} for v in s:gmatch("-?%d+") do a[#a+1]=tonumber(v) end
  if #a<24 then return end
  for i=1,4 do life[i]=a[i] pois[i]=a[4+i] end
  for i=1,4 do for j=1,4 do cmd[i][j]=a[8+(i-1)*4+j] end end
end
function on_enter() load() lab() end
local function newgame()
  life={40,40,40,40} pois={0,0,0,0}
  for i=1,4 do cmd[i]={0,0,0,0} end
  sel=0
end
function on_pad(d)
  if d=="ok" then mode=mode%#MODES+1 sel=0 sfx("tick") lab() return end
  local i for k=1,4 do if SIDE[k]==d then i=k end end
  if not i then return end
  local m=MODES[mode]
  if m.k=="life" then life[i]=clamp(life[i]+m.v,-99,999) sfx(m.v<0 and "back" or "tick")
  elseif m.k=="pois" then pois[i]=clamp(pois[i]+m.v,0,10) sfx(m.v<0 and "back" or "tick")
  elseif m.k=="reset" then life[i]=40 pois[i]=0 cmd[i]={0,0,0,0} sfx("confirm")
  elseif m.k=="cmd" then
    if sel==0 then sel=i sfx("tick")
    elseif sel==i then sel=0 sfx("back")
    else
      local before=cmd[i][sel]
      cmd[i][sel]=clamp(before+m.v,0,21)
      local real=cmd[i][sel]-before
      life[i]=life[i]-real          -- dano de comandante também tira vida
      sel=0 sfx(real<0 and "back" or "tick")
    end
    lab()
  end
  store()
end
function update() end
function draw()
  clear() decor()
  for i=1,4 do
    local p,c=POS[i],CAP[i]
    local col=dead(i) and C.bad or COL[i]
    if sel==i then ring(p[1],p[2],30,COL[i],3) end
    numtext(life[i],p[1],p[2],col,36,p[3])
    local cap=""
    if dead(i) then cap="fora!"
    else
      if pois[i]>0 then cap="veneno "..pois[i] end
      local mc=maxcmd(i)
      if mc>0 then cap=(cap~="" and (cap.." · ") or "").."cmdr "..mc end
    end
    if cap~="" then text(cap,c[1],c[2],dead(i) and C.bad or C.mute,10,CENTER,c[3]) end
  end
  local m=MODES[mode]
  rect(W//2-26,H//2-24,52,48,C.panel,10)
  if m.k=="cmd" and sel>0 then
    text("CMDR",W//2,H//2-14,COL[sel],10,CENTER) text("quem",W//2,H//2-2,C.fg,10,CENTER) text("recebe?",W//2,H//2+9,C.fg,10,CENTER)
  else
    text(m.s1,W//2,H//2-17,C.mute,10,CENTER)
    text(m.s2,W//2,H//2-2,C.accent,18,CENTER)
  end
end
