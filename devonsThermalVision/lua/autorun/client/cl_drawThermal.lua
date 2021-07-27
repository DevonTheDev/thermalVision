local entityTable = {}
local cloakedPlayers = {}

if not ConVarExists("thermal_vision_walls") then
	CreateClientConVar("thermal_vision_walls", "0", false, false, "To see entities through walls while using thermal vision.")
end

if not ConVarExists("thermal_vision_range") then
	CreateClientConVar("thermal_vision_range", "0", true, false, "Maximum range of thermal vision.")
end

hook.Add("EntityNetworkedVarChanged", "checkForOurs", function(ent, name, oldval, newval)

    if(name == "displayScreen") then
        if LocalPlayer():GetNW2Bool("displayScreen") == true then -- If the network bool is true (IE the screen should be displayed)

            surface.PlaySound("thermal_activate.wav")

            hook.Add("PreDrawViewModel", "ThermalVisionViewmodelColorON", function()
				render.SetColorModulation(0, 0, 1)
			end)

            hook.Add("PostDrawTranslucentRenderables", "thermalEffect", function()
            local TMWalls = GetConVar("thermal_vision_walls"):GetInt()
            local TMRange = math.abs(GetConVar("thermal_vision_range"):GetInt())
            
            local cur_pos_player = LocalPlayer():GetPos()
            local cur_pos_eyes = LocalPlayer():EyePos()+LocalPlayer():EyeAngles():Forward()*4.5
            local cur_ang_eyes = LocalPlayer():EyeAngles()
            cur_ang_eyes = Angle(cur_ang_eyes.p+90, cur_ang_eyes.y, 0)
            
            local extraGlowEnts = {}
            render.ClearStencil() -- Resets all values to zero
            render.SetStencilEnable(true)
                render.SetStencilWriteMask(255)
                render.SetStencilTestMask(255)
                render.SetStencilReferenceValue(1)
                
                for _, ent in pairs(ents.GetAll()) do -- For every player
                    if (ent:IsPlayer() or ent:IsNPC()) then -- If they are a player or NPC
                        if (ent == LocalPlayer()) then -- If they are the local player
                            if (!ent:Alive()) then -- If they are not alive then remove the thermal vision
                                ThermalVisionActive = false 
                                hook.Remove("PreDrawViewModel", "ThermalVisionViewmodelColorON")
                                hook.Remove("PostDrawTranslucentRenderables", "ThermalVisionToggleON")
                                return
                            end
                        else -- If the entity isnt the local player
                            if TMRange != 0 then -- If the thermal vision range isnt 0
                                if (ent:GetPos():DistToSqr(cur_pos_player) > TMRange) then continue end -- If the target entity is within the thermal vision range
                            end
                            
                            render.SetStencilCompareFunction(STENCIL_ALWAYS)
                            if (TMWalls == 1) then
                                render.SetStencilZFailOperation(STENCIL_REPLACE)
                            else
                                render.SetStencilZFailOperation(STENCIL_KEEP)
                            end
                            
                            render.SetStencilPassOperation(STENCIL_REPLACE)
                            render.SetStencilFailOperation(STENCIL_KEEP)
                            ent:DrawModel()
                            
                            render.SetStencilCompareFunction(STENCIL_EQUAL)
                            render.SetStencilZFailOperation(STENCIL_KEEP)
                            render.SetStencilPassOperation(STENCIL_KEEP)
                            render.SetStencilFailOperation(STENCIL_KEEP)
                            
                            cam.Start3D2D(cur_pos_eyes, cur_ang_eyes, 1)
                                surface.SetDrawColor(255, 255, 35, 255)
                                surface.DrawRect(-ScrW(), -ScrH(), ScrW()*2, ScrH()*2)
                            cam.End3D2D()
                            table.insert(entityTable, ent)
                        end
                    end
                end
                
                if (TMWalls == 1) then
                    halo.Add(extraGlowEnts, Color(255, 0, 0), 1, 1, 1, true, true)
                else
                    halo.Add(extraGlowEnts, Color(255, 0, 0), 1, 1, 1, true, false)
                end
                
                render.SetStencilCompareFunction(STENCIL_NOTEQUAL)
                render.SetStencilZFailOperation(STENCIL_KEEP)
                render.SetStencilPassOperation(STENCIL_KEEP)
                render.SetStencilFailOperation(STENCIL_KEEP)
                
                cam.Start3D2D(cur_pos_eyes, cur_ang_eyes, 1)
                    surface.SetDrawColor(0, 0, 150, 220)
                    surface.DrawRect(-ScrW(), -ScrH(), ScrW()*2, ScrH()*2)
                cam.End3D2D()
            render.SetStencilEnable(false)
                
           end)
        else

            surface.PlaySound("thermal_deactivate.mp3")

            hook.Remove("PreDrawViewModel", "ThermalVisionViewmodelColorON")
			hook.Remove("PostDrawTranslucentRenderables", "thermalEffect")
        end
    end
    
end)