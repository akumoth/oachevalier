local state = require('main.actor.states.state')
local class = require('main.utils.class')

local jumping = class.new_class({});

function jumping.new(movement, collision, inputs, fsm)
	local jumping_state = state({
		name = 'jumping',
		enter = function(self, from)
			inputs.erase_buffer({"jump"})
			
			collision.push = true
			if from == 'foxtrot' then
				if math.abs(movement.speed.x) <= movement.brake_speed then
					movement.speed.x = 0
				else
					movement.speed.x = movement.speed.x * 0.75
				end
			end

			sprite.play_flipbook("spr#spr", hash("jump"))
			self.vals.speed = movement.jump_speed
			fsm.state_duration = 3
		end,
		exit = function(self)
			movement:update_vertical_speed(self.vals.speed)
		end,
		update = function(self, dt)
			if not inputs.check_jumping() then
				self.vals.speed = movement.shorthop_speed
			end

			if fsm.state_duration < 1 then
				fsm:fall()
			end
		end,
		vals = {
			speed = vmath.vector3()
		}
	})
	local self = setmetatable(jumping_state, jumping)
	self._index = self
	return self
end

return jumping