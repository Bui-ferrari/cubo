-- name: Dados de Catan
-- icon: ............/.rrrrrr...../.rWrrWr.bbbb/.rrrrrr.bWWb/.rWrrWr.bbbb/.rrrrrr...../............/a.a.a.a.a.a./a.a.aaa.a.a./aaaaaaaaaaaa/aaaaaaaaaaaa/............
-- layout: both
-- Dois dados, histograma da partida e alerta do ladrão (7). Chacoalhe para rolar.
local RED,YEL=rgb(0xD6,0x45,0x45),rgb(0xE8,0xC2,0x3A)
local PIPS={[1]={{.5,.5}},[2]={{.28,.28},{.72,.72}},[3]={{.28,.28},{.5,.5},{.72,.72}},[4]={{.28,.28},{.72,.28},{.28,.72},{.72,.72}},
[5]={{.28,.28},{.72,.28},{.5,.5},{.28,.72},{.72,.72}},[6]={{.28,.28},{.72,.28},{.28,.5},{.72,.5},{.28,.72},{.72,.72}}}
local d={nil,nil}
local hist={} for s=2,12 do hist[s]=0 end
local stack={}
local n=0
local rolling,tick,tt=0,0,0
local function lab() labels("","","@back Desfazer","@reset Zerar","Rolar") repeat_pads("") end
function on_enter() lab() end
local function start() if rolling>0 then return end rolling=0.8 tick=0 sfx("roll") end
function on_pad(p)
  if rolling>0 then return end
  if p=="ok" then start()
  elseif p=="left" then
    local s=table.remove(stack)
    if s then hist[s[1]+s[2]]=hist[s[1]+s[2]]-1 n=n-1 sfx("back") end
    local l=stack[#stack]
    if l then d={l[1],l[2]} else d={nil,nil} end
  elseif p=="right" then
    for s=2,12 do hist[s]=0 end stack={} n=0 d={nil,nil} sfx("back")
  end
end
function on_shake() start() end
function update(dt)
  tt=tt+dt
  if rolling>0 then
    rolling=rolling-dt tick=tick-dt
    if tick<=0 then tick=0.07 d={math.random(1,6),math.random(1,6)} end
    if rolling<=0 then
      d={math.random(1,6),math.random(1,6)}
      local s=d[1]+d[2]
      hist[s]=hist[s]+1 n=n+1 stack[#stack+1]={d[1],d[2]}
      if #stack>99 then table.remove(stack,1) end
      sfx(s==7 and "back" or "thunk")
    end
  end
end
local function die(x,y,s,v,col)
  rect(x,y+3,s,s,C.mute,10) rect(x,y,s,s,col,10)
  if v then for _,p in ipairs(PIPS[v]) do circle(x+math.floor(p[1]*s),y+math.floor(p[2]*s),5,rgb(0x2A,0x1A,0x14)) end end
end
function draw()
  clear() decor()
  local P=portrait()
  local jx=rolling>0 and math.random(-2,2) or 0
  local cx=X0+CW//2
  local sum=(d[1] and d[2]) and d[1]+d[2] or nil
  local is7=sum==7 and rolling<=0
  local yd,ys,ya,yt,yc,base,mh,pitch,xh,ydig
  if P then
    die(cx-70+jx,34,54,d[1],RED) die(cx+16+jx,34,54,d[2],YEL)
    yd,ys,ya,yt,yc,base,mh,pitch,xh,ydig=0,110,138,146,172,266,90,16,30,277
    if sum then numtext(sum,cx,ys,is7 and C.bad or C.fg,30) end
  else
    die(X0+8+jx,Y0+4,54,d[1],RED) die(X0+72+jx,Y0+4,54,d[2],YEL)
    ya,yt,yc,base,mh,pitch,ydig=Y0+68,Y0+70,Y0+98,Y1-20,58,22,Y1-14
    xh=X0+(CW-11*pitch)//2+3
    if sum then numtext(sum,X0+190,Y0+34,is7 and C.bad or C.fg,40) end
  end
  if is7 then
    local on=math.floor(tt*3)%2==0
    rect(X0,ya,CW,26,on and C.bad or C.panel,8)
    text("LADRÃO! +7 cartas: descarte",cx,ya+6,on and rgb(255,255,255) or C.bad,12,CENTER)
  elseif sum and rolling<=0 then
    text((6-math.abs(sum-7)).." em 36 jogadas",cx,yt,C.mute,11,CENTER)
  else text(n==0 and "chacoalhe ou toque em Rolar" or "",cx,yt,C.mute,11,CENTER) end
  local mx=3 for s=2,12 do if hist[s]>mx then mx=hist[s] end end
  local bw=P and 13 or 18
  for s=2,12 do
    local x=xh+(s-2)*pitch
    local h=math.floor(hist[s]/mx*mh)
    local col=(s==7) and C.bad or C.accent2
    if sum and s==sum and rolling<=0 then col=C.accent end
    if h>0 then rect(x,base-h,bw,h,col,3) end
    rect(x,base,bw,2,C.mute)
    if n>0 then
      local e=math.floor(n*(6-math.abs(s-7))/36/mx*mh)
      rect(x+3,base-e-1,bw-6,2,C.fg)
    end
    numtext(s,x+bw//2,ydig,s==7 and C.bad or C.fg,9)
  end
  text(n.." jogadas · traço = esperado",cx,yc,C.mute,10,CENTER)
end
