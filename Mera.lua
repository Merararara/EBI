local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Merara Hub",
   Icon = 0,
   LoadingTitle = "Merara Hub",
   LoadingSubtitle = "Loading...",
   Theme = "DarkBlue",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "MeraraHub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "Key System",
      Subtitle = "Key System",
      Note = "No key needed",
      FileName = "Key",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {""}
   }
})

local PlayerTab = Window:CreateTab("Player", 4483362458)
local PlayerSection = PlayerTab:CreateSection("Player Settings")

getgenv().SavedWalkSpeed = 16
getgenv().SavedJumpPower = 50

local WalkSpeedSlider = PlayerTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WalkSpeedSlider",
   Callback = function(Value)
      getgenv().SavedWalkSpeed = Value
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

local JumpPowerSlider = PlayerTab:CreateSlider({
   Name = "Jump Power",
   Range = {50, 300},
   Increment = 1,
   Suffix = "Power",
   CurrentValue = 50,
   Flag = "JumpPowerSlider",
   Callback = function(Value)
      getgenv().SavedJumpPower = Value
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
   char:WaitForChild("Humanoid")
   wait(0.1)
   char.Humanoid.WalkSpeed = getgenv().SavedWalkSpeed
   char.Humanoid.JumpPower = getgenv().SavedJumpPower
end)

local InfiniteJumpToggle = PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      getgenv().InfiniteJump = Value
      if Value then
         game:GetService("UserInputService").JumpRequest:connect(function()
            if getgenv().InfiniteJump then
               game.Players.LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
            end
         end)
      end
   end,
})

local NoClipToggle = PlayerTab:CreateToggle({
   Name = "NoClip",
   CurrentValue = false,
   Flag = "NoClip",
   Callback = function(Value)
      getgenv().NoClip = Value
      game:GetService('RunService').Stepped:connect(function()
         if getgenv().NoClip then
            for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
               if v:IsA("BasePart") then
                  v.CanCollide = false
               end
            end
         end
      end)
   end,
})

local NoClipCamToggle = PlayerTab:CreateToggle({
   Name = "NoClip Cam",
   CurrentValue = false,
   Flag = "NoClipCam",
   Callback = function(Value)
      getgenv().NoClipCam = Value
      
      local Camera = game.Workspace.CurrentCamera
      
      if Value then
         getgenv().OriginalCameraMode = Camera.CameraType
         
         for _, part in pairs(Camera:GetDescendants()) do
            if part:IsA("BasePart") then
               part.CanCollide = false
            end
         end
         
         game:GetService("RunService").RenderStepped:Connect(function()
            if getgenv().NoClipCam then
               for _, part in pairs(game.Workspace:GetDescendants()) do
                  if part:IsA("BasePart") then
                     part.LocalTransparencyModifier = 0.5
                  end
               end
            end
         end)
         
         Camera.CameraType = Enum.CameraType.Custom
      else
         if getgenv().OriginalCameraMode then
            Camera.CameraType = getgenv().OriginalCameraMode
         end
         
         for _, part in pairs(game.Workspace:GetDescendants()) do
            if part:IsA("BasePart") then
               part.LocalTransparencyModifier = 0
            end
         end
      end
   end,
})

local TpTab = Window:CreateTab("Tp", 4483362458)
local TpSection = TpTab:CreateSection("Teleport")

local function getPlayerList()
   local players = {}
   for _, player in pairs(game.Players:GetPlayers()) do
      if player ~= game.Players.LocalPlayer then
         table.insert(players, player.Name)
      end
   end
   if #players == 0 then
      table.insert(players, "None")
   end
   return players
end

local PlayerDropdown = TpTab:CreateDropdown({
   Name = "Select Player",
   Options = getPlayerList(),
   CurrentOption = getPlayerList(),
   MultipleOptions = false,
   Flag = "PlayerDropdown",
   Callback = function(Option)
      getgenv().SelectedPlayer = Option[1]
   end,
})

task.spawn(function()
   while task.wait(2) do
      if PlayerDropdown then
         local players = getPlayerList()
         pcall(function()
            PlayerDropdown:Refresh(players)
         end)
      end
   end
end)

local TpToPlayerButton = TpTab:CreateButton({
   Name = "TP to Selected Player",
   Callback = function()
      if getgenv().SelectedPlayer and getgenv().SelectedPlayer ~= "None" then
         local targetPlayer = game.Players:FindFirstChild(getgenv().SelectedPlayer)
         if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
         end
      end
   end,
})

local TpInput = TpTab:CreateInput({
   Name = "Enter Coordinates (X, Y, Z)",
   PlaceholderText = "Example: 100, 50, 200",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      getgenv().TpCoords = Text
   end,
})

local TpToCoordButton = TpTab:CreateButton({
   Name = "TP to Coordinates",
   Callback = function()
      if getgenv().TpCoords then
         local coords = string.split(getgenv().TpCoords, ",")
         if #coords == 3 then
            local x = tonumber(coords[1])
            local y = tonumber(coords[2])
            local z = tonumber(coords[3])
            if x and y and z then
               game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
            end
         end
      end
   end,
})

local EspTab = Window:CreateTab("ESP", 4483362458)
local EspSection = EspTab:CreateSection("ESP Settings")

getgenv().ESPConnections = {}

local function createESP(player)
   pcall(function()
      if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
         local oldHighlight = player.Character:FindFirstChild("ESP_Highlight")
         if oldHighlight then
            oldHighlight:Destroy()
         end
         
         local highlight = Instance.new("Highlight")
         highlight.Parent = player.Character
         highlight.FillTransparency = 0.5
         highlight.OutlineTransparency = 0
         highlight.FillColor = Color3.fromRGB(255, 0, 0)
         highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
         highlight.Name = "ESP_Highlight"
      end
   end)
