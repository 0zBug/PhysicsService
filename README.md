# PhysicsService
Physics Service for the Client

```lua
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")

local Group = "Players-" .. game:GetService("HttpService"):GenerateGUID(false)

PhysicsService:CreateCollisionGroup(Group)
PhysicsService:CollisionGroupSetCollidable(Group, Group, false)

local function UnCollidePlayer(Player)
    local Character = Player.Character

    if Character then
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(v, Group)
            end
        end
    end

    Player.CharacterAdded:Connect(function(Character)
        Character:WaitForChild("Humanoid")

        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(v, Group)
            end
        end
    end)
end

for _, Player in pairs(Players:GetPlayers()) do
    UnCollidePlayer(Player)
end

Players.PlayerAdded:Connect(UnCollidePlayer)
```
