soldier = {}

function soldier:new(game)
    local object = {
        game = game,
    }
    setmetatable(object, { __index = soldier })
    return object
end

function soldier:interact()
    print "Hello soldier!"
end

soldier = soldier:new(game)
npcs["soldier"] = soldier