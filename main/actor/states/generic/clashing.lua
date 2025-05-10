local state = require('main.actor.states.state')
local class = require('main.utils.class')

local clashing = class.new_class({});

function clashing.new(movement, collision, inputs, fsm)
	local clashing_state = state({
		name = 'clashing',
		enter = function (self, from) 
			movement:reset_speed()
			if not self.vals.flip then
				self.vals.knockback = self.vals.knockback * -1
			end
			movement:update_horizontal_speed(self.vals.knockback)
			fsm.state_duration = 20
			sprite.play_flipbook("spr#spr", hash("idle"))
		end,
		exit = function (self, to) end,
		update = function (self, dt) 
			movement:update_vertical_speed(movement.slope_suck)

			if not collision.contact.d then
				movement:apply_gravity()
			end

			if fsm.state_duration < 16 and vmath.length(movement.speed) > 5 then
				movement:update_horizontal_speed(movement.speed.x/1.3)
			end

			if fsm.state_duration < 1 then
				if inputs.down() then
					fsm:crouch()
				elseif movement.move_dir.x == 0 then 
					fsm:stop()
				else
					fsm:walk()
				end
			end
		end,
		vals = {
			knockback = 0,
			flip = false,
		}
	})
	local self = setmetatable(clashing_state, clashing)
	self._index = self
	return self
end

return clashing