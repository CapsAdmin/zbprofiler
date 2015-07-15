local PLUGIN = {}

PLUGIN.name = "zerobrane profiler test"
PLUGIN.description = "used to test profiling in zerobrane"
PLUGIN.author = "CapsAdmin"

local profiler = require("zbprofiler")

function PLUGIN:onRegister()
	DisplayOutputLn("zb_profile_test_plugin: starting profiler")
	self.profile_save_func = profiler.start_profiling(true)
	self.jit_logging_save_func = profiler.start_jit_logging(true)
end

function PLUGIN:onUnRegister()
	DisplayOutputLn("zb_profile_test_plugin: stopping profiler")
	self.profile_save_func = profiler.start_profiling(false)
	self.jit_logging_save_func = profiler.start_jit_logging(false)	
end

function PLUGIN:onIdle()
	if (self.next_save or 0) < os.clock() then
		--DisplayOutputLn("zb_profile_test_plugin: saving results")
		
		if self.profile_save_func then
			self.profile_save_func()
		end
		
		if self.jit_logging_save_func then
			self.jit_logging_save_func()
		end
		
		self.next_save = os.clock() + 3
	end	
end

return PLUGIN