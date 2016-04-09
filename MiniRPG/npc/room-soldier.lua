soldier = {}

function soldier:new(game)
    local object = {
        game = game,
    }
    setmetatable(object, { __index = soldier })
    return object
end

function soldier:interact()
self.game:npc_say("soldier", "please, save the princess!")
end

soldier = soldier:new(game)
npcs["soldier"] = soldier