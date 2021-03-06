# PhysicsService
Physics Service for the Client

```lua
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local HttpService = game:GetService("HttpService")

local Group = "Players-" .. HttpService:GenerateGUID(false)

PhysicsService:CreateCollisionGroup(Group)
PhysicsService:CollisionGroupSetCollidable(Group, Group, false)

local function NoclipPlayer(Player)
    local Character = Player.Character

    if Character then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(v, Group)
            end
        end
    end

    Player.CharacterAdded:Connect(function(Character)
        Character:WaitForChild("HumanoidRootPart")
        Character:WaitForChild("Head")
        Character:WaitForChild("Humanoid")

        wait(0.1)

        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(v, Group)
            end
        end
    end)
end

for _, Player in pairs(Players:GetPlayers()) do
    NoclipPlayer(Player)
end

Players.PlayerAdded:Connect(NoclipPlayer)
```
