if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "MX4 Scope"
--ATTACHMENT.ID = "base" -- normally this is just your filename
ATTACHMENT.Description = { TFA.AttachmentColors["="], "8.7x zoom", TFA.AttachmentColors["-"], "40% higher zoom time",  TFA.AttachmentColors["-"], "10% slower aimed walking" }
ATTACHMENT.Icon = "entities/ins2_si_mx4.png" --Revers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"
ATTACHMENT.ShortName = "MX4"

ATTACHMENT.WeaponTable = {
	["VElements"] = {
		["rail_sights"] = {
			["active"] = true
		},
		["scope_mx4"] = {
			["active"] = function(wep, val) TFA.INS2.AnimateSight(wep) return true end,
			["ins2_sightanim_idle"] = "scope_idle",
			["ins2_sightanim_iron"] = "scope_zoom",
		},
		["sights_folded"] = {
			["active"] = false
		}
	},
	["WElements"] = {
		["rail_sights"] = {
			["active"] = true
		},
		["scope_mx4"] = {
			["active"] = true
		},
		["sights_folded"] = {
			["active"] = false
		}
	},
	["IronSightsPos"] = function( wep, val ) return wep.IronSightsPos_MX4 or val end,
	["IronSightsAng"] = function( wep, val ) return wep.IronSightsAng_MX4 or val end,
	["IronSightsSensitivity"] = function(wep,val)
		local res = val * wep:Get3DSensitivity( )
		return res, false, true
	end ,
	["Secondary"] = {
		["IronFOV"] = function( wep, val ) return wep.Secondary.IronFOV_MX4 or val * 0.9 end,
		["ScopeZoom"] = function( wep, val ) return 8.7 end
	},
	["IronSightTime"] = function( wep, val ) return val * 1.40 end,
	["IronSightMoveSpeed"] = function(stat) return stat * 0.9 end,
	["RTScopeFOV"] = function(wep, val) return (wep.RTScopeFOV_MX4 or wep:GetStat("Secondary.IronFOV")) / wep:GetStat("Secondary.ScopeZoom") / 2 end,
	["RTOpaque"] = -1,
	["RTMaterialOverride"] = -1,
	["INS2_SightVElement"] = "scope_mx4",
}

local shadowborder = 256

local cd = {}

local myshad
local debugcv = GetConVar("cl_tfa_debug_rt")