end

local function removeESP(player)
   pcall(function()
      if player.Character then
         local highlight = player.Character:FindFirstChild("ESP_Highlight")
         if highlight then
            highlight:Destroy()
         end
      end
   end)
end

local function removeAllESP()
   for _, player in pairs(game.Players:GetPlayers()) do
      removeESP(player)
   end
   
   for _, connection in pairs(getgenv().ESPConnections) do
      connection:Disconnect()
   end
   getgenv().ESPConnections = {}
end

local PlayerESPToggle = EspTab:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESP",
   Callback = function(Value)
      getgenv().PlayerESP = Value
      
      if Value then
         for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
               createESP(player)
               
               local charAddedConn = player.CharacterAdded:Connect(function()
                  if getgenv().PlayerESP then
                     wait(0.5)
                     createESP(player)
                  end
               end)
               table.insert(getgenv().ESPConnections, charAddedConn)
            end
         end
         
         local playerAddedConn = game.Players.PlayerAdded:Connect(function(player)
            if getgenv().PlayerESP then
               player.CharacterAdded:Connect(function()
                  wait(0.5)
                  createESP(player)
               end)
            end
         end)
         table.insert(getgenv().ESPConnections, playerAddedConn)
      else
         removeAllESP()
      end
   end,
})

local ESPColorPicker = EspTab:CreateColorPicker({
   Name = "ESP Color",
   Color = Color3.fromRGB(255, 0, 0),
   Flag = "ESPColor",
   Callback = function(Value)
      for _, player in pairs(game.Players:GetPlayers()) do
         if player ~= game.Players.LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if highlight then
               highlight.FillColor = Value
            end
         end
      end
   end
})

local ESPTransparencySlider = EspTab:CreateSlider({
   Name = "ESP Transparency",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 0.5,
   Flag = "ESPTransparency",
   Callback = function(Value)
      for _, player in pairs(game.Players:GetPlayers()) do
         if player ~= game.Players.LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if highlight then
               highlight.FillTransparency = Value
            end
         end
      end
   end,
})

local NameESPToggle = EspTab:CreateToggle({
   Name = "Name ESP",
   CurrentValue = false,
   Flag = "NameESP",
   Callback = function(Value)
      getgenv().NameESP = Value
      
      if Value then
         for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
               local BillboardGui = Instance.new("BillboardGui")
               BillboardGui.Name = "NameESP"
               BillboardGui.Parent = player.Character.Head
               BillboardGui.Size = UDim2.new(0, 100, 0, 30)
               BillboardGui.StudsOffset = Vector3.new(0, 2, 0)
               BillboardGui.AlwaysOnTop = true
               
               local TextLabel = Instance.new("TextLabel")
               TextLabel.Parent = BillboardGui
               TextLabel.BackgroundTransparency = 1
               TextLabel.Size = UDim2.new(1, 0, 1, 0)
               TextLabel.Text = player.Name
               TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
               TextLabel.TextSize = 14
               TextLabel.Font = Enum.Font.GothamBold
               TextLabel.TextStrokeTransparency = 0.5
            end
         end
      else
         for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") then
               local nameESP = player.Character.Head:FindFirstChild("NameESP")
               if nameESP then
                  nameESP:Destroy()
               end
            end
         end
      end
   end,
})

local RTXTab = Window:CreateTab("RTX", 4483362458)
local RTXSection = RTXTab:CreateSection("Ultra Realistic Graphics")

local ShaderToggle = RTXTab:CreateToggle({
   Name = "Ultra Shader Mode",
   CurrentValue = false,
   Flag = "UltraShader",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      
      if Value then
         getgenv().OriginalLightingShader = {
            Ambient = Lighting.Ambient,
            Brightness = Lighting.Brightness,
            ColorShift_Bottom = Lighting.ColorShift_Bottom,
            ColorShift_Top = Lighting.ColorShift_Top,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ExposureCompensation = Lighting.ExposureCompensation,
            GlobalShadows = Lighting.GlobalShadows,
            ShadowSoftness = Lighting.ShadowSoftness
         }
         
         Lighting.Ambient = Color3.fromRGB(70, 70, 70)
         Lighting.Brightness = 3
         Lighting.ColorShift_Bottom = Color3.fromRGB(25, 25, 40)
         Lighting.ColorShift_Top = Color3.fromRGB(255, 200, 150)
         Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 110)
         Lighting.ExposureCompensation = 0.3
         Lighting.GlobalShadows = true
         Lighting.ShadowSoftness = 1
         
         local Bloom = Instance.new("BloomEffect")
         Bloom.Name = "Shader_Bloom"
         Bloom.Intensity = 0.6
         Bloom.Size = 32
         Bloom.Threshold = 0.7
         Bloom.Parent = Lighting
         
         local SunRays = Instance.new("SunRaysEffect")
         SunRays.Name = "Shader_SunRays"
         SunRays.Intensity = 0.25
         SunRays.Spread = 0.5
         SunRays.Parent = Lighting
         
         local ColorCorrection = Instance.new("ColorCorrectionEffect")
         ColorCorrection.Name = "Shader_ColorCorrection"
         ColorCorrection.Brightness = 0.1
         ColorCorrection.Contrast = 0.3
         ColorCorrection.Saturation = 0.4
         ColorCorrection.TintColor = Color3.fromRGB(255, 250, 240)
         ColorCorrection.Parent = Lighting
         
         local DepthOfField = Instance.new("DepthOfFieldEffect")
         DepthOfField.Name = "Shader_DepthOfField"
         DepthOfField.FarIntensity = 0.15
         DepthOfField.FocusDistance = 0.1
         DepthOfField.InFocusRadius = 30
         DepthOfField.NearIntensity = 0.75
         DepthOfField.Parent = Lighting
         
         local Atmosphere = Instance.new("Atmosphere")
         Atmosphere.Name = "Shader_Atmosphere"
         Atmosphere.Density = 0.4
         Atmosphere.Offset = 0.3
         Atmosphere.Color = Color3.fromRGB(200, 200, 210)
         Atmosphere.Decay = Color3.fromRGB(100, 105, 115)
         Atmosphere.Glare = 0.6
         Atmosphere.Haze = 0.6
         Atmosphere.Parent = Lighting
         
         local Blur = Instance.new("BlurEffect")
         Blur.Name = "Shader_Blur"
         Blur.Size = 2
         Blur.Parent = Lighting
      else
         if getgenv().OriginalLightingShader then
            Lighting.Ambient = getgenv().OriginalLightingShader.Ambient
            Lighting.Brightness = getgenv().OriginalLightingShader.Brightness
            Lighting.ColorShift_Bottom = getgenv().OriginalLightingShader.ColorShift_Bottom
            Lighting.ColorShift_Top = getgenv().OriginalLightingShader.ColorShift_Top
            Lighting.OutdoorAmbient = getgenv().OriginalLightingShader.OutdoorAmbient
            Lighting.ExposureCompensation = getgenv().OriginalLightingShader.ExposureCompensation
            Lighting.GlobalShadows = getgenv().OriginalLightingShader.GlobalShadows
            Lighting.ShadowSoftness = getgenv().OriginalLightingShader.ShadowSoftness
         end
         
         for _, effect in pairs(Lighting:GetChildren()) do
            if effect.Name:match("Shader_") then
               effect:Destroy()
            end
         end
      end
   end,
})

