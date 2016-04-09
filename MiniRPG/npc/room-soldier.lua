soldier = {}

function soldier:new(game)
    local object = {
        game = game,
    }
    setmetatable(object, { __index = soldier })
    return object
end

function soldier:interact()
    if self.game:getMetaValueForKey("room_soldier_greeting") == "true" then
        self.game:npc_say("soldier","Please return her home safely.")
    else
        self.game:npc_say("soldier", "You must save the princess! She has been taken!")
        self.game:setMeta_forKey("true","room_soldier_greeting")
    end
end

soldier = soldier:new(game)
npcs["soldier"] = soldier