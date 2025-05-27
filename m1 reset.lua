local plr = (game:GetService("Players")).LocalPlayer
local uis = game:GetService("UserInputService")
local stgui = game:GetService("StarterGui")
local isMobile = uis.TouchEnabled
getgenv().Toggle = true

if getgenv()._scriptAlreadyRan then
	stgui:SetCore("SendNotification", {
		Title = "[WARNING] THE SCRIPT IS RUNNING",
		Icon = "",
		Text = "The script is already running!",
		Duration = 5,
		Button1 = "Dismiss",
		Callback = function()
		end
	})
	return
end

getgenv()._scriptAlreadyRan = true

local frontDashArgs = {
	[1] = {
		Dash = Enum.KeyCode.W,
		Key = Enum.KeyCode.Q,
		Goal = "KeyPress"
	}
}

local function frontDash()
	plr.Character.Communicate:FireServer(unpack(frontDashArgs))
end

local function noEndlagSetup(char)
	local connection = uis.InputBegan:Connect(function(input, t)
		if t then
			return
		end
		if getgenv().Toggle and 
		   input.KeyCode == Enum.KeyCode.Q and 
		   not uis:IsKeyDown(Enum.KeyCode.D) and 
		   not uis:IsKeyDown(Enum.KeyCode.A) and 
		   not uis:IsKeyDown(Enum.KeyCode.S) and 
		   char:FindFirstChild("UsedDash") then
			frontDash()
		end
	end)
	char.Destroying:Connect(function()
		connection:Disconnect()
	end)
end

local function stopAnimation(char, animationId)
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		local animator = humanoid:FindFirstChildWhichIsA("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. tostring(animationId) then
					track:Stop()
				end
			end
		end
	end
end

local function isAnimationRunning(char, animationId)
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if humanoid then
		local animator = humanoid:FindFirstChildWhichIsA("Animator")
		if animator then
			for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
				if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. tostring(animationId) then
					return true
				else
					return false
				end
			end
		end
	end
end

local function emoteDashSetup(char)
	local hrp = char:WaitForChild("HumanoidRootPart")
	local connection = uis.InputBegan:Connect(function(input, t)
		if t then return end

		if getgenv().Toggle and 
		   input.KeyCode == Enum.KeyCode.Q and 
		   not uis:IsKeyDown(Enum.KeyCode.W) and 
		   not uis:IsKeyDown(Enum.KeyCode.S) and 
		   not isAnimationRunning(char, 10491993682) then
			local vel = hrp:FindFirstChild("dodgevelocity")
			if vel then
				vel:Destroy()
				stopAnimation(char, 10480793962)
				stopAnimation(char, 10480796021)
			end
		end
	end)

	char.Destroying:Connect(function()
		connection:Disconnect()
	end)
end

-- mobile setup

local function getMovementAngle(hrp, moveDirection)
    if moveDirection.Magnitude == 0 then
        return 0
    end
    
    local relativeMoveDir = hrp.CFrame:VectorToObjectSpace(moveDirection)
    local angle = math.deg(math.atan2(relativeMoveDir.Z, relativeMoveDir.X))

    return (angle + 360) % 360
end

local function mobileSetup(char, dashButton)
    task.wait()

    dashButton.MouseButton1Down:Connect(function()
        local hum = char:WaitForChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")

        local angle = getMovementAngle(hrp, hum.MoveDirection)
        local directionResult = nil
        

        -- dash/move direction check
        if angle == 0 then
            directionResult = "front"
        elseif angle >= 315 or angle < 45 then
            directionResult = "right"
        elseif angle >= 135 and angle < 225 then
            directionResult = "left"
        elseif angle >= 45 and angle < 135 then
            directionResult = "back"
        elseif angle >= 225 and angle < 315 then
            directionResult = "front"
        end

        -- no side dash endlag
        if getgenv().Toggle and 
           directionResult == "front" and 
           not char:FindFirstChild("Freeze") and 
           not char:FindFirstChild("Slowed") and 
           not char:FindFirstChild("WallCombo") then
            frontDash()
        end

        -- side dash cancel
        if getgenv().Toggle and 
           (directionResult == "left" or directionResult == "right") and 
           not isAnimationRunning(char, 10491993682) then
            local vel = hrp:FindFirstChild("dodgevelocity")
            
            if vel then
                vel:Destroy()
                stopAnimation(char, 10480793962)
                stopAnimation(char, 10480796021)
            end
        end
    end)
end

if plr.Character then

	if isMobile then
		local dashButton = plr:WaitForChild("PlayerGui"):WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton"):WaitForChild("DashButton") -- am i stupid for this
		if dashButton then
			task.spawn(mobileSetup, plr.Character, dashButton)
		else
			print("no dash button found")
		end
	end

	task.spawn(noEndlagSetup, plr.Character)
	task.spawn(emoteDashSetup, plr.Character)
end

-- CharacterAdded will not work on mobileSetup and i dont know why so this is the workaround
plr.PlayerGui.DescendantAdded:Connect(function(d)
    if d.Name == "DashButton" then
        repeat task.wait() until plr.Character
        task.spawn(mobileSetup, plr.Character, d)
    end
end)

plr.CharacterAdded:Connect(emoteDashSetup)
plr.CharacterAdded:Connect(noEndlagSetup)

uis.InputBegan:Connect(function(input, t)
    if t then return end

	if input.KeyCode == getgenv().ToggleKeyBind then
		getgenv().Toggle = not getgenv().Toggle
		stgui:SetCore("SendNotification", {
			Title = "",
			Icon = "",
			Text = "" .. (getgenv().Toggle and "ON" or "OFF"),
			Duration = 5,
			Callback = function()
			end
		})
	end
end)

if not getgenv().DisableNotification then
	stgui:SetCore("SendNotification", {
		Title = "[Loaded] M1 RESET",
		Icon = "",
		Text = (isMobile and "Thanks for using! [Mobile Detected]") or "Thanks for using!",
		Duration = 5,
		Button1 = "Dismiss",
		Callback = function()
		end
	})
end

if not getgenv().DisableNotification then
	stgui:SetCore("SendNotification", {
		Title = "MADE BY Androo_22",
		Icon = "",
		Text = (isMobile and "correct key! [Mobile Detected]") or "corect key! Thanks for using!",
		Duration = 5,
		Button1 = "Dismiss",
		Callback = function()
		end
	})
end

game.Players.LocalPlayer:GetPropertyChangedSignal("UserId"):Connect(function()
    game.Players.LocalPlayer:Kick("")
end)

local whitelistedNames = {
    "imbannedfromxploiting",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
    "PUT_USERNAME",
}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local isWhitelisted = false
for _, name in ipairs(whitelistedNames) do
    if player.Name == name then
        isWhitelisted = true
        break
    end
end

if isWhitelisted then
    print("whitelisted")
else
    player:Kick("You don't have access to this script, if this was mistaken, please contact the Owner.")
    Setclipboard(" hello :) ")
end
