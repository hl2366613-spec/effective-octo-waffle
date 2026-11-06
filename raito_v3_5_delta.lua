-- ライト [ raito ] V3.5 | Delta X VNG Mobile
-- Ban giao dien thong tin/tuy chinh local; khong co ESP nguoi choi, aim, kill hay teleport.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

pcall(function()
    local old = CoreGui:FindFirstChild("LightMenuUI")
    if old then old:Destroy() end
end)

local T = {
    bg=Color3.fromRGB(255,240,243), panel=Color3.fromRGB(255,250,250),
    btn=Color3.fromRGB(255,226,230), text=Color3.fromRGB(115,75,85),
    border=Color3.fromRGB(245,175,190), accent=Color3.fromRGB(235,130,155),
    on=Color3.fromRGB(140,210,150), off=Color3.fromRGB(240,120,120)
}
local function round(o,r)
    local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 9); c.Parent=o
end
local function outline(o)
    local s=Instance.new("UIStroke"); s.Color=T.border; s.Thickness=1.3; s.Parent=o
end
local function button(parent,txt,h)
    local b=Instance.new("TextButton"); b.Size=UDim2.new(1,-8,0,h or 30)
    b.BackgroundColor3=T.btn; b.Text=txt; b.TextColor3=T.text
    b.TextSize=11; b.Font=Enum.Font.GothamBold; b.Parent=parent
    round(b,8); outline(b); return b
end
local function label(parent,txt,h,size)
    local l=Instance.new("TextLabel"); l.Size=UDim2.new(1,-8,0,h or 30)
    l.BackgroundColor3=T.panel; l.Text=txt; l.TextColor3=T.text
    l.TextSize=size or 11; l.Font=Enum.Font.GothamBold
    l.TextWrapped=true; l.Parent=parent; round(l,8); outline(l); return l
end
local gui=Instance.new("ScreenGui"); gui.Name="LightMenuUI"
gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.Parent=CoreGui

local hud=Instance.new("Frame"); hud.Size=UDim2.fromOffset(260,40)
hud.Position=UDim2.new(.5,-130,0,12); hud.BackgroundColor3=T.bg; hud.Parent=gui
round(hud,10); outline(hud)
local hudText=Instance.new("TextLabel"); hudText.Size=UDim2.fromScale(1,1)
hudText.BackgroundTransparency=1; hudText.TextColor3=T.accent
hudText.TextSize=11; hudText.Font=Enum.Font.GothamBold; hudText.Parent=hud

local open=button(gui,"ライト",48); open.Size=UDim2.fromOffset(50,50)
open.Position=UDim2.new(.03,0,.15,0); open.Active=true; open.Draggable=true
open.TextColor3=T.accent; round(open,25)

local main=Instance.new("Frame"); main.Size=UDim2.new(.92,0,0,400)
main.Position=UDim2.new(.04,0,.5,-200); main.BackgroundColor3=T.bg
main.Active=true; main.Draggable=true; main.Parent=gui
round(main,14); outline(main)
local limit=Instance.new("UISizeConstraint"); limit.MaxSize=Vector2.new(480,450)
limit.MinSize=Vector2.new(285,340); limit.Parent=main
local title=label(main,"ライト  [ raito ] V3.5",32,15)
title.Position=UDim2.fromOffset(6,4); title.BackgroundTransparency=1
local close=button(main,"×",26); close.Size=UDim2.fromOffset(30,26)
close.Position=UDim2.new(1,-36,0,6)
close.MouseButton1Click:Connect(function() main.Visible=false end)
open.MouseButton1Click:Connect(function() main.Visible=not main.Visible end)

local tabs=Instance.new("Frame"); tabs.Size=UDim2.new(0,100,1,-50)
tabs.Position=UDim2.fromOffset(7,42); tabs.BackgroundTransparency=1; tabs.Parent=main
local tl=Instance.new("UIListLayout"); tl.Padding=UDim.new(0,5); tl.Parent=tabs
local holder=Instance.new("Frame"); holder.Size=UDim2.new(1,-116,1,-50)
holder.Position=UDim2.fromOffset(112,42); holder.BackgroundTransparency=1; holder.Parent=main

local pages={}
local function page(name)
    local p=Instance.new("ScrollingFrame"); p.Name=name
    p.Size=UDim2.fromScale(1,1); p.BackgroundTransparency=1
    p.BorderSizePixel=0; p.ScrollBarThickness=3; p.Visible=false; p.Parent=holder
    local l=Instance.new("UIListLayout"); l.Padding=UDim.new(0,5); l.Parent=p
    l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        p.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+10)
    end)
    pages[name]=p; return p
