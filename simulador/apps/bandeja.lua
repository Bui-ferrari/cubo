-- name: Bandeja de dados
-- icon: ............/.aaa..bbb..../.aWa..bWb..../.aaa..bbb..../............/...bb...aaa.../..bWWb..aWa.../...bb...aaa.../............/.ffffffffff./.f........f./.ffffffffff./............
-- Cada pad adiciona um dado de um tipo. Monte a jogada, chacoalhe e pronto.
local TYPES={4,6,8,10,12,20}
-- posição dos 8 pads (sentido horário a partir do topo esquerdo)
local PAD={wn=1,ws=2,en=3,es=4,s=5,n=6}
local SHAPE={[2]={0},[4]={3,-90},[6]={4,45},[8]={4,0},[10]={5,-90},[12]={10,-90},[20]={6,-90},[100]={0}}
local tray={}
local cur=2
local rolled=false
local rolling=0
local function nm(t) return t==2 and "Moeda" or ("d"..t) end
local function lab()
  split_pads(2)
  labels(nm(TYPES[6]),"","d12","","Rolar","Tirar","Limpar")
  labels_side(nm(TYPES[3]),nm(TYPES[4]),nm(TYPES[1]),nm(TYPES[2]))
  repeat_pads("")
end
function on_enter() lab() end
local function add(t) if #tray<12 then tray[#tray+1]={t=t,v=nil} rolled=false sfx("tick") else sfx("back") end end
local function roll() if #tray==0 then return end rolling=0.8 sfx("roll") end
function on_pad(d)
  if PAD[d] then add(TYPES[PAD[d]]) end
end
function on_chord(c)
  if c=="ne" then roll()
  elseif c=="se" then if #tray>0 then tray[#tray]=nil rolled=false sfx("back") end
  elseif c=="sw" then tray={} rolled=false sfx("back") end
end
function on_shake() roll() end
function update(dt)
  if rolling>0 then
    rolling=rolling-dt
    for _,d in ipairs(tray) do d.v=math.random(1,d.t) end
    if rolling<=0 then for _,d in ipairs(tray) do d.v=math.random(1,d.t) end rolled=true sfx("thunk") end
  end
end
local function token(x,y,s,d)
  local sh=SHAPE[d.t]
  local r=s//2
  if d.t==2 or d.t==100 then circle(x,y,r,C.panel) ring(x,y,r,C.accent,2)
  else poly(x,y,math.floor(r*1.1),sh[1],sh[2],C.panel,true) poly(x,y,math.floor(r*1.1),sh[1],sh[2],C.accent,false,2) end
  text(d.v and (d.t==2 and (d.v==1 and "C" or "K") or d.v) or "",x,y-8,C.fg,16,CENTER)
  text(d.t==2 and "" or ("d"..d.t),x,y+r-12,C.mute,8,CENTER)
end
function draw()
  clear() decor()
  text("Bandeja",W//2,32,C.fg,20,CENTER)
  local n=#tray
  for i,d in ipairs(tray) do
    local c=(i-1)%4 local r=(i-1)//4
    local x=X0+24+c*46 local y=100+r*58
    local j=rolling>0 and math.random(-2,2) or 0
    token(x+j,y,40,d)
  end
  if n==0 then text("toque nos pads para",W//2,150,C.mute,12,CENTER) text("adicionar dados",W//2,168,C.mute,12,CENTER) end
  if rolled then
    local sum=0 for _,d in ipairs(tray) do sum=sum+(d.v or 0) end
    text("Total "..sum,W//2,262,C.accent,22,CENTER)
  else
    text(n.." dado"..(n==1 and "" or "s"),W//2,264,C.mute,12,CENTER)
  end
end
