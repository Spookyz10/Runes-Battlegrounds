local Cloth = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function Enable(Part, State, Type)
	for _, v in pairs(Part:GetDescendants()) do
		if v:IsA(Type) then
			v.Enabled = State
		end
	end
end

function Cloth.Trigger(Character, EnemyCharacter, Hit) --Somethings wrong here
	local Assets = {}

	for _, v in pairs(ReplicatedStorage.Resources.HeroHunter["Monster Form"].Cloth:GetChildren()) do
		local Cloned = v:Clone()
		table.insert(Assets, Cloned)

		if v.Name == "P0R" then
			Cloned.Parent = Character["Right Arm"]
			Cloned.Part0 = Character["Right Arm"]
		elseif v.Name == "P1R" then
			Cloned.Parent = Character["Right Arm"]
			Cloned.Part0 = Character["Right Arm"]
		elseif v.Name == "P0L" then
			Cloned.Parent = Character["Left Arm"]
			Cloned.Part0 = Character["Left Arm"]
		elseif v.Name == "P1L" then
			Cloned.Parent = Character["Left Arm"]
			Cloned.Part0 = Character["Left Arm"]
		end

		if v:IsA("Model") then
			Enable(Cloned, true, "Beam")
			Cloned.Parent = Character
		end
	end

	if Hit == true then
		local BeamR = Character:WaitForChild("BeamR")
		local BeamL = Character:WaitForChild("BeamL")
		local P0R = Character["Right Arm"].P0R
		local P1R = Character["Right Arm"].P1R
		local P0L = Character["Left Arm"].P0L
		local P1L = Character["Left Arm"].P1L

		if BeamR then
			BeamR.Beam.Attachment1 = EnemyCharacter.Torso.BodyFrontAttachment
			BeamR.Beam.CurveSize0 = 1.905
			BeamR.Beam.CurveSize1 = 6.592
			BeamR.Beam.Width0 = 0.875
			BeamR.Beam.Width1 = 0.875
		end

		if BeamL then
			BeamL.Beam.Attachment1 = EnemyCharacter.Torso.BodyFrontAttachment
			BeamL.Beam.CurveSize0 = -1.905
			BeamL.Beam.CurveSize1 = -7.531
			BeamL.Beam.Width0 = 0.875
			BeamL.Beam.Width1 = 0.875
		end

		if P0R then
			P0R.Part1 = BeamR.P0R
		end

		if P1R then
			P1R.Part1 = BeamR.P1R
		end

		if P0L then
			P0L.Part1 = BeamL.P0L
		end

		if P1L then
			P1L.Part1 = BeamL.P1L
		end
	elseif Hit == false then
		local BeamR = Character:WaitForChild("BeamR")
		local BeamL = Character:WaitForChild("BeamL")
		local P0R = Character["Right Arm"].P0R
		local P1R = Character["Right Arm"].P1R
		local P0L = Character["Left Arm"].P0L
		local P1L = Character["Left Arm"].P1L

		if BeamR then
			BeamR.Beam.Attachment1 = BeamR.P1R.Attachment
			BeamR.Beam.CurveSize0 = 3.471
			BeamR.Beam.CurveSize1 = 3.471
			BeamR.Beam.Width0 = 2
			BeamR.Beam.Width1 = 2
		end

		if BeamL then
			BeamL.Beam.Attachment1 = BeamL.P1L.Attachment
			BeamL.Beam.CurveSize0 = 3.471
			BeamL.Beam.CurveSize1 = 3.471
			BeamL.Beam.Width0 = 2
			BeamL.Beam.Width1 = 2
		end

		if P0R then
			P0R.Part1 = BeamR.P0R
		end

		if P1R then
			P1R.Part1 = BeamR.P1R
		end

		if P0L then
			P0L.Part1 = BeamL.P0L
		end

		if P1L then
			P1L.Part1 = BeamL.P1L
		end
	end
end

function Cloth.Delete(Character)
	local BeamR = Character:FindFirstChild("BeamR")
	local BeamL = Character:FindFirstChild("BeamL")

	local P0R = Character["Right Arm"]:FindFirstChild("P0R")
	local P1R = Character["Right Arm"]:FindFirstChild("P1R")
	local P0L = Character["Left Arm"]:FindFirstChild("P0L")
	local P1L = Character["Left Arm"]:FindFirstChild("P1L")

	if BeamR then
		BeamR:Destroy()
	end

	if BeamL then
		BeamL:Destroy()
	end

	if P0R then
		P0R:Destroy()
	end

	if P1R then
		P1R:Destroy()
	end

	if P0L then
		P0L:Destroy()
	end

	if P1L then
		P1L:Destroy()
	end
end

return Cloth
