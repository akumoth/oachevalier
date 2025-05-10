local state = require('main.actor.states.state')
local class = require('main.utils.class')

local attacking = class.new_class({});

function attacking.new(movement, collision, inputs, fsm, hitboxman)
	local attacking_state = state({
		name = 'attacking',
		enter = function (self, from)
			if from=="falling" or from=="airdashing" then
				self.vals.air = true
			end
			sprite.play_flipbook("spr#spr", inputs.get_attack(self.vals.air))
			
			if from ~= 'foxtrot' and from ~= "falling" and from ~= "airdashing" and from ~= "attacking" then
				movement:reset_speed()
				movement:update_vertical_speed(movement.slope_suck)
			end
			hitboxman.ignore_hitcollision = false

			local last_xspeed = movement.speed.x
			if self.vals.air then
				self.vals.max_xspeed[1] = math.abs(last_xspeed) + movement.drift_speed
				self.vals.max_xspeed[2] = math.abs(last_xspeed) - movement.drift_speed
				if movement.speed.x ~= 0 then
					self.vals.max_xspeed[1] = math.abs(last_xspeed)
					self.vals.max_xspeed[2] = math.max(math.abs(last_xspeed) - movement.drift_speed, 10)
				end
			end
		end,
		exit = function (self, to) 
			if to ~= "attacking" or collision.contact.d then 
				self.vals.air = false
			end
			print("leaving")
			msg.post("/level#level", "controller_hitbox_reset")
		end,
		update = function (self, dt)
			local slope = collision.slope_down or collision.slope_up

			if not self.vals.air then 
				if math.abs(vmath.length(movement.speed)) > ((slope) and 90 or 20) then
					movement:change_speed_length(-(vmath.length(movement.speed) / 4))
					movement:update_horizontal_speed(vmath.length(movement.speed) * math.abs(movement.speed.x)/movement.speed.x, true)
				else
					movement:reset_speed()
				end
			end

			if self.vals.collision_knockback > 0 then
				local knockback_speed = (20 + math.max(0, self.vals.collision_knockback))*8
				if self.vals.collision_flip then
					knockback_speed = knockback_speed * -1
				end

				movement:update_horizontal_speed(knockback_speed, true)

				self.vals.collision_knockback = 0
			end

			if self.vals.air then
				if movement.speed.y < 100 then
					if movement.move_dir.x ~= 0 then
						local fall_xspeed = movement.speed.x + (600 * movement.move_dir.x * dt)

						if math.abs(fall_xspeed) < self.vals.max_xspeed[1] and
						math.abs(fall_xspeed) > self.vals.max_xspeed[2] then
							movement:update_horizontal_speed(fall_xspeed)
						end
					end
				end
			end
		
			if not collision.contact.d then
				movement:apply_gravity()
			end

			local cursor = go.get("spr#spr", "cursor")

			if self.vals.air and collision.contact.d then
				fsm:land()
			end

			if cursor >= 1.0 then
				if not collision.contact.d then
					fsm:fall()
				elseif movement.move_dir.x == 0 then 
					fsm:stop()
				else
					fsm:walk()
				end
			end
		end,
		vals = {
			collision_knockback = 0,
			collision_angle = 0,
			collision_flip = false,
			max_xspeed = {0, 0}
		},
	})
	local self = setmetatable(attacking_state, attacking)
	self._index = self
	return self
end

return attacking