local RealisticShadowsToggle = RTXTab:CreateToggle({
   Name = "Ultra Realistic Shadows",
   CurrentValue = false,
   Flag = "RealisticShadows",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      
      if Value then
         Lighting.GlobalShadows = true
         Lighting.ShadowSoftness = 1
         Lighting.Technology = Enum.Technology.Future
      else
         Lighting.GlobalShadows = true
         Lighting.ShadowSoftness = 0.2
         Lighting.Technology = Enum.Technology.Compatibility
      end
   end,
})

local TimeSection = RTXTab:CreateSection("Time Presets")

local MorningButton = RTXTab:CreateButton({
   Name = "Morning Shader",
   Callback = function()
      local Lighting = game:GetService("Lighting")
      
      for _, effect in pairs(Lighting:GetChildren()) do
         if effect.Name:match("Time_") then
            effect:Destroy()
         end
      end
      
      Lighting.ClockTime = 6
      Lighting.Ambient = Color3.fromRGB(170, 170, 170)
      Lighting.OutdoorAmbient = Color3.fromRGB(200, 180, 140)
      Lighting.Brightness = 2.5
      Lighting.FogEnd = 100000
      Lighting.GlobalShadows = true
      Lighting.ShadowSoftness = 0.8
      
      local Bloom = Instance.new("BloomEffect")
      Bloom.Name = "Time_MorningBloom"
      Bloom.Intensity = 0.4
      Bloom.Size = 24
      Bloom.Threshold = 0.9
      Bloom.Parent = Lighting
      
      local SunRays = Instance.new("SunRaysEffect")
      SunRays.Name = "Time_MorningSunRays"
      SunRays.Intensity = 0.2
      SunRays.Spread = 0.3
      SunRays.Parent = Lighting
      
      local ColorCorrection = Instance.new("ColorCorrectionEffect")
      ColorCorrection.Name = "Time_MorningColor"
      ColorCorrection.Brightness = 0.1
      ColorCorrection.Contrast = 0.2
      ColorCorrection.Saturation = 0.3
      ColorCorrection.TintColor = Color3.fromRGB(255, 245, 230)
      ColorCorrection.Parent = Lighting
      
      local Atmosphere = Instance.new("Atmosphere")
      Atmosphere.Name = "Time_MorningAtmosphere"
      Atmosphere.Density = 0.3
      Atmosphere.Offset = 0.25
      Atmosphere.Color = Color3.fromRGB(220, 210, 200)
      Atmosphere.Decay = Color3.fromRGB(150, 140, 120)
      Atmosphere.Glare = 0.5
      Atmosphere.Haze = 0.3
      Atmosphere.Parent = Lighting
   end,
})

local NoonButton = RTXTab:CreateButton({
   Name = "Noon (Day) Shader",
   Callback = function()
      local Lighting = game:GetService("Lighting")
      
      for _, effect in pairs(Lighting:GetChildren()) do
         if effect.Name:match("Time_") then
            effect:Destroy()
         end
      end
      
      Lighting.ClockTime = 12
      Lighting.Ambient = Color3.fromRGB(200, 200, 200)
      Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
      Lighting.Brightness = 3
      Lighting.FogEnd = 100000
      Lighting.GlobalShadows = true
      Lighting.ShadowSoftness = 0.5
      
      local Bloom = Instance.new("BloomEffect")
      Bloom.Name = "Time_NoonBloom"
      Bloom.Intensity = 0.5
      Bloom.Size = 28
      Bloom.Threshold = 0.8
      Bloom.Parent = Lighting
      
      local SunRays = Instance.new("SunRaysEffect")
      SunRays.Name = "Time_NoonSunRays"
      SunRays.Intensity = 0.3
      SunRays.Spread = 0.4
      SunRays.Parent = Lighting
      
      local ColorCorrection = Instance.new("ColorCorrectionEffect")
      ColorCorrection.Name = "Time_NoonColor"
      ColorCorrection.Brightness = 0.15
      ColorCorrection.Contrast = 0.25
      ColorCorrection.Saturation = 0.4
      ColorCorrection.TintColor = Color3.fromRGB(255, 255, 250)
      ColorCorrection.Parent = Lighting
      
      local Atmosphere = Instance.new("Atmosphere")
      Atmosphere.Name = "Time_NoonAtmosphere"
      Atmosphere.Density = 0.25
      Atmosphere.Offset = 0.3
      Atmosphere.Color = Color3.fromRGB(230, 230, 240)
      Atmosphere.Decay = Color3.fromRGB(180, 180, 200)
      Atmosphere.Glare = 0.6
      Atmosphere.Haze = 0.2
      Atmosphere.Parent = Lighting
   end,
})

