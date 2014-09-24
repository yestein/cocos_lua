cocos_lua
=========

This Framework can work on `Cosos2d-x 3.0`, `cocos2d-x 3.1`, `cocos2d-x 3.2`

For more `documents` and `tutorials`

You can visit my `blog`: [http://yestein.com](http://yestein.com "yestein.com") ^_^ or click [here](http://yestein.com/?cat=76 "yestein.com") directly.

欢迎关注`微信订阅号`：yestein_developer<br>
<img src="http://raw.github.com/yestein/cocos-lua/master/weixin.jpg" width = 200>

How to Use it on cocos2d-x?
--------------------------------------------
* Step 1: Create a Project with Lua by project-creator which supplied by cosos2d-x.
* Step 2: Copy the “framework" folder to the script folder.Eg: In Cocos2d-x 3.x, copy to ...\src
* Step 3: Enter the "framework" folder, execute the "install.py"
* (Step 4: Add the folder "framework" and "script" into your xcode project resource if cocos2d-x version is old)

Now, You can start your journey by editing the "script/game_mgr.lua" and "preload.lua" ^_^.

PS:
* "game_mgr.lua" contains 1 function which called "GameMgr:_Init"

* function "GameMgr:_Init" will be called once when the game was luanched success, and you need to load your first scene in your game world.

* "preload.lua" declare the script files and orders which you want to load. And you can add files like this:


```
	AddPreloadFile("script/main_scene.lua")
```
or you can find the samples in "framework/preload.lua"