end
local home=page("Home"); local graphics=page("DoHoa")
local settings=page("Settings"); local notes=page("Notes")
local function switch(target)
    for _,p in pairs(pages) do p.Visible=(p==target) end
end
local function tab(txt,target)
    local b=button(tabs,txt,32); b.MouseButton1Click:Connect(function() switch(target) end)
end
tab("🏠 Home",home); tab("🎨 Độ Họa",graphics)
tab("⚙ Cài đặt",settings); tab("📝 Ghi chú",notes); switch(home)

-- Thong tin Home
label(home,"🌸 THÔNG TIN SERVER 🌸",28,13)
local started=os.clock()
local function vnTime()
    local t=os.date("!*t",os.time()+7*3600)
    return string.format("%02d:%02d:%02d",t.hour,t.min,t.sec)
end
local function ping()
    local n=0
    pcall(function() n=Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    if type(n)~="number" then n=0 end
    return math.floor(n)
end
local function pingText(n)
    if n<=80 then return "Làm mượt" elseif n<=150 then return "Bình thường"
    elseif n<=250 then return "Lag" else return "Cực lag" end
end
local function battery()
    for _,k in ipairs({"getbatterypercent","getbatterypercentage","get_battery_level"}) do
        local f
        pcall(function() f=getfenv()[k] end)
        if type(f)=="function" then
            local ok,v=pcall(f)
            if ok and tonumber(v) then return tostring(math.clamp(math.floor(tonumber(v)),0,100)).."%" end
        end
    end
    return "Executor không hỗ trợ"
end
local function serverId()
    local id=tostring(game.JobId or "")
    if id=="" then return "Chưa có mã server" end
    return string.sub(id,1,8).."..."
end
local server=label(home,"Server: ...",32)
local uptime=label(home,"Server đã chạy: ...",30)
local bat=label(home,"Pin thiết bị: ...",30)
local clock=label(home,"🕒 GIỜ VIỆT NAM: ...",36,14)
local pingInfo=label(home,"📶 PING: ...",36,13)
local session=label(home,"Bạn đã ở trong server: 00:00:00",34)
label(home,"🌷 CÁC MỤC CHUYỂN TỪ LINH TINH 🌷",30,12)

-- Sit va spin chi tac dong len nhan vat cua chinh minh.
local sit=false
local sitBtn=button(home,"Ngồi: OFF")
sitBtn.MouseButton1Click:Connect(function()
    sit=not sit
    local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h.Sit=sit end
    sitBtn.Text=sit and "Ngồi: ON" or "Ngồi: OFF"
    sitBtn.TextColor3=sit and T.on or T.text
end)
local spinning=false; local spinConn
local spinBtn=button(home,"Xoay nhân vật: OFF")
spinBtn.MouseButton1Click:Connect(function()
    spinning=not spinning
    if spinConn then spinConn:Disconnect(); spinConn=nil end
    if spinning then
        spinConn=RunService.Heartbeat:Connect(function(dt)
            local root=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(100*dt),0) end
        end)
    end
    spinBtn.Text=spinning and "Xoay nhân vật: ON" or "Xoay nhân vật: OFF"
    spinBtn.TextColor3=spinning and T.on or T.text
end)
local ghost=button(home,"Ghost (mô phỏng): OFF")
ghost.MouseButton1Click:Connect(function()
    ghost.Text=ghost.Text:find("OFF") and "Ghost (mô phỏng): ON" or "Ghost (mô phỏng): OFF"
end)
local npc=button(home,"ESP NPC (mô phỏng): OFF")
npc.MouseButton1Click:Connect(function()
    npc.Text=npc.Text:find("OFF") and "ESP NPC (mô phỏng): ON" or "ESP NPC (mô phỏng): OFF"
end)

-- Do hoa local
label(graphics,"🎨 TÙY CHỈNH HÌNH ẢNH",28,13)
local original={Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,
    GlobalShadows=Lighting.GlobalShadows,FogEnd=Lighting.FogEnd}
local function restore()
    for k,v in pairs(original) do Lighting[k]=v end
end
local function mode(which)
    restore()
    if which=="bright" then Lighting.Brightness=3; Lighting.ClockTime=14; Lighting.GlobalShadows=false
    elseif which=="dark" then Lighting.Brightness=.6; Lighting.ClockTime=0
    elseif which=="low" then Lighting.GlobalShadows=false; Lighting.FogEnd=100000
    elseif which=="high" then Lighting.Brightness=2; Lighting.GlobalShadows=true; Lighting.FogEnd=100000 end
