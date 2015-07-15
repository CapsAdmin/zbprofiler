-- modify this function to your needs
local function find_path(list, path)
	path = path:lower():gsub("\\", "/")
	
	for str, info in pairs(list) do
		str = ide.config.path.projectdir .. "/game/" .. str
		str = str:lower():gsub("\\", "/")
		
		if str == path then
			DisplayOutputLn("zb_profile_plugin: found info on path: ", path)
			return info 
		end
	end
	
	DisplayOutputLn("zb_profile_plugin: unable to find any info on path: ", path)
end

local PLUGIN = {}

PLUGIN.name = "zerobrane profiler visualizer"
PLUGIN.description = "proof of concept tools for visualing luajit's statistical profiler and trace abort reasons"
PLUGIN.author = "CapsAdmin"

PLUGIN.markers_setup = {}

local msgpack = require("luajit-msgpack-pure")

function PLUGIN:markLine(editor, line, intensity)
	local id = ide:GetMarker("heatmap_" .. math.floor(intensity*self.max_marker)) or self.max_marker
	editor:MarkerAdd(line-1, id)
end

function PLUGIN:annotateLine(editor, line, text)
	editor:AnnotationSetText(line-1, text)
	editor:AnnotationSetVisible(true)
end

function PLUGIN:onEditorLoad(editor)
	if not self.initialized then		
		local function load(path)
			return select(2, msgpack.unpack(assert(io.open(ide.config.path.projectdir .. "/" .. path, "rb")):read("*all")))
		end

		local tree = load("zerobrane_statistical.msgpack")
		
		if tree then
			local _, root = next(tree)
			
			local list = {}
			
			local function parse(node)
				for k,v in pairs(node.children) do
					local path, line = k:match("(.+):(.+)")
					list[path] = list[path] or {}
					list[path][line] = v.samples / root.samples
					parse(v)
				end
			end
			
			parse(root)
			
			self.profile_list = list
		end
		
		self.trace_abort_list = load("zerobrane_trace_aborts.msgpack")
			
		self.initialized = true
	end
	
	if not self.markers_setup[editor] then
		local r,g,b = unpack(ide:GetConfig().styles.text.bg)
		
		local max_markers = 10
		
		for i = 0, max_markers do
			r = r + math.ceil(i/max_markers * 50)
			local marker = ide:AddMarker("heatmap_" .. i, wxstc.wxSTC_MARK_BACKGROUND, {0,0,0,0}, {r,g,b})
			if not marker or i == max_markers then 
				self.max_marker = i-2
				break 
			end
			editor:MarkerDefine(ide:GetMarker("heatmap_" .. i))
		end

		self.markers_setup[editor] = true
	end
	
	local path = ide:GetDocument(editor).filePath
	
	if self.profile_list then
		local info = find_path(self.profile_list, path)
		if info then
			for line, intensity in pairs(info) do
				self:markLine(editor, line, intensity ^ 0.2)
			end
		end
	end
	
	if self.trace_abort_list then
		local info = find_path(self.trace_abort_list, path)
		if info then
			for line, reasons in pairs(info) do
				local str = {}
				for k,v in pairs(reasons) do
					table.insert(str, line .. ": " .. k .. " ("..v..")")
				end
				self:annotateLine(editor, line, table.concat(str, "\n"))
			end
		end
	end
end

return PLUGIN