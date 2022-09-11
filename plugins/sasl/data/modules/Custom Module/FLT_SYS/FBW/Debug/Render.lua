local mcos = function(a) return math.cos(math.rad(a)) end
local msin = function(a) return math.sin(math.rad(a)) end

local function vertRotate(vert, rot)
    local d_x = mcos(rot[1]) * (vert[3] * msin(rot[2]) * mcos(rot[3]) - vert[2] * msin(rot[3])) + msin(rot[1]) * (vert[2] * msin(rot[2]) * mcos(rot[3]) + vert[3] * msin(rot[3])) + vert[1] * mcos(rot[2]) * mcos(rot[3])
    local d_y = mcos(rot[1]) * (vert[3] * msin(rot[2]) * msin(rot[3]) + vert[2] * mcos(rot[3])) + msin(rot[1]) * (vert[2] * msin(rot[2]) * msin(rot[3]) - vert[3] * mcos(rot[3])) + vert[1] * mcos(rot[2]) * msin(rot[3])
    local d_z = vert[3] * mcos(rot[1]) * mcos(rot[2]) + vert[2] * msin(rot[1]) * mcos(rot[2]) - vert[1] * msin(rot[2])

    return {d_x, d_y, d_z}
end

local function vertsOrigin(verts)
    local origin_x = 0
    local origin_y = 0
    local origin_z = 0

    for i = 1, #verts do
        origin_x = origin_x + verts[i][1]
        origin_y = origin_y + verts[i][2]
        origin_z = origin_z + verts[i][3]
    end

    origin_x = origin_x / #verts
    origin_y = origin_y / #verts
    origin_z = origin_z / #verts

    return {origin_x, origin_y, origin_z}
end

local function cameraTransform(verts, camera)
    for i = 1, #verts do
        verts[i][1] = verts[i][1] - camera[1]
        verts[i][2] = verts[i][2] - camera[2]
        verts[i][3] = verts[i][3] - camera[3]
    end
end


local function triangulate(faces, tris)
    for key, face in ipairs(faces) do
        for i = 2, #face - 1 do
            table.insert(tris, {face[1], face[i], face[i + 1]})
        end
    end
end

local function trisNml(verts, tris, nmls)
    for key, tri in ipairs(tris) do
        local vert1, vert2, vert3 = verts[tri[1]], verts[tri[2]], verts[tri[3]]
        local vec1 = {vert2[1] - vert1[1], vert2[2] - vert1[2], vert2[3] - vert1[3]}
        local vec2 = {vert3[1] - vert1[1], vert3[2] - vert1[2], vert3[3] - vert1[3]}

        local nmlx =  vec1[2] * vec2[3] - vec1[3] * vec2[2]
        local nmly = -vec1[1] * vec2[3] + vec1[3] * vec2[1]
        local nmlz =  vec1[1] * vec2[2] - vec1[2] * vec2[1]

        table.insert(nmls, {nmlx, nmly, nmlz})
    end
end

local function dotProduct(vec1, vec2)
    return vec1[1] * vec2[1] + vec1[2] * vec2[2] + vec1[3] * vec2[3]
end

local function objInit(obj)
    local origin = vertsOrigin(obj.verts)
    obj.initVerts = {}

    --recenter then scale obj for rotation
    for key, vert in ipairs(obj.verts) do
        obj.initVerts[key] = {
            (vert[1] - origin[1]) * obj.scl[1],
            (vert[2] - origin[2]) * obj.scl[2],
            (vert[3] - origin[3]) * obj.scl[3]
        }
    end

    --rotate obj
    for key, vert in ipairs(obj.initVerts) do
        obj.initVerts[key] = vertRotate(vert, obj.rot)
    end

    --scale and translate obj
    for key, vert in ipairs(obj.initVerts) do
        obj.initVerts[key] = {
            vert[1] + origin[1] + obj.loc[1],
            vert[2] + origin[2] + obj.loc[2],
            vert[3] + origin[3] + obj.loc[3]
        }
    end
end

local function loadObj(tbl, obj)
    --import faces and reorder vertex index
    for key, face in ipairs(obj.faces) do
        local idx_add = #tbl.verts
        local newIdxFace = {}
        for i = 1, #face do
            newIdxFace[i] = face[i] + idx_add
        end

        table.insert(tbl.faces, newIdxFace)
    end

    --import vertices
    for key, vert in ipairs(obj.initVerts) do
        table.insert(tbl.verts, vert)
    end
end

local function clearRenderTable(tbl)
    tbl.verts = {}
    tbl.faces = {}
    tbl.tris = {}
    tbl.nmls = {}
    tbl.homoTris = {}
end


