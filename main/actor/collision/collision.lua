local class = require('main.utils.class')

local collision = class.new_class({})

local RAY_CAST_LEFT_ID = 1
local RAY_CAST_RIGHT_ID = 2
local RAY_CAST_UP_ID = 3
local RAY_CAST_UP_LEFT_ID = 4
local RAY_CAST_UP_RIGHT_ID = 5
local RAY_CAST_DOWN_ID = 6
local RAY_CAST_DOWN_LEFT_ID = 7
local RAY_CAST_DOWN_RIGHT_ID = 8

function collision.new(bounding_box)
	-- pass Defold-defined bounding box as argument
	local data = {}

	local bounds = {
		bottom = vmath.vector3(0, -bounding_box.dimensions.y/2, 0),
		top = vmath.vector3(0, bounding_box.dimensions.y/2, 0),
		left = vmath.vector3((-bounding_box.dimensions.x/2), 0, 0),
		right = vmath.vector3((bounding_box.dimensions.x/2), 0, 0),
	}

	local raycast_left = bounds.left + vmath.vector3(-1, 0, 0)
	local raycast_right = bounds.right + vmath.vector3(1, 0, 0)
	local raycast_up = bounds.top + vmath.vector3(0, 1, 0)
	local raycast_down = bounds.bottom + vmath.vector3(0, -1, 0)
	local raycast_down_left = raycast_down + raycast_left
	local raycast_up_left = raycast_up + raycast_left
	local raycast_down_right = raycast_down + raycast_right
	local raycast_up_right = raycast_up + raycast_right

	data.bounds = {unpack(bounds)}
	data.rays = {
		raycast_left,
		raycast_right,
		raycast_up,
		raycast_up_left,
		raycast_up_right,
		raycast_down,
		raycast_down_left,
		raycast_down_right,
	}

	data.position = vmath.vector3()
	data.world_position = vmath.vector3()

	data.fall_buffer = 3
	data.falling_dur = 0
	data.contact = {
		l = false,
		r = false,
		u = false,
		d = false
	}
	
	data.do_snap = false
	data.snap_length = vmath.vector3(0,-15,0)
	
	data.slope_left = nil
	data.slope_right = nil
	data.slope_upleft = nil
	data.slope_upright = nil
	
	local self = setmetatable(data, collision)
	self._index = self
	return self
end

