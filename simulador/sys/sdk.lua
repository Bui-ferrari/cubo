W,H=240,320
X0,Y0,X1,Y1=26,26,214,294
CW,CH=188,268
ROT=0   -- para quem o texto está virado: 0, 90, 180 ou 270 (só muda em apps '-- layout: both')
LEFT,CENTER,RIGHT=0,1,2
C=setmetatable({},{__index=function(t,k) local v=_theme(k) rawset(t,k,v) return v end})
function refresh_colors() for k in pairs(C) do C[k]=nil end end
function rgb(r,g,b) return (r<<16)|(g<<8)|b end
function clamp(v,a,b) if v<a then return a elseif v>b then return b end return v end
function clear(c) _clear(c or C.bg) end
function rect(x,y,w,h,c,r) _rect(x,y,w,h,c or C.fg,1,r or 0,0) end
function frame(x,y,w,h,c,r,t) _rect(x,y,w,h,c or C.fg,0,r or 0,t or 2) end
function circle(x,y,r,c) _circle(x,y,r,c or C.fg,1,2) end
function ring(x,y,r,c,t) _circle(x,y,r,c or C.fg,0,t or 2) end
function line(x1,y1,x2,y2,c,t) _line(x1,y1,x2,y2,c or C.fg,t or 2) end
function arc(x,y,r,a0,a1,c,t) _arc(x,y,r,a0,a1,c or C.fg,t or 6) end
function text(s,x,y,c,size,align,rot) _text(tostring(s),x,y,c or C.fg,size or 16,align or 0,rot or 0) end
-- número de dado centrado no ponto (cx,cy); sublinha 6 e 9 (e números que os contêm) para dar a orientação
function numtext(v,cx,cy,c,size,rot)
  local s=tostring(v) c=c or C.fg size=size or 16
  local r=((rot or 0)%360)
  if r==0 then text(s,cx,cy-size//2-1,c,size,CENTER) else text(s,cx,cy,c,size,CENTER,r) end
  if s:find("[69]") then
    local w=text_width(s,size) local t=math.max(2,size//10) local d=size//2+1
    if r==0 then rect(cx-w//2,cy+d,w,t,c)
    elseif r==180 then rect(cx-w//2,cy-d-t,w,t,c)
    elseif r==90 then rect(cx-d-t,cy-w//2,t,w,c)
    elseif r==270 then rect(cx+d,cy-w//2,t,w,c) end
  end
end
function tri(x1,y1,x2,y2,x3,y3,c) _tri(x1,y1,x2,y2,x3,y3,c or C.fg) end
function poly(x,y,r,n,rot,c,fill,t) _poly(x,y,r,n,rot or 0,c or C.fg,fill and 1 or 0,t or 2) end
-- decoração de canto de cada skin (quarto de círculo, canto cortado, barras)
function decor()
  local d=_theme("decor")
  if d==0 then circle(0,H,58,C.deco)
  elseif d==1 then tri(W,0,W,56,W-56*1.4466,0,C.deco)
  else rect(0,H-24,38,5,C.deco) rect(0,H-16,56,5,C.deco) rect(0,H-8,74,5,C.deco) end
end
function portrait() return H>=W end
function landscape() return W>H end
-- Pads (6, sem combinar toques). Nomes lógicos que o app recebe em on_pad(d): "up","down","left","right","ok".
-- "back" (Voltar) é do sistema: sobe um nível e nunca chega ao app.
-- labels(cima, baixo, esquerda, direita, ok): texto de cada pad na borda da tela. Vazio = pad sem função.
function labels(up,down,left,right,ok,back) _labels(up or "",down or "",left or "",right or "",ok or "",back or "") end
-- repeat_pads("left right"): nomes dos pads que repetem ao segurar
function repeat_pads(s) _repeat(s or "") end
function sfx(n) _sfx(n) end
function play(song,bpm,loop,wave) _play(song,bpm or 160,loop and 1 or 0,wave or "square") end
function stop_sound() _stopsound() end
function millis() return _millis() end
function now() return _time() end
function accel() return _accel() end
function home() _home() end
function text_width(s,size) return _tw(s,size) end
function wrap(s,size,maxw)
  local lines,line={},""
  for word in tostring(s):gmatch("%S+") do
    local t=(line=="") and word or (line.." "..word)
    if _tw(t,size)>maxw and line~="" then lines[#lines+1]=line line=word else line=t end
  end
  if line~="" then lines[#lines+1]=line end
  return lines
end
function speak(s) _speak(s) end
function speak_stop() _speak_stop() end
function wifi_state() return _wifi() end
function save(k,v) _save(k,tostring(v)) end
function recall(k,d) local v=_load(k) if v=="" then return d end return v end
local PAL={a="accent",b="accent2",f="fg",m="mute",o="ok",w="warn",r="bad",p="panel",W="white",k="black"}
function pixels(x,y,s,rows,pal)
  for j=1,#rows do
    local row=rows[j]
    for i=1,#row do
      local ch=row:sub(i,i)
      if ch~="." then
        local c=(pal and pal[ch]) or (PAL[ch] and C[PAL[ch]])
        if c then _rect(x+(i-1)*s,y+(j-1)*s,s,s,c,1,0,0) end
      end
    end
  end
end
os=nil debug=nil dofile=nil loadfile=nil require=nil package=nil
