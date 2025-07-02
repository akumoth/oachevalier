local input_mask = {}
input_mask[hash("moveUp")] = bit.lshift(1, 0)
input_mask[hash("moveDown")] = bit.lshift(1, 1)
input_mask[hash("moveLeft")] = bit.lshift(1, 2)
input_mask[hash("moveRight")] = bit.lshift(1, 3)
input_mask[hash("jump")] = bit.lshift(1, 4)
input_mask[hash("attack")] = bit.lshift(1, 5)
input_mask[hash("furia")] = bit.lshift(1, 6)

return input_mask