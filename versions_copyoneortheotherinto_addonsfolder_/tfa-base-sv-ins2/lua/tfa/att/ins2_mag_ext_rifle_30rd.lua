if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Extended Magazine"
ATTACHMENT.Description = {
	TFA.AttachmentColors["+"], "Increases magazine capacity to 30 rounds."
}
ATTACHMENT.Icon = "entities/ins2_att_mag_ext_rifle_30rd.png" --Revers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"
ATTACHMENT.ShortName = "MAG+"

local function checkSeqExists(wep, name)
	if not IsValid(wep) then return false end
	local owner = wep:GetOwner() or NULL
	if not wep:IsValid() then return false end
	local vm = owner:GetViewModel() or NULL
	if not vm:IsValid() then return false end
	local id = vm:LookupSequence(name)
	if id >= 0 then return true end
	return false
end

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["mag"] = {
			["active"] = false,
		},
		["mag_ext"] = {
			["active"] = true,
		}
	},
	["WElements"] = {
		["mag"] = {
			["active"] = false,
		},
		["mag_ext"] = {
			["active"] = true,
		}
	},
	["Animations"] = {
		["reload"] = function(wep, _val)
			local val = table.Copy(_val)
			if val.type == TFA.Enum.ANIMATION_SEQ then
				val.value = val.value .. "_ext"
			else
				val.type = TFA.Enum.ANIMATION_SEQ --Sequence or act
				val.value = "base_reload_ext"
			end
			return (checkSeqExists(wep, val.value) and val or _val), true, true
		end,
		["reload_empty"] = function(wep, _val)
			local val = table.Copy(_val)
			if val.type == TFA.Enum.ANIMATION_SEQ then
				val.value = val.value .. "_ext"
			else
				val.type = TFA.Enum.ANIMATION_SEQ --Sequence or act
				val.value = "base_reload_empty_ext"
			end
			return (checkSeqExists(wep, val.value) and val or _val), true, true
		end,
	},
	["Primary"] = {
		["ClipSize"] = function(wep, val)
			return wep.Primary.ClipSize_ExtRifle or 30
		end,
	},
}

function ATTACHMENT:Attach(wep)
	wep:Unload()
end

function ATTACHMENT:Detach(wep)
	wep:Unload()
end

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end
