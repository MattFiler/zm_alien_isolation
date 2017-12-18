require("ui.uieditor.widgets.HUD.ZM_Perks.ZMPerksContainerFactory")
require("ui.uieditor.widgets.HUD.ZM_RoundWidget.ZmRndContainer")
require("ui.uieditor.widgets.HUD.ZM_AmmoWidgetFactory.ZmAmmoContainerFactory")
require("ui.uieditor.widgets.HUD.ZM_Score.ZMScr")
require("ui.uieditor.widgets.DynamicContainerWidget")
require("ui.uieditor.widgets.Notifications.Notification")
require("ui.uieditor.widgets.HUD.ZM_NotifFactory.ZmNotifBGB_ContainerFactory")
require("ui.uieditor.widgets.HUD.ZM_CursorHint.ZMCursorHint")
require("ui.uieditor.widgets.HUD.CenterConsole.CenterConsole")
require("ui.uieditor.widgets.HUD.DeadSpectate.DeadSpectate")
require("ui.uieditor.widgets.MPHudWidgets.ScorePopup.MPScr")
require("ui.uieditor.widgets.HUD.ZM_PrematchCountdown.ZM_PrematchCountdown")
require("ui.uieditor.widgets.Scoreboard.CP.ScoreboardWidgetCP")
require("ui.uieditor.widgets.HUD.ZM_TimeBar.ZM_BeastmodeTimeBarWidget")
require("ui.uieditor.widgets.ZMInventory.RocketShieldBluePrint.RocketShieldBlueprintWidget")
require("ui.uieditor.widgets.Chat.inGame.IngameChatClientContainer")
require("ui.uieditor.widgets.BubbleGumBuffs.BubbleGumPackInGame")

CoD.Zombie.CommonHudRequire()

local function PreLoadCallback(HudRef, InstanceRef)
    CoD.Zombie.CommonPreLoadHud(HudRef, InstanceRef)
end

local function PostLoadCallback(HudRef, InstanceRef)
    CoD.Zombie.CommonPostLoadHud(HudRef, InstanceRef)
end

function LUI.createMenu.popup_zm_alien_isolation(InstanceRef)
    local HudRef = CoD.Menu.NewForUIEditor("popup_zm_alien_isolation")
    --PreLoadCallback(HudRef, InstanceRef) (Currently errors out... code checks for fetch anyways...)
    
    HudRef.soundSet = "HUD"
    HudRef:setOwner(InstanceRef)
    HudRef:setLeftRight(true, true, 0, 0)
    HudRef:setTopBottom(true, true, 0, 0)
    HudRef:playSound("menu_open", InstanceRef)
    
    HudRef.buttonModel = Engine.CreateModel(Engine.GetModelForController(InstanceRef), "popup_zm_alien_isolation.buttonPrompts")
    HudRef.anyChildUsesUpdateState = true
    	
		
		
		
	local AYZ_ObjectivePopup_Header = CoD.TextWithBg.new(HudRef, InstanceRef)
    AYZ_ObjectivePopup_Header:setLeftRight(false, false, -70.000000, 70.000000) -- 140px wide starting at centre of screen
    AYZ_ObjectivePopup_Header:setTopBottom(false, false, -200.000000, -220.000000) -- 20px high starting at centre of screen (+200px)
	--AYZ_ObjectivePopup_Header:setScale(0)
	AYZ_ObjectivePopup_Header:setScale(1)
	AYZ_ObjectivePopup_Header.Bg:setRGB(1, 1, 1) -- White
	AYZ_ObjectivePopup_Header.Bg:setAlpha(1)
	AYZ_ObjectivePopup_Header.Text:setScale(0.3)
	AYZ_ObjectivePopup_Header.Text:setText("OBJECTIVE UPDATED")
	AYZ_ObjectivePopup_Header.Text:setTTF("fonts/jixellation.ttf")
	AYZ_ObjectivePopup_Header.Text:setRGB(0, 0, 0) -- Black
	
	-- Testing GSC interaction
	local AYZ_ObjectivePopup = CoD.TextWithBg.new(HudRef, InstanceRef)
    AYZ_ObjectivePopup:setLeftRight(false, false, -500.000000, 500.000000) -- 1000px wide starting at centre of screen
    AYZ_ObjectivePopup:setTopBottom(false, false, -150.000000, -200.000000) -- 50px high starting at centre of screen (+150px)
	--AYZ_ObjectivePopup:setScale(0)
	AYZ_ObjectivePopup:setScale(1)
	AYZ_ObjectivePopup.Text:setText("Text Hasn't Loaded")
	AYZ_ObjectivePopup.Text:setTTF("fonts/jixellation.ttf")
	AYZ_ObjectivePopup.Text:setRGB(1, 1, 1) -- White
    
	local function updateObjectiveText(ModelRef)
		local objectiveText = Engine.GetModelValue(ModelRef)
		AYZ_ObjectivePopup.Text:setText(objectiveText) -- Update text
	end
	
    HudRef:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "AlienIsolationObjectivePopup"), updateObjectiveText)
    
	HudRef:addElement(AYZ_ObjectivePopup_Header)
    HudRef.AlienObjectivePopupHeader = AYZ_ObjectivePopup_Header
    HudRef:addElement(AYZ_ObjectivePopup)
    HudRef.AlienObjectivePopup = AYZ_ObjectivePopup
	
		
		
    
    local function HudCloseCallback(SenderObj)
		SenderObj.AlienObjectivePopup:close()
		SenderObj.AlienObjectivePopupHeader:close()
        
        Engine.GetModel(Engine.GetModelForController(InstanceRef), "popup_zm_alien_isolation.buttonPrompts")
        Engine.UnsubscribeAndFreeModel()
    end
    
    LUI.OverrideFunction_CallOriginalSecond(HudRef, "close", HudCloseCallback)
    
    --PostLoadCallback(HudRef, InstanceRef) (Currently errors out... code checks for fetch anyways...)
    return HudRef
end