local state = require('main.actor.states.state')
local class = require('main.utils.class')
local angle = require('main.utils.angle')

local hitstunned = class.new_class({});

local function slope_bounce_angle(slope, movement)
	local slope_angle = math.deg(math.atan2(slope.y, slope.x)) 
	if slope_angle < 0 then slope_angle = 360 + slope_angle end

	if slope_angle > 90 and slope_angle < 270 then 
		slope_angle = angle:flip_angle(slope_angle, "h")
	else 
		slope_angle = 360 - slope_angle
	end 

	local old_speed = movement.speed
	movement:rotate_dir(slope_angle*(math.pi/180))
	movement.speed = (old_speed+movement.speed)/2
end
function hitstunned.new(movement, collision, inputs, fsm)
	local hitstunned_state = state({
		name = 'hitstunned',
		enter = function (self, from) 
			movement.ignore_fallcap = true

			collision.push = false
			collision.do_snap = false
			collision.no_reset = true

			movement:reset_speed()
			go.set("spr#spr", "tint", vmath.vector4(1, 0, 0, 1))

			self.vals.hitstun = math.ceil((self.vals.hitstun)/movement.weight)
			self.vals.speed = math.ceil((self.vals.knockback)/movement.weight)
			self.vals.total_bounces = 0

			movement:update_horizontal_speed(self.vals.speed, false)
			movement:rotate_dir(self.vals.angle*(math.pi/180))

			local hitfreeze = math.max(3, math.ceil(self.vals.speed / 100))
			
			if collision:check_move_into_collision(movement.speed) then
				local slope = collision.slope_up or collision.slope_down
				
				if collision.contact.u or collision.contact.d then movement.speed.y = -movement.speed.y end
				if collision.contact.l or collision.contact.r then movement.speed.x = -movement.speed.x end

				if slope then slope_bounce_angle(slope, movement) end
				
				self.vals.angle = math.deg(math.atan2(movement.speed.y, movement.speed.x))

				hitfreeze = hitfreeze + 7
			end

			print("starting speed: " .. movement.speed)
			print("starting angle: " .. self.vals.angle)
			
			fsm.state_duration = self.vals.hitstun + hitfreeze
			movement.stop = hitfreeze

			if self.vals.hit_counter > 5 then
				self.vals.knockdown = true
			end
		end,
		exit = function (self, to) 
			movement.ignore_fallcap = false

			collision.no_reset = false
			
			go.set("spr#spr", "tint", vmath.vector4(1, 1, 1, 1))
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
			if vmath.length(movement.stored_speed) > 350 and movement.stop == 0 and self.vals.total_bounces < 3 then

				if (collision:check_move_into_collision(movement.stored_speed, ((math.floor(self.vals.angle) == 0 or math.ceil(math.abs(self.vals.angle)) == 180) and collision.contact.d))) then
					movement:reset_speed()
					movement:update_horizontal_speed(vmath.length(movement.stored_speed*0.95), false)

					local flipped_angle = self.vals.angle

					print("d: " .. tostring(collision.contact.d) .. " l: " .. tostring(collision.contact.l) .. " r: " .. tostring(collision.contact.r) .. " u: " .. tostring(collision.contact.u))
					
					if (collision.contact.d and (angle.normalize_angle(flipped_angle) > 180) or (not collision.contact.d)) and movement.stored_speed.y < 0 then 
						flipped_angle = angle:flip_angle(flipped_angle, "v")
					end
					
					if (collision.contact.l or collision.contact.r) and not slope then 
						flipped_angle = angle:flip_angle(flipped_angle, "h")
						if math.abs(movement.stored_speed.x) < 100 then
							movement.speed.x = movement.speed.x * 1.2
							flipped_angle = flipped_angle + 30
						end
						
					end

					movement:rotate_dir(flipped_angle*(math.pi/180))
					if slope then slope_bounce_angle(slope, movement) end

					self.vals.angle = math.deg(math.atan2(movement.speed.y, movement.speed.x))

					movement.stop = math.max(10, math.ceil(vmath.length(movement.speed)/100))
					
					fsm.state_duration = fsm.state_duration + math.floor(self.vals.hitstun/2) + movement.stop
					bounced = true

					print("bounced speed: " .. movement.stored_speed)
					print("bounced angle: " .. self.vals.angle)
					
					self.vals.total_bounces = self.vals.total_bounces + 1

				end
			end

			if movement.stop == 1 then
				local influence_dir = inputs.get_influence_dir()
				if influence_dir.x == 0 then influence_dir.x = 1 end
				if influence_dir.y == 0 then influence_dir.y = 1 end
				-- Make sure directional influence goes, well, in a direction, and that it's affected slightly by the current hit counter
				movement:update_horizontal_speed(movement.speed.x + (math.max(250 * (1+self.vals.hit_counter/8), math.abs(movement.speed.x)) * (influence_dir.x * movement.influence_mult * (1+self.vals.hit_counter/8))), false)
				movement:update_vertical_speed(movement.speed.y + (math.max(250 * (1+self.vals.hit_counter/8), math.abs(movement.speed.y)) * (influence_dir.y * movement.influence_mult  * (1+self.vals.hit_counter/8))))
			end

			if movement.stop < 1 then
				if collision.contact.d then
					if movement.speed.y <= 0 then 
						if (vmath.length(movement.speed) <= 450 or self.vals.total_bounces == 3) then
							movement:change_speed_length(-40)
						else
							movement:change_speed_length(-10)
						end
					end
				else
					if vmath.length(movement.stored_speed) < 300 and (collision.contact.l or collision.contact.r) then
						movement:update_horizontal_speed(0)
					end
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
			hit_counter = 0,
			knockdown = false
		}
	})
	local self = setmetatable(hitstunned_state, hitstunned)
	self._index = self
	return self
end

return hitstunned