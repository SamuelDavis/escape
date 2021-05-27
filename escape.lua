-- main
LEFT, RIGHT, UP, DOWN, FIRE1, FIRE2 = 0, 1, 2, 3, 4, 5
BLACK, DARK_BLUE, DARK_PURPLE, DARK_GREEN, BROWN, DARK_GRAY, LIGHT_GRAY, WHITE, RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, PINK, PEACH =
    0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
DIRECTIONS = {LEFT, RIGHT, UP, DOWN}
TEXT_WIDTH, TEXT_HEIGHT = 4, 6
CENTER = 64

function _init()
    _STATE = {
        rooms = {
            {[DOWN] = 3, [RIGHT] = 2}, {[DOWN] = 4, [LEFT] = 1},
            {[UP] = 1, [RIGHT] = 4}, true
        },
        history = {1},
        choice = nil
    }
    _DRW = DRAW_GAME
    _UPD = UPDATE_GAME
end

function _update() _UPD(_STATE) end

function _draw() _DRW(_STATE) end
-- >
-- draw
function DRAW_GAME(state)
    local room = state.history[#state.history]
    local exits = state.rooms[room]
    if exits == true then return end

    local text = "room" .. room .. ", exits are: "
    cls(INDIGO)
    print(text, 1, 1, WHITE)
    local i = 0
    for direction in pairs(exits) do
        local color = direction == state.choice and YELLOW or WHITE
        direction = DIRECTION_TO_STRING(direction) .. " "
        print(direction, #text * TEXT_WIDTH + #direction * TEXT_WIDTH * i + 1,
              1, color)
        i = i + 1
    end

    for k, v in pairs(state.history) do
        print(v, 1, 128 - TEXT_HEIGHT * k, WHITE)
    end
end
function DRAW_WIN()
    local text = "you escaped"
    print(text, CENTER - #text / 2 - 1, CENTER, YELLOW)
end
-- >
-- update
function UPDATE_GAME(state)
    local room = state.history[#state.history]
    local exits = state.rooms[room]
    for _, button in pairs(DIRECTIONS) do
        if exits == true then
            _UPD = NOOP
            _DRW = DRAW_WIN
        elseif btnp(button) and exits[button] ~= nil then
            if button == state.choice then
                state.choice = nil
                state.history[#state.history + 1] = exits[button]
            else
                state.choice = button
            end
            return
        end
    end
end
-- >
-- util
function DIRECTION_TO_STRING(direction)
    if direction == LEFT then
        return "L"
    elseif direction == RIGHT then
        return "R"
    elseif direction == UP then
        return "U"
    elseif direction == DOWN then
        return "D"
    end
    return nil
end

local function navigate(rooms, history)
    local room = history[#history]
    local doors = rooms[room]

    if doors == true then return print("Congratulations, you reached room4!") end

    print(room .. ", exits are:")
    for key in pairs(doors) do print(".." .. key) end

    io.write("Your move: ")
    io.flush()
    local move = io.read()
    local next = doors[move]

    if next == nil then
        print("invalid move: " .. move)
    else
        history[#history + 1] = next
    end

    return navigate(rooms, history)
end

function NOOP() end
