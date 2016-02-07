local bc = basiccomputers

function bc.register_can_dig(func)
	local old_can_dig = bc.can_dig
	function bc.can_dig(pos, player)
		if not func(pos, player) then
			return false
		else
			return old_can_dig(pos, player)
		end
	end
end

function bc.register_can_inv(func)
	local old_can_inv = bc.can_inv
	function bc.can_inv(pos, player)
		if not func(pos, player) then
			return false
		else
			return old_can_inv(pos, player)
		end
	end
end

function bc.register_can_click(func)
	local old_can_click = bc.can_click
	function bc.can_click(pos, player)
		if not func(pos, palyer) then
			return false
		else
			return old_can_click(pos, player)
		end
	end
end

function bc.register_on_punch(func)
	local old_on_punch = bc.on_punch
	function bc.on_punch(pos, player)
		func(pos, player)
		if old_on_punch then
			old_on_punch(pos, player)
		end
	end
end

function bc.register_on_start(func)
	local old_on_start = bc.on_start
	function bc.on_start(pos, player, start)
		if func(pos, player, start) then
			return true
		elseif old_on_start then
			return old_on_start(pos, player, start)
		end
		
	end
end

function bc.register_on_stop(func)
	local old_on_stop = bc.on_stop
	function bc.on_stop(pos, player)
		if func(pos, player) then
			return true
		elseif old_on_stop then
			return old_on_stop(pos, player)
		end
	end
end

function bc.register_on_reboot(func)
	local old_on_reboot = bc.on_reboot
	function bc.on_reboot(pos, player)
		if func(pos, player) then
			return true
		else
			return old_on_reboot(pos, player)
		end
	end
end

function bc.register_on_receive(func)
	local old_on_receive = bc.on_receive
	function bc.on_receive(pos, fields, player)
		if func(pos, fields, player) then
			return true
		else
			return old_on_receive(pos, fields, player)
		end
	end
end

function bc.register_on_calc(func)
	local old_on_calc = bc.on_calc
	function bc.on_calc(pos)
		if func(pos) then
			return true
		else
			return old_on_calc(pos)
		end
	end
end

function bc.register_upgrade(upgrade)
	local old_is_upgrade = bc.is_upgrade
	function bc.is_upgrade(u)
		if u == upgrade then
			return true
		else
			return old_is_upgrade(u)
		end
	end
end

function bc.register_command(cmd, func)
	bc.basic.cmds[cmd] = func
end

function bc.register_function(f, func)
	bc.basic.funcs[f] = func
end

bc.api = 0.01
