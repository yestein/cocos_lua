import os, os.path
import shutil

GameMgrFile = "../script/game_mgr.lua"
GameMgrContent = (
"function GameMgr:_Init()\n"
"    \n"
"end\n\n"
)

ProjectFile = "../project.lua"
ProjectContent = (
"PROJECT_PATH = \"script\""
)

PreloadFile = "../script/preload.lua"
PreloadContent = (
"--Sample\n"
"--AddPreloadFile(\"script/sample.lua\")\n"
)
AppDelegateFile = "../../frameworks/runtime-src/Classes/AppDelegate.cpp"

def replaceString(filepath, src_string, dst_string):
    content = ""
    f1 = open(filepath, "rb")
    for line in f1:
        strline = line.decode('utf8')
        if src_string in strline:
            content += strline.replace(src_string, dst_string)
        else:
            content += strline
    f1.close()
    f2 = open(filepath, "wb")
    f2.write(content.encode('utf8'))
    f2.close()

def install():
    if os.path.isfile(AppDelegateFile) == 1:
        print "replace", AppDelegateFile
        replaceString(AppDelegateFile, "src/main.lua", "src/framework/main.lua")
    else:
        print AppDelegateFile, " is not exists"


    if os.path.isfile(ProjectFile) != 1:
        print "create project.lua..."
        fp = open(ProjectFile, "w")
        fp.writelines(ProjectContent)
        fp.close()
    if os.path.isdir("../script") != 1:
        print "create folder <script>..."
        os.mkdir("../script")
    if os.path.isfile(GameMgrFile) != 1:
        print "create script/game_mgr.lua..."
        fp = open(GameMgrFile, "w")
        fp.writelines(GameMgrContent)
        fp.close()
    if os.path.isfile(PreloadFile) != 1:
        print "create script/preload.lua..."
        fp = open(PreloadFile, "w")
        fp.writelines(PreloadContent)
        fp.close()
    print "Install Success!"

install()
