function LUI.createMenu.blackscreen(Instance)
    local Hud = CoD.Menu.NewForUIEditor("blackscreen")

    Hud.soundSet = "HUD"
    Hud:setOwner(Instance)
    Hud:setLeftRight(true, true, 0, 0)
    Hud:setTopBottom(true, true, 0, 0)
    Hud:playSound("menu_open", Instance)

	local FullscreenBlackBox = CoD.TextWithBg.new(Hud, Instance)
    FullscreenBlackBox:setLeftRight(true, true, 0.000000, 0.000000)
    FullscreenBlackBox:setTopBottom(true, true, 0.000000, 0.000000)
    FullscreenBlackBox.Text:setText("")
    FullscreenBlackBox.Bg:setRGB(0, 0, 0)
    FullscreenBlackBox.Bg:setAlpha(1)
	
    Hud:addElement(FullscreenBlackBox)
    Hud.fullscreenContainer = FullscreenBlackBox

    local function OnHudClose(Sender)
        Sender.fullscreenContainer:close() 
    end

    LUI.OverrideFunction_CallOriginalSecond(Hud, "close", OnHudClose)

    return Hud
end