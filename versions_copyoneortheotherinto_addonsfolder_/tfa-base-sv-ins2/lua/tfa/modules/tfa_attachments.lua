TFA.Attachments = TFA.Attachments or {}
TFA.Attachments.Atts = {}

TFA.Attachments.Colors = {
	["active"] = Color(252, 151, 50, 255),
	["error"] = Color(225, 0, 0, 255),
	["background"] = Color(15, 15, 15, 64),
	["primary"] = Color(245, 245, 245, 255),
	["secondary"] = Color(153, 253, 220, 255),
	["+"] = Color(128, 255, 128, 255),
	["-"] = Color(255, 128, 128, 255),
	["="] = Color(192, 192, 192, 255)
}

TFA.Attachments.UIPadding = 2
TFA.Attachments.Path = "tfa/att/"
TFA_ATTACHMENT_ISUPDATING = false

function TFARegisterAttachment(att)
	local base

	if att.Base then
		base = TFA.Attachments.Atts[att.Base]
	else
		base = TFA.Attachments.Atts["base"]
	end

	if base then
		for k, v in pairs(base) do
			if not att[k] then
				att[k] = v
			end
		end
	end

	TFA.Attachments.Atts[att.ID or att.Name] = att
end

function TFAUpdateAttachments()
	TFA.AttachmentColors = TFA.Attachments.Colors --for compatibility
	TFA.Attachments.Atts = {}
	TFA_ATTACHMENT_ISUPDATING = true
	local tbl = file.Find(TFA.Attachments.Path .. "*base*", "LUA", "namedesc")
	local addtbl = file.Find(TFA.Attachments.Path .. "*", "LUA", "namedesc")

	for _, v in ipairs(addtbl) do
		if not string.find(v, "base") then
			table.insert(tbl, #tbl + 1, v)
		end
	end

	for _, v in ipairs(tbl) do
		local id = v
		v = TFA.Attachments.Path .. v
		ATTACHMENT = {}
		ATTACHMENT.ID = string.Replace(id, ".lua", "")

		if SERVER then
			AddCSLuaFile(v)
			include(v)
		else
			include(v)
		end

		TFARegisterAttachment(ATTACHMENT)
		ATTACHMENT = nil
	end

	ProtectedCall(function()
		hook.Run("TFAAttachmentsLoaded")
	end)

	TFA_ATTACHMENT_ISUPDATING = false
end

hook.Add("InitPostEntity", "TFAUpdateAttachmentsIPE", TFAUpdateAttachments)

if TFAUpdateAttachments then
	TFAUpdateAttachments()
end