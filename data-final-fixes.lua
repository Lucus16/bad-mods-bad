local scales = {
        ["assembling-machine-2"] = 2,
        ["assembling-machine-3"] = 4,
        ["oil-refinery"] = 2,
        ["chemical-plant"] = 2,
        ["centrifuge"] = 2,
        ["electric-furnace"] = 2,
        ["lab"] = 1,
        ["pumpjack"] = 2,
        ["electric-mining-drill"] = 1,
        ["rocket-silo"] = 1,
        ["crusher"] = 1,
        ["big-mining-drill"] = 2,
        ["biochamber"] = 2,
        ["electromagnetic-plant"] = 2,
        ["foundry"] = 2,
        ["biolab"] = 2,
        ["cryogenic-plant"] = 4,
}

data.raw.technology["speed-module-2"] = nil
data.raw.technology["speed-module-3"] = nil
data.raw.technology["efficiency-module-2"] = nil
data.raw.technology["efficiency-module-3"] = nil
data.raw.technology["productivity-module-2"] = nil
data.raw.technology["productivity-module-3"] = nil
data.raw.technology["effect-transmission"] = nil
data.raw.technology["quality-module"] = nil
data.raw.technology["quality-module-2"] = nil
data.raw.technology["quality-module-3"] = nil
data.raw.technology["epic-quality"] = nil
data.raw.technology["legendary-quality"] = nil

for _, module in pairs(data.raw.module) do
        module.effect = {}
end

for key, entities in pairs(data.raw) do
        for entity_name, entity in pairs(entities) do
                if entity.module_slots then
                        entity.allowed_effects = {}
                        entity.module_slots = 0
                end
        end
end

local function show(prefix, key, value)
        print(prefix .. key .. ": " .. tostring(value))
        if type(value) == "table" then
                for k, v in pairs(value) do
                        show(prefix .. "  ", k, v)
                end
        end
end

local function scalePower(powerUsageString, factor)
        local number = tonumber(powerUsageString:match("%d+"))
        local scaledNumber = math.floor(number * factor)
        return scaledNumber .. powerUsageString:match("%a+")
end

local function scaleEntity(entity, factor)
        if not entity then
                return
        end
        if entity.energy_usage then
                entity.energy_usage = scalePower(entity.energy_usage, factor)
        end
        if entity.crafting_speed then
                entity.crafting_speed = entity.crafting_speed * factor
        end
        if entity.energy_source.emissions_per_minute then
                for emission_type, emission_value in pairs(entity.energy_source.emissions_per_minute) do
                        entity.energy_source.emissions_per_minute[emission_type] = emission_value * factor
                end
        end
        entity.max_health = entity.max_health * factor
end

local function scaleRecipe(recipe, factor)
        recipe.energy_required = (recipe.energy_required or 0.5) * factor
        for _, ingredient in pairs(recipe.ingredients) do
                local name = ingredient.name or ingredient[1]
                local adjusted_factor = math.floor(factor / (scales[name] or 1))
                if ingredient.amount then
                        ingredient.amount = ingredient.amount * adjusted_factor
                else
                        ingredient[2] = ingredient[2] * adjusted_factor
                end
        end
end

local enableBuildingScaling = settings.startup["bad-mods-bad-enable-building-scaling"].value

if enableBuildingScaling then
        for name, factor in pairs(scales) do
                scaleRecipe(data.raw["recipe"][name], factor)
                scaleEntity(data.raw["assembling-machine"][name], factor)
                scaleEntity(data.raw["furnace"][name], factor)
                scaleEntity(data.raw["lab"][name], factor)
                scaleEntity(data.raw["mining-drill"][name], factor)
                scaleEntity(data.raw["rocket-silo"][name], factor)
        end
end
