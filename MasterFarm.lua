local player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

getgenv().MasterScriptID = tick()
local myScriptID = getgenv().MasterScriptID

local function getUIFolder()
    if gethui then
        return gethui()
    else
        return game:GetService("CoreGui")
    end
end

for _, gui in pairs(player.PlayerGui:GetChildren()) do
    if string.match(gui.Name, "FarmUI") or string.match(gui.Name, "MasterFarmUI") then
        gui:Destroy()
    end
end

-- ==============================================================
-- PLATOBOOST & CRYPTO LIBRARY (PROMETHEUS OBFUSCATOR SAFE)
-- ==============================================================
local max_a = 4294967296
local max_b = max_a - 1

local function func_c(d, e)
    local f = 0
    local g = 1
    while d ~= 0 or e ~= 0 do 
        local h = d % 2
        local i = e % 2
        local j = (h + i) % 2
        f = f + j * g
        d = math.floor(d / 2)
        e = math.floor(e / 2)
        g = g * 2 
    end
    return f % max_a 
end

local function func_k(d, e, l, ...)
    local m
    if e then 
        d = d % max_a
        e = e % max_a
        m = func_c(d, e)
        if l then 
            m = func_k(m, l, ...) 
        end
        return m 
    elseif d then 
        return d % max_a 
    else 
        return 0 
    end 
end

local function func_n(d, e, l, ...)
    local m
    if e then 
        d = d % max_a
        e = e % max_a
        m = (d + e - func_c(d, e)) / 2
        if l then 
            m = func_n(m, l, ...) 
        end
        return m 
    elseif d then 
        return d % max_a 
    else 
        return max_b 
    end 
end

local function func_o(p) 
    return max_b - p 
end

local function lshift(d, r)
    if r < 0 then 
        local pos_r = -r
        if pos_r > 31 then return 0 end
        return math.floor((d % max_a) % (2^32) / (2^pos_r))
    end
    return (d * (2^r)) % (2^32) 
end

local function func_q(d, r)
    if r < 0 then 
        return lshift(d, -r) 
    end
    return math.floor(d % (2^32) / (2^r))
end

local function func_s(p, r)
    if r > 31 or r < -31 then 
        return 0 
    end
    return func_q(p % max_a, r)
end

local function func_t(p, r)
    p = p % max_a
    r = r % 32
    local u = func_n(p, (2^r) - 1)
    return func_s(p, r) + lshift(u, 32 - r)
end

local hash_table = {
    0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
    0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
    0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
    0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
    0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
    0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
    0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
    0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
}

local function str_to_hex(x)
    return string.gsub(x, ".", function(l_val) 
        return string.format("%02x", string.byte(l_val)) 
    end)
end

local function func_y(z, A)
    local x = ""
    for idx = 1, A do 
        local C = z % 256
        x = string.char(C) .. x
        z = (z - C) / 256 
    end
    return x 
end

local function func_D(x, B)
    local A = 0
    for B_idx = B, B + 3 do 
        A = A * 256 + string.byte(x, B_idx) 
    end
    return A 
end

local function func_E(F, G)
    local H = 64 - (G + 9) % 64
    G = func_y(8 * G, 8)
    F = F .. "\128" .. string.rep("\0", H) .. G
    return F 
end

local function func_I(J)
    J[1] = 0x6a09e667
    J[2] = 0xbb67ae85
    J[3] = 0x3c6ef372
    J[4] = 0xa54ff53a
    J[5] = 0x510e527f
    J[6] = 0x9b05688c
    J[7] = 0x1f83d9ab
    J[8] = 0x5be0cd19
    return J 
end

local function func_K(F, B_val, J)
    local L = {}
    for M = 1, 16 do 
        L[M] = func_D(F, B_val + (M - 1) * 4) 
    end
    for M = 17, 64 do 
        local N = L[M - 15]
        local O = func_k(func_t(N, 7), func_t(N, 18), func_s(N, 3))
        N = L[M - 2]
        L[M] = (L[M - 16] + O + L[M - 7] + func_k(func_t(N, 17), func_t(N, 19), func_s(N, 10))) % max_a 
    end
    
    local d = J[1]
    local e = J[2]
    local l = J[3]
    local P = J[4]
    local Q = J[5]
    local R = J[6]
    local S_val = J[7]
    local T = J[8]
    
    for idx = 1, 64 do 
        local O = func_k(func_t(d, 2), func_t(d, 13), func_t(d, 22))
        local U = func_k(func_n(d, e), func_n(d, l), func_n(e, l))
        local V = (O + U) % max_a
        local W = func_k(func_t(Q, 6), func_t(Q, 11), func_t(Q, 25))
        local X = func_k(func_n(Q, R), func_n(func_o(Q), S_val))
        local Y = (T + W + X + hash_table[idx] + L[idx]) % max_a
        
        T = S_val
        S_val = R
        R = Q
        Q = (P + Y) % max_a
        P = l
        l = e
        e = d
        d = (Y + V) % max_a 
    end
    
    J[1] = (J[1] + d) % max_a
    J[2] = (J[2] + e) % max_a
    J[3] = (J[3] + l) % max_a
    J[4] = (J[4] + P) % max_a
    J[5] = (J[5] + Q) % max_a
    J[6] = (J[6] + R) % max_a
    J[7] = (J[7] + S_val) % max_a
    J[8] = (J[8] + T) % max_a
