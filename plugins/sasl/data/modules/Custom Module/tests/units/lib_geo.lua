dofile("../libs/geo-helpers.lua")


TestLibGeo = {} --class
function TestLibGeo:test_heading_difference()
    local result = heading_difference(130,150)
    lu.assertEquals( type(result), 'number' )
    lu.assertEquals( result, 20 )

    local result = heading_difference(150, 130)
    lu.assertEquals( type(result), 'number' )
    lu.assertEquals( result, -20 )

    local result = heading_difference(90,290)
    lu.assertEquals( type(result), 'number' )
    lu.assertEquals( result, -160 )

    local result = heading_difference(290, 90)
    lu.assertEquals( type(result), 'number' )
    lu.assertEquals( result, 160 )

    local result = heading_difference(0, 180)
    lu.assertEquals( type(result), 'number' )
    lu.assertEquals( math.abs(result), 180 )

    local result = heading_difference(180, 0)
    lu.assertEquals( type(result), 'number' )
    lu.assertEquals( math.abs(result), 180 )

    local result = heading_difference(0, 340)
    lu.assertEquals( type(result), 'number' )
    lu.assertEquals( result, -20 )

    local result = heading_difference(0, -20)
    lu.assertEquals( type(result), 'number' )
    lu.assertEquals( result, -20 )

    local result = heading_difference(0, -340)
    lu.assertEquals( type(result), 'number' )
    lu.assertEquals( result, 20 )

end

function TestLibGeo:test_intersecting_radials_1()
    local lat1 = 22.237582904751
    local lon1 = 113.72558803208
    local lat2 = 22.266352778
    local lon2 = 113.759936111
    local angle1 = 38
    local angle2 = 251

    local res_lat, res_lon = intersecting_radials(lat1, lon1, lat2, lon2, angle1, angle2)
    lu.assertEquals( type(res_lat), 'number' )
    lu.assertEquals( type(res_lon), 'number' )
    lu.assertAlmostEquals( res_lat, 22.261944, 1e-4 )
    lu.assertAlmostEquals( res_lon, 113.746111, 1e-4)

end

function TestLibGeo:test_intersecting_radials_2()


    local lat1 = 50
    local lon1 = 50
    local lat2 = 60
    local lon2 = 60
    local angle1 = 45
    local angle2 = 45

    local res_lat, res_lon = intersecting_radials(lat1, lon1, lat2, lon2, angle1, angle2)
    lu.assertEquals( type(res_lat), 'number' )
    lu.assertEquals( type(res_lon), 'number' )
    lu.assertAlmostEquals( res_lat, -38.911389, 1e-3)
    lu.assertAlmostEquals( res_lon, -143.128889, 1e-3)
end

function TestLibGeo:test_intersecting_radials_3()
    local lat1 = -10
    local lon1 = 50
    local lat2 = -10.0000001
    local lon2 = 50.0000001
    local angle1 = 13
    local angle2 = 67

    local res_lat, res_lon = intersecting_radials(lat1, lon1, lat2, lon2, angle1, angle2)
    lu.assertEquals( type(res_lat), 'number' )
    lu.assertEquals( type(res_lon), 'number' )
    lu.assertAlmostEquals( res_lat, -10)
    lu.assertAlmostEquals( res_lon, 50)
end

function TestLibGeo:test_intersecting_radials_4()
    local lat1 = -50
    local lon1 = 50
    local lat2 = 60
    local lon2 = 60
    local angle1 = 20
    local angle2 = 90

    local res_lat, res_lon = intersecting_radials(lat1, lon1, lat2, lon2, angle1, angle2)
    lu.assertEquals( type(res_lat), 'number' )
    lu.assertEquals( type(res_lon), 'number' )
    lu.assertAlmostEquals( res_lat, 57.262778, 1e-3)
    lu.assertAlmostEquals( res_lon, 86.099444, 1e-3)
end

function TestLibGeo:test_intersecting_radials_5()
    local lat1 = 50.2
    local lon1 = -10
    local lat2 = 50.5
    local lon2 = -10.1
    local angle1 = 260
    local angle2 = 30

    local res_lat, res_lon = intersecting_radials(lat1, lon1, lat2, lon2, angle1, angle2)
    lu.assertEquals( type(res_lat), 'nil' )
    lu.assertEquals( type(res_lon), 'nil' )
end

function TestLibGeo:test_intersecting_radials_6()
    local lat1 = 50.2
    local lon1 = -10
    local lat2 = 50.5
    local lon2 = -10.1
    local angle1 = 260
    local angle2 = 190

    local res_lat, res_lon = intersecting_radials(lat1, lon1, lat2, lon2, angle1, angle2)
    lu.assertEquals( type(res_lat), 'number' )
    lu.assertEquals( type(res_lon), 'number' )
    lu.assertAlmostEquals( res_lat, 50.178611, 1e-4)
    lu.assertAlmostEquals( res_lon, -10.188611,1e-4)
end

-- class TestLibGeo