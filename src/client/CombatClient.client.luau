--[[
	CombatClient.client.luau
	
	Controles:
	  Click esquerdo (M1)   → ataque normal / aéreo / uppercut (Space+Click)
	  Click esquerdo        → se uma tool estiver selecionada, ativa o skill dela
	  F (hold/release)      → block
	
	Skills:
	  Clique na tool no hotbar para selecioná-la (selectedTool).
	  Clique na tela enquanto a tool está selecionada → FireServer do skill.
	  As tools NUNCA são equipadas no personagem — ficam só no Backpack.
	  
	  Para isso funcionar, cada Tool no Studio deve ter:
	    RequiresHandle = false   (propriedade da Tool, não atributo)
	  Isso impede o Roblox de mover a tool para o character ao clicar nela.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

local CombatRemotes = ReplicatedStorage.Remotes.Combat

-- Tool atualmente "selecionada" pelo jogador (clicou no hotbar)
local selectedTool = nil

-- ─── Helpers ────────────────────────────────────────────────────────────────

local function getHumanoid()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function isInAir()
	local hum = getHumanoid()
	return hum and hum.FloorMaterial == Enum.Material.Air
end

-- Retorna a tool do Backpack com o nome dado, ou nil
local function getToolByName(name)
	return player.Backpack:FindFirstChild(name)
end

-- ─── Seleção de tool via clique no hotbar ───────────────────────────────────
--
-- O Roblox expõe o hotbar através de CoreGui/PlayerGui, mas a forma mais
-- simples e confiável é escutar Tool.Equipped no próprio Backpack.
-- Porém, se RequiresHandle = false, o engine ainda dispara Equipped/Unequipped
-- quando o jogador clica a tool no hotbar — ele só não move a tool pro char.
-- Então aproveitamos isso para rastrear qual tool está "selecionada".

local function watchTool(tool)
	-- Equipped dispara quando o jogador seleciona a tool no hotbar
	tool.Equipped:Connect(function()
		selectedTool = tool
		-- Imediatamente desequipa para a tool não aparecer no character
		-- (só necessário se RequiresHandle = true no Studio; com false isso
		--  já não acontece, mas não custa garantir)
		if tool.Parent == player.Character then
			tool.Parent = player.Backpack
		end
	end)

	tool.Unequipped:Connect(function()
		if selectedTool == tool then
			selectedTool = nil
		end
	end)

	-- Se a tool for destruída/removida, limpa a seleção
	tool.AncestryChanged:Connect(function()
		if not tool:IsDescendantOf(player.Backpack) and selectedTool == tool then
			selectedTool = nil
		end
	end)
end

-- Observa tools que já estão no Backpack e as que chegarem depois
for _, tool in player.Backpack:GetChildren() do
	if tool:IsA("Tool") then
		watchTool(tool)
	end
end

player.Backpack.ChildAdded:Connect(function(child)
	if child:IsA("Tool") then
		watchTool(child)
	end
end)

-- ─── Click esquerdo ──────────────────────────────────────────────────────────

mouse.Button1Down:Connect(function()
	-- Se há uma tool selecionada, o clique ativa o skill
	if selectedTool and getToolByName(selectedTool.Name) then
		CombatRemotes.Skill:FireServer(selectedTool)
		return
	end

	-- Caso contrário, M1 normal
	local air = isInAir()
	local uppercut = (not air) and UserInputService:IsKeyDown(Enum.KeyCode.Space)
	CombatRemotes.M1:FireServer(air, uppercut)
end)

-- ─── Block (F) ───────────────────────────────────────────────────────────────

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then
		return
	end
	if input.KeyCode == Enum.KeyCode.F then
		CombatRemotes.BlockStart:FireServer()
	end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
	if gpe then
		return
	end
	if input.KeyCode == Enum.KeyCode.F then
		CombatRemotes.BlockEnd:FireServer()
	end
end)
