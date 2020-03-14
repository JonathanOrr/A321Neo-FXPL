-------------------------------------------------------------------------------
-- Context windows
-------------------------------------------------------------------------------

local function contextWindowHeaderDrawDef(window, w, h)
    local elColor = { 0.8, 0.8, 0.8, 1.0 }
    sasl.gl.drawRectangle(0, 0, w, h, { 0.28, 0.28, 0.28, 1.0 })

    sasl.gl.drawWideLine(7, 7, h - 7, h - 7, 2, elColor)
    sasl.gl.drawWideLine(7, h - 7, h - 7, 7, 2, elColor)
    sasl.gl.drawConvexPolygon({ h + 7, 7, h + 18, 7, h + 18, h - 7, h + 7, h - 7 }, false, 1, elColor)
    sasl.gl.drawWidePolyLine({ h + 10, h - 7, h + 10, 10, h + 18, 10 }, 1, elColor)

    sasl.gl.drawWideLine(w - 7, 7, w - h + 7, h - 7, 2, elColor)
    sasl.gl.drawWideLine(w - 7, h - 7, w - h + 7, 7, 2, elColor)
    sasl.gl.drawConvexPolygon({ w - 2 * h + 7, 7, w - 2 * h + 18, 7, w - 2 * h + 18, h - 7, w - 2 * h + 7, h - 7 }, false, 1, elColor)
    sasl.gl.drawWidePolyLine({ w - 2 * h + 10, h - 7, w - 2 * h + 10, 10, w - 2 * h + 18, 10 }, 1, elColor)
end

local function contextWindowHeaderMDownDef(window, x, y, w, h, button)
    if isInRect({ 0, 0, h, h }, x, y) or isInRect({ w - h, 0, h, h }, x, y) then
        window:setIsVisible(false)
        return true
    end
    if isInRect({ h, 0, h, h }, x, y) or isInRect({ w - 2 * h, 0, h, h }, x, y) then
        window:setMode(SASL_CW_MODE_POPOUT)
        return true
    end
    return false
end

local function getContextWindowDecorationDef(window)
    return {
        headerHeight = 25,
        draw = function(w, h) contextWindowHeaderDrawDef(window, w, h) end,
        onMouseDown = function(x, y, w, h, button) return contextWindowHeaderMDownDef(window, x, y, w, h, button) end,
        onMouseUp = function(x, y, w, h, button) return false end,
        onMouseHold = function(x, y, w, h, button) return false end,
        onMouseMove = function(x, y, w, h) return 1 end,
        onMouseWheel = function(x, y, w, h, clicks) return false end,
        main = {}
    }
end

local defaultWindowName = "cWindow"

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- @class ContextWindowDecorationCallbacks
--- @field draw fun(w:number, h:number)
--- @field onMouseDown fun(x:number, y:number, w:number, h:number):boolean
--- @field onMouseUp fun(x:number, y:number, w:number, h:number):boolean
--- @field onMouseHold fun(x:number, y:number, w:number, h:number):boolean
--- @field onMouseMove fun(x:number, y:number, w:number, h:number):number
--- @field onMouseWheel fun(x:number, y:number, w:number, h:number, clicks:number):boolean

--- @class ContextWindowDecoration : ContextWindowDecorationCallbacks
--- @field headerHeight number
--- @field main ContextWindowDecorationCallbacks

--- @class ContextWindowParams
--- @field name string
--- @field position number[]
--- @field minimumSize number[]
--- @field maximumSize number[]
--- @field visible boolean
--- @field proportional boolean
--- @field gravity number[]
--- @field noBackground boolean
--- @field layer CWLayerID
--- @field noDecore boolean
--- @field customDecore boolean
--- @field decoration ContextWindowDecoration
--- @field noResize boolean
--- @field resizeMode CWResizeModeID
--- @field noMove boolean
--- @field vrAuto boolean
--- @field fbo boolean
--- @field clip boolean
--- @field clipSize number[]
--- @field command string
--- @field description string
--- @field callback fun(id:number, event:CWEventID)
--- @field resizeCallback fun(c:Component, w:number, h:number, mode:CWModeID, proportional:boolean):number, number, number, number
--- @field components Component[]

