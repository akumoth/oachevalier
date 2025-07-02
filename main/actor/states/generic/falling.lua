local state = require('main.actor.states.state')
local class = require('main.utils.class')

local falling = class.new_class({});

function falling.new(movement, collision, inputs, fsm)
	local falling_state = state({
		name = 'falling',
		enter = function(self, from)
			sprite.play_flipbook("spr#spr", hash("air"))
			collision.do_snap = false
			collision.push = false

			if from == 'hitstunned' then
				movement:update_horizontal_speed(math.min(movement.speed.x, movement.walk_speed))
			elseif from == 'jumping' then
				fsm.state_duration = 8
			end

			local last_xspeed = movement.speed.x
			self.vals.max_xspeed[1] = math.abs(last_xspeed) + movement.drift_speed
			self.vals.max_xspeed[2] = -movement.drift_speed
			if math.abs(movement.speed.x) > movement.drift_speed then
				self.vals.max_xspeed[1] = math.abs(last_xspeed)
			end
		end,
		exit = function(self, to) 
		end,
		update = function(self, dt)

			if collision.contact.d then
				fsm:land()
			end
			
			if movement.speed.y < 100 then
				if movement.move_dir.x ~= 0 then
					local fall_xspeed = movement.speed.x + (600 * movement.move_dir.x * dt)

					if math.abs(fall_xspeed) < self.vals.max_xspeed[1] and
					math.abs(fall_xspeed) > self.vals.max_xspeed[2] then
						movement:update_horizontal_speed(fall_xspeed)
					end
				end
			end

			movement:apply_gravity()
			
		end,
		vals = {
			max_xspeed = {0, 0}
		}
	})
	local self = setmetatable(falling_state, falling)
	self._index = self
	return self
end

return falling