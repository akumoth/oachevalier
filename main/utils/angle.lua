local M = { }

function M.normalize_angle(angle)
	if (angle < 0) then
		return 360 + angle
	else
		return angle
	end
end

function M:flip_angle(angle, mode)
	if mode == nil then mode = "h" end
	local flip 
	if mode == "h" then 
		flip = 180 - angle
		flip = self.normalize_angle(flip)
	elseif mode == "v" then
		flip = 360 - angle
	end
	return flip
end


return M