--- @class ContextWindow
--- @field id number
--- @field component Component
--- @field decoration ContextWindowDecoration
--- @field setSizeLimits fun(self:ContextWindow, minWidth:number, minHeight:number, maxWidth:number, maxHeight:number)
--- @field getSizeLimits fun(self:ContextWindow):number, number, number, number
--- @field setResizeMode fun(self:ContextWindow, mode:CWResizeModeID)
--- @field setIsVisible fun(self:ContextWindow, isVisible:boolean)
--- @field isVisible fun(self:ContextWindow):boolean
--- @field setTitle fun(self:ContextWindow, title:string)
--- @field setGravity fun(self:ContextWindow, left:number, top:number, right:number, bottom:number)
--- @field setPosition fun(self:ContextWindow, x:number, y:number, w:number, h:number)
--- @field getPosition fun(self:ContextWindow):number, number, number, number
--- @field setMode fun(self:ContextWindow, mode:CWModeID, monitor:number)
--- @field getMode fun(self:ContextWindow):CWModeID, monitor
--- @field isPoppedOut fun(self:ContextWindow):boolean
--- @field isInVR fun(self:ContextWindow):boolean
--- @field setVrAutoHandling fun(self:ContextWindow, auto:boolean)
--- @field setProportional fun(self:ContextWindow, isProportional:boolean)
--- @field setResizable fun(self:ContextWindow, isResizable:boolean)
--- @field setMovable fun(self:ContextWindow, isMovable:boolean)
--- @field setCallback fun(self:ContextWindow, callback:fun(id:number, event:CWEventID))
--- @field destroy fun(self:ContextWindow)

