local S = minetest.get_translator("landmine")

minetest.register_node("landmine:land_mine", {
    description = S("Landmine"),
    groups = {cracky = 3},
    tiles = {"landmine_buried.png"},
    inventory_image = "landmine_item.png",
    drawtype = "nodebox",
    paramtype2 = "facedir",
    paramtype = "light",
    node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, -0.45, 0.5}
    },
    sounds = default.node_sound_stone_defaults(),
    on_construct = function(pos)
        minetest.get_node_timer(pos):start(0.05)
    end,
    on_timer = function(pos, elapsed)
        local player_pos = nil
        local item_on_mine = false

        for _, player in ipairs(minetest.get_connected_players()) do
            local playerpos = player:get_pos()
            local playerpos_rounded = vector.round(playerpos)
            if playerpos_rounded.x == pos.x and playerpos_rounded.y == pos.y and playerpos_rounded.z == pos.z then
                player_pos = playerpos
                break
            end
        end

        if not player_pos then
            local objs = minetest.get_objects_inside_radius(pos, 0.5)
            for _, obj in ipairs(objs) do
                local entity = obj:get_luaentity()
                if entity and entity.name == "__builtin:item" then
                    item_on_mine = true
                    break
                end
            end
        end

        if player_pos or item_on_mine then
            minetest.after(0.05, function()
                tnt.boom(pos, {radius = 3, damage_radius = 10, explode_center = true})
            end)
            minetest.remove_node(pos)
        end

        return true
    end,
})

minetest.register_craft({
    output = "landmine:land_mine",
    recipe = {
        {"default:steel_ingot", "tnt:tnt", "default:steel_ingot"},
        {"default:tin_ingot", "default:copper_ingot", "default:tin_ingot"},
        {"default:steel_ingot", "tnt:tnt", "default:steel_ingot"},
    }
})
