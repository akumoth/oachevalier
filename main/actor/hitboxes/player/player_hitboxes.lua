local hitboxes = {}
hitboxes[hash("idle")] = {
		[1] = {
			{x_offset=1, y_offset=17, width=14, height=33, is_player=true},
			{x_offset=-5, y_offset=-8, width=11, height=21, is_player=true},
			{x_offset=-9, y_offset=-24, width=13, height=13, is_player=true},
			{x_offset=8, y_offset=-9, width=12, height=20, is_player=true},
			{x_offset=7, y_offset=-24, width=15, height=12, is_player=true}
		}
	}
	
hitboxes[hash("walk")] = {
		[1] = {
			{x_offset=0, y_offset=12, width=14, height=46, is_player=true},
			{x_offset=8, y_offset=-15, width=12, height=30, is_player=true},
			{x_offset=-8, y_offset=-15, width=12, height=30, is_player=true},
		}
	}
hitboxes[hash("jump")] = {
	}
hitboxes[hash("air")] = {
	}
hitboxes[hash("nground")] = {
	[1] = {
		{x_offset=-2, y_offset=10, width=16, height=33, is_player=true},
		{x_offset=-15, y_offset=11, width=18, height=15, is_player=true},
		{x_offset=-14, y_offset=-23, width=14, height=14, is_player=true},
		{x_offset=2, y_offset=-12, width=16, height=11, is_player=true},
		{x_offset=13, y_offset=-22, width=20, height=15, is_player=true},
	},
	[2] = {
		{x_offset=-1, y_offset=9, width=16, height=42, is_player=true},
		{x_offset=8, y_offset=-17, width=16, height=26, is_player=true},
		{x_offset=-14, y_offset=-23, width=14, height=14, is_player=true},
	},
	[3] = {
		-- hurt
		{x_offset=1, y_offset=20, width=16, height=21, is_player=true},
		{x_offset=5, y_offset=2, width=16, height=26, is_player=true},
		{x_offset=2, y_offset=-17, width=16, height=13, is_player=true},
		{x_offset=-6, y_offset=-24, width=20, height=11, is_player=true},
		{x_offset=16, y_offset=-18, width=18, height=24, is_player=true},
		-- hit
		{x_offset=18, y_offset=2, width=23, height=44, is_player=true, is_hitbox=true, is_clashable=true},
		{x_offset=28, y_offset=4, width=20, height=40, is_player=true, is_hitbox=true, is_clashable=true},
		{x_offset=38, y_offset=6, width=10, height=36, is_player=true, is_hitbox=true, is_clashable=true},
		{x_offset=45, y_offset=9, width=8, height=30, is_player=true, is_hitbox=true, is_clashable=true},
	},
	[5] = {
		-- hurt
		{x_offset=1, y_offset=20, width=16, height=21, is_player=true},
		{x_offset=5, y_offset=2, width=16, height=26, is_player=true},
		{x_offset=2, y_offset=-17, width=16, height=13, is_player=true},
		{x_offset=-6, y_offset=-24, width=20, height=11, is_player=true},
		{x_offset=16, y_offset=-18, width=18, height=24, is_player=true},
		-- hit
		{x_offset=13, y_offset=19, width=16, height=24, is_player=true, is_hitbox=true, is_clashable=true, duration=3},
		{x_offset=32, y_offset=19, width=22, height=20, is_player=true, is_hitbox=true, is_clashable=true, duration=3},
		{x_offset=47, y_offset=19, width=8, height=18, is_player=true, is_hitbox=true, is_clashable=true, duration=3},
	}
}

return hitboxes