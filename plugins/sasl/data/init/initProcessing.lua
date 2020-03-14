-------------------------------------------------------------------------------
-- Draw
-------------------------------------------------------------------------------

--- Draws (2D) all components.
--- @param components Component[]
function drawAll(components)
    for _, v in ipairs(components) do
        private.drawComponent(v)
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Draws 3D from components.
--- @param components Component[]
function drawAll3D(components)
    for _, v in ipairs(components) do
        private.drawComponent3D(v)
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Draws objects from components.
--- @param components Component[]
function drawAllObjects(components)
    for _, v in ipairs(components) do
        private.drawObjects(v)
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Simulator framerate dataref
local simFRP = globalPropertyf("sim/operation/misc/frame_rate_period")

--- Draws component to its 2D render target.
--- @param v Component
function private.drawComponentToTarget(v)
    setRenderTarget(v.renderTarget, true)
    v:draw()
    restoreRenderTarget()
end

--- Draws component in 2D.
--- @param v Component
function private.drawComponent(v)
    if v and toboolean(get(v.visible)) then
        sasl.gl.saveGraphicsContext()
        local renderTargetExist = toboolean(get(v.fbo))
        if renderTargetExist then
            local omitRendering = toboolean(get(v.noRenderSignal))
            if not omitRendering then
                local currentFPS = 1.0 / get(simFRP)
                local limit = get(v.fpsLimit)
                if limit == -1 or limit >= currentFPS then
                    private.drawComponentToTarget(v)
                    v.frames = 0
                else
                    if v.frames > currentFPS / limit then
                        private.drawComponentToTarget(v)
                        v.frames = 0
                    else
                        v.frames = v.frames + 1
                    end
                end
            end
            local pos = get(v.position)
            sasl.gl.setComponentTransform(pos[1], pos[2], pos[3], pos[4], v.size[1], v.size[2])
            sasl.gl.drawTexture(v.renderTarget, 0, 0, v.size[1], v.size[2], 1, 1, 1, 1)
            set(v.noRenderSignal, false)
        else
            local pos = get(v.position)
            sasl.gl.setComponentTransform(pos[1], pos[2], pos[3], pos[4], v.size[1], v.size[2])
            local clip = toboolean(get(v.clip))
            local cs = get(v.clipSize) and get(v.clipSize) or { pos[1], pos[2], pos[3], pos[4] }
            local clipSize = cs[3] > 0 and cs[4] > 0
            if clip then
                if clipSize then
                    sasl.gl.setClipArea(cs[1], cs[2], cs[3], cs[4])
                else
                    sasl.gl.setClipArea(0, 0, v.size[1], v.size[2])
                end
            end
            v:draw()
            if clip then
                sasl.gl.resetClipArea()
            end
        end
        sasl.gl.restoreGraphicsContext()
    end
end

--- Draws 3D from component.
--- @param v Component
function private.drawComponent3D(v)
    v:draw3D()
end

--- Draws objects from components.
--- @param v Component
function private.drawObjects(v)
    v:drawObjects()
end

-------------------------------------------------------------------------------
-- Update
-------------------------------------------------------------------------------

--- Updates all components.
--- @param components Component[]
function updateAll(components)
    for _, v in ipairs(components) do
        private.updateComponent(v)
    end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Updates component.
--- @param v Component
function private.updateComponent(v)
    if v and v.update then
        v:update()
    end
end

-------------------------------------------------------------------------------
-- Utilities
-------------------------------------------------------------------------------

--- Calls callback function for component recursively.
--- @param name string
--- @param component Component
function private.callCallback(name, component)
    local handler = rawget(component, name)
    if handler then
        handler()
    end
    for i = #component.components, 1, -1 do
        private.callCallback(name, component.components[i])
    end
end

--- Calls callback for all components layers.
--- @param name string
function private.callCallbackForAllLayers(name)
    private.callCallback(name, popups)
    private.callCallback(name, panel)
    private.callCallback(name, contextWindows)
end

-------------------------------------------------------------------------------
-- Other
-------------------------------------------------------------------------------

--- Draws 3D panel components.
function drawPanelStage()
    private.drawComponent(panel)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Draws old-style popups components.
function drawPopupsStage()
    private.drawComponent(popups)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Draws 3D.
function draw3DStage()
    private.drawComponent3D(panel)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Draws objects.
function drawObjectsStage()
    private.drawObjects(panel)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Updates components.
function update()
    private.updateComponent(panel)
    private.updateComponent(popups)
    private.updateComponent(contextWindows)
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Called whenever the user's plane is positioned at a new airport.
function onAirportLoaded()
    private.callCallbackForAllLayers("onAirportLoaded")
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Called whenever new scenery is loaded.
function onSceneryLoaded()
    private.callCallbackForAllLayers("onSceneryLoaded")
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Called whenever the user adjusts the number of X-Plane aircraft models.
function onAirplaneCountChanged()
    private.callCallbackForAllLayers("onAirplaneCountChanged")
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Called when user aircraft is loaded.
function onPlaneLoaded()
    private.callCallbackForAllLayers("onPlaneLoaded")
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Called when user aircraft is unloaded.
function onPlaneUnloaded()
    private.callCallbackForAllLayers("onPlaneUnloaded")
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Called whenever user plane is crashed.
function onPlaneCrash()
    local planeCrashHandler = rawget(panel, 'onPlaneCrash')
    needReload = 1
    if planeCrashHandler then
        needReload = planeCrashHandler()
    end
    if needReload == 0 then
        for i = #panel.components, 1, -1 do
            private.callCallback('onPlaneCrash', panel.components[i])
        end
        private.callCallback('onPlaneCrash', popups)
        private.callCallback('onPlaneCrash', contextWindows)
    end
    return needReload
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Called on module shutdown.
function shutdownModules()
    private.callCallbackForAllLayers("onModuleShutdown")
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

--- Called when module is unloading.
function doneModules()
    private.callCallbackForAllLayers("onModuleDone")
    private.saveState()
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------