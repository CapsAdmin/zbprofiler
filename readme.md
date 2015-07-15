This will highlight areas of your code where the CPU has spent most of its time in varying amounts of red and annotate why certain areas of the code could not be jit compiled after the profiler has been run for a little while. Restart zerobrane to refresh the results.

![ScreenShot](https://dl.dropboxusercontent.com/u/244444/ShareX/2015-07/2015-07-15_12-25-07.png)

#install:
1. download the latest version of zerobrane https://github.com/pkulchenko/ZeroBraneStudio/archive/master.zip
1. luajit-msgpack-pure.lua > ZeroBraneStudio/lualibs/luajit-msgpack-pure.lua
2. zb_profile_plugin.lua > ZeroBraneStudio/packages/zb_profile_plugin.lua
			
#install for use with löve:
note: löve/love.exe should exist

1. luajit-msgpack-pure.lua > löve/luajit-msgpack-pure.lua
2. zbprofiler.lua > löve/zbprofiler.lua
3. place your löve project in löve/mygame/
4. modify your löve project:

```
local profiler = require("zbprofiler")

function love.load()
	profiler.start()
end

function love.update() 
	profiler.save(3)
end
```

5. in zerobrane set your project directory to löve/ 
6. modify zb_profile_plugin.lua
```
6: str = ide.config.path.projectdir .. "/" .. str
>
6: str = ide.config.path.projectdir .. "/mygame/" .. str
```
	
#install for use with zerobrane:
1. luajit-msgpack-pure.lua > ZeroBraneStudio/lualibs/luajit-msgpack-pure.lua
2. zbprofiler.lua > ZeroBraneStudio/lualibs/zbprofiler.lua
4. zb_profile_test_plugin.lua > ZeroBraneStudio/packages/zb_profile_test_plugin.lua
5. compile luajit 2.1
6. luajit/src/lua51.dll > ZeroBraneStudio/bin/lua51.dll
7. luajit/src/jit/* >  ZeroBraneStudio/lualibs/jit/*

#issues and todo
- It's kinda clumsy to install. 
- I use markers to add the red lines which is a very ugly way to do it (but I can't find any other way to do it). Scintillia is limited to around 20 markers too.
- maybe add more annottion info and or tooltips to view the assembly of the compiled code
- show percent in the margin somehow
