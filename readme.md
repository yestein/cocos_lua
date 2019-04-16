[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)

I have gave up cocos2d, so it will no update.
=====================================================

cocos_lua
=========

This Framework can work on `Cosos2d-x 3.0`, `cocos2d-x 3.1`, `cocos2d-x 3.2`  Now.

And it can easiy updated for furture versions, reason is below.

Why choose it?
---------------

####* Do never modify core code of cocos2d-x, so you can upgrade your cocos2d-x version easily.
(Please forget those endless conflicts when updating version.)

####* Supply a Game Logic Framework besides make cocos2d-x suit for Lua developing.

####* Need only write Lua script but no C++ code in your game developing.

####* Support Scene Reload, Script Reload(now only in windwos), and no need to reboot your application. 

For more `documents` and `tutorials`

You can visit my `blog`: [http://yestein.com](http://yestein.com "yestein.com") ^_^ or click [here](http://yestein.com/?cat=76 "yestein.com") directly.

欢迎关注`微信订阅号`：yestein_developer<br>
<img src="http://raw.github.com/yestein/cocos-lua/master/weixin.jpg" width = 200>

How to Use it on cocos2d-x?
--------------------------------------------
* Step 1: Create a Project with Lua by project-creator which supplied by cosos2d-x.
* Step 2: Copy the `framework` folder to the script folder.(Eg: In Cocos2d-x 3.x, copy to ...\src)
* Step 3: Enter the `framework` folder, execute the "install.py"
* (Step 4: Add the folder `framework` and `script` into your xcode project resource if cocos2d-x version is old)
* (Step 5: You can Modify the `project.lua`, change the project name you wish, its mean which folder framework will luanched, default is `script`.)
* 
Now, You can start your journey by editing the `script/game_mgr.lua` and `preload.lua` ^_^.

PS:
* "game_mgr.lua" contains 1 function which called "GameMgr:_Init"

* function "GameMgr:_Init" will be called once when the game was luanched success, and you need to load your first scene in your game world.

* "preload.lua" declare the script files and orders which you want to load. And you can add files like this:


```
	AddPreloadFile("script/main_scene.lua")
```
or you can write it like this, then you no not write the project folder path.
```
	AddProjectFile("main_scene.lua")
```

you can find the samples in `framework/preload.lua`



