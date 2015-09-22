--=======================================================================
-- File Name    : slide_count_helper.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/12/11 17:50:38
-- Description  : description
-- Modify       :
--=======================================================================

if not SlideCountHelper then
    SlideCountHelper = NewLogicNode("SlideCount")
end

function SlideCountHelper:_Uninit()
    self.count = nil
    self.judge_rect = nil
    return 1
end

function SlideCountHelper:_Init(judge_rect)
    self.judge_rect = judge_rect
    self.count = 0
    return 1
end

function SlideCountHelper:SetStartTouch(x, y)
    self.last_in_box = cc.rectContainsPoint(self.judge_rect, cc.p(x, y))
end

function SlideCountHelper:TestTouch(x, y)
    local current_in_box = cc.rectContainsPoint(self.judge_rect, cc.p(x, y))
    local last_in_box = self.last_in_box
    self.last_in_box = current_in_box
    if (not current_in_box and last_in_box) then
        self:AddCount()
        return 1
    end
    return 0
end

function SlideCountHelper:AddCount()
    self.count = self.count + 1
end

function SlideCountHelper:GetCount()
    return self.count
end