local SunsetButton = RTXTab:CreateButton({
   Name = "Sunset Shader",
   Callback = function()
      local Lighting = game:GetService("Lighting")
      
      for _, effect in pairs(Lighting:GetChildren()) do
         if effect.Name:match("Time_") then
            effect:Destroy()
         end
      end
      
      Lighting.ClockTime = 18
      Lighting.Ambient = Color3.fromRGB(150, 100, 80)
      Lighting.OutdoorAmbient = Color3.fromRGB(255, 140, 50)
      Lighting.Brightness = 1.8
      Lighting.FogEnd = 50000
      Lighting.GlobalShadows = true
      Lighting.ShadowSoftness = 0.9
      
      local Bloom = Instance.new("BloomEffect")
      Bloom.Name = "Time_SunsetBloom"
      Bloom.Intensity = 0.7
      Bloom.Size = 32
      Bloom.Threshold = 0.6
      Bloom.Parent = Lighting
      
      local SunRays = Instance.new("SunRaysEffect")
      SunRays.Name = "Time_SunsetSunRays"
      SunRays.Intensity = 0.4
      SunRays.Spread = 0.5
      SunRays.Parent = Lighting
      
      local ColorCorrection = Instance.new("ColorCorrectionEffect")
      ColorCorrection.Name = "Time_SunsetColor"
      ColorCorrection.Brightness = 0.05
      ColorCorrection.Contrast = 0.3
      ColorCorrection.Saturation = 0.6
      ColorCorrection.TintColor = Color3.fromRGB(255, 180, 120)
      ColorCorrection.Parent = Lighting
      
      local Atmosphere = Instance.new("Atmosphere")
      Atmosphere.Name = "Time_SunsetAtmosphere"
      Atmosphere.Density = 0.4
      Atmosphere.Offset = 0.25
      Atmosphere.Color = Color3.fromRGB(255, 160, 100)
      Atmosphere.Decay = Color3.fromRGB(200, 100, 60)
      Atmosphere.Glare = 0.7
      Atmosphere.Haze = 0.5
      Atmosphere.Parent = Lighting
   end,
})

local NightButton = RTXTab:CreateButton({
   Name = "Night Shader",
   Callback = function()
      local Lighting = game:GetService("Lighting")
      
      for _, effect in pairs(Lighting:GetChildren()) do
         if effect.Name:match("Time_") then
            effect:Destroy()
         end
      end
      
      Lighting.ClockTime = 0
      Lighting.Ambient = Color3.fromRGB(50, 50, 80)
      Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 60)
      Lighting.Brightness = 0.8
      Lighting.FogEnd = 30000
      Lighting.GlobalShadows = true
      Lighting.ShadowSoftness = 1
      
      local Bloom = Instance.new("BloomEffect")
      Bloom.Name = "Time_NightBloom"
      Bloom.Intensity = 0.8
      Bloom.Size = 30
      Bloom.Threshold = 0.5
      Bloom.Parent = Lighting
      
      local ColorCorrection = Instance.new("ColorCorrectionEffect")
      ColorCorrection.Name = "Time_NightColor"
      ColorCorrection.Brightness = -0.1
      ColorCorrection.Contrast = 0.4
      ColorCorrection.Saturation = 0.2
      ColorCorrection.TintColor = Color3.fromRGB(180, 180, 220)
      ColorCorrection.Parent = Lighting
      
      local Atmosphere = Instance.new("Atmosphere")
      Atmosphere.Name = "Time_NightAtmosphere"
      Atmosphere.Density = 0.5
      Atmosphere.Offset = 0.2
      Atmosphere.Color = Color3.fromRGB(80, 80, 120)
      Atmosphere.Decay = Color3.fromRGB(50, 50, 80)
      Atmosphere.Glare = 0.3
      Atmosphere.Haze = 0.6
      Atmosphere.Parent = Lighting
      
      local Blur = Instance.new("BlurEffect")
      Blur.Name = "Time_NightBlur"
      Blur.Size = 1
      Blur.Parent = Lighting
   end,
})

local FogButton = RTXTab:CreateButton({
   Name = "Foggy Shader",
   Callback = function()
      local Lighting = game:GetService("Lighting")
      
      for _, effect in pairs(Lighting:GetChildren()) do
         if effect.Name:match("Time_") then
            effect:Destroy()
         end
      end
      
      Lighting.FogEnd = 500
      Lighting.FogStart = 0
      Lighting.FogColor = Color3.fromRGB(192, 192, 192)
      Lighting.Brightness = 1.5
      Lighting.Ambient = Color3.fromRGB(150, 150, 150)
      Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
      Lighting.GlobalShadows = true
      Lighting.ShadowSoftness = 1
      
      local Bloom = Instance.new("BloomEffect")
      Bloom.Name = "Time_FogBloom"
      Bloom.Intensity = 0.3
      Bloom.Size = 20
      Bloom.Threshold = 0.9
      Bloom.Parent = Lighting
      
      local ColorCorrection = Instance.new("ColorCorrectionEffect")
      ColorCorrection.Name = "Time_FogColor"
      ColorCorrection.Brightness = 0
      ColorCorrection.Contrast = 0.1
      ColorCorrection.Saturation = -0.2
      ColorCorrection.TintColor = Color3.fromRGB(220, 220, 230)
      ColorCorrection.Parent = Lighting
      
      local Atmosphere = Instance.new("Atmosphere")
      Atmosphere.Name = "Time_FogAtmosphere"
      Atmosphere.Density = 0.8
      Atmosphere.Offset = 0.5
      Atmosphere.Color = Color3.fromRGB(200, 200, 210)
      Atmosphere.Decay = Color3.fromRGB(150, 150, 160)
      Atmosphere.Glare = 0.2
      Atmosphere.Haze = 0.9
      Atmosphere.Parent = Lighting
      
      local Blur = Instance.new("BlurEffect")
      Blur.Name = "Time_FogBlur"
      Blur.Size = 3
      Blur.Parent = Lighting
   end,
})