function collision:handle_collisions(origin, movement)
	local offset = vmath.vector3()
	local previous_ground_contact = self.contact.d
	self.contact.u = false
	self.contact.d = false
	self.contact.l = false
	self.contact.r = false
	
	for id, ray in ipairs(self.rays) do
		
		local result = physics.raycast(origin + offset, origin + offset + ray, {hash("world")})
		if result then
			
			local separation = ray * (1 - result.fraction)
			--	Set slope data on collision object (to process when changing velocity and so on)
			self.slope_left = id == RAY_CAST_DOWN_LEFT_ID and result.normal.x ~= 0 and result.normal.y ~= 0 and result.normal
			self.slope_right = id == RAY_CAST_DOWN_RIGHT_ID and result.normal.x ~= 0 and result.normal.y ~= 0 and result.normal
			-- slope for up left and up right corners of the raycasts
			self.slope_upleft = id == RAY_CAST_UP_LEFT_ID and result.normal.x ~= 0 and result.normal.y ~= 0 and result.normal
			self.slope_upright = id == RAY_CAST_UP_RIGHT_ID and result.normal.x ~= 0 and result.normal.y ~= 0 and result.normal
			

			if id == RAY_CAST_DOWN_ID or id == RAY_CAST_DOWN_LEFT_ID or id == RAY_CAST_DOWN_RIGHT_ID then
				
				if result.normal.y > 0.7 and movement.speed.y <= 0 then
					self.contact.d = true
					separation.x = 0
				elseif result.normal.x ~= 0 then
					if self.contact.l or self.contact.r then
						separation.x = 0
						separation.y = 0
					else
						separation.y = 0
					end
				else
					separation.y = 0
					separation.x = 0
				end
			elseif id == RAY_CAST_UP_ID or id == RAY_CAST_UP_LEFT_ID or id == RAY_CAST_UP_RIGHT_ID then
				
				if result.normal.y < -0.7 then	
					self.contact.u = true
					if self.contact.l or self.contact.r or result.fraction < 0.6 then
						if (movement.speed.x > 0 and separation.x > 0) or (movement.speed.x < 0 and separation.x < 0) then
							separation.x = 0
						end
						
						separation.y = 0
					end
					
				elseif result.normal.x ~= 0 then
					if self.contact.l or self.contact.r then
						separation.x = 0
						separation.y = 0
					else
						separation.y = 0
					end
				else
					separation.x = 0
					separation.y = 0
				end
			elseif id == RAY_CAST_LEFT_ID or id == RAY_CAST_RIGHT_ID then
				self.contact.l = id == RAY_CAST_LEFT_ID
				self.contact.r = id == RAY_CAST_RIGHT_ID
			else
				separation.x = 0
				separation.y = 0
			end
			offset = offset - separation
		end
	end

	if not self.no_reset then
		if	(self.contact.l and movement.speed.x < 0) or 
		(self.contact.r and movement.speed.x > 0) then 
			movement:update_horizontal_speed(0) 
		end

		if (self.contact.u and movement.speed.y > 0) or 
		(not previous_ground_contact and self.contact.d and movement.speed.y < 0) then 
			movement:update_vertical_speed(0) 
		end
	end

	-- try to snap downwards
	if self.do_snap and not self.contact.d then
		local snap_left_vec = origin + offset + self.rays[RAY_CAST_DOWN_LEFT_ID]
		local snap_right_vec = origin + offset + self.rays[RAY_CAST_DOWN_RIGHT_ID]

		local snap_result = nil

		local separation
		for _, snap in ipairs({snap_left_vec, snap_right_vec}) do
			local result = physics.raycast(snap, snap + self.snap_length, {hash("world")})
			
			if result and result.fraction > 0.001 then
				if snap_result == nil then
					snap_result = result.position
					separation = (self.snap_length) * (1 - result.fraction)
					self.slope_left = result.normal.x ~= 0 and result.normal.y ~= 0 and result.normal
				elseif snap_result.y < result.position.y then
					snap_result = result.position
					separation = (self.snap_length) * (1 - result.fraction)
					self.slope_left = nil
					self.slope_right = result.normal.x ~= 0 and result.normal.y ~= 0 and result.normal
				end
			end
		end

		if snap_result ~= nil then
			print(separation.y)
			offset.y = offset.y + (self.snap_length.y - separation.y - 1)
			self.contact.d = true
			
			print("snapped!")
		end
	end
	
	-- use a falling buffer, aka a bit of coyote time to handle slopes and stuff like that better
	if self.contact.d then
		self.falling_dur = 0
	else
		self.falling_dur = self.falling_dur + 1
	end

	if self.falling_dur > self.fall_buffer then
		self.slope_left = nil
		self.slope_right = nil
		msg.post("#", "is_falling")
	end
	return offset
end

function collision:check_move_into_collision(movement_vector, ignore_ground)
	if ignore_ground == nil then ignore_ground = false end
	return (not ignore_ground and self.contact.d and movement_vector.y < 0) or 
	(self.contact.u and movement_vector.y > 0) or 
	(self.contact.l and movement_vector.x < 0) or
	(self.contact.r and movement_vector.x > 0)
end

function collision:show_debug_rays(origin)
	for id, ray in ipairs(self.rays) do
		msg.post("@render:", "draw_line", { start_point = origin, end_point = origin + ray, color = vmath.vector4(1, 0, 0, 1) })
	end
end

return collision