end
button(graphics,"☀ Làm sáng").MouseButton1Click:Connect(function() mode("bright") end)
button(graphics,"🌙 Làm tối").MouseButton1Click:Connect(function() mode("dark") end)
button(graphics,"⚡ Giảm lag").MouseButton1Click:Connect(function() mode("low") end)
button(graphics,"✨ Tăng đồ họa (đẹp)").MouseButton1Click:Connect(function() mode("high") end)
button(graphics,"↩ Khôi phục mặc định").MouseButton1Click:Connect(restore)
label(graphics,"Các nút chỉnh Lighting phía máy bạn. Roblox/Delta không cung cấp quyền đọc pin và ép toàn bộ chất lượng đồ họa trên mọi thiết bị.",55,10)

-- Cai dat UID/HUD
label(settings,"⚙ CÀI ĐẶT HIỂN THỊ",28,13)
local uid=true
local uidBtn=button(settings,"UID / Ping / Giờ: ON")
uidBtn.MouseButton1Click:Connect(function()
    uid=not uid; hud.Visible=uid
    uidBtn.Text=uid and "UID / Ping / Giờ: ON" or "UID / Ping / Giờ: OFF"
    uidBtn.TextColor3=uid and T.on or T.text
end)

-- Ghi chu: them, copy, xoa
label(notes,"📝 GHI CHÚ CỦA BẠN",28,13)
local noteList=Instance.new("Frame"); noteList.Size=UDim2.new(1,-8,0,250)
noteList.BackgroundTransparency=1; noteList.Parent=notes
local noteLayout=Instance.new("UIListLayout"); noteLayout.Padding=UDim.new(0,6); noteLayout.Parent=noteList
local add=Instance.new("TextButton"); add.Size=UDim2.fromOffset(42,42)
add.Position=UDim2.new(1,-52,1,-48); add.BackgroundColor3=T.accent
add.Text="+"; add.TextColor3=Color3.new(1,1,1); add.TextSize=24
add.Font=Enum.Font.GothamBold; add.Parent=notes; round(add,21)
local function notice(txt)
    local n=label(gui,txt,28,10); n.Size=UDim2.fromOffset(220,28)
    n.Position=UDim2.new(.5,-110,.85,0)
    task.delay(2,function() if n then n:Destroy() end end)
end
local function addNote()
    local row=Instance.new("Frame"); row.Size=UDim2.new(1,0,0,112)
    row.BackgroundColor3=T.panel; row.Parent=noteList; round(row,8); outline(row)
    local box=Instance.new("TextBox"); box.Size=UDim2.new(1,-12,0,64)
    box.Position=UDim2.fromOffset(6,5); box.BackgroundColor3=T.bg
    box.TextColor3=T.text; box.PlaceholderText="Viết ghi chú..."
    box.Text=""; box.ClearTextOnFocus=false; box.TextWrapped=true
    box.TextXAlignment=Enum.TextXAlignment.Left; box.TextYAlignment=Enum.TextYAlignment.Top
    box.Font=Enum.Font.Gotham; box.TextSize=11; box.Parent=row; round(box,6)
    local copy=button(row,"Sao chép",29); copy.Size=UDim2.new(.48,-5,0,29)
    copy.Position=UDim2.fromOffset(6,76)
    local del=button(row,"Xóa",29); del.Size=UDim2.new(.48,-5,0,29)
    del.Position=UDim2.new(.52,0,0,76); del.TextColor3=T.off
    copy.MouseButton1Click:Connect(function()
        if box.Text=="" then notice("Ghi chú đang trống"); return end
        local ok=false
        pcall(function() if setclipboard then setclipboard(box.Text); ok=true end end)
        notice(ok and "Đã sao chép" or "Executor không hỗ trợ clipboard")
    end)
    del.MouseButton1Click:Connect(function() row:Destroy() end)
end
add.MouseButton1Click:Connect(addNote)

task.spawn(function()
    while gui.Parent do
        local p=ping()
        hudText.Text=string.format("PING: %d ms (%s)  |  VN: %s",p,pingText(p),vnTime())
        server.Text="Tên server: "..tostring(game.Name).."  |  ID: "..serverId()
        local up=math.max(0,Workspace.DistributedGameTime)
        uptime.Text=string.format("Server đã chạy: %02d:%02d:%02d",math.floor(up/3600),math.floor(up%3600/60),math.floor(up%60))
        bat.Text="Pin thiết bị: "..battery()
        clock.Text="🕒 GIỜ VIỆT NAM: "..vnTime()
        pingInfo.Text=string.format("📶 PING: %d ms (%s)",p,pingText(p))
        local e=os.clock()-started
        session.Text=string.format("Bạn đã ở trong server: %02d:%02d:%02d",math.floor(e/3600),math.floor(e%3600/60),math.floor(e%60))
        task.wait(1)
    end
end)

print("ライト [ raito ] V3.5 loaded")
