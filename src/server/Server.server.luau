for i, v in script.Parent.Modules:GetChildren() do
	if v:IsA("ModuleScript") then
		require(v)
	end
end
