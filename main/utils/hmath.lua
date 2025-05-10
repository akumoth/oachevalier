local M = { }

function M.sign(x)
	return x > 0 and 1 or (x == 0 and 0 or -1)
end

return M