end

local function lDigest(F)
    F = func_E(F, #F)
    local J = func_I({})
    for idx = 1, #F, 64 do 
        func_K(F, idx, J) 
    end
    return str_to_hex(func_y(J[1], 4) .. func_y(J[2], 4) .. func_y(J[3], 4) .. func_y(J[4], 4) .. func_y(J[5], 4) .. func_y(J[6], 4) .. func_y(J[7], 4) .. func_y(J[8], 4))
end

local function lEncode(tbl) 
    return HttpService:JSONEncode(tbl) 
end

local function lDecode(str) 
    return HttpService:JSONDecode(str) 
end

local service = 29478
local secret = "8078c961-f3e4-426f-be85-90480673ff94"
local useNonce = true

local onMessage = function(message) 
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Platoboost",
            Text = message,
            Duration = 5
        })
    end)
end

repeat task.wait(1) until game:IsLoaded()

local requestSending = false
local cachedLink = ""
local cachedTime = 0

local fSetClipboard
if setclipboard then fSetClipboard = setclipboard else fSetClipboard = toclipboard end

local fRequest
if request then fRequest = request elseif http_request then fRequest = http_request elseif syn_request then fRequest = syn_request end

local fStringChar = string.char
local fToString = tostring
local fStringSub = string.sub
local fOsTime = os.time
local fMathRandom = math.random
local fMathFloor = math.floor

local fGetHwid
pcall(function() fGetHwid = gethwid end)
if not fGetHwid then 
    fGetHwid = function() return game:GetService("Players").LocalPlayer.UserId end 
end

local host = "https://api.platoboost.com"
local hostResponse = fRequest({ Url = host .. "/public/connectivity", Method = "GET" })
if hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429 then
    host = "https://api.platoboost.net"
end

local function cacheLink()
    if cachedTime + (10 * 60) < fOsTime() then
        local response = fRequest({
            Url = host .. "/public/start",
            Method = "POST",
            Body = lEncode({ service = service, identifier = lDigest(fToString(fGetHwid())) }),
            Headers = { ["Content-Type"] = "application/json" }
        })
        if response.StatusCode == 200 then
            local decoded = lDecode(response.Body)
            if decoded.success == true then
                cachedLink = decoded.data.url
                cachedTime = fOsTime()
                return true, cachedLink
            else
                onMessage(decoded.message)
                return false, decoded.message
            end
        elseif response.StatusCode == 429 then
            local msg = "you are being rate limited, please wait 20 seconds and try again."
            onMessage(msg) 
            return false, msg
        end
        local msg = "Failed to cache link."
        onMessage(msg) 
        return false, msg
    else 
        return true, cachedLink 
    end
end

cacheLink()

local function generateNonce()
    local str = ""
    for _ = 1, 16 do 
        str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97) 
    end
    return str
end

for _ = 1, 5 do
    local oNonce = generateNonce()
    task.wait(0.2)
    if generateNonce() == oNonce then
        local msg = "platoboost nonce error."
        onMessage(msg)
        error(msg)
    end
end

local function copyLink()
    local success, link = cacheLink()
    if success then 
        fSetClipboard(link) 
    end
end

local function redeemKey(key)
    local nonce = generateNonce()
    local endpoint = host .. "/public/redeem/" .. fToString(service)
    local body = { identifier = lDigest(fToString(fGetHwid())), key = key }
    if useNonce then 
        body.nonce = nonce 
    end
    
    local response = fRequest({ 
        Url = endpoint, 
        Method = "POST", 
        Body = lEncode(body), 
        Headers = { ["Content-Type"] = "application/json" } 
    })

    if response.StatusCode == 200 then
        local decoded = lDecode(response.Body)
        if decoded.success == true then
            if decoded.data.valid == true then
                if useNonce then
                    if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then 
                        return true
                    else 
                        onMessage("failed to verify integrity.")
                        return false 
                    end  
                else 
                    return true 
                end
            else 
                onMessage("key is invalid.")
                return false 
            end
        else
            if fStringSub(decoded.message, 1, 27) == "unique constraint violation" then
                onMessage("you already have an active key, please wait for it to expire before redeeming it.")
                return false
            else 
                onMessage(decoded.message)
                return false 
            end
Scripti toparlayıp topluluğun kullanımına sunmak çok iyi bir fikir; obfuscate etmeden önce son rötuşları yapıp tam sürüm haline getirelim!

Fakat şu an yeni bir sohbette olduğumuz için üzerinde çalıştığımız o son koda erişimim yok. Gerekli eklemeleri yapabilmem için o script'i buraya tekrar yapıştırabilir misin? 

Bir de eklenecekler listesini tam netleştirmek adına; Plato arayüzünü (UI) entegre edip menüleri kurduktan sonra, "her şey" diyerek bahsettiğin ve içine eklememi istediğin ekstra Luau fonksiyonları (oto-farm, anti-AFK, teleport vb.) tam olarak neler?
