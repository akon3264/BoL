-- [[ Akali Combo by apilat ]] --
-- [[ Configurables ]] --

ComboKey = 32
HarassKey = string.byte("V")

-- [[ Menu ]] --

function OnLoadMainMenu()
	Config:addParam("combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, ComboKey)
	Config:addParam("harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, HarassKey)
	Config:addTS(Target)
end

function OnLoadComboMenu()
	Config:addSubMenu("Combo Settings", "CSettings")
	Config.CSettings:addParam("useaa", "Use AA in Combo", SCRIPT_PARAM_ONOFF, true)
	Config.CSettings:addParam("shroud", "Auto shroud if enemy still lives", SCRIPT_PARAM_ONOFF, true)
end

function OnLoadHarassMenu()
	Config:addSubMenu("Harass Settings", "HSettings")
	Config.HSettings:addParam("useaa", "Use AA to Harass", SCRIPT_PARAM_ONOFF, true)
	Config.HSettings:addParam("useq", "Use Q to Harass", SCRIPT_PARAM_ONOFF, true)
	Config.HSettings:addParam("usee", "Use E to Harass", SCRIPT_PARAM_ONOFF, true)
end

function OnLoadDrawMenu()
	Config:addSubMenu("Drawing Settings", "DSettings")
	Config.DSettings:addParam("drawq", "Draw Q range", SCRIPT_PARAM_ONOFF, false)
	Config.DSettings:addParam("drawe", "Draw E range", SCRIPT_PARAM_ONOFF, false)
	Config.DSettings:addParam("drawult", "Draw Ult range", SCRIPT_PARAM_ONOFF, true)
end

function OnLoadItemsMenu()
	Config:addSubMenu("Items Settings", "ISettings")
	Config.ISettings:addParam("hex", "Use Hextech Gunblade", SCRIPT_PARAM_ONOFF, false)
	Config.ISettings:addParam("bwc", "Use Bilgewater Cutlass", SCRIPT_PARAM_ONOFF, false)
	Config.ISettings:addParam("btr", "Use Blade of the Ruined King", SCRIPT_PARAM_ONOFF, false)
end

-- [[ Variables ]] --

function OnLoadVariables()
	Version = "1.0"
		SpellQ = {id = "Q", range = 600, ready = false}
		SpellW = {id = "W", delay = 0, width = 800, range = 700, speed = nil, ready = false}
		SpellE = {id = "E", range = nil, width = 650, ready = false}
		SpellR = {id = "R", range = 800, ready = false}
		HEX = {id = 3146, range = 700, ready = false, slot = nil}
		BWC = {id = 3144, range = 450, ready = false, slot = nil}
		BTR = {id = 3153, range = 450, ready = false, slot = nil}
	Config = scriptConfig("Akali", "akali")
	Target = TargetSelector(TARGET_LOW_HP_PRIORITY, SpellR.range)
	Target.name = "Akali Combo"
end

-- [[ OnLoad ]] --

function OnLoad()
	if myHero.charName ~= "Akali" then return end
	
	OnLoadVariables()
	OnLoadMainMenu()
	OnLoadComboMenu()
	OnLoadHarassMenu()
	OnLoadDrawMenu()
	OnLoadItemsMenu()
	PrintChat("<font color=\"#FFFFFF\">>> Akali Combo " .. Version ..  " by <font color=\"#4565C5\">apilat</font> loaded! <<</font>")
end

-- [[ OnTick ]] --

function OnTick()
	Target:update()
	
	SpellQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SpellW.ready = (myHero:CanUseSpell(_W) == READY)
	SpellE.ready = (myHero:CanUseSpell(_E) == READY)
	SpellR.ready = (myHero:CanUseSpell(_R) == READY)
	
	HEX.slot = GetInventorySlotItem(HEX.id)
	BWC.slot = GetInventorySlotItem(BWC.id)
	BTR.slot = GetInventorySlotItem(BTR.id)
	
	if HEX.slot ~= nil then
		HEX.ready = (myHero:CanUseSpell(HEX.slot) == READY)
	end
	
	if BWC.slot ~= nil then
		BWC.ready = (myHero:CanUseSpell(BWC.slot) == READY)
	end
	
	if BTR.slot ~= nil then
		BTR.ready = (myHero:CanUseSpell(BTR.slot) == READY)
	end
	
	if Target.target ~= nil and Config.combo then
		Combo()
	end
	
	if Target.target ~= nil and Config.harass then
		Harass()
	end
end

-- [[ OnDraw ]] --

function OnDraw()
	if Config.DSettings.drawult then DrawCircle(myHero.x, myHero.y, myHero.z, SpellR.range, 0xFF0000) end
	if Config.DSettings.drawq then DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.range, 0x0000FF) end
	if Config.DSettings.drawe then DrawCircle(myHero.x, myHero.y, myHero.z, SpellE.width/2, 0x00FF00) end
end

-- [[ Combo ]] --

function Combo()
	if Target.target ~= nil and HEX.ready and Config.ISettings.hex and GetDistance(myHero, Target.target) <= HEX.range then
		CastSpell(HEX.slot, Target.target)
	end
	if Target.target ~= nil and BWC.ready and Config.ISettings.bwc and GetDistance(myHero, Target.target) <= BWC.range then
		CastSpell(BWC.slot, Target.target)
	end
	if Target.target ~= nil and BTR.ready and Config.ISettings.btr and GetDistance(myHero, Target.target) <= BTR.range then
		CastSpell(BTR.slot, Target.target)
	end
	if Target.target ~= nil and SpellR.ready and GetDistance(myHero, Target.target) > SpellR.range-100 and myHero.ms < Target.target.ms then
		CastSpell(_R, Target.target)
	end
	if Target.target ~= nil and SpellR.ready and GetDistance(myHero, Target.target) > SpellQ.range then
		CastSpell(_R, Target.target)
	end
	if Target.target ~= nil and SpellQ.ready and GetDistance(myHero, Target.target) <= SpellQ.range then
		CastSpell(_Q, Target.target)
		if Config.CSettings.useaa and Target.target ~= nil then
			myHero:Attack(Target.target)
		end
	end
	if Target.target ~= nil and SpellE.ready and GetDistance(myHero, Target.target) <= SpellE.width/2 then
		CastSpell(_E)
		if Config.CSettings.useaa and Target.target ~= nil then
			myHero:Attack(Target.target)
		end
	end
	if Target.target ~= nil and Config.CSettings.shroud and SpellW.ready and myHero.mana > 100 and myHero.level >= 6 then
		CastSpell(_W, myHero.x, myHero.z)
	end
	if GetDistance(myHero, Target.target) <= myHero.range then
		myHero:Attack(Target.target)
	end
end

-- [[ Harass ]] --

function Harass()
	if Target.target ~= nil and SpellQ.ready and GetDistance(myHero, Target.target) <= SpellQ.range and Config.HSettings.useq then
		CastSpell(_Q,Target.target)
		if Config.HSettings.useaa and Target.target ~= nil then
			myHero:Attack(Target.target)
		end
	end
	if Target.target ~= nil and SpellE.ready and GetDistance(myHero, Target.target) <= SpellE.width/2 and Config.HSettings.usee then
		CastSpell(_E)
		if Config.HSettings.useaa and Target.target ~= nil then
			myHero:Attack(Target.target)
		end
	end
end
