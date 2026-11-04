-- name: Marcadores e dado
-- icon: ............/.aaaa..bbbb./.a..a..b..b./.aaaa..bbbb./............/ffffffffffff/f..........f/f..ff..ff..f/f..........f/f..ff..ff..f/f..........f/ffffffffffff
-- Veneno (10 = derrota), energia, experiência e um dado. Cima/baixo escolhem a linha.
local DICE={20,2,6,10,12}
local val={0,0,0}       -- veneno, energia, experiência
local NAMES={"Veneno","Energia","Experiência"}
local row=1
local di=1
local result=nil
local rolling=0
local function lab()
  if row<=3 then labels("Acima","Abaixo","Menos","Mais","Zerar") repeat_pads("left right")
  else labels("Acima","Abaixo","Anterior","Próximo","Rolar") repeat_pads("") end
end
local function store() save("m",val[1]..","..val[2]..","..val[3]..","..di) end
function on_enter()
  local s=recall("m","")
  if s~="" then local a={} for v in s:gmatch("-?%d+") do a[#a+1]=tonumber(v) end
    if #a>=4 then val={a[1],a[2],a[3]} di=clamp(a[4],1,#DICE) end end
  lab()
end
local function roll() if rolling<=0 then rolling=0.8 sfx("roll") end end
function on_pad(d)
  if d=="up" then row=(row-2)%4+1 sfx("tick") lab()
  elseif d=="down" then row=row%4+1 sfx("tick") lab()
  elseif row<=3 then
    if d=="left" then val[row]=math.max(0,val[row]-1) sfx("back")
    elseif d=="right" then val[row]=math.min(row==1 and 10 or 99,val[row]+1) sfx(row==1 and val[row]>=10 and "lose" or "tick")
    elseif d=="ok" then val[row]=0 sfx("back") end
    store()
  else
    if d=="left" then di=(di-2)%#DICE+1 result=nil sfx("tick") store()
    elseif d=="right" then di=di%#DICE+1 result=nil sfx("tick") store()
    elseif d=="ok" then roll() end
  end
end
function on_shake() if row==4 then roll() end end
function update(dt)
  if rolling>0 then
    rolling=rolling-dt
    result=math.random(1,DICE[di])
  end
end
function draw()
  clear() decor()
  for r=1,4 do
    local y=30+(r-1)*66
    local on=(r==row)
    rect(X0,y,CW,60,on and C.panel or C.bg,12)
    frame(X0,y,CW,60,on and C.accent or C.mute,12,on and 3 or 1)
    if r<=3 then
      local bad=(r==1 and val[1]>=10)
      text(NAMES[r],X0+12,y+8,on and C.fg or C.mute,14,LEFT)
      numtext(val[r],X1-36,y+30,bad and C.bad or C.fg,34)
      if r==1 then
        for k=1,10 do circle(X0+16+(k-1)*14,y+46,4,k<=val[1] and C.bad or C.mute) end
        if bad then text("derrota",X0+12,y+8+14,C.bad,10,LEFT) end
      end
    else
      local t=DICE[di]
      text(t==2 and "Moeda" or ("d"..t),X0+12,y+8,on and C.fg or C.mute,14,LEFT)
      if result then
        if t==2 then text(result==1 and "CARA" or "COROA",X1-60,y+22,C.accent,20,CENTER)
        else numtext(result,X1-40,y+30,C.accent,34) end
      else text("rolar",X1-50,y+22,C.mute,14,CENTER) end
    end
  end
end
