-- name: Iniciativa
-- icon: ............/.aa.fffffff./............/.bb.ffffff../............/.aa.ffff..../............/.bb.ff....../............/............/............/............
-- layout: both
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
local function rowbox(x,y,w,h,on) rect(x,y,w,h,on and C.panel or C.bg,10) if on then frame(x,y,w,h,C.accent,10,2) end end
local function setup_row(i,x,y,w)
  local on=(i==sel)
  rowbox(x,y,w,32,on)
  circle(x+20,y+16,11,COLS[i])
  text(NAMES[i],x+20,y+16-7,rgb(255,255,255),14,CENTER)
  if ini[i]>0 then numtext(ini[i],x+w-40,y+16,on and C.accent or C.fg,22)
  else text("fora",x+w-40,y+16-6,C.mute,12,CENTER) end
end
function draw()
  clear() decor()
  local land=landscape()
  if phase=="setup" then
    text("Iniciativa",W//2,land and Y0-4 or 30,C.fg,18,CENTER)
    if land then   -- duas colunas de 3
      local cw=(CW-8)//2
      for i=1,N do
        local c=(i-1)//3 local r=(i-1)%3
        setup_row(i,X0+c*(cw+8),Y0+26+r*(34+8),cw)
      end
    else
      for i=1,N do setup_row(i,X0,58+(i-1)*36,CW) end
    end
  else
    local n=#order
    if land then
      text("Rodada ",X0+30,Y0-2,C.mute,14,CENTER) numtext(round,X0+80,Y0+6,C.accent,18)
      -- vez atual à esquerda, fila à direita
      local c=order[pos]
      local lw=150
      rect(X0,Y0+30,lw,CH-52,COLS[c],12) frame(X0-2,Y0+28,lw+4,CH-48,C.fg,14,3)
      text("Vez de",X0+lw//2,Y0+52,rgb(255,255,255),14,CENTER)
      text(NAMES[c],X0+lw//2,Y0+72,rgb(255,255,255),34,CENTER)
      numtext(ini[c],X0+lw//2,Y0+CH-46,rgb(255,255,255),26)
      local show=math.min(n-1,4)
      local rx=X0+lw+12
      local rw=CW-lw-12
      for k=1,show do
        local idx=((pos-1+k)%n)+1
        local cc=order[idx]
        local y=Y0+30+(k-1)*34
        rect(rx,y,rw,30,C.panel,10)
        text(NAMES[cc],rx+12,y+8,C.fg,14,LEFT)
        numtext(ini[cc],rx+rw-26,y+15,C.fg,18)
      end
    else
      text("Rodada ",W//2-12,30,C.mute,14,CENTER) numtext(round,W//2+34,38,C.accent,18)
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
      end
      if n>=2 then text("próximo: "..NAMES[order[(pos%n)+1]],W//2,282,C.mute,11,CENTER) end
    end
  end
end
