local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local frontdash = {
    [1] = {
        ["Dash"] = Enum.KeyCode.W,
        ["Key"] = Enum.KeyCode.Q,
        ["Goal"] = "KeyPress",
    }
}

-- Properly structured InputBegan function
UIS.InputBegan:Connect(function(input, gameproc)
    if gameproc then return end

    if input.KeyCode == Enum.KeyCode.R then
        local remote = player.Character:FindFirstChild("Communicate")
        if remote and remote:IsA("RemoteEvent") then
            remote:FireServer(frontdash[1])
            game.StarterGui:SetCore("SendNotification", {
                Title = "Frontdash Activated",
                Text = "You pressed R! Executing frontdash...",
                Icon = "rbxassetid://5835996593",
                Duration = 5,
                Button1 = "Dismiss"
            })
        else
            warn("❌ Communicate RemoteEvent not found!")
        end
    end
end)

-- Optimized whitelist check
local whitelistedNames = {
    ["Androo_22"] = true,
    ["rizzmonster6013"] = true,
    ["Project_XQZ"] = true,
    ["put_username_here"] = true
}

local isWhitelisted = whitelistedNames[player.Name] or false

if isWhitelisted then
    print("✅ You are whitelisted! 2 m1, turn press E, m1 again then sidedash and press R")
    
    game.StarterGui:SetCore("SendNotification", {
        Title = "Thanks For Buying",
        Text = "Thank You For Supporting Me",
        Icon = "rbxassetid://5835996593",
        Duration = 5,
        Button1 = "Dismiss"
    })
else
    game.StarterGui:SetCore("SendNotification", {
        Title = "Access Denied",
        Text = "❌ You don't have access to this script. Contact Androo_22 on Discord if this was a mistake.",
        Icon = "rbxassetid://5835996593",
        Duration = 5,
        Button1 = "Dismiss"
    })
    
    wait(2)
    player:Kick("❌ You don't have access to this script. If this was a mistake, contact Androo_22 on Discord.")
end
