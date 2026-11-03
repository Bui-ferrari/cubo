-- name: Placar
-- icon: .....ff.....f/....f..f.../...f....f.../....f..f..../.....ff...../.ff.......ff./f..f.....f..f/f..f.....f..f/.ff.......ff./.....ff...../....f..f..../.....ff.....
-- Um jogador por lado do cubo. Cada número fica virado para o seu jogador.
local sc={0,0,0,0}   -- n, e, s, w
local minus=false
local hist={}
local SIDE={"n","e","s","w"}
local POS={{120,78,180},{192,160,-90},{120,250,0},{48,160,90}}
local COL={"accent","ok","warn","bad"}
local function lab() labels("+1","+1","+1","+1",minus and "Modo +" or "Modo -","Desfazer","Zerar") end
function on_enter() local s=recall("p","") if s~="" then local i=1 for v in s:gmatch("-?%d+") do sc[i]=tonumber(v) i=i+1 end end repeat_pads("") lab() end
local function store() save("p",table.concat(sc,",")) end
function on_pad(d,n)
  for i,k in ipairs(SIDE) do
    if k==d then
      table.insert(hist,{i,sc[i]}) if #hist>20 then table.remove(hist,1) end
      sc[i]=clamp(sc[i]+(minus and -1 or 1),-99,999)
      if n==1 then sfx(minus and "back" or "tick") end
      store()
    end
  end
end
function on_chord(c)
  if c=="ne" then minus=not minus sfx("tick") lab()
  elseif c=="se" then local h=table.remove(hist) if h then sc[h[1]]=h[2] store() sfx("back") end
  elseif c=="sw" then sc={0,0,0,0} hist={} store() sfx("back") end
end
function draw()
  clear() decor()
  for i,p in ipairs(POS) do
    text(sc[i],p[1],p[2],C[COL[i]],40,CENTER,p[3])
  end
  rect(W//2-26,H//2-13,52,26,C.panel,13)
  text(minus and "−1" or "+1",W//2,H//2,minus and C.bad or C.ok,16,CENTER,0)
end