local StormButton = RTXTab:CreateButton({
   Name = "Storm Shader",
   Callback = function()
      local Lighting = game:GetService("Lighting")
      
      for _, effect in pairs(Lighting:GetChildren()) do
         if effect.Name:match("Time_") then
            effect:Destroy()
         end
      end
      
      Lighting.ClockTime = 14
      Lighting.Ambient = Color3.fromRGB(80, 80, 100)
      Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 120)
      Lighting.Brightness = 1
      Lighting.FogEnd = 1000
      Lighting.FogColor = Color3.fromRGB(100, 100, 120)
      Lighting.GlobalShadows = true
      Lighting.ShadowSoftness = 0.7
      
      local Bloom = Instance.new("BloomEffect")
      Bloom.Name = "Time_StormBloom"
      Bloom.Intensity = 0.6
      Bloom.Size = 25
      Bloom.Threshold = 0.7
      Bloom.Parent = Lighting
      
      local ColorCorrection = Instance.new("ColorCorrectionEffect")
      ColorCorrection.Name = "Time_StormColor"
      ColorCorrection.Brightness = -0.05
      ColorCorrection.Contrast = 0.35
      ColorCorrection.Saturation = 0.1
      ColorCorrection.TintColor = Color3.fromRGB(180, 180, 200)
      ColorCorrection.Parent = Lighting
      
      local Atmosphere = Instance.new("Atmosphere")
      Atmosphere.Name = "Time_StormAtmosphere"
      Atmosphere.Density = 0.6
      Atmosphere.Offset = 0.3
      Atmosphere.Color = Color3.fromRGB(120, 120, 140)
      Atmosphere.Decay = Color3.fromRGB(80, 80, 100)
      Atmosphere.Glare = 0.4
      Atmosphere.Haze = 0.7
      Atmosphere.Parent = Lighting
      
      local Blur = Instance.new("BlurEffect")
      Blur.Name = "Time_StormBlur"
      Blur.Size = 2
      Blur.Parent = Lighting
   end,
})

local EffectsSection = RTXTab:CreateSection("Effects")

local RTXToggle = RTXTab:CreateToggle({
   Name = "RTX Mode",
   CurrentValue = false,
   Flag = "RTX",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      
      if Value then
         getgenv().OriginalLighting = {
            Ambient = Lighting.Ambient,
            Brightness = Lighting.Brightness,
            ColorShift_Bottom = Lighting.ColorShift_Bottom,
            ColorShift_Top = Lighting.ColorShift_Top,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            ExposureCompensation = Lighting.ExposureCompensation
         }
         
         Lighting.Ambient = Color3.fromRGB(128, 128, 128)
         Lighting.Brightness = 2.5
         Lighting.ColorShift_Bottom = Color3.fromRGB(11, 0, 20)
         Lighting.ColorShift_Top = Color3.fromRGB(240, 127, 66)
         Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
         Lighting.ExposureCompensation = 0.2
         
         if not Lighting:FindFirstChild("BloomEffect") then
            local Bloom = Instance.new("BloomEffect")
            Bloom.Name = "RTX_Bloom"
            Bloom.Intensity = 0.5
            Bloom.Size = 24
            Bloom.Threshold = 0.8
            Bloom.Parent = Lighting
         end
         
         if not Lighting:FindFirstChild("SunRaysEffect") then
            local SunRays = Instance.new("SunRaysEffect")
            SunRays.Name = "RTX_SunRays"
            SunRays.Intensity = 0.15
            SunRays.Spread = 0.4
            SunRays.Parent = Lighting
         end
         
         if not Lighting:FindFirstChild("ColorCorrectionEffect") then
            local ColorCorrection = Instance.new("ColorCorrectionEffect")
            ColorCorrection.Name = "RTX_ColorCorrection"
            ColorCorrection.Brightness = 0.05
            ColorCorrection.Contrast = 0.2
            ColorCorrection.Saturation = 0.3
            ColorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
            ColorCorrection.Parent = Lighting
         end
         
         if not Lighting:FindFirstChild("DepthOfFieldEffect") then
            local DepthOfField = Instance.new("DepthOfFieldEffect")
            DepthOfField.Name = "RTX_DepthOfField"
            DepthOfField.FarIntensity = 0.1
            DepthOfField.FocusDistance = 0.05
            DepthOfField.InFocusRadius = 20
            DepthOfField.NearIntensity = 0.5
            DepthOfField.Parent = Lighting
         end
      else
         if getgenv().OriginalLighting then
            Lighting.Ambient = getgenv().OriginalLighting.Ambient
            Lighting.Brightness = getgenv().OriginalLighting.Brightness
            Lighting.ColorShift_Bottom = getgenv().OriginalLighting.ColorShift_Bottom
            Lighting.ColorShift_Top = getgenv().OriginalLighting.ColorShift_Top
            Lighting.OutdoorAmbient = getgenv().OriginalLighting.OutdoorAmbient
            Lighting.ExposureCompensation = getgenv().OriginalLighting.ExposureCompensation
         end
         
         for _, effect in pairs(Lighting:GetChildren()) do
            if effect.Name:match("RTX_") then
               effect:Destroy()
            end
         end
      end
   end,
})