function ATTACHMENT:Attach(wep)
	if not IsValid(wep) then return end
	wep.RTCodeOld = wep.RTCodeOld or wep.RTCode
	wep.RTCode = function( myself , rt, scrw, scrh)
		if not IsValid(myself.Owner) then return end
		local rttw, rtth
		rttw = ScrW()
		rtth = ScrH()
		local att, ts
		if wep:VMIV() then
			att = wep.OwnerViewModel:GetAttachment( wep.RTAttachment_MX4 or 0 )
		end
		if att and att.Pos then
			if not wep.LastOwnerPos then
				wep.LastOwnerPos = wep.Owner:GetShootPos()
			end

			local owoff = wep.Owner:GetShootPos() - wep.LastOwnerPos
			wep.LastOwnerPos = wep.Owner:GetShootPos()
			local pos = att.Pos - owoff
			ts = pos:ToScreen()
		end
		if not myshad then
			myshad = Material( "vgui/scope_shadowmask_test")
		end

		local ang = IsValid(myself.OwnerViewModel) and myself.OwnerViewModel:GetAngles() or myself.Owner:EyeAngles()
		if wep.ScopeAngleTransforms_MX4 then
			ang:RotateAroundAxis(ang:Right(), wep.ScopeAngleTransforms_MX4.p )
			ang:RotateAroundAxis(ang:Up(), wep.ScopeAngleTransforms_MX4.y )
			ang:RotateAroundAxis(ang:Forward(), wep.ScopeAngleTransforms_MX4.r )
		end
		cd.angles = ang
		cd.origin = myself.Owner:GetShootPos()
		cd.x = 0
		cd.y = 0
		cd.w = rttw
		cd.h = rtth
		cd.fov = wep:GetStat("RTScopeFOV")
		cd.drawviewmodel = false
		cd.drawhud = false
		render.Clear(0, 0, 0, 255, true, true)
		if myself.CLIronSightsProgress > 0.005 then
			render.RenderView(cd)
		end
		cam.Start2D()
		if ts then
			local scrpos = ts

			scrpos.x = scrpos.x / scrw
			scrpos.y = scrpos.y / scrh

			scrpos.x = scrpos.x - 0.5
			scrpos.y = scrpos.y - 0.5
			if wep.ScopeOverlayTransforms_MX4 then
				scrpos.x = scrpos.x + wep.ScopeOverlayTransforms_MX4[1]
				scrpos.y = scrpos.y + wep.ScopeOverlayTransforms_MX4[2]
			end
			scrpos.x = scrpos.x * rttw
			scrpos.y = scrpos.y * rtth
			scrpos.x = math.Clamp(scrpos.x, -1024, 1024)
			scrpos.y = math.Clamp(scrpos.y, -1024, 1024)

			if wep.ScopeOverlayTransformMultiplier_MX4 then
				scrpos.x = scrpos.x * wep.ScopeOverlayTransformMultiplier_MX4
				scrpos.y = scrpos.y * wep.ScopeOverlayTransformMultiplier_MX4
			end

			if not self.scrpos then
				self.scrpos = scrpos
			end

			self.scrpos.x = math.Approach(self.scrpos.x, scrpos.x, (scrpos.x - self.scrpos.x) * FrameTime() * 10)
			self.scrpos.y = math.Approach(self.scrpos.y, scrpos.y, (scrpos.y - self.scrpos.y) * FrameTime() * 10)
			scrpos = self.scrpos

			local rtow, rtoh = 0, 0
			if wep.RTScopeOffset_MX4 then
				rtow = self.RTScopeOffset_MX4[1] * rttw
				rtoh = self.RTScopeOffset_MX4[2] * rtth
			end
			local rtw, rth = rttw * 1, rtth * 1
			if self.RTScopeScale_MX4 then
				rtw = rtw * self.RTScopeScale_MX4[1]
				rth = rth * self.RTScopeScale_MX4[2]
			end
			local distfac = math.pow( 1 - math.Clamp( ( att.Pos:Distance( wep.Owner:GetShootPos() ) - ( wep.ScopeDistanceMin_MX4 or 4 ) ) / ( wep.ScopeDistanceRange_MX4 or 10 ), 0, 1 ), 1 )
			rtw = Lerp( distfac, rtw * 0.1, rtw * 2 )
			rth = Lerp( distfac, rth * 0.1, rth * 2 )
			local cpos = Vector( -scrpos.x + rttw / 2, -scrpos.y + rtth / 2, 0 )
			cpos.x = math.Round(cpos.x)
			cpos.y = math.Round(cpos.y)

			surface.SetMaterial(myshad)
			surface.SetDrawColor(color_white)
			if debugcv and debugcv:GetBool() then
				surface.DrawTexturedRect( rttw / 2 - rtw / 2 + rtow, rtth / 2 - rth / 2 + rtoh, rtw, rth)
			else
				surface.DrawTexturedRect( cpos.x - rtw / 2, cpos.y - rth / 2, rtw, rth )

				surface.SetDrawColor(color_black)
				surface.DrawRect( cpos.x - rtw / 2 - 2047, cpos.y - 1024, 2048, 2048)
				surface.DrawRect( cpos.x + rtw / 2 - 1, cpos.y - 1024, 2048, 2048)
				surface.DrawRect( cpos.x - 1024, cpos.y - rtw / 2 - 2047, 2048, 2048)
				surface.DrawRect( cpos.x - 1024, cpos.y + rtw / 2 - 1, 2048, 2048)
			end
		else
			surface.SetMaterial(myshad)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(-shadowborder, -shadowborder, shadowborder * 2 + rttw , shadowborder * 2 + rtth )
		end
		surface.SetDrawColor(ColorAlpha(color_black, 255 * (1 - myself.CLIronSightsProgress)))
		surface.DrawRect(0, 0, scrw, scrh)
		cam.End2D()
	end
end

function ATTACHMENT:Detach(wep)
	if not IsValid(wep) then return end
	wep.RTCode = wep.RTCodeOld
	wep.RTCodeOld = nil
end

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end
