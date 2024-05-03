data.raw["recipe"]["beacon"] = nil
data.raw["technology"]["effect-transmission"] = nil

for _, module in pairs(data.raw["module"]) do
        module.effect = {}
end

for key, entities in pairs(data.raw) do
        for entity_name, entity in pairs(entities) do
                if entity.module_specification then
                        entity.allowed_effects = {}
                        entity.module_specification.module_slots = 0
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
        if entity.energy_usage then
                entity.energy_usage = scalePower(entity.energy_usage, factor)
        end
        if entity.crafting_speed then
                entity.crafting_speed = entity.crafting_speed * factor
        end
        if entity.energy_source.emissions_per_minute then
                entity.energy_source.emissions_per_minute = entity.energy_source.emissions_per_minute * factor
        end
        entity.max_health = entity.max_health * factor
end

local function scaleRecipe(recipe, factor)
        recipe.energy_required = (recipe.energy_required or 0.5) * factor
        for _, ingredient in pairs(recipe.ingredients) do
                ingredient[#ingredient] = ingredient[#ingredient] * factor
        end
end

scaleEntity(data.raw["mining-drill"]["pumpjack"], 2)
scaleRecipe(data.raw["recipe"]["pumpjack"].normal, 2)
scaleRecipe(data.raw["recipe"]["pumpjack"].expensive, 2)

scaleEntity(data.raw["assembling-machine"]["assembling-machine-2"], 2)
scaleRecipe(data.raw["recipe"]["assembling-machine-2"].normal, 2)
scaleRecipe(data.raw["recipe"]["assembling-machine-2"].expensive, 2)

scaleEntity(data.raw["assembling-machine"]["assembling-machine-3"], 4)
scaleRecipe(data.raw["recipe"]["assembling-machine-3"], 2)
