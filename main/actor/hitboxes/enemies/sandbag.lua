local framedata = {}

local frame_const = require('main.actor.hitboxes.frame_const')
local FRAME_STATUS = frame_const.FRAME_STATUS

framedata[hash("idle")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=0, y_offset=0, width=30, height=50},
		}
	}
}

framedata[hash("hitstunned")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=0, y_offset=0, width=30, height=50},
		}
	}
}

framedata[hash("landing")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=0, y_offset=0, width=30, height=50},
		}
	}
}

framedata[hash("air")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
			{x_offset=0, y_offset=0, width=30, height=50},
		}
	}
}

framedata[hash("tech")] = {
	[1] = {
		state = FRAME_STATUS.INACTIVE,
		hitbox_data = {	
		}
	}
}

return framedata