local function creatDrawBuffers(width)
    local depthBuffer = {}
    for i = 1, width do
        table.insert(depthBuffer, {})
    end

    return depthBuffer
end

local function triNml(v1, v2, v3)
    local vec1 = {v2[1] - v1[1], v2[2] - v1[2], v2[3] - v1[3]}
    local vec2 = {v3[1] - v1[1], v3[2] - v1[2], v3[3] - v1[3]}

    local nmlx =  vec1[2] * vec2[3] - vec1[3] * vec2[2]
    local nmly = -vec1[1] * vec2[3] + vec1[3] * vec2[1]
    local nmlz =  vec1[1] * vec2[2] - vec1[2] * vec2[1]

    return {nmlx, nmly, nmlz}
end

local function homogenizeTris(v1, v2, v3, fov)
    local homoTri = {v1, v2, v3}

    for i = 1, #homoTri do
        homoTri[i][1] = homoTri[i][1]
        homoTri[i][2] = homoTri[i][2]
        homoTri[i][3] = math.tan(math.rad(fov) / 2) * homoTri[i][3]
    end

    return homoTri
end

local function projectTris(homoTri, screen)
    local projTri = {}
    for key, vert in ipairs(homoTri) do
        table.insert(
            projTri,
            {
                vert[1] / vert[3] * (screen[3] / 2) + (screen[3] / 2) + screen[1],
                vert[2] / vert[3] * (screen[4] / 2) + (screen[4] / 2) + screen[2],
            }
        )
    end

    return projTri
end

local function drawTriangle(tbl, depthBuffer, v1, v2, v3, color)
    local homoTri = homogenizeTris(v1, v2, v3, tbl.fov)
    local homoNml = triNml(homoTri[1], homoTri[2], homoTri[3])

    --sort
    if homoTri[3][2] < homoTri[2][2] then
        local temp = homoTri[3]
        homoTri[3] = homoTri[2]
        homoTri[2] = temp
    end
    if homoTri[2][2] < homoTri[1][2] then
        local temp = homoTri[2]
        homoTri[2] = homoTri[1]
        homoTri[1] = temp
    end
    if homoTri[3][2] < homoTri[2][2] then
        local temp = homoTri[3]
        homoTri[3] = homoTri[2]
        homoTri[2] = temp
    end

    local tri2D = projectTris(homoTri, tbl.screen)

    local ymin2D = math.ceil(tri2D[1][2])
    local ymax2D = math.ceil(tri2D[3][2])
    local ymin3D = math.ceil(homoTri[1][2])
    local ymax3D = math.ceil(homoTri[3][2])
    for i = Math_clamp(ymin2D, 1, tbl.screen[4]), Math_clamp(ymax2D, 1, tbl.screen[4]) do
        local long_x_2D  = Math_rescale(tri2D[1][2], tri2D[1][1], tri2D[3][2], tri2D[3][1], i)
        local short_x_2D = Table_interpolate({{tri2D[1][2], tri2D[1][1]},{tri2D[2][2], tri2D[2][1]},{tri2D[3][2], tri2D[3][1]}}, i)
        local long_x_3D  = Math_rescale(homoTri[1][2], homoTri[1][1], homoTri[3][2], homoTri[3][1], i)
        local short_x_3D = Table_interpolate({{homoTri[1][2], homoTri[1][1]},{homoTri[2][2], homoTri[2][1]},{homoTri[3][2], homoTri[3][1]}}, i)

        local xmin2D = math.ceil(math.min(long_x_2D, short_x_2D))
        local xmax2D = math.ceil(math.max(long_x_2D, short_x_2D))
        local xmin3D = math.ceil(math.min(long_x_3D, short_x_3D))
        local xmax3D = math.ceil(math.max(long_x_3D, short_x_3D))

        local y3D = Math_rescale(ymin2D, ymin3D, ymax2D, ymax3D, i)
        for j = Math_clamp(xmin2D, 1, tbl.screen[3]), Math_clamp(xmax2D - 1, 1, tbl.screen[3]) do
            local x3D = Math_rescale(xmin2D, xmin3D, xmax2D, xmax3D, j)
            local z3D = (homoNml[1] * (xmin3D - x3D) + homoNml[2] * (ymin3D - y3D) + homoNml[3] * homoTri[1][3]) / homoNml[3]

            if not depthBuffer[i][j] or z3D < depthBuffer[i][j] then
                sasl.gl.drawLine(j, i, j + 1, i, color)
                depthBuffer[i][j] = z3D
            end
        end
    end
end


