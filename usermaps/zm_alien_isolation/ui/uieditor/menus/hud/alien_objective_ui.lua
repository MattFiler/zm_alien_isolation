function LUI.createMenu.alien_objective(Instance)
    local Hud = CoD.Menu.NewForUIEditor("alien_objective")

    --All Possible Objectives (ENGLISH)
    local ObjectiveArray = {"Sign in to the Torrens.","Explore the Torrens.","Reroute power to open the door.","Collect your weapons.","Survive until power is restored to the lobby.","Enter the Spaceflight Terminal.","Restore power to the Spaceflight Terminal.","Get to the Tow Platform and escape on the Torrens.","Find a keycard to open the door.","Activate the first Docking Clamp terminal.","Activate the second Docking Clamp terminal.","Pressurise the airlock.","Survive while the airlock pressurises.","Everybody get to the airlock!"}

    --Hud Container
    Hud.soundSet = "HUD"
    Hud:setOwner(Instance)
    Hud:setLeftRight(true, true, 0, 0)
    Hud:setTopBottom(true, true, 0, 0)
    Hud.Bg:setAlpha(0)
    Hud:playSound("menu_open", Instance)

    --Update Title
	local AudiologBox1 = CoD.TextWithBg.new(Hud, Instance)
    AudiologBox1:setLeftRight(false, false, 300, 300)
    AudiologBox1:setTopBottom(true, false, 50, 150)
    AudiologBox1.Text:setText("OBJECTIVE UPDATED:")
    AudiologBox1.Text:setTTF("fonts/jixellation.ttf")
    AudiologBox1.Text:setScale(1)
    AudiologBox1.Bg:setRGB(0, 0, 0)
    AudiologBox1.Bg:setAlpha(1)

    --Objective Text
    local AudiologBox2 = CoD.TextWithBg.new(Hud, Instance)
    AudiologBox2.Text:setText(ObjectiveArray[1])
    AudiologBox2.Text:setTTF("fonts/jixellation.ttf")
    AudiologBox2:setLeftRight(false, false, 300, 300)
    AudiologBox2:setTopBottom(true, false, 200, 300)
    AudiologBox2.Bg:setRGB(0.098, 0.098, 0.098)
    AudiologBox2.Bg:setAlpha(0.8)

    local function AlienObjectiveUpdate(ModelRef)
        if IsParamModelEqualToString(ModelRef, "AYZ_ObjectiveNotification") then
            local notifyData = CoD.GetScriptNotifyData(ModelRef)
            AudiologBox2.Text:setText(ObjectiveArray[notifyData[1]])
        end
    end
    Hud:subscribeToGlobalModel(InstanceRef, "PerController", "scriptNotify", AlienObjectiveUpdate)
    
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