--[[
	Freeze
	Módulo genérico pra travar um personagem por completo (posição + rotação),
	de forma robusta o suficiente pra resistir a shiftlock e outros sistemas
	que escrevem CFrame direto no HumanoidRootPart.

	Por que não usar HumRP.Anchored direto:
	- A engine tem uma regressão conhecida onde Anchored não prende de forma
	  confiável a posição em personagens client-owned (a maioria dos players).
	- Anchorar brigaria com Tweens/outras movimentações que o próprio código
	  da skill queira fazer.

	Como funciona:
	- Rotação: adiciona a tag "CantRotate". O RotationController (client)
	  já verifica essa tag antes de escrever qualquer CFrame de rotação
	  (inclusive shiftlock), então isso sozinho já bloqueia giro.
	- Posição: weld o HumanoidRootPart numa Part ancorada e invisível.
	  WeldConstraint mantém a transformação relativa fixa, então mesmo que
	  algo tente mover o HRP, ele é puxado de volta no próximo step físico.

	API:
		local handle = Freeze.Lock(Character)
			Trava posição + rotação. Retorna um handle (a Part âncora) que
			deve ser passado pra Freeze.Release depois.

		Freeze.Release(Character, handle, keepRotationLock?)
			Destroi o weld/âncora (se existir) e, a menos que
			keepRotationLock seja true, também remove a tag "CantRotate".
			Use keepRotationLock = true quando você só quer soltar a
			posição temporariamente (ex: pra rodar uma Tween) mas manter
			a rotação travada.
]]

local Freeze = {}

function Freeze.Lock(Character)
	local HumRP = Character:FindFirstChild("HumanoidRootPart")
	if not HumRP then
		return nil
	end

	Character:AddTag("CantRotate")

	local lockAnchor = Instance.new("Part")
	lockAnchor.Name = "FreezeLockAnchor"
	lockAnchor.Anchored = true
	lockAnchor.CanCollide = false
	lockAnchor.CanTouch = false
	lockAnchor.CanQuery = false
	lockAnchor.Transparency = 1
	lockAnchor.Size = Vector3.new(0.1, 0.1, 0.1)
	lockAnchor.CFrame = HumRP.CFrame
	lockAnchor.Parent = workspace

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = lockAnchor
	weld.Part1 = HumRP
	weld.Parent = lockAnchor

	return lockAnchor
end

function Freeze.Release(Character, lockHandle, keepRotationLock)
	if lockHandle and lockHandle.Parent then
		lockHandle:Destroy()
	end

	if not keepRotationLock then
		Character:RemoveTag("CantRotate")
	end
end

return Freeze
