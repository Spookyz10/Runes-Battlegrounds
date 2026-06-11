local module = {}

--[[
    Sistema de iFrames por nível numérico.

    Níveis de resistência (AddXiFrames):
        1  = iframes básicos   → bloqueiam ataques pierce 0 (M1, skills normais sem argumento)
        2  = iframes fortes    → bloqueiam ataques pierce 0 e 1
        3  = iframes absolutos → bloqueiam tudo (pierce 0, 1 e 2)

    Níveis de penetração (HasiFrame pierceLevel):
        0  = ataque normal         → bloqueado por qualquer iframe (1+)
        1  = ataque médio          → bloqueado por iframes fortes (2+)
        2  = ataque forte/ultimate → bloqueado apenas por iframes absolutos (3)

    Uso nas skills:
        iFramesService:HasiFrame(EnemyCharacter)       -- pierce 0, padrão
        iFramesService:HasiFrame(EnemyCharacter, 1)    -- pierce 1, ignora iframes básicos
        iFramesService:HasiFrame(EnemyCharacter, 2)    -- pierce 2, ignora básicos e fortes

    Uso nas defesas:
        iFramesService:AddBaseiFrames(Character)   -- valor 1
        iFramesService:AddStrongiFrames(Character) -- valor 2
        iFramesService:AddAlliFrames(Character)    -- valor 3
]]

function module:HasiFrame(Character, pierceLevel)
	local current = Character:GetAttribute("iFrames") or 0
	if current <= 0 then
		return false
	end

	local level = pierceLevel or 0

	-- tem iframe se a resistência atual é maior que o pierce do ataque
	-- pierce 0 → bloqueado por iFrames >= 1
	-- pierce 1 → bloqueado por iFrames >= 2
	-- pierce 2 → bloqueado por iFrames >= 3
	return current > level
end

function module:AddBaseiFrames(Character)
	local current = Character:GetAttribute("iFrames") or 0
	if current >= 1 then
		return
	end
	Character:SetAttribute("iFrames", 1)
end

function module:AddStrongiFrames(Character)
	local current = Character:GetAttribute("iFrames") or 0
	if current >= 2 then
		return
	end
	Character:SetAttribute("iFrames", 2)
end

function module:AddAlliFrames(Character)
	Character:SetAttribute("iFrames", 3)
end

function module:RemoveAlliFrames(Character)
	Character:SetAttribute("iFrames", 0)
end

function module:RemoveiFrames(Character, iFrameHandle)
	local current = Character:GetAttribute("iFrames") or 0
	if current <= 0 then
		return
	end

	if iFrameHandle == "All" then
		Character:SetAttribute("iFrames", 0)
	elseif iFrameHandle == "Strong" then
		if current >= 2 then
			Character:SetAttribute("iFrames", 1)
		end
	elseif iFrameHandle == "Base" then
		if current <= 1 then
			Character:SetAttribute("iFrames", 0)
		end
	end
end

function module:GetLevel(Character)
	return Character:GetAttribute("iFrames") or 0
end

return module
