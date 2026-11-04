-- layout: both
local ITEMS={"Skin","Virar tela","Inclinar","Volume","Brilho","Wi-Fi","Voltar"}
local sel=1
local first=1
local SKINS={"Cubo","Criya","PokePlace","Obirô"}
local TURN={"manual","inclinar"}
function on_enter() refresh_colors() labels("Acima","Abaixo","Menos","Mais","OK") repeat_pads("") end
local function change(dir)
  local k=ITEMS[sel]
  if k=="Skin" then _set("theme",(_get("theme")+dir)%4) refresh_colors() sfx("tick")
  elseif k=="Virar tela" then _set("orient",(_get("orient")+1)%2) sfx("tick")
  elseif k=="Inclinar" then _set("tilt",dir>0 and 1 or 0) sfx("tick")
  elseif k=="Volume" then _set("vol",clamp(_get("vol")+dir,0,5)) sfx("confirm")
  elseif k=="Brilho" then _set("bright",clamp(_get("bright")+dir,1,5)) sfx("tick")
  elseif k=="Wi-Fi" and dir>0 then sfx("confirm") _launch_store()
  elseif k=="Voltar" and dir>0 then home()
  else sfx("back") end
end
function on_pad(d)
  if d=="up" then sel=(sel-2)%#ITEMS+1 sfx("tick")
  elseif d=="down" then sel=sel%#ITEMS+1 sfx("tick")
  elseif d=="right" or d=="ok" then change(1)
  elseif d=="left" then change(-1) end
end
local function value(k)
  if k=="Skin" then return SKINS[_get("theme")+1]
  elseif k=="Virar tela" then return TURN[_get("orient")+1]
  elseif k=="Inclinar" then
    if _get("orient")==1 then return "(Virar tela manda)" end
    return _get("tilt")==1 and "navegar" or "desligado"
  elseif k=="Volume" then return string.rep("|",_get("vol")).." "..(_get("vol"))
  elseif k=="Brilho" then return string.rep("|",_get("bright")).." "..(_get("bright"))
  elseif k=="Wi-Fi" then local w=_wifi() return (w=="off" or w=="fail") and "desligado" or (w=="ready" and "conectado" or "...")
  else return "" end
end
function draw()
  clear()
  decor()
  local land=landscape()
  text("Ajustes",W//2,land and 28 or 34,C.fg,land and 20 or 24,CENTER)
  local top=land and 54 or 66
  local vis=math.floor((Y1-top)/30)
  if vis>#ITEMS then vis=#ITEMS end
  -- rolagem: mantém o item selecionado à vista
  if sel<first then first=sel end
  if sel>first+vis-1 then first=sel-vis+1 end
  first=clamp(first,1,#ITEMS-vis+1)
  for r=0,vis-1 do
    local i=first+r
    local k=ITEMS[i]
    local y=top+r*30
    if i==sel then rect(X0,y-4,CW,27,C.panel,10) frame(X0,y-4,CW,27,C.accent,10,3) end
    text(k,X0+10,y+2,C.fg,16,LEFT)
    local v=value(k)
    local size=12
    local room=CW-20-text_width(k,16)-10
    while size>8 and text_width(v,size)>room do size=size-1 end
    text(v,X1-10,y+4,i==sel and C.accent or C.mute,size,RIGHT)
  end
  if first>1 then tri(X1-8,top-10,X1-14,top-4,X1-2,top-4,C.mute) end
  if first+vis-1<#ITEMS then tri(X1-8,top+vis*30+2,X1-14,top+vis*30-4,X1-2,top+vis*30-4,C.mute) end
end
