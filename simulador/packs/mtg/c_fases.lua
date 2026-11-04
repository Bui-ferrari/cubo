-- name: Fases do turno
-- icon: ............/.ffffffffff./............/.aaaaaaaaaa./............/.ffffffffff./............/.ffffffffff./............/.ffffffffff./............/............
-- layout: both
-- Sete etapas do turno, uma vez para cada jogador. Direita avança, esquerda volta, OK passa o turno.
local BLUE,RED=rgb(0x3E,0x7A,0xA7),rgb(0xD6,0x45,0x45)
local PC={BLUE,RED}
local PN={"azul","vermelho"}
local PH={"Desvirar","Manutenção","Compra","Principal 1","Combate","Principal 2","Final"}
local ph,turn,who=1,1,1
local armed=0
local function lab()
  labels("","@reset "..(armed>0 and "Confirmar?" or "Zerar"),"Anterior","Próximo","@ok Passar turno")
  repeat_pads("")
end
local function store() save("f",ph..","..turn..","..who) end
function on_enter()
  local s=recall("f","")
  if s~="" then local a={} for v in s:gmatch("%d+") do a[#a+1]=tonumber(v) end
    if #a>=3 then ph,turn,who=clamp(a[1],1,7),math.max(1,a[2]),clamp(a[3],1,2) end end
  lab()
end
local function pass() ph=1 turn=turn+1 who=3-who sfx("win") end
function on_pad(d)
  if d=="right" then if ph<7 then ph=ph+1 sfx("tick") else pass() end
  elseif d=="left" then if ph>1 then ph=ph-1 sfx("back") end
  elseif d=="ok" then pass()
  elseif d=="down" then
    if armed>0 then ph,turn,who=1,1,1 armed=0 sfx("confirm") else armed=3 sfx("tick") end
    lab() store() return
  end
  store()
end
function update(dt) if armed>0 then armed=armed-dt if armed<=0 then armed=0 lab() end end end
function draw()
  clear() decor()
  local land=landscape()
  local w=rgb(255,255,255)
  rect(X0,land and Y0 or 30,CW,34,PC[who],12)
  text("Turno "..turn.." · vez do "..PN[who],W//2,(land and Y0 or 30)+8,w,14,CENTER)
  local cw=land and (CW-8)//2 or CW
  for r=1,7 do
    local x,y
    if land then x=X0+((r-1)//4)*(cw+8) y=Y0+40+((r-1)%4)*36
    else x=X0 y=70+(r-1)*32 end
    local on=(r==ph)
    if on then rect(x,y,cw,28,PC[who],10) else frame(x,y,cw,28,C.mute,10,1) end
    text(r,x+16,y+6,on and w or C.mute,16,CENTER)
    text(PH[r],x+36,y+6,on and w or C.fg,land and 14 or 16,LEFT)
  end
end