local function prepareTris(tbl)
    tbl.depthBuffer = creatDrawBuffers(tbl.screen[3])
    cameraTransform(tbl.verts, tbl.camera)
    triangulate(tbl.faces, tbl.tris)
    trisNml(tbl.verts, tbl.tris, tbl.nmls)
end

local function render(tbl)
    for key, tri in ipairs(tbl.tris) do
        local vert1, vert2, vert3 = tbl.verts[tri[1]], tbl.verts[tri[2]], tbl.verts[tri[3]]
        local triVerts = {vert1, vert2, vert3}
        if dotProduct(tbl.nmls[key], vertsOrigin(triVerts)) < 0 then
            local colors = {
                {1, 1, 1,},
                {1, 1, 0,},
                {0, 1, 1,},
                {1, 0, 0,},
                {0, 1, 0,},
                {0, 0, 1,},

                {0.5, 1, 1, },
                {1, 0.5, 0, },
                {0, 0.5, 1, },
                {0.5, 1, 0, },
                {0, 1, 0.5, },
                {0.75, 0.25, 0.5,},
            }
 
            drawTriangle(tbl, tbl.depthBuffer, vert1, vert2, vert3, dotProduct(tbl.nmls[key], vertsOrigin(triVerts)) < 0 and colors[key % 6 + 1] or {0,0,0})
        end
    end

    clearRenderTable(tbl)
end

local cube_obj = {
    loc = {0, 0, 3},
    rot = {0, 0, 0},
    scl = {1, 1, 1},

    verts = {
        {-1,-1,-1},
        {1,-1,-1},
        {1,-1,1},
        {-1,-1,1},
        {1,1,-1},
        {-1,1,-1},
        {-1,1,1},
        {1,1,1},
    },
    faces = {
        {1, 2, 3, 4},
        {2, 5, 8, 3},
        {5, 6, 7, 8},
        {6, 1, 4, 7},
        {4, 3, 8, 7},
        {6, 5, 2, 1},
    },
}
local icosphere_obj = {
    loc = {0, 0, 3},
    rot = {0, 0, 0},
    scl = {1, 1, 1},

    verts = {
        {0.000000,  -1.000000, 0.000000},
        {0.723600,  -0.447215, 0.525720},
        {-0.276385, -0.447215, 0.850640},
        {-0.894425, -0.447215, 0.000000},
        {-0.276385, -0.447215, -0.850640},
        {0.723600,  -0.447215, -0.525720},
        {0.276385,  0.447215,  0.850640},
        {-0.723600, 0.447215,  0.525720},
        {-0.723600, 0.447215,  -0.525720},
        {0.276385,  0.447215,  -0.850640},
        {0.894425,  0.447215,  0.000000},
        {0.000000,  1.000000,  0.000000},
    },
    faces = {
        {1,2,3},
        {2,1,6},
        {1,3,4},
        {1,4,5},
        {1,5,6},
        {2,6,11},
        {3,2,7},
        {4,3,8},
        {5,4,9},
        {6,5,10},
        {2,11,7},
        {3,7,8},
        {4,8,9},
        {5,9,10},
        {6,10,11},
        {7,11,12},
        {8,7,12},
        {9,8,12},
        {10,9,12},
        {11,10,12},
    },
}

local test_tbl = {
    screen = {0, 0, 500,500},

    camera = {0, 1.2, -0.5},
    fov = 90,

    verts = {},
    faces = {},

    tris = {},
    nmls = {},
}

function update()
    --[[cube_obj.rot[1] = cube_obj.rot[1] - get(DELTA_TIME) * 20
    cube_obj.rot[2] = cube_obj.rot[2] + get(DELTA_TIME) * 20
    objInit(cube_obj)
    loadObj(test_tbl, cube_obj)
    prepareTris(test_tbl)

    for i = 1, #test_tbl.nmls do
        print(table.concat(test_tbl.nmls[i], ','))
    end

    print("")]]
end

--[[for i = 1, #test_tbl.verts do
        print(table.concat(test_tbl.verts[i], ','))
    end
    
    print("")
    
    for i = 1, #test_tbl.faces do
        print(table.concat(test_tbl.faces[i], ','))
    end
    
    print("")
    
    for i = 1, #test_tbl.tris do
        print(table.concat(test_tbl.tris[i], ','))
    end
    
    print("")
    
    for i = 1, #test_tbl.nmls do
        print(table.concat(test_tbl.nmls[i], ','))
    end
    
    print("")
    
    for i = 1, #test_tbl.homoTris do
        print(table.concat(test_tbl.homoTris[i][1], ','), table.concat(test_tbl.homoTris[i][2], ','), table.concat(test_tbl.homoTris[i][3], ','))
    end]]

function draw()
    --render(test_tbl, 0, 0, 500)
end