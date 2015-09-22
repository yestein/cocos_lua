--=======================================================================
-- File Name    : story_mgr.lua
-- Creator      : Abel(abel@koogame.com)
-- Date         : 2015/8/25 13:50:03
-- Description  : description
-- Modify       :
--=======================================================================


if not StoryMgr then
    StoryMgr = {}
end

local talk_config = {}
talk_config.Head_In_Time = 0.2
talk_config.Bottom_Fade_In = 0.5
talk_config.Time_Interval = 3

function StoryMgr:Uninit()
    self.story_config = nil
end

function StoryMgr:Init()
    self.story_config = {}
end


function StoryMgr:LoadStory(story_id, config)
    assert(not self.story_config[story_id])
    self.story_config[story_id] = config
end

function StoryMgr:PlayStory(scene, story_id, call_back)

    if not self.story_config[story_id] then
        assert(false, "Not Story")
    end
    function onTouchEvent(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end

    local mask_layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), visible_size.width, visible_size.height)
    mask_layer:setLocalZOrder(99)
    mask_layer:setTouchEnabled(true)
    mask_layer:registerScriptTouchHandler(onTouchEvent)
    scene:AddLayer("story_mask_layer", mask_layer, 99)

    local talk_action_list = {}

    local talk_frame_name = {"TALK_FRAME_SELF", "TALK_FRAME_ENEMY"}

    local image = {"image/battle/head_1.png", "image/battle/head_2.png"}

    local talk_progress = 1

    for _, data in pairs(self.story_config[story_id].story_talk) do

            talk_action_list[#talk_action_list + 1] = cc.CallFunc:create(function()
                local data = self.story_config[story_id].story_talk[talk_progress]
                local talk_frame = mask_layer:getChildByTag(data.talk_type)
                if not talk_frame then
                    talk_frame = self:CreateStoryTalk(mask_layer, image[data.talk_type], data.content, data.talk_type)
                end

                self:UpdateStoryTalk(talk_frame, image[data.talk_type], data.content, data.talk_type)

                talk_progress = talk_progress + 1

            end)
            talk_action_list[#talk_action_list + 1] = cc.DelayTime:create(talk_config.Head_In_Time + talk_config.Bottom_Fade_In + talk_config.Time_Interval)
    end

    local function talkExit()

    end

    local function talkEnd()

        scene:RemoveLayer("story_mask_layer")
        if call_back then
            Lib:SafeCall(call_back)
        end
    end
    talk_action_list[#talk_action_list + 1] = cc.CallFunc:create(talkEnd)
    mask_layer:runAction(cc.Sequence:create(unpack(talk_action_list)))

end

function StoryMgr:CreateStoryTalk(mask_layer, image_icon, content, talk_type)


   local talk_frame = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), visible_size.width, 150)
   talk_frame:setVisible(false)

   local talk_icon = cc.Sprite:create(image_icon)
   talk_frame:addChild(talk_icon, 1, 1)

   local talk_content = cc.LabelTTF:create(content, "", 30, cc.size(500, 100), cc.TEXT_ALIGNMENT_LEFT)
   talk_content:setVisible(false)
   talk_frame:addChild(talk_content, 2, 2)
   mask_layer:addChild(talk_frame)
   talk_frame:setTag(talk_type)

   if talk_type == 1 then
        talk_frame:setPosition(cc.p(0, 400))
        talk_icon:setPosition(talk_icon:getContentSize().width/2, talk_icon:getContentSize().height/2)
        talk_content:setAnchorPoint(0, 1)
        talk_content:setPosition(talk_icon:getContentSize().width+50, 130)
   elseif talk_type == 2 then
        talk_frame:setPosition(cc.p(0, 150))
        talk_icon:setPosition(visible_size.width-talk_icon:getContentSize().width/2, talk_icon:getContentSize().height/2)
        talk_content:setAnchorPoint(1, 1)
        talk_content:setPosition(visible_size.width-talk_icon:getContentSize().width-50, 130)
   end
   return talk_frame
end

function StoryMgr:UpdateStoryTalk(talk_frame, image_icon, content ,talk_type)

    local talk_icon = talk_frame:getChildByTag(1)
    local talk_content = talk_frame:getChildByTag(2)
    talk_frame:setOpacity(0)
    talk_content:setVisible(false)
    talk_content:setString(content)
    local function headMove()
        talk_frame:setVisible(true)
        local positionX, positionY = talk_icon:getPosition()
        if talk_type == 1 then

        talk_icon:setPosition(positionX - talk_icon:getContentSize().width, positionY)

        elseif talk_type == 2 then

        talk_icon:setPosition(positionX + talk_icon:getContentSize().width, positionY)
        end

        talk_icon:runAction(cc.MoveTo:create(talk_config.Head_In_Time,cc.p(positionX, positionY)))
   end

   local function frameFadeIn()
        talk_content:setVisible(true)
        talk_frame:runAction(cc.FadeTo:create(talk_config.Bottom_Fade_In, 150))
   end
   local action_list = {}
   if not talk_frame:isVisible() then
    action_list[#action_list + 1] = cc.CallFunc:create(headMove)
    action_list[#action_list + 1] = cc.DelayTime:create(talk_config.Head_In_Time)
   end
    action_list[#action_list + 1] = cc.CallFunc:create(frameFadeIn)
    talk_frame:runAction(cc.Sequence:create(unpack(action_list)))
end