local BloomToggle = RTXTab:CreateToggle({
   Name = "Bloom Effect",
   CurrentValue = false,
   Flag = "Bloom",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      
      if Value then
         local Bloom = Instance.new("BloomEffect")
         Bloom.Name = "CustomBloom"
         Bloom.Intensity = 0.4
         Bloom.Size = 24
         Bloom.Threshold = 0.8
         Bloom.Parent = Lighting
      else
         local bloom = Lighting:FindFirstChild("CustomBloom")
         if bloom then
            bloom:Destroy()
         end
      end
   end,
})

local BloomIntensitySlider = RTXTab:CreateSlider({
   Name = "Bloom Intensity",
   Range = {0, 1},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 0.4,
   Flag = "BloomIntensity",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      local bloom = Lighting:FindFirstChild("CustomBloom") or Lighting:FindFirstChild("RTX_Bloom")
      if bloom then
         bloom.Intensity = Value
      end
   end,
})

local SunRaysToggle = RTXTab:CreateToggle({
   Name = "Sun Rays",
   CurrentValue = false,
   Flag = "SunRays",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      
      if Value then
         local SunRays = Instance.new("SunRaysEffect")
         SunRays.Name = "CustomSunRays"
         SunRays.Intensity = 0.15
         SunRays.Spread = 0.4
         SunRays.Parent = Lighting
      else
         local sunRays = Lighting:FindFirstChild("CustomSunRays")
         if sunRays then
            sunRays:Destroy()
         end
      end
   end,
})

local ColorCorrectionToggle = RTXTab:CreateToggle({
   Name = "Color Correction",
   CurrentValue = false,
   Flag = "ColorCorrection",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      
      if Value then
         local ColorCorrection = Instance.new("ColorCorrectionEffect")
         ColorCorrection.Name = "CustomColorCorrection"
         ColorCorrection.Brightness = 0.05
         ColorCorrection.Contrast = 0.2
         ColorCorrection.Saturation = 0.3
         ColorCorrection.Parent = Lighting
      else
         local cc = Lighting:FindFirstChild("CustomColorCorrection")
         if cc then
            cc:Destroy()
         end
      end
   end,
})

local SaturationSlider = RTXTab:CreateSlider({
   Name = "Saturation",
   Range = {-1, 1},
   Increment = 0.1,
   Suffix = "",
   CurrentValue = 0,
   Flag = "Saturation",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      local cc = Lighting:FindFirstChild("CustomColorCorrection") or Lighting:FindFirstChild("RTX_ColorCorrection")
      if cc then
         cc.Saturation = Value
      end
   end,
})

local AtmosphereToggle = RTXTab:CreateToggle({
   Name = "Atmosphere",
   CurrentValue = false,
   Flag = "Atmosphere",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      
      if Value then
         local Atmosphere = Instance.new("Atmosphere")
         Atmosphere.Name = "CustomAtmosphere"
         Atmosphere.Density = 0.3
         Atmosphere.Offset = 0.25
         Atmosphere.Color = Color3.fromRGB(199, 199, 199)
         Atmosphere.Decay = Color3.fromRGB(106, 112, 125)
         Atmosphere.Glare = 0.4
         Atmosphere.Haze = 0.4
         Atmosphere.Parent = Lighting
      else
         local atmos = Lighting:FindFirstChild("CustomAtmosphere")
         if atmos then
            atmos:Destroy()
         end
      end
   end,
})

local NoShadowsToggle = RTXTab:CreateToggle({
   Name = "Remove Shadows",
   CurrentValue = false,
   Flag = "NoShadows",
   Callback = function(Value)
      if Value then
         getgenv().OriginalShadows = game:GetService("Lighting").GlobalShadows
         game:GetService("Lighting").GlobalShadows = false
      else
         if getgenv().OriginalShadows ~= nil then
            game:GetService("Lighting").GlobalShadows = getgenv().OriginalShadows
         end
      end
   end,
})

local PerformanceModeToggle = RTXTab:CreateToggle({
   Name = "Performance Mode",
   CurrentValue = false,
   Flag = "PerformanceMode",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      
      if Value then
         for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("Atmosphere") then
               effect.Enabled = false
            end
         end
         
         settings().Rendering.QualityLevel = "Level01"
      else
         for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") or effect:IsA("Atmosphere") then
               effect.Enabled = true
            end
         end
         
         settings().Rendering.QualityLevel = "Automatic"
      end
   end,
})

local ResetGraphicsButton = RTXTab:CreateButton({
   Name = "Reset All Graphics",
   Callback = function()
      local Lighting = game:GetService("Lighting")
      
      for _, effect in pairs(Lighting:GetChildren()) do
         if effect.Name:match("Custom") or effect.Name:match("RTX_") or effect.Name:match("Shader_") then
            effect:Destroy()
         end
      end
      
      Lighting.Ambient = Color3.fromRGB(138, 138, 138)
      Lighting.Brightness = 2
      Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
      Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
      Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
      Lighting.GlobalShadows = true
      Lighting.ShadowSoftness = 0.2
      Lighting.Technology = Enum.Technology.Compatibility
      Lighting.ClockTime = 14
      Lighting.FogEnd = 100000
      
      settings().Rendering.QualityLevel = "Automatic"
   end,
})

