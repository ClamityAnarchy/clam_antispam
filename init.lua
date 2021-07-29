--ANTI SPAM

local spam_warnings = 3 -- warn this many times before taking action

local msg_count = {}
local first_msg = {}
local spam_warn = {}
clam_antispam = {}
clam_antispam.muted = {}


--This is a statistic generated from historic clamity chat. the key is the amount of messages and the value is the shortest time anyone has taken to say that many messages ( this list was provided by anon5 )
local msg_cap = { 
	[1]=0,
	[2]=0,
	[3]=6,
	[4]=10,
	[5]=14,
	[6]=18,
	[7]=36,
	[8]=39,
	[9]=60,
	[10]=86,
	[11]=124,
	[12]=137,
	[13]=150,
	[14]=156,
	[15]=171,
	[16]=177,
	[17]=192,
	[18]=207,
	[19]=233,
	[20]=244,
	[21]=270,
	[22]=303,
	[23]=318,
	[24]=342,
	[25]=355,
	[26]=402,
	[27]=412,
	[28]=450,
	[29]=492,
	[30]=540,
	[31]=555,
	[32]=588,
	[33]=592
}
--[[] debug
msg_cap = {
	[1]=0,
	[2]=0,
	[3]=6,
	[4]=6,
	[5]=6,
	[6]=6,
	[7]=6,
	[8]=6,
	[9]=10
}--]]
local function process_msg(name,message)
	if msg_count[name] == nil then msg_count[name] = 0 end
	if msg_count[name] <= 1 then first_msg[name] = os.time() end
	local et=os.time() - first_msg[name] --elapsed time
	msg_count[name] = msg_count[name] + 1
	
	--restart the "loop" when the time hits the largest value from the list	
	if et > msg_cap[#msg_cap] then 
		msg_count[name] = 1
		spam_warn[name] = 1
	end
		
	--kick the player when they said more messages than on the list within the max time
	if msg_cap[msg_count[name]] == nil then 
		if msg_count[name] > #msg_cap then  minetest.kick_player(name, "You talk too much") end
		msg_count[name] = math.random(3,msg_cap[#msg_cap]) --set the counter to a random position to make it less predictable
		return true
	end
	
	if et < msg_cap[msg_count[name]] then --spam detected
		if not spam_warn[name] then spam_warn[name]=1 end		
		 --if the player has been warned sufficiently, only display their spam to them.
		if spam_warn[name] and spam_warn[name] >= spam_warnings then
			clam_antispam.muted[name] = true
		else --otherwise print a warning
			spam_warn[name] = spam_warn[name] + 1
			minetest.chat_send_player(name,"Don't spam >:( you have been warned (" .. spam_warn[name] .. ").")
		end
	else 
		clam_antispam.muted[name] = nil
		spam_warn[name] = 1
	end
	
	if not clam_antispam.muted[name] then 
		minetest.chat_send_all(message) 
	else
		minetest.chat_send_player(name,message)
	end
	return true
end

minetest.unregister_chatcommand("me")
minetest.unregister_chatcommand("greentext")

minetest.register_chatcommand("me", {
	params = "<action>",
	description = "Show chat action (e.g., '/me orders a pizza' displays '<player name> orders a pizza')",
	privs = {shout = true},
	func = function(name, param)
		if param:find("<") or param:find(">") then
			param = minetest.strip_colors(param)
		end
		return process_msg(name," " .. minetest.colorize("#B0B0B0", name .. " " .. param))
	end,
})

minetest.register_chatcommand("greentext", {
	params = "<action>",
	description = "Sends a message in greentext",
	privs = {shout = true},
	func = function(name, param)
		return process_msg(name,minetest.colorize("#789922", " <" .. name .. ">: >" .. param))
	end,
})
--table.insert(minetest.registered_on_chat_message, 1, 
minetest.register_on_chat_message(function(name, message)
	return process_msg(name,'<'..name..'> '..message)
end)