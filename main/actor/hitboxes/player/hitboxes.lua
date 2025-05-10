local framedata = {}

local frame_const = require('main.actor.hitboxes.frame_const')
local FRAME_STATUS = frame_const.FRAME_STATUS

framedata[hash("idle")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=1, y_offset=17, width=14, height=33, is_player=true},
			{x_offset=-5, y_offset=-8, width=11, height=21, is_player=true},
			{x_offset=-9, y_offset=-24, width=13, height=13, is_player=true},
			{x_offset=8, y_offset=-9, width=12, height=20, is_player=true},
			{x_offset=7, y_offset=-24, width=15, height=12, is_player=true}
		}
	}
}
	
framedata[hash("walk")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=0, y_offset=12, width=14, height=46, is_player=true},
			{x_offset=8, y_offset=-15, width=12, height=30, is_player=true},
			{x_offset=-8, y_offset=-15, width=12, height=30, is_player=true},
		}
	}
}

framedata[hash("jump")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=0, y_offset=12, width=14, height=46, is_player=true},
			{x_offset=8, y_offset=-15, width=12, height=30, is_player=true},
			{x_offset=-8, y_offset=-15, width=12, height=30, is_player=true},
		}
	}
}

framedata[hash("crouch")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=8, y_offset=-15, width=12, height=38, is_player=true},
			{x_offset=-8, y_offset=-15, width=12, height=38, is_player=true},
		}
	}
}
framedata[hash("stand_to_crouch")] = framedata[hash("crouch")]
framedata[hash("crouch_to_stand")] = framedata[hash("idle")]

framedata[hash("landing")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=0, y_offset=12, width=14, height=46, is_player=true},
			{x_offset=8, y_offset=-15, width=12, height=30, is_player=true},
			{x_offset=-8, y_offset=-15, width=12, height=30, is_player=true},
		}
	}
}

framedata[hash("air")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=0, y_offset=12, width=14, height=46, is_player=true},
			{x_offset=8, y_offset=-15, width=12, height=30, is_player=true},
			{x_offset=-8, y_offset=-15, width=12, height=30, is_player=true},
		}
	}
}

