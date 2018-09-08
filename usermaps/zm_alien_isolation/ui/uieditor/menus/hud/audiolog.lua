function LUI.createMenu.audiolog(Instance)
    local Hud = CoD.Menu.NewForUIEditor("audiolog")

    --Hud Container
    Hud.soundSet = "HUD"
    Hud:setOwner(Instance)
    Hud:setLeftRight(true, true, 0, 0)
    Hud:setTopBottom(true, true, 0, 0)
    Hud.Bg:setAlpha(0)
    Hud:playSound("menu_open", Instance)

    --Update Title
	local AudiologBox1 = CoD.TextWithBg.new(Hud, Instance)
    AudiologBox1:setLeftRight(true, true, 0, 0)
    AudiologBox1:setTopBottom(true, true, 0, 0)
    AudiologBox1:setAlpha(1)
    AudiologBox1.Text:setText("AUDIOLOG PLACEHOLDER")
    AudiologBox1.Text:setTTF("fonts/jixellation.ttf")
    AudiologBox1.Text:setScale(1)
    AudiologBox1.Bg:setRGB(0, 0, 0)
    AudiologBox1.Bg:setAlpha(1)

    --Objective Text
    local AudiologBox2 = CoD.TextWithBg.new(Hud, Instance)
    AudiologBox2:setAlpha(0)
    AudiologBox2.Text:setTTF("fonts/jixellation.ttf")
    AudiologBox2:setLeftRight(true, true, 0, 0)
    AudiologBox2:setTopBottom(true, true, 0, 0)
    AudiologBox2.Text:setText("AUDIOLOG PLACEHOLDER")
    AudiologBox2.Bg:setRGB(0.098, 0.098, 0.098)
    AudiologBox2.Bg:setAlpha(0.8)

    local function ShowHideAudiolog(ModelRef)
        if IsParamModelEqualToString(ModelRef, "AYZ_AudiologVisible") then
            local notifyData = CoD.GetScriptNotifyData(ModelRef)
            --AudiologBox1:setAlpha(notifyData[1])
            AudiologBox2:setAlpha(notifyData[1])
        end
    end
    Hud:subscribeToGlobalModel(InstanceRef, "PerController", "scriptNotify", ShowHideAudiolog)
    
    Hud:addElement(AudiologBox1)
    Hud.box1 = AudiologBox1
    Hud:addElement(AudiologBox2)
    Hud.box2 = AudiologBox2

    local function OnHudClose(Sender)
        Sender.box1:close() 
        Sender.box2:close() 
    end

    LUI.OverrideFunction_CallOriginalSecond(Hud, "close", OnHudClose)

    return Hud
end