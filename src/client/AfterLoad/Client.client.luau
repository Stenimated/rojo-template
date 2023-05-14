local ReplicatedStorage = game:GetService("ReplicatedStorage")

for i, v in ReplicatedStorage.Client:GetChildren() do
	if v:IsA("ModuleScript") then
		require(v)
	end
end