local ResetRTXButton = RTXTab:CreateButton({
   Name = "Quick Reset RTX",
   Callback = function()
      local Lighting = game:GetService("Lighting")
      
      for _, effect in pairs(Lighting:GetChildren()) do
         if effect.Name:match("Shader_") then
            effect:Destroy()
         end
      end
      
      if getgenv().OriginalLightingShader then
         Lighting.Ambient = getgenv().OriginalLightingShader.Ambient
         Lighting.Brightness = getgenv().OriginalLightingShader.Brightness
         Lighting.ColorShift_Bottom = getgenv().OriginalLightingShader.ColorShift_Bottom
         Lighting.ColorShift_Top = getgenv().OriginalLightingShader.ColorShift_Top
         Lighting.OutdoorAmbient = getgenv().OriginalLightingShader.OutdoorAmbient
         Lighting.ExposureCompensation = getgenv().OriginalLightingShader.ExposureCompensation
         Lighting.GlobalShadows = getgenv().OriginalLightingShader.GlobalShadows
         Lighting.ShadowSoftness = getgenv().OriginalLightingShader.ShadowSoftness
      end
   end,
})

local FETab = Window:CreateTab("FE Universal", 4483362458)
local FESection = FETab:CreateSection("FE Scripts")

local ShiftLockButton = FETab:CreateButton({
   Name = "Shift Lock",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Shift-lock-64302"))()
   end,
})

local FlyV3Button = FETab:CreateButton({
   Name = "Fly V3",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
   end,
})

local HugToolButton = FETab:CreateButton({
   Name = "Hug Tool",
   Callback = function()
      loadstring(game:HttpGet("https://raw.githubusercontent.com/ExploitFin/Animations/refs/heads/main/Front%20and%20Back%20Hug%20Tool"))()
   end,
})

local FEAnimationButton = FETab:CreateButton({
   Name = "FE Animation",
   Callback = function()
      loadstring(game:HttpGet(('https://pastebin.com/raw/1p6xnBNf'), true))()
   end,
})

local AimbotButton = FETab:CreateButton({
   Name = "Aimbot",
   Callback = function()
      loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Aimbot-Mobile-34677"))()
   end,
})

local PortalButton = FETab:CreateButton({
   Name = "Portal",
   Callback = function()
      loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/Test4/refs/heads/main/Portal'))()
   end,
})

local MiscTab = Window:CreateTab("Misc", 4483362458)
local MiscSection = MiscTab:CreateSection("Other Settings")

local ThemeDropdown = MiscTab:CreateDropdown({
   Name = "UI Theme",
   Options = {"Default", "Amber", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Oceanic"},
   CurrentOption = {"Default"},
   MultipleOptions = false,
   Flag = "ThemeDropdown",
   Callback = function(Option)
      Rayfield:SetTheme(Option[1])
   end,
})

local ColorPicker = MiscTab:CreateColorPicker({
   Name = "Accent Color",
   Color = Color3.fromRGB(255, 255, 255),
   Flag = "ColorPicker",
   Callback = function(Value)
      for _, obj in pairs(game:GetService("CoreGui"):GetDescendants()) do
         if obj:IsA("Frame") or obj:IsA("TextButton") then
            if obj.BackgroundColor3 ~= Color3.fromRGB(30, 30, 30) then
               obj.BackgroundColor3 = Value
            end
         end
      end
   end
})

local ColorSection = MiscTab:CreateSection("Quick Colors")

local PurpleButton = MiscTab:CreateButton({
   Name = "Purple Theme",
   Callback = function()
      for _, obj in pairs(game:GetService("CoreGui"):GetDescendants()) do
         if obj:IsA("Frame") or obj:IsA("TextButton") then
            if obj.Name:find("Main") or obj.Name:find("Button") then
               obj.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
            end
         end
      end
   end,
})

local WhiteButton = MiscTab:CreateButton({
   Name = "White Theme",
   Callback = function()
      for _, obj in pairs(game:GetService("CoreGui"):GetDescendants()) do
         if obj:IsA("Frame") or obj:IsA("TextButton") then
            if obj.Name:find("Main") or obj.Name:find("Button") then
               obj.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
         end
         if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            obj.TextColor3 = Color3.fromRGB(0, 0, 0)
         end
      end
   end,
})

local BlackButton = MiscTab:CreateButton({
   Name = "Black Theme",
   Callback = function()
      for _, obj in pairs(game:GetService("CoreGui"):GetDescendants()) do
         if obj:IsA("Frame") or obj:IsA("TextButton") then
            if obj.Name:find("Main") or obj.Name:find("Button") then
               obj.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            end
         end
      end
   end,
})

local GrayButton = MiscTab:CreateButton({
   Name = "Gray Theme",
   Callback = function()
      for _, obj in pairs(game:GetService("CoreGui"):GetDescendants()) do
         if obj:IsA("Frame") or obj:IsA("TextButton") then
            if obj.Name:find("Main") or obj.Name:find("Button") then
               obj.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
            end
         end
      end
   end,
})

local SkyBlueButton = MiscTab:CreateButton({
   Name = "Sky Blue Theme",
   Callback = function()
      for _, obj in pairs(game:GetService("CoreGui"):GetDescendants()) do
         if obj:IsA("Frame") or obj:IsA("TextButton") then
            if obj.Name:find("Main") or obj.Name:find("Button") then
               obj.BackgroundColor3 = Color3.fromRGB(135, 206, 235)
            end
         end
      end
   end,
})

local PinkButton = MiscTab:CreateButton({
   Name = "Pink Theme",
   Callback = function()
      for _, obj in pairs(game:GetService("CoreGui"):GetDescendants()) do
         if obj:IsA("Frame") or obj:IsA("TextButton") then
            if obj.Name:find("Main") or obj.Name:find("Button") then
               obj.BackgroundColor3 = Color3.fromRGB(255, 192, 203)
            end
         end
      end
   end,
})

local BrownButton = MiscTab:CreateButton({
   Name = "Brown Theme",
   Callback = function()
      for _, obj in pairs(game:GetService("CoreGui"):GetDescendants()) do
         if obj:IsA("Frame") or obj:IsA("TextButton") then
            if obj.Name:find("Main") or obj.Name:find("Button") then
               obj.BackgroundColor3 = Color3.fromRGB(139, 69, 19)
            end
         end
      end
   end,
})

local FPSCounter = MiscTab:CreateLabel("FPS: 0")

task.spawn(function()
   local lastTime = tick()
   local frameCount = 0
   
   game:GetService("RunService").RenderStepped:Connect(function()
      frameCount = frameCount + 1
      local currentTime = tick()
      
      if currentTime - lastTime >= 1 then
         local fps = math.floor(frameCount / (currentTime - lastTime))
         FPSCounter:Set("FPS: " .. fps)
         frameCount = 0
         lastTime = currentTime
      end
   end)
end)

local PingLabel = MiscTab:CreateLabel("Ping: 0ms")

task.spawn(function()
   while wait(2) do
      local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString()
      PingLabel:Set("Ping: " .. ping)
   end
end)

local FullbrightToggle = MiscTab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "Fullbright",
   Callback = function(Value)
      local Lighting = game:GetService("Lighting")
      
      if Value then
         getgenv().OldAmbient = Lighting.Ambient
         getgenv().OldBrightness = Lighting.Brightness
         getgenv().OldOutdoorAmbient = Lighting.OutdoorAmbient
         
         Lighting.Ambient = Color3.fromRGB(255, 255, 255)
         Lighting.Brightness = 2
         Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
      else
         if getgenv().OldAmbient then
            Lighting.Ambient = getgenv().OldAmbient
            Lighting.Brightness = getgenv().OldBrightness
            Lighting.OutdoorAmbient = getgenv().OldOutdoorAmbient
         end
      end
   end,
})

