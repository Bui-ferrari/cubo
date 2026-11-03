-- name: Reflexo
-- icon: ............/.....aa...../....aaaa..../...aaaaaa.../............/.aa..aa..aa./.aa..aa..aa./............/...aaaaaa.../....aaaa..../.....aa...../............
-- store: 1
-- Um jogador por lado. Espere o VAI! e toque no seu pad primeiro. Cedo demais = fora da rodada.
local state="idle"     -- idle, wait, go, done
local t,delay=0,0
local out={n=false,e=false,s=false,w=false}
local winner=nil
local POS={n={120,70,180},e={196,160,-90},s={120,250,0},w={44,160,90}}
local PM={up="n",right="e",down="s",left="w"}
local function lab() labels("","","","","Iniciar") end
function on_enter() repeat_pads("") lab() end
local function start() state="wait" t=0 delay=2+math.random()*4 out={n=false,e=false,s=false,w=false} winner=nil sfx("tick") labels("","","","","") end
function on_pad(d)
  if d=="ok" then if state=="idle" or state=="done" then start() end return end
  d=PM[d]
  if state=="wait" then if not out[d] then out[d]=true sfx("back") end
  elseif state=="go" then if not out[d] then winner=d state="done" sfx("win") lab() end
  end
end
function update(dt)
  t=t+dt
  if state=="wait" and t>=delay then state="go" t=0 sfx("confirm")
    if out.n and out.e and out.s and out.w then state="done" end end
end
function draw()
  local bg=C.bg
  if state=="go" then bg=C.ok end
  clear(bg) if state~="go" then decor() end
  local msg={idle="Reflexo",wait="espere...",go="VAI!",done=winner and "ponto!" or "ninguém"}
  text(msg[state],W//2,H//2-14,state=="go" and C.bg or C.fg,state=="go" and 40 or 24,CENTER)
  for k,p in pairs(POS) do
    local c=C.panel
    if out[k] then c=C.bad end
    if winner==k then c=C.accent end
    circle(p[1],p[2],16,c)
    text(out[k] and "×" or (winner==k and "★" or ""),p[1],p[2],C.bg,18,CENTER,p[3])
  end
  if state=="idle" then text("cada jogador toca no seu lado",W//2,H//2+22,C.mute,10,CENTER) end
end