--- Creates modern 2D context window with attached components hierarchy.
--- @param tbl ContextWindowParams
--- @return ContextWindow
function contextWindow(tbl)
    local window = {}
    local cName = defaultWindowName
    if tbl.name ~= nil then
        cName = tbl.name
    end
    local c = private.createComponent(cName)
    c.position = createProperty { 0, 0, 0, 0 }

    local cwDecoration = SASL_CW_DECORATED_XP
    if get(tbl.noDecore) then
        cwDecoration = SASL_CW_NON_DECORATED
    elseif get(tbl.customDecore) then
        cwDecoration = SASL_CW_DECORATED
    end

    local layer = SASL_CW_LAYER_FLOATING_WINDOWS
    if tbl.layer ~= nil then
        layer = tbl.layer
    end

    set(c.position, { 0, 0, tbl.position[3], tbl.position[4] })
    set(c.clip, tbl.clip)
    set(c.clipSize, tbl.clipSize)
    if tbl.visible ~= nil then
        set(c.visible, tbl.visible)
    else
        set(c.visible, false)
    end
    c.size = { tbl.position[3], tbl.position[4] }
    c.components = tbl.components

    startComponentsCreation(tbl)
    if not get(tbl.noBackground) then
        if not rectangle then
            rectangle = loadComponent("rectangle")
        end

        table.insert(c.components, 1,
           rectangle { position = { 0, 0, c.size[1], c.size[2] } } )
    end
    finishComponentsCreation()

    -------------------------------------------------------------------------------

    function drawContextWindow(wId)
        private.drawComponent(c)
    end

    function onMouseDownContextWindow(wId, x, y, button)
        private.eventCounter = 0
        return processMouseDown(c, x, y, button)
    end

    function onMouseUpContextWindow(wId, x, y, button)
        private.eventCounter = 0
        return processMouseUp(c, x, y, button)
    end

    function onMouseHoldContextWindow(wId, x, y, button)
        private.eventCounter = 0
        return processMouseHold(c, x, y, button)
    end

    function onMouseWheelContextWindow(wId, x, y, wheelClicks)
        private.eventCounter = 0
        return processMouseWheel(c, x, y, wheelClicks)
    end

    function onMouseMoveContextWindow(wId, x, y)
        private.eventCounter = 0
        private.setOnInterceptingWindow(false)
        sasl.gl.setCursorLayer(wId)

        local resultCursor = 1
        processMouseMove(c, x, y)
        if private.isOSCursorHidden() then
            resultCursor = 2
        end
        return resultCursor
    end

    local resizeCallback = tbl.resizeCallback
    function onContextWindowResize(wId, width, height, mode, proportional)
        if resizeCallback then
            return resizeCallback(c, width, height, mode, proportional)
        else
            local cP = get(c.position)
            if proportional and
                (mode == SASL_CW_MODE_POPOUT or
                mode == SASL_CW_MODE_MONITOR_FULL or
                cwDecoration == SASL_CW_DECORATED_XP)
            then
                local center = { width / 2, height / 2 }
                local scale = math.min(width / cP[3], height / cP[4])

                cP[3] = cP[3] * scale
                cP[4] = cP[4] * scale
                cP[1] = math.floor(center[1] - cP[3] / 2)
                cP[2] = math.floor(center[2] - cP[4] / 2)
            else
                cP[3] = width
                cP[4] = height
                cP[1] = 0
                cP[2] = 0
            end
            set(c.position, cP)
            return cP[1], cP[2], cP[3], cP[4]
        end
    end

    function onContextWindowLayoutChange(wId, isInFront)
        private.eventCounter = 1
        local currentFocusedComponentPath = private.getFocusedComponentPath()
        local focusedNow = false
        if currentFocusedComponentPath then
            focusedNow = currentFocusedComponentPath[1] == c
            if focusedNow and not isInFront then
                private.clearFocusedComponentPaths()
            end
        end
        if not focusedNow and isInFront then
            private.setFocusedPath({ c })
        end
    end

    -------------------------------------------------------------------------------

    local p = tbl.position
    window.id = sasl.windows.createContextWindow(cwDecoration, layer, p[1], p[2], p[3], p[4],
        drawContextWindow,
        onMouseDownContextWindow,
        onMouseUpContextWindow,
        onMouseHoldContextWindow,
        onMouseMoveContextWindow,
        onMouseWheelContextWindow,
        onContextWindowResize,
        onContextWindowLayoutChange)

    window.component = c

    -------------------------------------------------------------------------------

    if cwDecoration == SASL_CW_DECORATED then
        window.decoration = getContextWindowDecorationDef(window)
        local decor = window.decoration
        if tbl.decoration ~= nil then
            for k, v in pairs(tbl.decoration) do
                decor[k] = v
            end
        end
        sasl.windows.setContextWindowDecoration(window.id, decor.headerHeight,
            decor.draw, decor.onMouseDown, decor.onMouseUp,
            decor.onMouseHold, decor.onMouseMove, decor.onMouseWheel,
            decor.main.draw, decor.main.onMouseDown, decor.main.onMouseUp,
            decor.main.onMouseHold, decor.main.onMouseMove, decor.main.onMouseWheel)
    end

    -------------------------------------------------------------------------------

    window.setSizeLimits = function(self, minWidth, minHeight, maxWidth, maxHeight)
        sasl.windows.setContextWindowSizeLimits(self.id, minWidth, minHeight, maxWidth, maxHeight)
    end
    window.getSizeLimits = function(self)
        local minW, minH, maxW, maxH = sasl.windows.getContextWindowSizeLimits(self.id)
        return minW, minH, maxW, maxH
    end
    window.setResizeMode = function(self, mode)
        sasl.windows.setContextWindowResizeMode(self.id, mode)
    end

    local sLimits = { 100, 100, 2048, 2048 }
    if get(tbl.minimumSize) then
        sLimits[1] = tbl.minimumSize[1]
        sLimits[2] = tbl.minimumSize[2]
    end
    if get(tbl.maximumSize) then
        sLimits[3] = tbl.maximumSize[1]
        sLimits[4] = tbl.maximumSize[2]
    end
    window:setSizeLimits(sLimits[1], sLimits[2], sLimits[3], sLimits[4])

    local resizeMode = SASL_CW_RESIZE_ALL_BOUNDS
    if tbl.resizeMode ~= nil then
        resizeMode = tbl.resizeMode
    end
    window:setResizeMode(resizeMode)

    -------------------------------------------------------------------------------

    window.setIsVisible = function(self, isVisible)
        sasl.windows.setContextWindowVisible(self.id, isVisible)
        set(self.component.visible, isVisible)
        if not isVisible then
            private.setPressedComponentPath(nil)
            private.setCursor(nil)
        end
    end
    window.isVisible = function(self)
        return sasl.windows.getContextWindowVisible(self.id)
    end

    if not get(c.visible) then
        window:setIsVisible(false)
    end

    -------------------------------------------------------------------------------

    window.cmd = nil
    if get(tbl.command) then
        local command = sasl.createCommand(get(tbl.command), get(tbl.description))

        function commandHandler(phase)
            if phase == SASL_COMMAND_BEGIN then
                window:setIsVisible(not window:isVisible())
            end
            return 0
        end
        window.cmd = command

        sasl.registerCommandHandler(window.cmd, 0, commandHandler)
    end

    -------------------------------------------------------------------------------

    window.setTitle = function(self, title)
        sasl.windows.setContextWindowTitle(self.id, title)
    end
    if get(tbl.name) then
        window:setTitle(get(tbl.name))
    end

    window.setGravity = function(self, left, top, right, bottom)
        sasl.windows.setContextWindowGravity(self.id, left, top, right, bottom)
    end
    if get(tbl.gravity) then
        local gr = get(tbl.gravity)
        window:setGravity(gr[1], gr[2], gr[3], gr[4])
    end

    window.setPosition = function(self, x, y, width, height)
        sasl.windows.setContextWindowPosition(self.id, x, y, width, height)
    end
    window.getPosition = function(self)
        return sasl.windows.getContextWindowPosition(self.id)
    end

    -------------------------------------------------------------------------------

    window.setMode = function(self, mode, monitor)
        private.setCursor(nil)
        sasl.windows.setContextWindowMode(self.id, mode, monitor)
    end

    window.getMode = function(self)
        return sasl.windows.getContextWindowMode(self.id)
    end

    window.isPoppedOut = function(self)
        return sasl.windows.isContextWindowPoppedOut(self.id)
    end

    window.isInVR = function(self)
        return sasl.windows.isContextWindowInVR(self.id)
    end

    local autoVr = false
    window.setVrAutoHandling = function(self, auto)
        sasl.windows.setContextWindowVrAutoHandling(self.id, auto)
    end
    if tbl.vrAuto ~= nil then
        autoVr = tbl.vrAuto
    end
    window:setVrAutoHandling(autoVr)

    -------------------------------------------------------------------------------

    local proportional = true
    if tbl.proportional ~= nil then
        proportional = tbl.proportional
    end
    window.setProportional = function(self, isProportional)
        sasl.windows.setContextWindowProportional(self.id, isProportional)
    end
    window:setProportional(proportional)

    window.setResizable = function(self, isResizable)
        sasl.windows.setContextWindowResizable(self.id, isResizable)
    end
    if tbl.noResize then
        window:setResizable(false)
        window:setSizeLimits(p[3], p[4], p[3], p[4])
    end

    window.setMovable = function(self, isMovable)
        sasl.windows.setContextWindowMovable(self.id, isMovable)
    end
    if tbl.noMove then
        window:setMovable(false)
    end

    -------------------------------------------------------------------------------

    window.setCallback = function(self, callback)
        sasl.windows.setContextWindowCallback(self.id, callback)
    end
    if tbl.callback ~= nil then
        window:setCallback(tbl.callback)
    end

    -------------------------------------------------------------------------------

    window.destroy = function(self)
        sasl.windows.destroyContextWindow(self.id)
        if self.cmd ~= nil then
            sasl.unregisterCommandHandler(self.cmd, 0)
        end
        for k, v in ipairs(contextWindows.components) do
            if v == c then
                table.remove(contextWindows.components, k)
                break
            end
        end
    end

    -------------------------------------------------------------------------------

    c.window = window
    c.saveState = createProperty(false)
    if get(tbl.saveState) then
        set(c.saveState, true)
        private.applyContextWindowState(c)
    end

    contextWindows.component(c)
    return window
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Saves context windows states in global state holder.
function private.saveContextWindowsState()
    local cw = {}
    for _, c in ipairs(contextWindows.components) do
        local name = c.name
        local sstate = get(c.saveState)
        if sstate and name ~= defaultWindowName then
            local modeId, modeMonitor = c.window:getMode()
            local x, y, w, h = c.window:getPosition()
            local vis = c.window:isVisible()
            cw[name] = {
                mode = { modeId, modeMonitor },
                position = { x, y, w, h },
                visible = vis
            }
        end
    end

    if not #cw then
        return
    end

    private.savedState.contextWindows = cw
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Applies saved state for context window associated with component
function private.applyContextWindowState(c)
    local name = c.name
    if name ~= defaultWindowName then
        local st = private.savedState.contextWindows[name]
        if st then
            local mode = st.mode
            local p = st.position
            local visible = st.visible
            if mode and p and mode[1] ~= SASL_CW_MODE_VR then
                c.window:setMode(mode[1], mode[2])
                c.window:setPosition(p[1], p[2], p[3], p[4])
                if visible ~= nil then
                    c.window:setIsVisible(visible)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------