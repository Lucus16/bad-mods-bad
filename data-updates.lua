local scales = {
        ["assembling-machine-2"] = 2,
        ["assembling-machine-3"] = 4,
        ["chemical-plant"] = 2,
        ["electric-furnace"] = 2,
        ["oil-refinery"] = 2,
        ["pumpjack"] = 2,
}

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
                entity.energy_source.emissions_per_minute = entity.energy_source.emissions_per_minute * factor
        end
        entity.max_health = entity.max_health * factor
end

local function scaleRecipe(recipe, factor)
        if recipe.normal and recipe.expensive then
                scaleRecipe(recipe.normal, factor)
                scaleRecipe(recipe.expensive, factor)
        else
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
end

local enableBuildingScaling = settings.startup["bad-mods-bad-enable-building-scaling"].value

if enableBuildingScaling then
        for name, factor in pairs(scales) do
                scaleRecipe(data.raw["recipe"][name], factor)
                scaleEntity(data.raw["assembling-machine"][name], factor)
                scaleEntity(data.raw["furnace"][name], factor)
                scaleEntity(data.raw["mining-drill"][name], factor)
        end
end
