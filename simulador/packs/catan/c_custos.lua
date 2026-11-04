-- name: Custos
-- icon: ............/.....aa...../....aaaa..../...aaaaaa.../..aaaaaaaa../..a.aaaa.a../..a.a..a.a../..aaaaaaaa../............/............/............/............
-- layout: both
-- Cartinha de consulta: quanto custa construir. Toque em Ler para ouvir.
local R={mad={"Madeira",rgb(0x2E,0x7D,0x32)},tij={"Tijolo",rgb(0xC0,0x50,0x2D)},la={"Lã",rgb(0x8C,0xC6,0x3F)},tri={"Trigo",rgb(0xD9,0xA8,0x1E)},min={"Minério",rgb(0x6E,0x7B,0x88)}}
local ITEMS={
 {"Estrada",{{"mad",1},{"tij",1}},"Limite de 15 por jogador","1 madeira e 1 tijolo","estrada"},
 {"Colônia",{{"mad",1},{"tij",1},{"la",1},{"tri",1}},"Vale 1 ponto · limite de 5","1 madeira, 1 tijolo, 1 lã e 1 trigo","colonia"},
 {"Cidade",{{"tri",2},{"min",3}},"Vale 2 pontos · troca uma colônia","2 trigos e 3 minérios","cidade"},
 {"Carta de evolução",{{"la",1},{"tri",1},{"min",1}},"Cavaleiro, ponto ou progresso","1 lã, 1 trigo e 1 minério","carta"}}
local i=1
local tt=0
function on_enter() labels("","","Anterior","Próximo","Ler") repeat_pads("") end
function on_pad(p)
  if p=="left" then i=(i-2)%#ITEMS+1 sfx("tick")
  elseif p=="right" then i=i%#ITEMS+1 sfx("tick")
  elseif p=="ok" then speak(ITEMS[i][1]..": "..ITEMS[i][4]) end
end
function update(dt) tt=tt+dt end
local function icon(k,cx,cy)
  local fg=C.fg
  if k=="estrada" then line(cx-34,cy+10,cx+34,cy-10,fg,10) line(cx-34,cy+10,cx+34,cy-10,C.accent,5)
  elseif k=="colonia" then rect(cx-18,cy-4,36,26,C.accent,4) tri(cx-24,cy-3,cx+24,cy-3,cx,cy-26,fg)
  elseif k=="cidade" then rect(cx-30,cy-4,60,28,C.accent,4) rect(cx-30,cy-24,24,22,C.accent,4) tri(cx-34,cy-24,cx-2,cy-24,cx-18,cy-38,fg) rect(cx+4,cy+6,12,18,fg,2)
  else rect(cx-20,cy-28,40,56,C.panel,6) frame(cx-20,cy-28,40,56,C.accent,6,3) text("?",cx,cy-12,C.accent,26,CENTER) end
end
function draw()
  clear() decor()
  local P=portrait()
  local it=ITEMS[i]
  local c=it[2]
  local tw,gap=P and 42 or 36,P and 6 or 4
  local tx=P and W//2 or X0+60
  text(it[1],tx,P and 34 or Y0+6,C.fg,(#it[1]>12) and 16 or 22,CENTER)
  icon(it[5],tx,P and 92 or Y0+72)
  local x0,yc
  if P then x0=W//2-(#c*tw+(#c-1)*gap)//2 yc=150
  else x0=X0+CW-(4*tw+3*gap)+(4-#c)*(tw+gap)//2 yc=Y0+44 end
  for k=1,#c do
    local r=R[c[k][1]]
    local x=x0+(k-1)*(tw+gap)
    rect(x,yc,tw,tw,r[2],10)
    numtext(c[k][2],x+tw//2,yc+tw//2,rgb(255,255,255),P and 24 or 20)
    text(r[1],x+tw//2,yc+tw+4,C.fg,P and 10 or 9,CENTER)
  end
  text(it[3],P and W//2 or X0+CW//2,P and 222 or Y1-42,C.mute,11,CENTER)
  local dy=P and 262 or Y1-12
  for k=1,#ITEMS do
    local dx=(P and W//2 or X0+CW//2)+(k-2.5)*16
    if k==i then circle(dx,dy,5,C.accent) else ring(dx,dy,4,C.mute,2) end
  end
end
