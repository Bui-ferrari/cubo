-- name: Duelo de dados
-- icon: ............/.bbbbbb....../.bWbbbb....../.bbbWbb....../.bbbbbb....../.bbbbbb.oooooo/........oWoooo/........oooWoo/........oooooo/........oooooo/............/............
-- Dois dados prontos, um em cada ponta. Cada jogador toca no seu lado e o maior vence.
local BLUE,ORANGE=rgb(0x3E,0x7A,0xA7),rgb(0xEC,0x66,0x3B)
local PIPS={[1]={{.5,.5}},[2]={{.25,.25},{.75,.75}},[3]={{.25,.25},{.5,.5},{.75,.75}},[4]={{.25,.25},{.75,.25},{.25,.75},{.75,.75}},
[5]={{.25,.25},{.75,.25},{.5,.5},{.25,.75},{.75,.75}},[6]={{.25,.25},{.75,.25},{.25,.5},{.75,.5},{.25,.75},{.75,.75}}}
local faces=12   -- Futebol de Cartão usa só d12
local v={nil,nil}      -- 1 = lado de cima (azul), 2 = lado de baixo (laranja)
local roll={0,0}
local result=nil
local function lab() labels("Rolar azul","Rolar laranja","","","Novo") repeat_pads("") end
function on_enter() repeat_pads("") lab() end
local function try_result()
  if v[1] and v[2] and roll[1]<=0 and roll[2]<=0 then
    result=(v[1]>v[2]) and 1 or ((v[2]>v[1]) and 2 or 0)
    sfx(result==0 and "back" or "win")
  end
end
local function start(i)
  if result then v={nil,nil} result=nil end
  if roll[i]>0 then return end
  roll[i]=0.7 sfx("roll")
end
function on_pad(d)
  if d=="up" then start(1)
  elseif d=="down" then start(2)
  elseif d=="ok" then v={nil,nil} result=nil sfx("tick") end
end
function on_shake() end
function update(dt)
  for i=1,2 do
    if roll[i]>0 then
      roll[i]=roll[i]-dt
      v[i]=math.random(1,faces)
      if roll[i]<=0 then v[i]=math.random(1,faces) sfx("thunk") try_result() end
    end
  end
end
local function die(i,cy,rot)
  local s=92
  local x=W//2-s//2
  local y=cy-s//2
  local col=(i==1) and BLUE or ORANGE
  local jit=roll[i]>0 and math.random(-3,3) or 0
  x=x+jit
  local win=(result==i)
    poly(W//2+jit,cy+3,50,10,-90,C.mute,true)
    poly(W//2+jit,cy,50,10,-90,col,true)
    if win then poly(W//2+jit,cy,56,10,-90,C.fg,false,4) end
    if v[i] then numtext(v[i],W//2+jit,cy,rgb(255,255,255),36,rot) end
  if win then text("VENCEU",W//2,cy+(i==1 and -66 or 66),C.accent,14,CENTER,rot) end
end
function draw()
  clear() decor()
  die(1,92,180)
  die(2,228,0)
  local msg=result==0 and "empate" or (result and "" or "toque no seu lado")
  if msg~="" then text(msg,W//2,160,C.mute,12,CENTER) end
end
