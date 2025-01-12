local class = require('main.utils.class')

local movement = class.new_class({})

function movement.new(_data)
	assert(_data)
	assert(_data.collision)
	local data = {
		collision = _data.collision,
		facing_dir = _data.facing_dir or vmath.vector3(1.0, 0, 0),
		move_dir = vmath.vector3(),
		last_dir = vmath.vector3(),
		
		speed = vmath.vector3(),

		walk_speed = _data.walk_speed or 180,
		jump_speed = _data.jump_speed or 780,

		gravity_speed = -35, -- gravity's impact per frame
		
		weight = _data.weight or 1,
		fall_speed = _data.fall_speed or -250, -- max falling speed
		ignore_gravity = false, -- ignore gravity for this frame

		slope_suck = -25, -- amount to suck actor towards slope by
	}

	local self = setmetatable(data, movement)
	self._index = self

	return self
end

function movement:update_vertical_speed(velocity) 
	if velocity == 0 then self.speed.y = velocity return end

	self.speed.y = velocity
end

function movement:update_horizontal_speed(velocity)
	if velocity == 0 then self.speed.x = velocity return end

	local new_dir = velocity/math.abs(velocity)

	if self.collision.wall_contact == new_dir then
		self.speed.x = 0
		return
	end

	self.speed.x = velocity

	if self.collision then
		if self.collision.slope_right then
			self.speed.y = (velocity * -new_dir * self.collision.slope_right.y) + self.slope_suck
			self.speed.x = velocity * (self.collision.slope_right.y)
		elseif self.collision.slope_left then
			self.speed.y = (velocity * -new_dir * self.collision.slope_left.y) + self.slope_suck
			self.speed.x = velocity * (self.collision.slope_left.y)
		end
	end
end

function movement:change_speed_length(amount)
	self.speed = self.speed * (1 + amount/vmath.length(self.speed))
end

function movement:apply_gravity()
	if self.ignore_gravity then return end
	if self.speed.y > self.fall_speed then
		local gravity = self.gravity_speed
		if self.speed.y > 0 and self.speed.y < 100 then
			gravity = gravity * .6
		end
		self.speed.y = self.speed.y + (gravity * self.weight) 
	else
		self.speed.y = self.fall_speed
	end
end

function movement:update_move_dir(left, right)
	self.move_dir.x = 0
	if left() then
		self.move_dir.x = -1
	end

	if right() then
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

function movement:update_facing_dir(update_sprite)
	if self.last_dir.x ~= 0 then 
		self.facing_dir.x = self.last_dir.x
	end
	update_sprite() -- sprite.set_hflip("#actor_sprite", self.facing_dir.x < 0)
end

function movement:rotate_dir(q)
	local rot = vmath.quat_rotation_z(q)
	self.speed = vmath.rotate(rot, self.speed)
end

function movement:reset_speed()
	self:update_horizontal_speed(0)
	self:update_vertical_speed(0)
end
return movement