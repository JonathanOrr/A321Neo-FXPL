
local EPSILON=0.0000000001

local function compute_area(polygon, N)

    local A = 0
    local j = N-1
    for i = 0,N-1 do
        A = A + polygon[j+1][1] * polygon[i+1][2] - polygon[i+1][1] * polygon[j+1][2]
        j = i
    end

    return A/2
end

local function inside_triangle(Ax,Ay,Bx,By,Cx,Cy,Px,Py)

  local ax = Cx - Bx
  local ay = Cy - By
  local bx = Ax - Cx
  local by = Ay - Cy;
  local cx = Bx - Ax
  local cy = By - Ay
  local apx= Px - Ax
  local apy= Py - Ay
  local bpx= Px - Bx
  local bpy= Py - By
  local cpx= Px - Cx
  local cpy= Py - Cy;

  local aCROSSbp = ax*bpy - ay*bpx;
  local cCROSSap = cx*apy - cy*apx;
  local bCROSScp = bx*cpy - by*cpx;

  return ((aCROSSbp >= 0.0) and (bCROSScp >= 0.0) and (cCROSSap >= 0.0))

end

local function snip(polygon, u, v, w, N, V)

    local Ax = polygon[V[u+1]+1][1]
    local Ay = polygon[V[u+1]+1][2]
    local Bx = polygon[V[v+1]+1][1]
    local By = polygon[V[v+1]+1][2]
    local Cx = polygon[V[w+1]+1][1]
    local Cy = polygon[V[w+1]+1][2]
    
    if (((Bx-Ax)*(Cy-Ay)) - ((By-Ay)*(Cx-Ax))) < EPSILON then
        return false
    end
    
    for p=0,N-1 do
        if p ~= u and p ~= v and p ~= w then
        
            local Px = polygon[V[p+1]+1][1]
            local Py = polygon[V[p+1]+1][2]
            if inside_triangle(Ax,Ay,Bx,By,Cx,Cy,Px,Py) then
                return false
            end
        end
    end
    
    return true
    
end

function polygon_triangulation(polygon)

    local to_ret = {}  -- Set of triangles to return
    
    local N = #polygon -- Number of points of the countour
    
    if N <= 3 then
        return {polygon} -- it has no sense to triangulate a triangle or a line
    end
    
    local V = {}       -- Support vector for indeces
    
    if compute_area(polygon, N) > 0 then
        for i=0,N-1 do
            V[i+1] = i
        end
    else
        for i=0,N-1 do
            V[i+1] = (N-1) - i
        end
    end
    
    local NV = N
    local count = 2 * N
    local v = N -1
    
    while NV > 2 do

        if count <= 0 then
            break
        end
        count = count - 1
        
        -- Search 3 vertices in the polygon
        local u = v
        if u >= NV then
            u = 0
        end
        v = u+1
        if v >= NV then
            v = 0
        end
        local w = v+1
        if w >= NV then
            w = 0
        end
        
        if snip(polygon, u, v, w, NV, V) then
            local a = V[u+1]
            local b = V[v+1]
            local c = V[w+1]
            
            table.insert(to_ret, {polygon[a+1],polygon[b+1],polygon[c+1]})
            
            local s = v
            for t=v+1,NV-1 do
                V[s+1] = V[t+1]
                s = s + 1
            end
            
            NV = NV - 1
            
            count = 2 * NV
        end

    end

    return to_ret
end

