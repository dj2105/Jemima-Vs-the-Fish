local GAME_W, GAME_H = 640, 480
local TURN_LIMIT = 12 -- temporary tuning value; not yet a final design decision
local ROUTE_LEN = 4
local MIN_NODES, MAX_NODES = 25, 30

local BUTTONS = { "a", "b", "x", "y" }
local BUTTON_COLOURS = {
    a = { 0.20, 0.85, 0.35 },
    b = { 0.95, 0.25, 0.25 },
    x = { 0.25, 0.55, 1.00 },
    y = { 1.00, 0.82, 0.20 },
}

local graph
local phase
local fishNode
local fishTurnStart
local hiddenNode
local routeNodes
local routeButtons
local pounceNode
local cursor = { x = GAME_W / 2, y = GAME_H / 2 }
local selectedNode
local currentTurn
local revealStep
local revealTimer
local revealFishNode
local resultText
local resultKind
local controller
local fontSmall, fontNormal, fontLarge

local function copyArray(t)
    local out = {}
    for i = 1, #t do out[i] = t[i] end
    return out
end

local function shuffle(t)
    for i = #t, 2, -1 do
        local j = love.math.random(i)
        t[i], t[j] = t[j], t[i]
    end
end

local function distanceSquared(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return dx * dx + dy * dy
end

local function orientation(a, b, c)
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
end

local function segmentsCross(a, b, c, d)
    local o1 = orientation(a, b, c)
    local o2 = orientation(a, b, d)
    local o3 = orientation(c, d, a)
    local o4 = orientation(c, d, b)
    return (o1 * o2 < 0) and (o3 * o4 < 0)
end

local function newNode(x, y)
    return {
        x = x,
        y = y,
        edges = {},
        moves = {},
        status = "active", -- active, destroyed, discarded
    }
end

local function degree(g, i, activeOnly)
    local n = g.nodes[i]
    local count = 0
    for _, edgeIndex in ipairs(n.edges) do
        local e = g.edges[edgeIndex]
        local other = (e.a == i) and e.b or e.a
        if not activeOnly or g.nodes[other].status == "active" then
            count = count + 1
        end
    end
    return count
end

local function edgeExists(g, a, b)
    for _, e in ipairs(g.edges) do
        if (e.a == a and e.b == b) or (e.a == b and e.b == a) then
            return true
        end
    end
    return false
end

local function edgeWouldCross(g, a, b)
    local na, nb = g.nodes[a], g.nodes[b]
    for _, e in ipairs(g.edges) do
        if e.a ~= a and e.a ~= b and e.b ~= a and e.b ~= b then
            if segmentsCross(na, nb, g.nodes[e.a], g.nodes[e.b]) then
                return true
            end
        end
    end
    return false
end

local function addEdge(g, a, b)
    if a == b or edgeExists(g, a, b) then return false end
    if degree(g, a, false) >= 4 or degree(g, b, false) >= 4 then return false end
    if edgeWouldCross(g, a, b) then return false end

    local e = { a = a, b = b, buttonA = nil, buttonB = nil }
    table.insert(g.edges, e)
    local idx = #g.edges
    table.insert(g.nodes[a].edges, idx)
    table.insert(g.nodes[b].edges, idx)
    return true
end

local function countDegreeType(g, wanted)
    local count = 0
    for i = 1, #g.nodes do
        if degree(g, i, false) == wanted then count = count + 1 end
    end
    return count
end

local function countJunctions(g)
    local count = 0
    for i = 1, #g.nodes do
        if degree(g, i, false) >= 3 then count = count + 1 end
    end
    return count
end

local function placeNodes(n)
    local nodes = {}
    local minDist2 = 42 * 42
    local attempts = 0

    while #nodes < n and attempts < 12000 do
        attempts = attempts + 1
        local candidate = newNode(love.math.random(48, 592), love.math.random(82, 398))
        local okay = true
        for _, existing in ipairs(nodes) do
            if distanceSquared(candidate, existing) < minDist2 then
                okay = false
                break
            end
        end
        if okay then table.insert(nodes, candidate) end
    end

    if #nodes ~= n then return nil end
    return nodes
end

local function connectSpanningTree(g)
    local n = #g.nodes
    local connected = { [1] = true }
    local connectedCount = 1

    while connectedCount < n do
        local bestA, bestB, bestD
        for a = 1, n do
            if connected[a] and degree(g, a, false) < 4 then
                for b = 1, n do
                    if not connected[b] then
                        local d = distanceSquared(g.nodes[a], g.nodes[b])
                        if (not bestD or d < bestD) and not edgeWouldCross(g, a, b) then
                            bestA, bestB, bestD = a, b, d
                        end
                    end
                end
            end
        end

        if not bestA or not addEdge(g, bestA, bestB) then
            return false
        end
        connected[bestB] = true
        connectedCount = connectedCount + 1
    end

    return true
end

local function candidateEdges(g, mode)
    local candidates = {}
    local n = #g.nodes

    for a = 1, n - 1 do
        local da = degree(g, a, false)
        if da < 4 then
            for b = a + 1, n do
                local db = degree(g, b, false)
                if db < 4 and not edgeExists(g, a, b) and not edgeWouldCross(g, a, b) then
                    local d2 = distanceSquared(g.nodes[a], g.nodes[b])
                    if d2 <= 180 * 180 then
                        local score = d2
                        if mode == "leaves" then
                            if da == 1 then score = score - 5000 end
                            if db == 1 then score = score - 5000 end
                        elseif mode == "junctions" then
                            if da == 2 then score = score - 3500 end
                            if db == 2 then score = score - 3500 end
                        end
                        table.insert(candidates, { a = a, b = b, score = score })
                    end
                end
            end
        end
    end

    table.sort(candidates, function(left, right) return left.score < right.score end)
    return candidates
end

local function chooseAndAddCandidate(g, mode)
    local candidates = candidateEdges(g, mode)
    if #candidates == 0 then return false end
    local pick = love.math.random(math.min(10, #candidates))
    local c = candidates[pick]
    return addEdge(g, c.a, c.b)
end

local function assignButtons(g)
    for i, node in ipairs(g.nodes) do
        node.moves = {}
        local labels = copyArray(BUTTONS)
        shuffle(labels)
        for slot, edgeIndex in ipairs(node.edges) do
            local e = g.edges[edgeIndex]
            local button = labels[slot]
            local other
            if e.a == i then
                e.buttonA = button
                other = e.b
            else
                e.buttonB = button
                other = e.a
            end
            node.moves[button] = other
        end
    end
end

local function buildGraphOnce()
    local n = love.math.random(MIN_NODES, MAX_NODES)
    local nodes = placeNodes(n)
    if not nodes then return nil end

    local g = { nodes = nodes, edges = {} }
    if not connectSpanningTree(g) then return nil end

    local targetDeadEnds = math.max(2, math.floor(n * 0.10 + 0.5))
    local targetJunctions = math.max(7, math.floor(n * 0.28 + 0.5))

    local safety = 0
    while countDegreeType(g, 1) > targetDeadEnds and safety < 30 do
        safety = safety + 1
        if not chooseAndAddCandidate(g, "leaves") then break end
    end

    safety = 0
    while countJunctions(g) < targetJunctions and safety < 35 do
        safety = safety + 1
        if not chooseAndAddCandidate(g, "junctions") then break end
    end

    local starts = {}
    for i = 1, n do
        local d = degree(g, i, false)
        if d == 3 or d == 4 then table.insert(starts, i) end
    end

    if #starts == 0 then return nil end
    if countDegreeType(g, 1) > 5 then return nil end

    assignButtons(g)
    g.startNode = starts[love.math.random(#starts)]
    return g
end

local function generateGraph()
    for _ = 1, 60 do
        local g = buildGraphOnce()
        if g then return g end
    end
    error("Could not generate a valid map")
end

local function activeMove(fromNode, button)
    local to = graph.nodes[fromNode].moves[button]
    if to and graph.nodes[to].status == "active" then
        return to
    end
    return nil
end

local function nearestActiveNode(x, y)
    local best, bestD
    for i, node in ipairs(graph.nodes) do
        if node.status == "active" then
            local dx, dy = node.x - x, node.y - y
            local d = dx * dx + dy * dy
            if not bestD or d < bestD then
                best, bestD = i, d
            end
        end
    end
    return best
end

local function markDisconnectedFromFish()
    local reachable = {}
    local queue = { fishNode }
    local head = 1
    reachable[fishNode] = true

    while head <= #queue do
        local current = queue[head]
        head = head + 1
        local node = graph.nodes[current]
        for _, edgeIndex in ipairs(node.edges) do
            local e = graph.edges[edgeIndex]
            local other = (e.a == current) and e.b or e.a
            if graph.nodes[other].status == "active" and not reachable[other] then
                reachable[other] = true
                table.insert(queue, other)
            end
        end
    end

    for i, node in ipairs(graph.nodes) do
        if node.status == "active" and not reachable[i] then
            node.status = "discarded"
        end
    end
end

local function destroyNode(i)
    graph.nodes[i].status = "destroyed"
    markDisconnectedFromFish()
end

local function startFishTurn()
    phase = "fish"
    fishTurnStart = fishNode
    hiddenNode = fishNode
    routeNodes = { fishNode }
    routeButtons = {}
    pounceNode = nil
    selectedNode = nil
    resultText = nil
    resultKind = nil
end

local function newGame()
    graph = generateGraph()
    fishNode = graph.startNode
    currentTurn = 1
    cursor.x, cursor.y = GAME_W / 2, GAME_H / 2
    startFishTurn()
end

local function finishTurnResolution()
    local finalNode = routeNodes[ROUTE_LEN + 1]
    fishNode = finalNode

    -- Full catch always has priority, even if this node was visited earlier.
    if pounceNode == finalNode then
        resultKind = "full"
        resultText = "FULL CATCH! Jemima wins."
        phase = "gameover"
        return
    end

    local brief = false
    for i = 2, ROUTE_LEN do -- only the three intermediate nodes
        if routeNodes[i] == pounceNode then
            brief = true
            break
        end
    end

    if brief then
        resultKind = "brief"
        resultText = "BRIEF CATCH! That node is destroyed."
        destroyNode(pounceNode) -- destruction happens only after all four route steps

        if degree(graph, fishNode, true) == 0 then
            resultKind = "stalemate"
            resultText = "STALEMATE! Jemima stranded the Fish. Lesser Fish victory."
            phase = "gameover"
            return
        end
    else
        resultKind = "miss"
        resultText = "MISS. The Fish gets away."
    end

    if currentTurn >= TURN_LIMIT then
        resultKind = "fishwin"
        resultText = "TURN LIMIT REACHED! The Fish escapes."
        phase = "gameover"
        return
    end

    phase = "result"
end

local function confirmJemimaPounce()
    if not selectedNode then return end
    pounceNode = selectedNode
    phase = "reveal"
    revealStep = 0
    revealTimer = 0
    revealFishNode = fishTurnStart
end

local function inputFishButton(button)
    if phase ~= "fish" then return end
    local nextNode = activeMove(hiddenNode, button)
    if not nextNode then return end

    hiddenNode = nextNode
    table.insert(routeButtons, button)
    table.insert(routeNodes, nextNode)

    if #routeButtons == ROUTE_LEN then
        phase = "jemima"
        cursor.x, cursor.y = graph.nodes[fishTurnStart].x, graph.nodes[fishTurnStart].y
        selectedNode = nearestActiveNode(cursor.x, cursor.y)
    end
end

local function getScale()
    local w, h = love.graphics.getDimensions()
    local s = math.min(w / GAME_W, h / GAME_H)
    local ox = (w - GAME_W * s) / 2
    local oy = (h - GAME_H * s) / 2
    return s, ox, oy
end

local function setColour(c, alpha)
    love.graphics.setColor(c[1], c[2], c[3], alpha or 1)
end

local function drawEdge(e)
    local a, b = graph.nodes[e.a], graph.nodes[e.b]
    local active = a.status == "active" and b.status == "active"

    if active then
        local mx, my = (a.x + b.x) / 2, (a.y + b.y) / 2

        -- Every connection is exactly two colours: the half touching each
        -- node tells the Fish which face button selects that path there.
        love.graphics.setLineWidth(7)
        love.graphics.setColor(0.03, 0.04, 0.05, 0.95)
        love.graphics.line(a.x, a.y, b.x, b.y)

        love.graphics.setLineWidth(4)
        setColour(BUTTON_COLOURS[e.buttonA])
        love.graphics.line(a.x, a.y, mx, my)
        setColour(BUTTON_COLOURS[e.buttonB])
        love.graphics.line(mx, my, b.x, b.y)
    else
        love.graphics.setLineWidth(2)
        love.graphics.setColor(0.48, 0.50, 0.52, 0.12)
        love.graphics.line(a.x, a.y, b.x, b.y)
    end
end

local function drawNode(i, node)
    if node.status == "discarded" then
        love.graphics.setColor(0.42, 0.44, 0.46, 0.22)
        love.graphics.circle("fill", node.x, node.y, 7)
        return
    elseif node.status == "destroyed" then
        love.graphics.setColor(0.90, 0.20, 0.20, 0.35)
        love.graphics.circle("line", node.x, node.y, 8)
        love.graphics.line(node.x - 6, node.y - 6, node.x + 6, node.y + 6)
        love.graphics.line(node.x + 6, node.y - 6, node.x - 6, node.y + 6)
        return
    end

    love.graphics.setColor(0.10, 0.11, 0.12, 1)
    love.graphics.circle("fill", node.x, node.y, 8)
    love.graphics.setColor(0.95, 0.95, 0.93, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", node.x, node.y, 8)

    if i == fishTurnStart and (phase == "fish" or phase == "jemima") then
        love.graphics.setColor(0.20, 0.90, 0.90, 0.95)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", node.x, node.y, 13)
    end
end

local function drawRouteTrail()
    if phase ~= "reveal" and phase ~= "gameover" and phase ~= "result" then return end
    if not routeNodes or #routeNodes < 2 then return end

    local maxSegment = math.min(revealStep or ROUTE_LEN, ROUTE_LEN)
    if phase == "result" or phase == "gameover" then maxSegment = ROUTE_LEN end

    love.graphics.setColor(0.20, 0.90, 0.90, 0.45)
    love.graphics.setLineWidth(3)
    for step = 1, maxSegment do
        local a = graph.nodes[routeNodes[step]]
        local b = graph.nodes[routeNodes[step + 1]]
        love.graphics.line(a.x, a.y, b.x, b.y)
    end
end

local function drawFishMarker()
    local nodeIndex
    if phase == "reveal" then
        nodeIndex = revealFishNode
    else
        nodeIndex = fishNode
    end
    if phase == "fish" or phase == "jemima" then
        nodeIndex = fishTurnStart
    end
    if not nodeIndex then return end

    local n = graph.nodes[nodeIndex]
    love.graphics.setColor(0.15, 0.85, 0.92, 1)
    love.graphics.circle("fill", n.x, n.y, 5)
end

local function drawPounce()
    if not pounceNode then return end
    local n = graph.nodes[pounceNode]
    love.graphics.setColor(1.00, 0.35, 0.72, 0.95)
    love.graphics.setLineWidth(3)
    love.graphics.circle("line", n.x, n.y, 15)
    love.graphics.line(n.x - 10, n.y, n.x + 10, n.y)
    love.graphics.line(n.x, n.y - 10, n.x, n.y + 10)
end

local function drawJemimaCursor()
    if phase ~= "jemima" then return end
    if selectedNode then
        local n = graph.nodes[selectedNode]
        love.graphics.setColor(1.00, 0.35, 0.72, 0.80)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", n.x, n.y, 13)
    end

    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.setLineWidth(1)
    love.graphics.circle("line", cursor.x, cursor.y, 4)
end

local function drawButtonLegend()
    love.graphics.setFont(fontSmall)
    local x = 404
    local y = 448
    love.graphics.setColor(0.8, 0.82, 0.84, 1)
    love.graphics.print("PATH COLOURS:", x, y)
    x = x + 88
    for _, button in ipairs(BUTTONS) do
        setColour(BUTTON_COLOURS[button])
        love.graphics.circle("fill", x, y + 6, 5)
        love.graphics.setColor(0.92, 0.92, 0.92, 1)
        love.graphics.print(string.upper(button), x + 8, y)
        x = x + 34
    end
end

local function drawHud()
    love.graphics.setFont(fontNormal)
    love.graphics.setColor(0.94, 0.94, 0.92, 1)
    love.graphics.print("JEMIMA vs THE FISH", 18, 14)

    love.graphics.setFont(fontSmall)
    love.graphics.setColor(0.68, 0.72, 0.76, 1)
    love.graphics.print("Turn " .. currentTurn .. " / " .. TURN_LIMIT, 520, 18)

    local message
    if phase == "fish" then
        message = "FISH: secretly enter 4 valid A/B/X/Y moves. The route stays hidden."
    elseif phase == "jemima" then
        message = "JEMIMA: move the cursor with D-pad/arrows. A/Enter pounces on the highlighted node."
    elseif phase == "reveal" then
        message = "REVEAL: route resolving..."
    elseif phase == "result" then
        message = resultText .. "  Press A/Enter for the next turn."
    elseif phase == "gameover" then
        message = resultText .. "  Press Start/Enter for a new random map."
    end

    love.graphics.setColor(0.84, 0.86, 0.88, 1)
    love.graphics.printf(message or "", 18, 420, 604, "left")
    drawButtonLegend()
end

function love.load()
    love.math.setRandomSeed(os.time())
    love.graphics.setBackgroundColor(0.035, 0.045, 0.055)
    fontSmall = love.graphics.newFont(11)
    fontNormal = love.graphics.newFont(15)
    fontLarge = love.graphics.newFont(24)
    local joysticks = love.joystick.getJoysticks()
    controller = joysticks[1]
    newGame()
end

function love.joystickadded(joystick)
    if not controller then controller = joystick end
end

function love.update(dt)
    if phase == "jemima" then
        local dx, dy = 0, 0
        if love.keyboard.isDown("left") then dx = dx - 1 end
        if love.keyboard.isDown("right") then dx = dx + 1 end
        if love.keyboard.isDown("up") then dy = dy - 1 end
        if love.keyboard.isDown("down") then dy = dy + 1 end

        if controller then
            local ax = controller:getGamepadAxis("leftx") or 0
            local ay = controller:getGamepadAxis("lefty") or 0
            if math.abs(ax) > 0.20 then dx = dx + ax end
            if math.abs(ay) > 0.20 then dy = dy + ay end
            if controller:isGamepadDown("dpleft") then dx = dx - 1 end
            if controller:isGamepadDown("dpright") then dx = dx + 1 end
            if controller:isGamepadDown("dpup") then dy = dy - 1 end
            if controller:isGamepadDown("dpdown") then dy = dy + 1 end
        end

        local length = math.sqrt(dx * dx + dy * dy)
        if length > 0 then
            dx, dy = dx / length, dy / length
            cursor.x = math.max(18, math.min(GAME_W - 18, cursor.x + dx * 220 * dt))
            cursor.y = math.max(55, math.min(405, cursor.y + dy * 220 * dt))
            selectedNode = nearestActiveNode(cursor.x, cursor.y)
        end
    elseif phase == "reveal" then
        revealTimer = revealTimer + dt
        if revealTimer >= 0.55 then
            revealTimer = revealTimer - 0.55
            if revealStep < ROUTE_LEN then
                revealStep = revealStep + 1
                revealFishNode = routeNodes[revealStep + 1]
                if revealStep == ROUTE_LEN then
                    finishTurnResolution()
                end
            end
        end
    end
end

function love.gamepadpressed(_, button)
    if phase == "fish" and BUTTON_COLOURS[button] then
        inputFishButton(button)
        return
    end

    if phase == "jemima" and button == "a" then
        confirmJemimaPounce()
        return
    end

    if phase == "result" and button == "a" then
        currentTurn = currentTurn + 1
        startFishTurn()
        return
    end

    if phase == "gameover" and (button == "start" or button == "a") then
        newGame()
    end
end

function love.keypressed(key)
    if phase == "fish" then
        if key == "a" or key == "b" or key == "x" or key == "y" then
            inputFishButton(key)
        end
        return
    end

    if phase == "jemima" and (key == "return" or key == "space") then
        confirmJemimaPounce()
        return
    end

    if phase == "result" and (key == "return" or key == "space") then
        currentTurn = currentTurn + 1
        startFishTurn()
        return
    end

    if phase == "gameover" and (key == "return" or key == "space") then
        newGame()
    end
end

function love.draw()
    local s, ox, oy = getScale()
    love.graphics.push()
    love.graphics.translate(ox, oy)
    love.graphics.scale(s, s)

    for _, e in ipairs(graph.edges) do drawEdge(e) end
    drawRouteTrail()
    for i, node in ipairs(graph.nodes) do drawNode(i, node) end
    drawFishMarker()
    drawPounce()
    drawJemimaCursor()
    drawHud()

    love.graphics.pop()
end
