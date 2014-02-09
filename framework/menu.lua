--=======================================================================
-- File Name    : menu.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

if not MenuMgr then
	MenuMgr = {}
end

function MenuMgr:Init()
	self.tbMenu = {}
	return 1
end

function MenuMgr:Uninit()
	self.tbMenu = {}
end

function MenuMgr:CreateMenu(szName, szBgImg)
	if self.tbMenu[szName] then
		cclog("CreateMenu[%s] Failed Already Exists", szName)
		return self.tbMenu[szName].ccmenuObj
	end

	local layerMenu = CCLayer:create()
	local tbBgSize = nil
	if szBgImg then
		local spriteBG = CCSprite:create(szBgImg)
		if spriteBG then
			layerMenu:addChild(spriteBG, 1, 100)
			spriteBG:setPosition(0, 0)
			spriteBG:setAnchorPoint({0.5, 0.5})
			tbBgSize = spriteBG:getTextureRect().size
		end
	end

	self.tbMenu[szName] ={ ccmenuObj = layerMenu, tbBgSize = tbBgSize}

    return layerMenu
end

function MenuMgr:DestroyMenu(szName)
	self.tbMenu[szName] = nil
end

function MenuMgr:UpdateByImage(szName, tbElementList, tbParam)
	local tbMenu = self:GetMenu(szName)
	if not tbMenu then
		cclog("CreateMenu[%s] is not Exists", szName)
		return 0
	end

	local szAlignType = tbParam.szAlignType or "left"
	local nIntervalX = tbParam.nIntervalX or 15
	local nIntervalY = tbParam.nIntervalY or 0
	
	local menuArray = {}
	local layerMenu = tbMenu.ccmenuObj
	if layerMenu:getChildByTag(1) then
		layerMenu:removeChildByTag(1, true)
	end

	local tbVisibleSize = CCDirector:getInstance():getVisibleSize()
	local itemHeight = nil
	local nY = 0
	local nMaxWidth = 0
	local nSumWidth = 0
	for nRow, tbRow in ipairs(tbElementList) do
		nSumWidth = 0
		local nX = 0
		if nRow ~= 1 then
			nY = nY - nIntervalY
		end
		local tbRowMenu = {}
		for nCol, tbElement in ipairs(tbRow) do
			local menu = cc.MenuItemImage:create(
				tbElement.szNormal,
				tbElement.szSelected,
				tbElement.szDisabled
			)
			menu:registerScriptTapHandler(tbElement.fnCallBack)
			local itemWidth = menu:getContentSize().width
			if not itemHeight then
		    	itemHeight = menu:getContentSize().height
		    end

			if szAlignType == "right" then
				if nCol ~= 1 then
					nX = nX - nIntervalX
					nSumWidth = nSumWidth + nIntervalX
				end
		    	nX = nX - itemWidth / 2
		    	nSumWidth = nSumWidth + itemWidth
		    	menu:setPosition(nX, nY - itemHeight / 2)
		    	nX = nX - itemWidth / 2
		    else
		    	if nCol ~= 1 then
		    		nX = nX + nIntervalX
		    		nSumWidth = nSumWidth + nIntervalX
		    	end
		    	nX = nX + itemWidth / 2
		    	menu:setPosition(nX, nY - itemHeight / 2)
				nX = nX + itemWidth / 2
				nSumWidth = nSumWidth + itemWidth
		    end
		    tbRowMenu[#tbRowMenu + 1] = menu
	    	menuArray[#menuArray+ 1] = menu
	    end
	    if szAlignType == "center" then
	    	local nOffsetX = math.floor(nX / 2)
	    	for _, menu in ipairs(tbRowMenu) do
	    		local nMenuX, nMenuY = menu:getPosition()
	    		menu:setPosition(nMenuX - nOffsetX, nMenuY)
	    	end
		end
		nY = nY - itemHeight
		if nSumWidth > nMaxWidth then
			nMaxWidth = nSumWidth
		end
	end
	local menuTools = cc.Menu:create(unpack(menuArray))
    if szAlignType == "center" and itemHeight then
		local nOffsetY = math.floor(-nY / 2)
		menuTools:setPosition(0, nOffsetY)
	else
    	menuTools:setPosition(0, 0)
    end
    local pBG = layerMenu:getChildByTag(100)
    if pBG then
    	local tbBgSize = tbMenu.tbBgSize
    	pBG:setScaleX((nMaxWidth + 20) / tbBgSize.width)
    	pBG:setScaleY((10 - nY) / tbBgSize.height)
    end
    layerMenu:addChild(menuTools, 1, 1)
    return 1
end

function MenuMgr:UpdateBySprite(szName, tbElementList, tbParam)
	local tbMenu = self:GetMenu(szName)
	if not tbMenu then
		cclog("CreateMenu[%s] is not Exists", szName)
		return 0
	end

	local szAlignType = tbParam.szAlignType or "left"
	local nIntervalX = tbParam.nIntervalX or 15
	local nIntervalY = tbParam.nIntervalY or 0
	
	local menuArray = {}
	local layerMenu = tbMenu.ccmenuObj
	if layerMenu:getChildByTag(1) then
		layerMenu:removeChildByTag(1, true)
	end

	local tbVisibleSize = CCDirector:getInstance():getVisibleSize()
	local itemHeight = nil
	local nY = 0
	local nMaxWidth = 0
	local nSumWidth = 0
	for nRow, tbRow in ipairs(tbElementList) do
		nSumWidth = 0
		local nX = 0
		if nRow ~= 1 then
			nY = nY - nIntervalY
		end
		local tbRowMenu = {}
		for nCol, tbElement in ipairs(tbRow) do
			local texture = CCTextureCache:getInstance():addImage(tbElement.szImage)
			local rectNormal = cc.rect(unpack(tbElement.tbRect["normal"]))
			local frameNormal = CCSpriteFrame:createWithTexture(texture, rectNormal)
			local spriteNormal = CCSprite:createWithSpriteFrame(frameNormal)

			local rectSelected = cc.rect(unpack(tbElement.tbRect["selected"]))
			local frameSelected = CCSpriteFrame:createWithTexture(texture, rectSelected)
			local spriteSelected = CCSprite:createWithSpriteFrame(frameSelected)
			local menu = CCMenuItemSprite:create(spriteNormal, spriteSelected)
			menu:registerScriptTapHandler(tbElement.fnCallBack)
			local itemWidth = menu:getContentSize().width
			if not itemHeight then
		    	itemHeight = menu:getContentSize().height
		    end

			if szAlignType == "right" then
				if nCol ~= 1 then
					nX = nX - nIntervalX
					nSumWidth = nSumWidth + nIntervalX
				end
		    	nX = nX - itemWidth / 2
		    	nSumWidth = nSumWidth + itemWidth
		    	menu:setPosition(nX, nY - itemHeight / 2)
		    	nX = nX - itemWidth / 2
		    else
		    	if nCol ~= 1 then
		    		nX = nX + nIntervalX
		    		nSumWidth = nSumWidth + nIntervalX
		    	end
		    	nX = nX + itemWidth / 2
		    	menu:setPosition(nX, nY - itemHeight / 2)
				nX = nX + itemWidth / 2
				nSumWidth = nSumWidth + itemWidth
		    end
		    tbRowMenu[#tbRowMenu + 1] = menu
	    	menuArray[#menuArray+ 1] = menu
	    end
	    if szAlignType == "center" then
	    	local nOffsetX = math.floor(nX / 2)
	    	for _, menu in ipairs(tbRowMenu) do
	    		local nMenuX, nMenuY = menu:getPosition()
	    		menu:setPosition(nMenuX - nOffsetX, nMenuY)
	    	end
		end
		nY = nY - itemHeight
		if nSumWidth > nMaxWidth then
			nMaxWidth = nSumWidth
		end
	end
	local menuTools = cc.Menu:create(unpack(menuArray))
    if szAlignType == "center" and itemHeight then
		local nOffsetY = math.floor(-nY / 2)
		menuTools:setPosition(0, nOffsetY)
	else
    	menuTools:setPosition(0, 0)
    end
    local pBG = layerMenu:getChildByTag(100)
    if pBG then
    	local tbBgSize = tbMenu.tbBgSize
    	pBG:setScaleX((nMaxWidth + 20) / tbBgSize.width)
    	pBG:setScaleY((10 - nY) / tbBgSize.height)
    end
    layerMenu:addChild(menuTools, 1, 1)
    return 1
end

function MenuMgr:UpdateByString(szName, tbElementList, tbParam)
	local szFontName = tbParam.szFontName or ""
	local nSize = tbParam.nSize or 16
	local szAlignType = tbParam.szAlignType or "left"
	local nIntervalX = tbParam.nIntervalX or 15
	local nIntervalY = tbParam.nIntervalY or 0

	local tbMenu = self:GetMenu(szName)
	if not tbMenu then
		cclog("CreateMenu[%s] is not Exists", szName)
		return 0
	end
	local menuArray = {}
	local layerMenu = tbMenu.ccmenuObj
	if layerMenu:getChildByTag(1) then
		layerMenu:removeChildByTag(1, true)
	end

	local tbVisibleSize = CCDirector:getInstance():getVisibleSize()
	local itemHeight = nil
	local nY = 0
	local nMaxWidth = 0
	local nSumWidth = 0
	for nRow, tbRow in ipairs(tbElementList) do
		nSumWidth = 0
		local nX = 0
		if nRow ~= 1 then
			nY = nY - nIntervalY
		end
		local tbRowMenu = {}
		for nCol, tbElement in ipairs(tbRow) do
			local ccLabel = CCLabelTTF:create(tbElement.szItemName or "错误的菜单项", szFontName, nSize)
			local menu = CCMenuItemLabel:create(ccLabel)
			menu:registerScriptTapHandler(tbElement.fnCallBack)
			local itemWidth = menu:getContentSize().width
			if not itemHeight then
		    	itemHeight = menu:getContentSize().height
		    end

			if szAlignType == "right" then
				if nCol ~= 1 then
					nX = nX - nIntervalX
					nSumWidth = nSumWidth + nIntervalX
				end
		    	nX = nX - itemWidth / 2
		    	nSumWidth = nSumWidth + itemWidth
		    	menu:setPosition(nX, nY - itemHeight / 2)
		    	nX = nX - itemWidth / 2
		    else
		    	if nCol ~= 1 then
		    		nX = nX + nIntervalX
		    		nSumWidth = nSumWidth + nIntervalX
		    	end
		    	nX = nX + itemWidth / 2
		    	menu:setPosition(nX, nY - itemHeight / 2)
				nX = nX + itemWidth / 2
				nSumWidth = nSumWidth + itemWidth
		    end
		    tbRowMenu[#tbRowMenu + 1] = menu
	    	menuArray[#menuArray + 1] = menu
	    end
	    if szAlignType == "center" then
	    	local nOffsetX = math.floor(nX / 2)
	    	for _, menu in ipairs(tbRowMenu) do
	    		local nMenuX, nMenuY = menu:getPosition()
	    		menu:setPosition(nMenuX - nOffsetX, nMenuY)
	    	end
		end
		nY = nY - itemHeight
		if nSumWidth > nMaxWidth then
			nMaxWidth = nSumWidth
		end
	end
	local menuTools = cc.Menu:create(unpack(menuArray))
	if szAlignType == "center" and itemHeight then
		local nOffsetY = math.floor(-nY / 2)
		menuTools:setPosition(0, nOffsetY)
	else
    	menuTools:setPosition(0, 0)
    end
    local pBG = layerMenu:getChildByTag(100)
    if pBG then
    	local tbBgSize = tbMenu.tbBgSize
    	pBG:setScaleX((nMaxWidth + 20) / tbBgSize.width)
    	pBG:setScaleY((10 - nY) / tbBgSize.height)
    end
    layerMenu:addChild(menuTools, 1, 1)

    return 1
end

function MenuMgr:GetMenu(szName)
	return self.tbMenu[szName]
end
