-- Wi-Fi e Loja de apps (simulados no navegador)
local sel=1
local t=0
function on_enter() refresh_colors() t=0 end
local function lab()
  local w=_wifi()
  if w=="off" or w=="fail" then labels("Conectar","","","","Conectar")
  elseif w=="ready" then labels("Acima","Instalar","Abaixo","Remover","OK","Atualizar")
  else labels("","","","") end
  repeat_pads("")
end
local last=""
local function toggle() if _store_count()>0 then _store_toggle(sel) sfx(_store_has(sel)==1 and "win" or "back") end end
function on_pad(d)
  local w=_wifi()
  if w=="off" or w=="fail" then if d=="n" then _wifi_go() sfx("confirm") end return end
  if w~="ready" then return end
  local n=_store_count()
  if d=="n" then sel=(sel-2)%n+1 sfx("tick")
  elseif d=="s" then sel=sel%n+1 sfx("tick")
  elseif d=="e" then if _store_has(sel)==0 then toggle() end
  elseif d=="w" then if _store_has(sel)==1 then toggle() end end
end
function on_chord(c)
  local w=_wifi()
  if c=="ne" then if w=="off" then _wifi_go() sfx("confirm") elseif w=="ready" then toggle() end
  elseif c=="se" and w=="ready" then _wifi_off() _wifi_go() sfx("tick") end
end
function update(dt) t=t+dt local w=_wifi() if w~=last then last=w lab() end end
function draw()
  clear() decor()
  text("Loja",W//2,34,C.fg,24,CENTER)
  local w=_wifi()
  if w=="off" or w=="fail" then
    text("Wi-Fi desligado",W//2,130,C.fg,18,CENTER)
    text("toque em Conectar",W//2,160,C.mute,12,CENTER)
  elseif w=="scan" or w=="on" or w=="check" then
    local dots=string.rep(".",1+math.floor(t*3)%3)
    text(w=="scan" and "Procurando redes" or (w=="on" and "Conectado a Casa-Maker" or "Buscando atualizações"),W//2,120,C.fg,14,CENTER)
    text(dots,W//2,146,C.accent,28,CENTER)
    arc(W//2,210,22,t*360,t*360+110,C.accent,6)
  else
    text("Casa-Maker · sistema 0.3 em dia",W//2,58,C.ok,11,CENTER)
    local n=_store_count()
    local first=math.max(1,math.min(sel-2,n-4))
    for k=0,4 do
      local i=first+k
      if i>n then break end
      local y=76+k*44
      local has=_store_has(i)==1
      rect(X0,y,CW,40,C.panel,10)
      if i==sel then frame(X0,y,CW,40,C.accent,10,3) end
      text(_store_name(i),X0+10,y+5,C.fg,14,LEFT)
      text(_store_kind(i)..string.format(" · %.1f KB",_store_size(i)),X0+10,y+24,C.mute,10,LEFT)
      text(has and "instalado" or "disponível",X1-10,y+24,has and C.ok or C.accent,10,RIGHT)
    end
  end
end
function _app_name_store(i) return _store_name(i) end
