-- name: Iniciativa
-- icon: ............/.aa.fffffff./............/.bb.ffffff../............/.aa.ffff..../............/.bb.ff....../............/............/............/............
-- Defina a iniciativa de até 6 combatentes (0 = fora) e siga a ordem, rodada a rodada.
local N=6
local NAMES={"A","B","C","D","E","F"}
local COLS={rgb(0x3E,0x7A,0xA7),rgb(0xD6,0x45,0x45),rgb(0x4C,0xAF,0x7A),rgb(0xF2,0xB5,0x31),rgb(0x9B,0x6B,0xD1),rgb(0xEC,0x66,0x3B)}
local ini={0,0,0,0,0,0}
do local s=recall("ini","") local i=1 for v in s:gmatch("%d+") do if i<=N then ini[i]=tonumber(v) end i=i+1 end end
local phase="setup"      -- setup, fight
local sel=1
local order={}
local pos,round=1,1
local function persist() save("ini",table.concat(ini,",")) end
local function lab()
  if phase=="setup" then labels("@up Acima","@down Abaixo","@minus Valor","@plus Valor","@play Começar") repeat_pads("left right")
  else labels("@left Anterior","Editar","","","@right Próximo") repeat_pads("") end
end
function on_enter() lab() end
local function build()
  order={}
  for i=1,N do if ini[i]>0 then order[#order+1]=i end end
  table.sort(order,function(x,y) if ini[x]~=ini[y] then return ini[x]>ini[y] end return x<y end)
end
function on_pad(d)
  if phase=="setup" then
    if d=="up" then sel=(sel-2)%N+1 sfx("tick")
    elseif d=="down" then sel=sel%N+1 sfx("tick")
    elseif d=="left" then ini[sel]=clamp(ini[sel]-1,0,30) persist() sfx("tick")
    elseif d=="right" then ini[sel]=clamp(ini[sel]+1,0,30) persist() sfx("tick")
    elseif d=="ok" then build() if #order==0 then sfx("back") else phase="fight" pos=1 round=1 sfx("confirm") lab() end end
  else
    if d=="ok" then pos=pos+1 if pos>#order then pos=1 round=round+1 sfx("win") else sfx("tick") end
    elseif d=="up" then pos=pos-1 if pos<1 then if round>1 then round=round-1 pos=#order else pos=1 end end sfx("tick")
    elseif d=="down" then phase="setup" sfx("tick") lab() end
  end
end
function on_shake() end
function draw()
  clear() decor()
  if phase=="setup" then
    text("Iniciativa",W//2,30,C.fg,18,CENTER)
    for i=1,N do
      local y=58+(i-1)*36
      local on=(i==sel)
      rect(X0,y,CW,32,on and C.panel or C.bg,10)
      if on then frame(X0,y,CW,32,C.accent,10,2) end
      circle(X0+20,y+16,11,COLS[i])
      text(NAMES[i],X0+20,y+16-7,rgb(255,255,255),14,CENTER)
      if ini[i]>0 then numtext(ini[i],X0+CW-40,y+16,on and C.accent or C.fg,22)
      else text("fora",X0+CW-40,y+16-6,C.mute,12,CENTER) end
    end
  else
    text("Rodada ",W//2-12,30,C.mute,14,CENTER) numtext(round,W//2+34,38,C.accent,18)
    local n=#order
    local show=math.min(n,6)
    for k=1,show do
      local idx=((pos-1+k-1)%n)+1
      local c=order[idx]
      local y=(k==1) and 58 or (112+(k-2)*34)
      local h=(k==1) and 48 or 30
      local on=(k==1)
      rect(X0,y,CW,h,on and COLS[c] or C.panel,12)
      if on then frame(X0-2,y-2,CW+4,h+4,C.fg,14,3) end
      local fg=on and rgb(255,255,255) or C.fg
      text(on and ("Vez de "..NAMES[c]) or NAMES[c],X0+14,y+h//2-(on and 9 or 7),fg,on and 18 or 14,LEFT)
      numtext(ini[c],X0+CW-30,y+h//2,fg,on and 26 or 18)
      if k==1 then end
    end
    if n>=2 then text("próximo: "..NAMES[order[(pos%n)+1]],W//2,282,C.mute,11,CENTER) end
  end
end
