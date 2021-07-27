SWEP.Author = "Devon"
SWEP.Base = "weapon_base"
SWEP.PrintName = "Thermal Vision"

SWEP.Spawnable = true
SWEP.SetHoldType = "slam"
SWEP.UseHands = true 

SWEP.DrawAmmo = false 

SWEP.Slot = 1
SWEP.SlotPos = 0

SWEP.ShouldDropOnDie = false 

function SWEP:ShouldDrawViewModel()
    return false
end

function SWEP:Equip( owner )
    return owner
end

function SWEP:PrimaryAttack()
    
    return false

end

function SWEP:SecondaryAttack()
    
    self:GetOwner():SetNW2Bool("displayScreen", !self:GetOwner():GetNW2Bool("displayScreen"))
    
end