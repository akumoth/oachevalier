local state = require('main.actor.states.state')
local class = require('main.utils.class')
local angle = require('main.utils.angle')

local hitstunned = class.new_class({});

function hitstunned.new(movement, collision, inputs, fsm)
	local hitstunned_state = state({
		name = 'hitstunned',
		enter = function (self, from) 
			movement.ignore_fallcap = true
			collision.do_snap = false

			movement:reset_speed()

			self.vals.hitstun = 5 + math.ceil((self.vals.hitstun)/movement.weight)
			self.vals.speed = math.ceil((self.vals.knockback)/movement.weight)
			self.vals.total_bounces = 0

			movement:update_horizontal_speed(self.vals.speed, false)
			movement:rotate_dir(self.vals.angle*(math.pi/180))
			print(self.vals.angle)
			if collision:check_move_into_collision(movement.speed) then
				if collision.contact.l or collision.contact.r then movement.speed.x = -movement.speed.x end
				if collision.contact.u or collision.contact.d then movement.speed.y = -movement.speed.y end
				self.vals.angle = math.deg(math.atan2(movement.speed.y, movement.speed.x))
			end

			local hitfreeze = math.max(3, math.ceil(self.vals.speed / 100) + 1)
			fsm.state_duration = self.vals.hitstun + hitfreeze
			movement.stop = hitfreeze
			print(self.vals.knockback)
		end,
		exit = function (self, to) 
			movement.ignore_fallcap = false
		end,
		update = function (self, dt) 
			if movement.stop > 1 then
				go.set("spr", "position", vmath.vector3(math.random(-3, 3),math.random(-3, 3),0))
			else
				go.set("spr", "position", vmath.vector3())
			end
			
			local bounced = false
			local slope = collision.slope_up or collision.slope_down
			-- bounce off walls/floor
			if vmath.length(movement.stored_speed) > 450 and movement.stop == 0 and self.vals.total_bounces < 3 then

				if (collision:check_move_into_collision(movement.stored_speed, ((math.floor(self.vals.angle) == 0 or math.ceil(math.abs(self.vals.angle)) == 180) and collision.contact.d))) then

					movement:reset_speed()
					movement:update_horizontal_speed(vmath.length(movement.stored_speed*0.95), false)

					local flipped_angle = self.vals.angle
					if (collision.contact.d and (angle.normalize_angle(flipped_angle) > 180) or (not collision.contact.d)) then 
						flipped_angle = angle:flip_angle(flipped_angle, "v")
					end

					if (collision.contact.l or collision.contact.r) and not slope then flipped_angle = angle:flip_angle(flipped_angle, "h") end

					movement:rotate_dir(flipped_angle*(math.pi/180))
					if slope then
						local slope_angle = math.deg(math.atan2(slope.y, slope.x)) 
						if slope_angle < 0 then slope_angle = 360 + slope_angle end

						if slope_angle > 90 and slope_angle < 270 then 
							slope_angle = angle:flip_angle(slope_angle, "h")
						else 
							slope_angle = 360 - slope_angle
						end 
						
						local prev_speed = movement.speed
						movement:rotate_dir(slope_angle*(math.pi/180))
						movement.speed = (prev_speed + movement.speed)/2
					end

					self.vals.angle = math.deg(math.atan2(movement.speed.y, movement.speed.x))
					movement.stop = math.max(3, math.ceil(vmath.length(movement.speed)/200))
					fsm.state_duration = fsm.state_duration + math.floor(self.vals.hitstun/2) + movement.stop
					bounced = true

					self.vals.total_bounces = self.vals.total_bounces + 1

				end
			end

			if movement.stop == 1 then
				local influence_dir = inputs.get_influence_dir()
				if influence_dir.x == 0 then influence_dir.x = 1 end
				if influence_dir.y == 0 then influence_dir.y = 1 end
				print("before influence: " .. movement.speed)
				print(influence_dir)
				print(movement.influence_mult)
				movement:update_horizontal_speed(movement.speed.x + (math.max(250, math.abs(movement.speed.x)) * (influence_dir.x * movement.influence_mult)), false)
				movement:update_vertical_speed(movement.speed.y + (math.max(250, math.abs(movement.speed.y)) * (influence_dir.y * movement.influence_mult)))
				print("influenced: " .. movement.speed)
			end

			if movement.stop < 1 then
				if collision.contact.d and movement.speed.y <= 0 then
					if (vmath.length(movement.speed) <= 450 or self.vals.total_bounces == 3) then
						movement:change_speed_length(-40)
					else
						movement:change_speed_length(-10)
					end
				else
					movement:apply_gravity()
				end
			end
		
			if fsm.state_duration < 1 then
				if self.vals.knockdown then
					if collision.contact.d then
						fsm:knockdown()
					elseif inputs.do_jump(true) then
						fsm:tech()
					end
				else
					if not collision.contact.d then
						fsm:fall()
					elseif inputs.down() then
						fsm:crouch()
					elseif movement.move_dir.x == 0 then 
						fsm:stop()
					else
						fsm:walk()
					end
				end
			end

			movement.stored_speed = vmath.vector3(movement.speed)
		end, 
		vals = {
			hitstun = 0,
			knockback = 0,
			speed = 0,
			angle = 0,
			total_bounces = 0,
			knockdown = false
		}
	})
	local self = setmetatable(hitstunned_state, hitstunned)
	self._index = self
	return self
end

return hitstunned