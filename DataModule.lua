local module = {}
module.Profiles = {}

local template = {
	Gold = 0,
	Flowers = 0
}

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local profileService = require(ServerScriptService.Libs.ProfileService)

local profileStore = profileService.GetProfileStore("PlayerData", template).Mock

local function PlayerAdded(player)
	local profile = profileStore:LoadProfileAsync("Player_" .. player.UserId)
	
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		
		profile:ListenToRelease(function()
			module.Profiles[player] = nil
			player:Kick()
		end)
		
		if player:IsDescendantOf(Players) == true then
			module.Profiles[player] = profile
		else
			profile:Release()
		end
	else
		player:Kick() 
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(PlayerAdded, player)
end

Players.PlayerAdded:Connect(PlayerAdded)

Players.PlayerRemoving:Connect(function(player)
	local profile = module.Profiles[player]
	
	if profile ~= nil then
		profile:Release()
	end
end)

return module