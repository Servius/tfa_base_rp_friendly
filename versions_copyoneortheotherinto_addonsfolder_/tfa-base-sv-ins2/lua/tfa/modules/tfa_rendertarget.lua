
local onevec = Vector(1, 1, 1)

local function RBP(vm)
	local bc = vm:GetBoneCount()
	if not bc or bc <= 0 then return end

	for i = 0, bc do
		vm:ManipulateBoneScale(i, onevec)
		vm:ManipulateBoneAngles(i, angle_zero)
		vm:ManipulateBonePosition(i, vector_origin)
	end
end

if CLIENT then
	local props = {
		["$translucent"] = 1
	}

	local TFA_RTMat = CreateMaterial("tfa_rtmaterial", "UnLitGeneric", props) --Material("models/weapons/TFA/shared/optic")
	local TFA_RTScreen = GetRenderTargetEx("TFA_RT_Screen", 512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888)
	local TFA_RTScreenO = GetRenderTargetEx("TFA_RT_ScreenO", 512, 512, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_SEPARATE, 0, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888)
	local oldVmModel = ""
	local oldWep = nil

	local ply, vm, wep

	local function TFARenderScreen()
		ply = GetViewEntity()
		if not IsValid(ply) or not ply:IsPlayer() then
			ply = LocalPlayer()
			return
		end
		if not IsValid(vm) then
			vm = ply:GetViewModel()
			return
		end
		wep = ply:GetActiveWeapon()
		if oldVmModel ~= vm:GetModel() or ( wep ~= oldWep ) then
			if IsValid(oldWep) then
				oldWep.MaterialCached = nil
			end
			oldWep = wep
			RBP(vm)
			vm:SetSubMaterial()
			vm:SetSkin(0)

			oldVmModel = vm:GetModel()
			return
		end


		if not IsValid(wep) then
			return
		end

		if wep.Skin and isnumber(wep.Skin) then
			vm:SetSkin(wep.Skin)
			wep:SetSkin(wep.Skin)
		end

		if wep.MaterialTable and not wep.MaterialCached then
			wep.MaterialCached = {}

			if #wep.MaterialTable >= 1 and #wep:GetMaterials() <= 1 then
				wep:SetMaterial(wep.MaterialTable[1])
			else
				wep:SetMaterial("")
			end

			wep:SetSubMaterial(nil, nil)
			vm:SetSubMaterial(nil, nil)
			for k, v in ipairs(wep.MaterialTable) do
				if not wep.MaterialCached[k] then
					wep.MaterialCached[k] = true
					vm:SetSubMaterial(k-1,v)
				end
			end
		end

		if not wep.RTMaterialOverride or not wep.RTCode then return end
		oldVmModel = vm:GetModel()
		local w, h = ScrW(), ScrH()
		local oldrt = render.GetRenderTarget()

		if not wep.RTOpaque then
			render.SetRenderTarget(TFA_RTScreen)
		else
			render.SetRenderTarget(TFA_RTScreenO)
		end

		render.Clear(0, 0, 0, 0, true, true)
		render.SetViewPort(0, 0, 512, 512)
		wep:RTCode(TFA_RTMat, w, h)
		render.SetRenderTarget(oldrt)
		render.SetViewPort(0, 0, w, h)

		if not wep.RTOpaque then
			TFA_RTMat:SetTexture("$basetexture", TFA_RTScreen)
		else
			TFA_RTMat:SetTexture("$basetexture", TFA_RTScreenO)
		end

		wep.Owner:GetViewModel():SetSubMaterial(wep.RTMaterialOverride, "!tfa_rtmaterial")
	end

	hook.Add("RenderScene", "TFASCREENS", TFARenderScreen)
end