local AntiAFKToggle = MiscTab:CreateToggle({
   Name = "Anti AFK",
   CurrentValue = false,
   Flag = "AntiAFK",
   Callback = function(Value)
      getgenv().AntiAFK = Value
      
      if Value then
         local VirtualUser = game:GetService("VirtualUser")
         game:GetService("Players").LocalPlayer.Idled:connect(function()
            if getgenv().AntiAFK then
               VirtualUser:CaptureController()
               VirtualUser:ClickButton2(Vector2.new())
            end
         end)
      end
   end,
})

local AntiFlingToggle = MiscTab:CreateToggle({
   Name = "Anti Fling",
   CurrentValue = false,
   Flag = "AntiFling",
   Callback = function(Value)
      getgenv().AntiFling = Value
      
      local Player = game.Players.LocalPlayer
      local Character = Player.Character or Player.CharacterAdded:Wait()
      local RootPart = Character:WaitForChild("HumanoidRootPart")
      
      if Value then
         getgenv().AntiFlingConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if getgenv().AntiFling and Character and RootPart then
               for _, v in pairs(Character:GetDescendants()) do
                  if v:IsA("BasePart") then
                     v.Velocity = Vector3.new(0, 0, 0)
                     v.RotVelocity = Vector3.new(0, 0, 0)
                  end
               end
            end
         end)
      else
         if getgenv().AntiFlingConnection then
            getgenv().AntiFlingConnection:Disconnect()
         end
      end
   end,
})

local FOVSlider = MiscTab:CreateSlider({
   Name = "Field of View",
   Range = {70, 120},
   Increment = 1,
   Suffix = "°",
   CurrentValue = 70,
   Flag = "FOVSlider",
   Callback = function(Value)
      game.Workspace.CurrentCamera.FieldOfView = Value
   end,
})

local ServerSection = MiscTab:CreateSection("Server Settings")

local RejoinButton = MiscTab:CreateButton({
   Name = "Rejoin",
   Callback = function()
      wait(1)
      game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
   end,
})

local ServerHopButton = MiscTab:CreateButton({
   Name = "Server Hop",
   Callback = function()
      local TeleportService = game:GetService("TeleportService")
      local Players = game:GetService("Players")
      local LocalPlayer = Players.LocalPlayer
      
      local servers = {}
      local req = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
      local body = game:GetService("HttpService"):JSONDecode(req)
      
      if body and body.data then
         for i, v in pairs(body.data) do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.id ~= game.JobId then
               if tonumber(v.playing) < tonumber(v.maxPlayers) then
                  table.insert(servers, v.id)
               end
            end
         end
      end
      
      if #servers > 0 then
         local randomServer = servers[math.random(1, #servers)]
         TeleportService:TeleportToPlaceInstance(game.PlaceId, randomServer, LocalPlayer)
      end
   end,
})

local LowServerButton = MiscTab:CreateButton({
   Name = "Low Player Server",
   Callback = function()
      local TeleportService = game:GetService("TeleportService")
      local Players = game:GetService("Players")
      local LocalPlayer = Players.LocalPlayer
      
      local servers = {}
      local req = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
      local body = game:GetService("HttpService"):JSONDecode(req)
      
      if body and body.data then
         for i, v in pairs(body.data) do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.id ~= game.JobId then
               table.insert(servers, {id = v.id, playing = tonumber(v.playing)})
            end
         end
         
         table.sort(servers, function(a, b)
            return a.playing < b.playing
         end)
         
         if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, LocalPlayer)
         end
      end
   end,
})

local ResetButton = MiscTab:CreateButton({
   Name = "Reset Settings",
   Callback = function()
      game.Players.LocalPlayer.Character.Humanoid.Health = 0
   end,
})

local DestroyUIButton = MiscTab:CreateButton({
   Name = "Close UI",
   Callback = function()
      Rayfield:Destroy()
   end,
})

Rayfield:LoadConfiguration()
