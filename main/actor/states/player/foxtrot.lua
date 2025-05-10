local state = require('main.actor.states.state')
local class = require('main.utils.class')

local foxtrot = class.new_class({});

function foxtrot.new(movement, collision, inputs, fsm)
	local foxtrot_state = state({
		name = 'foxtrot',
		enter = function(self, from) 
			sprite.play_flipbook("spr#spr", hash("idle"))
			-- The first foxtrot always follows the player's facing direction,
			-- but the second one follows their last tapped direction.
			if from == 'idle' or from == 'attacking' then
				movement:update_facing_dir(true)
			elseif from == 'foxtrot' then
				fsm.can_foxtrot = false
			end

			if self.vals.can_cancel and not from == 'clashing' then
				self.vals.speed.x = movement.step_speed * movement.facing_dir.x
			else
				self.vals.speed.x = movement.step_speed * movement.last_dir.x
			end

			-- Needs more testing. Foxtrot may last too long after the resolution
			-- was changed.
			fsm.state_duration = 18
		end,
		exit = function(self) end,
		update = function(self, dt)
			movement:update_horizontal_speed(self.vals.speed.x)
			if fsm.can_foxtrot and fsm.state_duration > 13 then
				movement:update_facing_dir()
			elseif fsm.state_duration < 7 then
				local flip = movement:get_speed_dir().x

				movement:update_horizontal_speed(movement.brake_speed * flip)
			end

			if fsm.state_duration < 1 then
				if movement.move_dir.x ~= 0 then
					fsm:walk()
				else
					fsm:stop()
				end
			end
		end,
		vals = {
			speed = vmath.vector3(),
		}
	})
	local self = setmetatable(foxtrot_state, foxtrot)
	self._index = self
	return self
end

return foxtrot