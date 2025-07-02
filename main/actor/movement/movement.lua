local class = require('main.utils.class')
local hmath = require('main.utils.hmath')

local movement = class.new_class({})

function movement.new(_data)
	assert(_data)
	assert(_data.collision)
	assert(_data.inputs)
	local data = {
		collision = _data.collision,
		inputs = _data.inputs,
		facing_dir = _data.facing_dir or vmath.vector3(1.0, 0, 0),
		move_dir = vmath.vector3(),
		last_dir = vmath.vector3(),
		
		speed = vmath.vector3(),
		push = vmath.vector3(),
		
		stored_speed = vmath.vector3(),
		influence_mult = .08,
		
		walk_speed = _data.walk_speed or 180,
		jump_speed = _data.jump_speed or 650,
		drift_speed = _data.drift_speed or 130,
		
		shorthop_speed = _data.shorthop_speed or 500,
		side_tech_speed = _data.side_tech_speed or 230,
		up_tech_speed = _data.up_tech_speed or 528,
		
		tech_angle = _data.tech_angle or 70,

		neutral_tech_time = _data.neutral_tech_time or 22,
		side_tech_time = _data.side_tech_time or 34,
		up_tech_time = _data.up_tech_time or _data.neutral_tech_time or 22,
		air_tech_time = _data.air_tech_time or 12,
		
		pusher_speed = vmath.vector3(160, 0, 0),
		pushed_speed = vmath.vector3(160, 0, 0),
		
		gravity_speed = -35, -- gravity's impact per frame
		
		weight = _data.weight or 1,
		fall_speed = _data.fall_speed or -250, -- max falling speed
		ignore_gravity = false, -- ignore gravity for this frame
		ignore_fallcap = false, -- ignore fallspeed cap
		
		slope_suck = -25, -- amount to suck actor towards slope by
		stop = 0, -- frames to completely stop movement during
	}

	local self = setmetatable(data, movement)
	self._index = self

	return self
end

function movement:update_vertical_speed(velocity) 
	if velocity == 0 then self.speed.y = velocity return end
	self.speed.y = velocity
end

function movement:update_horizontal_speed(velocity, check_slope)
	if velocity == 0 or velocity ~= velocity then self.speed.x = 0 return end
	if check_slope == nil then check_slope = true end

	local new_dir = hmath.sign(velocity)

	if self.collision.wall_contact == new_dir then
		self.speed.x = 0
		return
	end

	self.speed.x = velocity

	if self.collision and check_slope then
		if self.collision.slope_down then
			self.speed.y = (velocity * -new_dir * self.collision.slope_down.y) + self.slope_suck
			self.speed.x = velocity * (self.collision.slope_down.y)
		end
	end
end

function movement:get_speed_dir()
	local xdir = hmath.sign(self.speed.x)
	if xdir ~= xdir then
		xdir = 0
	end

	local ydir = hmath.sign(self.speed.y)
	if ydir ~= ydir then
		ydir = 0
	end

	local dir = vmath.vector3(xdir, ydir, 0)
	
	return dir
end

function movement:change_speed_length(amount)
	if vmath.length(self.speed) == 0 then return end
	local sign = hmath.sign(self.speed.x)
	self.speed = self.speed * (1 + amount/vmath.length(self.speed))
	if sign ~= hmath.sign(self.speed.x) then self:reset_speed() return end
end

function movement:apply_gravity()
	if self.speed.y > self.fall_speed then
		local gravity = self.gravity_speed
		if self.speed.y > 0 and self.speed.y < 100 then
			gravity = gravity * .6
		end
		self.speed.y = self.speed.y + (gravity * self.weight) 
	else
		if not self.ignore_fallcap then
			self.speed.y = self.fall_speed
		end
	end
end

function movement:update_move_dir()
	self.move_dir.x = 0
	if self.inputs.left() then
		self.move_dir.x = -1
	end

	if self.inputs.right() then
		if self.move_dir.x ~= 0 then
			self.move_dir.x = 0
		else
			self.move_dir.x = 1
		end
	end

	if self.move_dir.x ~= 0 or self.move_dir.y ~= 0 then
		self.last_dir = vmath.vector3(self.move_dir)
	end
end

function movement:update_facing_dir(last)
	if last == true then
		if self.last_dir.x ~= 0 then 
			self.facing_dir.x = self.last_dir.x
		end
	else
		if self.move_dir.x ~= 0 then 
			self.facing_dir.x = self.move_dir.x
		end
	end
	self.inputs.update_sprite() -- sprite.set_hflip("#actor_sprite", self.facing_dir.x < 0)
end

function movement:rotate_dir(q)
	local rot = vmath.quat_rotation_z(q)
	self.speed = vmath.rotate(rot, self.speed)
end

function movement:set_push(speed, slope, debug)
	slope = slope or self.collision.slope_down
	
	if self.collision.contact.d and speed.y < 0 then speed.y = 0 end
	if self.collision.contact.u and speed.y > 0 then speed.y = 0 end
	if self.collision.contact.l and speed.x < 0 then speed.x = 0 end
	if self.collision.contact.r and speed.x > 0 then speed.x = 0 end
	
	self.push = speed
	if slope then
		self.push.y = (self.push.x * -hmath.sign(self.push.x) * math.abs(slope.y))
		self.push.x = self.push.x * math.abs(slope.x)
		if debug then print(self.push) end
	end
end

function movement:reset_speed()
	self:update_horizontal_speed(0, true)
	self:update_vertical_speed(0)
end
return movement