framedata[hash("nground")] = {
	[1] = {
		state = FRAME_STATUS.STARTUP,
		hitbox_data = {	
				{x_offset=-2, y_offset=10, width=16, height=33, is_player=true},
				{x_offset=-15, y_offset=11, width=18, height=15, is_player=true},
				{x_offset=-14, y_offset=-23, width=14, height=14, is_player=true},
				{x_offset=2, y_offset=-12, width=16, height=11, is_player=true},
				{x_offset=13, y_offset=-22, width=20, height=15, is_player=true},
		}
	},
	[2] = {
		state = FRAME_STATUS.STARTUP,
		hitbox_data = {	
				{x_offset=-1, y_offset=9, width=16, height=42, is_player=true},
				{x_offset=8, y_offset=-17, width=16, height=26, is_player=true},
				{x_offset=-14, y_offset=-23, width=14, height=14, is_player=true},
		}
	},
	[3] = {
		state = FRAME_STATUS.ACTIVE,
		hitbox_data = {	
				-- hurt
				{x_offset=1, y_offset=20, width=16, height=21, is_player=true},
				{x_offset=5, y_offset=2, width=16, height=26, is_player=true},
				{x_offset=2, y_offset=-17, width=16, height=13, is_player=true},
				{x_offset=-6, y_offset=-24, width=20, height=11, is_player=true},
				{x_offset=16, y_offset=-18, width=18, height=24, is_player=true},
				-- hi
				{x_offset=18, y_offset=2, width=23, height=44, is_player=true, is_hitbox=true, is_clashable=true, is_collision=true, knockback=40, knockback_angle=90},
				{x_offset=28, y_offset=4, width=20, height=40, is_player=true, is_hitbox=true, is_clashable=true, is_collision=true, knockback=40, knockback_angle=90},
				{x_offset=38, y_offset=6, width=10, height=36, is_player=true, is_hitbox=true, is_clashable=true, is_collision=true, knockback=50, knockback_angle=90},
				{x_offset=45, y_offset=9, width=8, height=30, is_player=true, is_hitbox=true, is_clashable=true, is_collision=true, knockback=50, knockback_angle=80},
		}
	},
	[5] = {
		state = FRAME_STATUS.ACTIVE,
		hitbox_data = {	
				-- hurt
				{x_offset=1, y_offset=20, width=16, height=21, is_player=true},
				{x_offset=5, y_offset=2, width=16, height=26, is_player=true},
				{x_offset=2, y_offset=-17, width=16, height=13, is_player=true},
				{x_offset=-6, y_offset=-24, width=20, height=11, is_player=true},
				{x_offset=16, y_offset=-18, width=18, height=24, is_player=true},
				-- hit
				{x_offset=13, y_offset=19, width=16, height=24, is_player=true, is_hitbox=true, is_clashable=true, is_collision=true, duration=3, knockback=40, knockback_angle=90},
				{x_offset=32, y_offset=19, width=22, height=20, is_player=true, is_hitbox=true, is_clashable=true, is_collision=true, duration=3, knockback=40, knockback_angle=90},
				{x_offset=47, y_offset=19, width=8, height=18, is_player=true, is_hitbox=true, is_clashable=true, is_collision=true, duration=3, knockback=40, knockback_angle=90},
		}
	},
	[8] = {
		state = FRAME_STATUS.RECOVERY,
		hitbox_data = {	
			-- hurt
			{x_offset=1, y_offset=20, width=16, height=21, is_player=true},
			{x_offset=5, y_offset=2, width=16, height=26, is_player=true},
			{x_offset=2, y_offset=-17, width=16, height=13, is_player=true},
			{x_offset=-6, y_offset=-24, width=20, height=11, is_player=true},
			{x_offset=16, y_offset=-18, width=18, height=24, is_player=true},
		}
	}
	
}
framedata[hash("nair")] = {
	land_lag = 9,
	extension = hash("nair_ext"),
	[1] = {
		state = FRAME_STATUS.STARTUP,
		cancel_land = true,
		hitbox_data = {	
				{x_offset=-6, y_offset=2, width=12, height=32, is_player=true},
				{x_offset=-9, y_offset=-19, width=18, height=16, is_player=true},
				{x_offset=7, y_offset=-18, width=14, height=25, is_player=true},
				{x_offset=-6, y_offset=18, width=15, height=14, is_player=true},
				{x_offset=-19, y_offset=13, width=15, height=10, is_player=true},
		}
	},
	[2] = {
		state = FRAME_STATUS.STARTUP,
		hitbox_data = {	
				{x_offset=-7, y_offset=2, width=16, height=34, is_player=true},
				{x_offset=-8, y_offset=-19, width=18, height=10, is_player=true},
				{x_offset=6, y_offset=-18, width=11, height=25, is_player=true},
				{x_offset=-19, y_offset=11, width=15, height=10, is_player=true},
		}
	},
	[4] = {
		state = FRAME_STATUS.ACTIVE,
		cancel_land = false,
		hitbox_data = {	
				-- clean hit
				-- hurt
				{x_offset=-13, y_offset=6, width=12, height=15, is_player=true},
				{x_offset=10, y_offset=0, width=21, height=30, is_player=true},
				{x_offset=-1, y_offset=-18, width=11, height=25, is_player=true},
				{x_offset=-16, y_offset=20, width=15, height=14, is_player=true},
				{x_offset=-7, y_offset=-2, width=12, height=18, is_player=true},
				{x_offset=-24, y_offset=12, width=15, height=8, is_player=true},
				-- hit
				{x_offset=13, y_offset=0, width=24, height=40, is_player=true, is_hitbox=true, knockback=35, knockback_angle=90},
				{x_offset=20, y_offset=20, width=14, height=16, is_player=true, is_hitbox=true, knockback=45, knockback_angle=90},
		}
	},
	[6] = {
		state = FRAME_STATUS.ACTIVE,
		hitbox_data = {	
				-- weaker late hit
				-- hurt
				{x_offset=-13, y_offset=6, width=12, height=17, is_player=true},
				{x_offset=10, y_offset=0, width=21, height=30, is_player=true},
				{x_offset=4, y_offset=-19, width=11, height=25, is_player=true},
				{x_offset=-20, y_offset=20, width=15, height=14, is_player=true},
				{x_offset=-5, y_offset=-7, width=12, height=18, is_player=true},
				{x_offset=-26, y_offset=15, width=15, height=8, is_player=true},
				-- hit
				{x_offset=12, y_offset=5, width=20, height=40, is_player=true, is_hitbox=true, knockback=32, knockback_angle=90, duration=1},
				{x_offset=20, y_offset=25, width=14, height=16, is_player=true, is_hitbox=true, knockback=40, knockback_angle=90, duration=1},
		}
	},
	[7] = {
		state = FRAME_STATUS.ACTIVE,
		can_extend = true,
		hitbox_data = {	
				{x_offset=-12, y_offset=6, width=12, height=17, is_player=true},
				{x_offset=-1, y_offset=11, width=10, height=30, is_player=true},
				{x_offset=4, y_offset=-19, width=11, height=25, is_player=true},
				{x_offset=-14, y_offset=20, width=15, height=14, is_player=true},
				{x_offset=-5, y_offset=-7, width=12, height=18, is_player=true},
				{x_offset=-23, y_offset=15, width=15, height=8, is_player=true},
		}
	},
	[10] = {
		state = FRAME_STATUS.RECOVERY,
		can_extend = true,
	},
	[13] = {
		state = FRAME_STATUS.RECOVERY,
		hitbox_data = {	
				{x_offset=-9, y_offset=10, width=12, height=17, is_player=true},
				{x_offset=-2, y_offset=17, width=10, height=30, is_player=true},
				{x_offset=0, y_offset=-19, width=11, height=25, is_player=true},
				{x_offset=-10, y_offset=25, width=15, height=14, is_player=true},
				{x_offset=-5, y_offset=-7, width=12, height=18, is_player=true},
				{x_offset=-23, y_offset=23, width=15, height=8, is_player=true},
		}
	},
	[14] = {
		state = FRAME_STATUS.RECOVERY,
		can_extend = nil,
		cancel_land = true,
		hitbox_data = {	
				{x_offset=-9, y_offset=10, width=12, height=17, is_player=true},
				{x_offset=4, y_offset=4, width=10, height=20, is_player=true},
				{x_offset=-4, y_offset=-19, width=11, height=25, is_player=true},
				{x_offset=-8, y_offset=25, width=15, height=14, is_player=true},
				{x_offset=-5, y_offset=-7, width=12, height=18, is_player=true},
		}
	},
	[17] = {
		state = FRAME_STATUS.RECOVERY,
		hitbox_data = {	
				{x_offset=-1, y_offset=10, width=12, height=17, is_player=true},
				{x_offset=13, y_offset=-15, width=10, height=20, is_player=true},
				{x_offset=0, y_offset=-19, width=11, height=25, is_player=true},
				{x_offset=-2, y_offset=25, width=15, height=14, is_player=true},
				{x_offset=3, y_offset=-7, width=12, height=18, is_player=true},
		}
	},
}
framedata[hash("nair_ext")] = {
	land_lag = 15,
	[1] = {
		state = FRAME_STATUS.STARTUP,
		cancel_land = false,
		hitbox_data = {	{x_offset=-12, y_offset=21, width=13, height=14, is_player=true},
						{x_offset=-11, y_offset=7, width=13, height=21, is_player=true},
						{x_offset=-2, y_offset=-1, width=13, height=58, is_player=true},
						{x_offset=5, y_offset=-17, width=13, height=21, is_player=true},
						{x_offset=-19, y_offset=18, width=13, height=16, is_player=true}
		}
	},
	[6] = {
		state = FRAME_STATUS.ACTIVE,
		-- strong early hit
		hitbox_data = {	
						-- hurt
						{x_offset=-16, y_offset=23, width=15, height=16, is_player=true},
						{x_offset=-8, y_offset=9, width=13, height=21, is_player=true},
						{x_offset=-2, y_offset=-1, width=13, height=24, is_player=true},
						{x_offset=7, y_offset=-13, width=20, height=12, is_player=true},
						{x_offset=-23, y_offset=18, width=13, height=16, is_player=true},
						{x_offset=14, y_offset=-25, width=12, height=20, is_player=true},
						{x_offset=11, y_offset=0, width=20, height=30, is_player=true},
						-- hit
						{x_offset=15, y_offset=4, width=33, height=34, is_player=true, is_hitbox=true, knockback=60, knockback_angle=270},
						{x_offset=25, y_offset=-14, width=21, height=13, is_player=true, is_hitbox=true, knockback=50, knockback_angle=270},
		}
	},
	[8] = {
		state = FRAME_STATUS.ACTIVE,
		-- weak late hit
		hitbox_data = {	
						-- hurt
						{x_offset=-12, y_offset=23, width=15, height=16, is_player=true},
						{x_offset=-8, y_offset=9, width=13, height=21, is_player=true},
						{x_offset=3, y_offset=-4, width=15, height=24, is_player=true},
						{x_offset=-20, y_offset=14, width=13, height=16, is_player=true},
						{x_offset=16, y_offset=-23, width=23, height=21, is_player=true},
						-- hit
						{x_offset=19, y_offset=-9, width=22, height=26, is_player=true, is_hitbox=true, knockback=50, knockback_angle=270, duration=1},
						{x_offset=24, y_offset=-21, width=21, height=13, is_player=true, is_hitbox=true, knockback=43, knockback_angle=270, duration=1},
		}
	},
	[11] = {
		state = FRAME_STATUS.ACTIVE,
		hitbox_data = {	
			{x_offset=-7, y_offset=23, width=15, height=16, is_player=true},
			{x_offset=-8, y_offset=9, width=13, height=21, is_player=true},
			{x_offset=3, y_offset=-4, width=15, height=24, is_player=true},
			{x_offset=-17, y_offset=12, width=10, height=16, is_player=true},
			{x_offset=7, y_offset=-8, width=23, height=21, is_player=true},
		}
	},
	[12] = {
		state = FRAME_STATUS.RECOVERY,
	},
	[14] = {
		state = FRAME_STATUS.RECOVERY,
		cancel_land = true,
		hitbox_data = {	
			{x_offset=-7, y_offset=23, width=15, height=16, is_player=true},
			{x_offset=-8, y_offset=9, width=13, height=21, is_player=true},
			{x_offset=3, y_offset=-4, width=15, height=24, is_player=true},
			{x_offset=-17, y_offset=12, width=10, height=16, is_player=true},
			{x_offset=7, y_offset=-8, width=23, height=21, is_player=true},
		}
	},
}
return framedata