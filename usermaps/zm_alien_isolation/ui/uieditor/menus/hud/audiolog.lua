function LUI.createMenu.blackscreen(Instance)
    local Hud = CoD.Menu.NewForUIEditor("audiolog")

    Hud.soundSet = "HUD"
    Hud:setOwner(Instance)
    Hud:setLeftRight(true, true, 0, 0)
    Hud:setTopBottom(true, true, 0, 0)
    Hud:playSound("menu_open", Instance)

    --Audiolog Title
	local AudiologBox1 = CoD.TextWithBg.new(Hud, Instance)
    AudiologBox1:setLeftRight(true, true, 0.000000, 0.000000)
    AudiologBox1:setTopBottom(true, true, 0.000000, 0.000000)
    AudiologBox1.Text:setText("PLAYING AUDIOLOG")
    AudiologBox1.Text:setTTF("fonts/jixellation.ttf")
    AudiologBox1.Text:setScale(0.3)
    AudiologBox1.Bg:setRGB(0, 0, 0)
    AudiologBox1.Bg:setAlpha(1)

    --Audiolog Title
    local AudiologBox2 = CoD.TextWithBg.new(Hud, Instance)
    AudiologBox2:setLeftRight(true, true, 0.000000, 0.000000)
    AudiologBox2:setTopBottom(true, true, 0.000000, 0.000000)
    AudiologBox2.Text:setText("PLAYING AUDIOLOG")
    AudiologBox2.Text:setTTF("fonts/jixellation.ttf")
    AudiologBox2.Text:setScale(0.3)
    AudiologBox2.Bg:setRGB(0, 0, 0)
    AudiologBox2.Bg:setAlpha(1)
	
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