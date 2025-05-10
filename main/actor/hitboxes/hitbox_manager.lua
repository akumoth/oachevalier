local class = require('main.utils.class')

local hitboxman = class.new_class({})

-- Hitboxes are created via factories.
-- When they're created, the current hitbox ID is stored inside the current_hitboxes table to be cleared once the hitbox changes.
-- We also have a last_hitbox table, which will be checked to avoid creating the same hitboxes twice.
function hitboxman.new(_data)
	assert(_data)
	assert(_data.hitboxes)
	assert(_data.movement)
	local data = {
		hitboxes = _data.hitboxes,
		movement = _data.movement,
		ignore_hitcollision = false,
		ignore_update = false,
		last_hitbox = {
			anim = nil,
			frame = nil,
		},
		state = -1,
		
		can_extend = false,
		-- URL of the game objects that have the hitboxes we are being attacked with are placed here.
		-- This prevents the actor from being hit by the same hitbox twice.
		--
		-- When they spawn a hitbox, a message is sent that removes the given URL from the list,
		-- so that this actor may be hit again. 
		ignore_senders = {},

		base_land_lag = _data.land_lag or 5,
		cur_land_lag = _data.land_lag or 5,
		cancel_land = false,
		
		current_hitboxes = {}
	}
	local self = setmetatable(data, hitboxman)
	self._index = self

	return self
end

-- Resets the currently spawned hitboxes.
function hitboxman:reset()
	go.delete(self.current_hitboxes)
	self.current_hitboxes = {}
end

-- Update hitboxes based on the current animation + currently playing frame
function hitboxman:update()
	if self.ignore_update then return end
	
	local current_anim = go.get("spr#spr", "animation")
	local cursor = go.get("spr#spr", "cursor")
	local frame_count = go.get("spr#spr", "frame_count")
	-- Calculating the current frame is a bit of an odd process.
	-- Cursor is a normalized vector from the start to the end of the animation,
	-- so it starts at 0 and ends at 1.
	-- It needs to be multiplied by the (frame count - 1), then rounded
	-- to avoid errors with decimals
	local current_frame = math.floor((cursor*(frame_count-1))+1.5)

	local flip = self.movement.facing_dir.x < 0

	-- Immediately nope out if we already have spawned the needed hitboxes.
	if current_anim == self.last_hitbox.anim and current_frame == self.last_hitbox.frame then return end	

	if self.hitboxes[current_anim] ~= {} and self.hitboxes[current_anim][current_frame] ~= nil then 

		if self.hitboxes[current_anim][current_frame]['hitbox_data'] ~= nil then
			self:reset() -- Remove previous hitboxes
			for _, properties in ipairs(self.hitboxes[current_anim][current_frame]['hitbox_data']) do
				properties.parent = msg.url() -- Make sure the hitboxes are parented to this object, not the factory
				properties.flip = flip -- Reverse x offset if the actor is facing left
				local id = factory.create("#hitbox_factory", nil, nil, properties)
				table.insert(self.current_hitboxes, id) -- Populate current_hitbox table
			end
		end
	
		self.state = self.hitboxes[current_anim][current_frame]['state'] or self.state or -1

		self.can_extend = self.hitboxes[current_anim][current_frame]['can_extend'] or nil
		
		if self.hitboxes[current_anim][current_frame]['cancel_land'] ~= nil then
			self.cancel_land = self.hitboxes[current_anim][current_frame]['cancel_land']
		end
			
		self.cur_land_lag = self.hitboxes[current_anim]['land_lag'] or self.base_land_lag
		
		-- save the last created hitbox so we don't create them again
		self.last_hitbox.anim = current_anim
		self.last_hitbox.frame = current_frame

		
	end
end

function hitboxman:flip()
	if self.current_hitboxes ~= {} then
		for _, hitbox in ipairs(self.current_hitboxes) do
			local url = msg.url(nil, hitbox, nil)
			msg.post(url, "flip", {flip = self.movement.facing_dir.x < 0})
		end
	end
end

return hitboxman