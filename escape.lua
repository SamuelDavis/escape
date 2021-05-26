-- main
CENTER = 64
LEFT, RIGHT, UP, DOWN, FIRE1, FIRE2 = 0, 1, 2, 3, 4, 5
BLACK, DARK_BLUE, DARK_PURPLE, DARK_GREEN, BROWN, DARK_GRAY, LIGHT_GRAY, WHITE, RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, PINK, PEACH =
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15

WEST, EAST, NORTH, SOUTH = 1, 2, 3, 4
NORTHWEST, SOUTHWEST, NORTHEAST, SOUTHEAST = 17, 18, 19, 20
EXIT = 16
DELTA = {[LEFT] = {-1, 0}, [RIGHT] = {1, 0}, [UP] = {0, -1}, [DOWN] = {0, 1}}
EXITS = {
    [LEFT] = {WEST, NORTHWEST, SOUTHWEST},
    [RIGHT] = {EAST, NORTHEAST, SOUTHEAST},
    [UP] = {NORTH, NORTHWEST, NORTHEAST},
    [DOWN] = {SOUTH, SOUTHWEST, SOUTHEAST}
}

_UPDATE = function() end
_DRAW = function() end
PLAYER = {-1, -1}
SEEN = {}

function _init()
    mset(0, 1, NORTH)
    mset(0, 0, SOUTHEAST)
    mset(1, 0, SOUTHWEST)
    mset(1, 1, NORTHEAST)
    mset(2, 1, SOUTHWEST)
    mset(2, 2, NORTHWEST)
    mset(1, 2, EXIT)

    PLAYER = {0, 1}
    see(unpack(PLAYER))

    _UPDATE = game_update
    _DRAW = game_draw

    camera(-(CENTER / 2), -(CENTER / 2))
end

function _update() _UPDATE() end

function _draw() _DRAW() end
-- >8
-- game
function game_update()
    local current_tile = mget(unpack(PLAYER))

    if current_tile == EXIT then
        camera(0, 0)
        _UPDATE = noop
        _DRAW = win_draw
        return
    end

    local direction = get_direction(EXITS)
    if direction == nil then return end

    if not is_exit(direction, current_tile) then return end

    local target_position = get_target(PLAYER, DELTA[direction])
    if mget(unpack(target_position)) == nil then return end

    PLAYER[1], PLAYER[2] = unpack(target_position)
    see(unpack(PLAYER))
end
function game_draw()
    cls()
    for i, value in ipairs(SEEN) do
        local x, y = unpack(value)
        local sprite = mget(x, y)
        if sprite == EXIT then
            pal()
        elseif i == #SEEN then
            pal(RED, YELLOW)
            pal(GREEN, DARK_GRAY)
            pal(BLUE, INDIGO)
        elseif i == #SEEN - 1 then
            pal(RED, LIGHT_GRAY)
            pal(GREEN, DARK_GRAY)
            pal(BLUE, DARK_BLUE)
        else
            pal(RED, LIGHT_GRAY)
            pal(GREEN, DARK_GRAY)
            pal(BLUE, BLACK)
        end
        spr(sprite, x * 8, y * 8)
    end
    x, y = unpack(PLAYER)
    spr(mget(x, y), x * 8, y * 8)
    pal()
end
function win_draw()
    local text = "win"
    local text_width, text_height = #text * 4, 4;
    local offset_x, offset_y = text_width, text_height
    rectfill(CENTER - offset_x, CENTER - offset_y, CENTER + offset_x,
             CENTER + offset_y, BLACK)
    rect(CENTER - offset_x, CENTER - offset_y, CENTER + offset_x,
         CENTER + offset_y, WHITE)
    print(text, CENTER - text_width / 2, CENTER - text_height / 2, WHITE)
end
-- >8
-- util
function noop() end
function see(x, y) SEEN[#SEEN + 1] = {x, y} end
function tbl_eql(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return nil end

    for key, value in pairs(a) do if value ~= b[key] then return false end end

    return true
end

function get_direction(directions)
    for direction in pairs(directions) do
        if btnp(direction) then return direction end
    end
    return nil
end

function is_exit(direction, tile)
    for _, value in pairs(EXITS[direction] or {}) do
        if tile == value then return true end
    end

    return false
end

function get_target(start, delta)
    return {start[1] + delta[1], start[2] + delta[2]}
end
