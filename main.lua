
local PhysicsService = game:GetService("PhysicsService")
local Workspace = game:GetService("Workspace")

local function FindCollisionGroup(CollisionGroup)
    local CollisionGroups = string.split(gethiddenproperty(Workspace, "CollisionGroups"), "\\")

    for _, v in pairs(CollisionGroups) do
        if string.split(v, "^")[1] == CollisionGroup then
            return v
        end
    end

    return false
end

local function EditCollisionGroup(GroupName, ...)
    local args = {...}

    local CollisionGroups = string.split(gethiddenproperty(Workspace, "CollisionGroups"), "\\")

    local Group = ""
    for i, CollisionGroup in pairs(CollisionGroups) do
        local split = CollisionGroup:split("^")
        if split[1] == GroupName  then
            for i = 1, 3 do
                if not args[i] then
                    args[i] = split[i]
                end
            end

            Group = Group .. string.format("%s%s^%s^%s", ((i == 1 and "") or "\\"), args[1], args[2], args[3])
        else	
            Group = Group .. string.format("%s%s^%s^%s", ((i == 1 and "") or "\\"), split[1], split[2], split[3])
        end
    end

    sethiddenproperty(Workspace, "CollisionGroups", Group)
end

local namecall
namecall = hookmetamethod(game, "__namecall" ,newcclosure(function(self,...)
    if not checkcaller() then return namecall(self, ...) end
    local args = {...}

    if self == PhysicsService then
        if getnamecallmethod() == "RenameCollisionGroup" then
            local CollisionGroup, Name = args[1], args[2]

            assert(typeof(CollisionGroup) == "string", string.format("Bad argument #1 to '?' (string expected, got %s)", typeof(CollisionGroup)))
            assert(typeof(Name) == "string", string.format("Bad argument #2 to '?' (string expected, got %s)", typeof(Name)))
            assert(FindCollisionGroup(CollisionGroup) ~= false, "Cannot find the collision group")
            assert(FindCollisionGroup(Name) == false, "This collision group already exists!")

            string.gsub(gethiddenproperty(Workspace, "CollisionGroups"), "([%w%p]*)(" .. CollisionGroup .. "%^%d+%^%-%d+)([%w%p]*)", function(arg1, arg2, arg3)
                local Split = string.split(FindCollisionGroup(CollisionGroup), "^")

                sethiddenproperty(Workspace, "CollisionGroups", arg1 .. string.format("%s^%s^%s", Name, Split[2], Split[3]) .. arg3)
            end)

            return
        elseif getnamecallmethod() == "RemoveCollisionGroup"  then
            local CollisionGroup = args[1]

            string.gsub(gethiddenproperty(Workspace, "CollisionGroups"), "([%w%p]*)(" .. CollisionGroup .. "%^%d+%^%-%d+)([%w%p]*)", function(arg1, arg2, arg3)
                local CollisionGroups = ""
                for _, v in pairs(string.split(arg3,"\\")) do
                    CollisionGroups = CollisionGroups .. "\\" .. string.gsub(v, "(%w+%^)(%d+)(%^%-%d+)", function(arg1, arg2, arg3) 
                        return arg1 .. math.floor(tonumber(arg2) - 1) .. arg3 
                    end)
                end

                if string.sub(CollisionGroups, 1, 1) == "\\" then
                    CollisionGroups = string.sub(CollisionGroups, 2) 
                end

                CollisionGroups = arg1 .. CollisionGroups

                if string.sub(#CollisionGroups, #CollisionGroups) == "\\" then
                    CollisionGroups = string.sub(CollisionGroups, 1, #CollisionGroups - 1)
                end

                sethiddenproperty(Workspace, "CollisionGroups", CollisionGroups)
            end)

            return
        elseif getnamecallmethod() == "CreateCollisionGroup" then
            local Name = args[1]

            assert(FindCollisionGroup(Name) == false, "Could not create collision group, one with that name already exists.")
            sethiddenproperty(Workspace, "CollisionGroups", string.format("%s\\%s^%s^%s", gethiddenproperty(Workspace, "CollisionGroups"), Name, tonumber(#PhysicsService:GetCollisionGroups()), "-1"))

            return true
        elseif getnamecallmethod() == "CollisionGroupSetCollidable" then
            local Group1, Group2, Collidable = args[1], args[2], args[3]

            assert(typeof(Group1) == "string", string.format("Bad argument #1 to '?' (string expected, got %s)", typeof(Group1)))
            assert(typeof(Group2) == "string", string.format("Bad argument #2 to '?' (string expected, got %s)", typeof(Group2)))
            assert(typeof(Collidable) == "boolean", string.format("Bad argument #3 to '?' (boolean expected, got %s)", typeof(Collidable)))
            assert(FindCollisionGroup(Group1) ~= false, "Both collision groups must be valid.")
            assert(FindCollisionGroup(Group2) ~= false, "Both collision groups must be valid.")

            local CollisionGroup1 = string.split(FindCollisionGroup(Group1), "^")
            local CollisionGroup2 = string.split(FindCollisionGroup(Group2), "^")

            if Collidable == false then
                if PhysicsService:CollisionGroupsAreCollidable(Group1, Group2) == true then
                    if Group1 == Group2 then
                        EditCollisionGroup(CollisionGroup1[1], false, false, (tonumber(CollisionGroup1[3])) - (2 ^ (tonumber(CollisionGroup1[2]))))
                    elseif Group1 ~= Group2 then
                        EditCollisionGroup(CollisionGroup1[1], false, false, (tonumber(CollisionGroup1[3])) - (2 ^ (tonumber(CollisionGroup2[2]))))
                        EditCollisionGroup(CollisionGroup2[1], false, false, (tonumber(CollisionGroup2[3])) - (2 ^ (tonumber(CollisionGroup1[2]))))
                    end
                end
            elseif Collidable == true then
                if PhysicsService:CollisionGroupsAreCollidable(Group1, Group2) == false then
                    if Group1 == Group2 then
                        EditCollisionGroup(CollisionGroup1[1], false, false, (tonumber(CollisionGroup1[3])) + (2 ^ (tonumber(CollisionGroup1[2]))))
                    elseif Group1 ~= Group2 then
                        EditCollisionGroup(CollisionGroup1[1], false, false, (tonumber(CollisionGroup1[3])) + (2 ^ (tonumber(CollisionGroup2[2]))))
                        EditCollisionGroup(CollisionGroup2[1], false, false, (tonumber(CollisionGroup2[3])) + (2 ^ (tonumber(CollisionGroup1[2]))))
                    end
                end
            end

            return
        end
    end 

    return namecall(self, ...)
end))
