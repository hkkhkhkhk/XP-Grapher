local mrad = math.rad
local mdeg = math.deg
local mcos = math.cos
local msin = math.sin
local masin = math.asin
local macos = math.acos
local matan2= math.atan2

function Move_along_distance(origin_lat, origin_lon, distance, angle)   -- Distance in M
    -- WARNING
    -- WARNING: Probably incorrect, consider to use Move_along_distance_v2
    -- WARNING
    local a = mrad(90-angle)

    local lat0 = mcos(math.pi / 180.0 * origin_lat)

    local lat = origin_lat  + (180/math.pi) * (distance / 6378137) * msin(a)
    local lon = origin_lon + (180/math.pi) * (distance / 6378137) / mcos(lat0) * mcos(a)
    return lat,lon
end

function Move_along_distance_v2(origin_lat, origin_lon, distance, angle) -- Distance in M
    local theta = mrad(angle)
    local EARTH_RADIUS = 6378136.6
    local angular_dist = distance / EARTH_RADIUS

    local s_lat1 = msin(mrad(origin_lat))
    local c_lat1 = mcos(mrad(origin_lat))
    local c_ang  = mcos(angular_dist)
    local s_ang  = msin(angular_dist)
    local c_theta= mcos(theta)
    local s_theta= msin(theta)

    local lat2 = masin(s_lat1 * c_ang + c_lat1 * s_ang * c_theta)
    local s_lat2 = msin(lat2)

    local lon2 = mrad(origin_lon) + matan2(s_theta * s_ang * c_lat1, c_ang - s_lat1 * s_lat2)
    
    return mdeg(lat2), mdeg(lon2)
end

function Move_along_distance_NM(origin_lat, origin_lon, distance, angle) -- Distance in NM
    local theta = mrad(angle)
    local EARTH_RADIUS = 6378136.6
    local angular_dist = distance * 1852 / EARTH_RADIUS

    local s_lat1 = msin(mrad(origin_lat))
    local c_lat1 = mcos(mrad(origin_lat))
    local c_ang  = mcos(angular_dist)
    local s_ang  = msin(angular_dist)
    local c_theta= mcos(theta)
    local s_theta= msin(theta)

    local lat2 = masin(s_lat1 * c_ang + c_lat1 * s_ang * c_theta)
    local s_lat2 = msin(lat2)

    local lon2 = mrad(origin_lon) + matan2(s_theta * s_ang * c_lat1, c_ang - s_lat1 * s_lat2)
    
    return mdeg(lat2), mdeg(lon2)
end



function GC_distance_kt(lat1, lon1, lat2, lon2)

    --This function returns great circle distance between 2 points.
    --Found here: http://bluemm.blogspot.gr/2007/01/excel-formula-to-calculate-distance.html
    --lat1, lon1 = the coords from start position (or aircraft's) / lat2, lon2 coords of the target waypoint.
    --6371km is the mean radius of earth in meters. Since X-Plane uses 6378 km as radius, which does not makes a big difference,
    --(about 5 NM at 6000 NM), we are going to use the same.
    --Other formulas I've tested, seem to break when latitudes are in different hemisphere (west-east).

    if lat1 == lat2 and lon1 == lon2 then
        return 0
    end

    local distance = macos(mcos(mrad(90-lat1))*mcos(mrad(90-lat2))+ msin(mrad(90-lat1))*msin(mrad(90-lat2))*mcos(mrad(lon1-lon2))) * (6378000/1852)

    return distance

end

function GC_distance_km(lat1, lon1, lat2, lon2)
    return GC_distance_kt(lat1, lon1, lat2, lon2) * 1.852
end


function get_distance_nm(lat1,lon1,lat2,lon2)
    return GC_distance_kt(lat1, lon1, lat2, lon2)
end

function get_bearing(lat1,lon1,lat2,lon2)
    local lat1_rad = mrad(lat1)
    local lat2_rad = mrad(lat2)
    local lon1_rad = mrad(lon1)
    local lon2_rad = mrad(lon2)

    local x = msin(lon2_rad - lon1_rad) * mcos(lat2_rad)
    local y = mcos(lat1_rad) * msin(lat2_rad) - msin(lat1_rad)*mcos(lat2_rad)*mcos(lon2_rad - lon1_rad)
    local theta = matan2(y, x)
    local brng = (theta * 180 / math.pi + 360) % 360

    return brng
end

function get_earth_bearing(lat1,lon1,lat2,lon2)
    return (90 - get_bearing(lat1,lon1,lat2,lon2)) % 360
end

function point_from_a_segment(x1, y1, x2, y2, distance)
    local den = math.sqrt((x2-x1)^2 + (y2-y1)^2)
    local t = distance / den
    local x3 = (1-t) * x1 + t * x2
    local y3 = (1-t) * y1 + t * y2

    return x3,y3
end

function point_from_a_segment_lat_lon(lat1, lon1, lat2, lon2, distance_nm)  -- APPROXIMATED! Only for short distances
    local den = get_distance_nm(lat1,lon1,lat2,lon2)
    local t = distance_nm / den
    local lat3 = (1-t) * lat1 + t * lat2
    local lon3 = (1-t) * lon1 + t * lon2

    return lat3, lon3
end

function point_from_a_segment_lat_lon_limited(lat1, lon1, lat2, lon2, distance_nm, limit)  -- APPROXIMATED! Only for short distances
    local den = get_distance_nm(lat1,lon1,lat2,lon2)
    local t = distance_nm / den
    t = math.min(limit, t)
    local lat3 = (1-t) * lat1 + t * lat2
    local lon3 = (1-t) * lon1 + t * lon2

    return lat3, lon3
end

function heading_difference(hdg1,hdg2) -- range -180 to 180, difference between 2 bearings, +ve is right turn, -ve is left.
    local turn = 0
        turn =  (hdg1-hdg2)%360
    turn = turn > 180 and (360-turn) or -turn
    return turn
end

function mid_point(lat1, lon1, lat2, lon2)
    return (lat1+lat2)/2,(lon1+lon2)/2
end

function convert_ddm_to_dd(ddm_lat, ddm_lon)

    local output_lat = 0
    local output_lon = 0

    if ddm_lat > 0 then
        ddm_lat = Round_fill(ddm_lat, 1)
        ddm_lat = Fwd_string_fill(ddm_lat, "0", 6)
        ddm_lat_degrees = tonumber(string.sub(ddm_lat, 1, 2))
        ddm_lat_minutes = tonumber(string.sub(ddm_lat, 3, 6))/60
        output_lat = ddm_lat_degrees + ddm_lat_minutes
    else
        ddm_lat = Round_fill(ddm_lat, 1)
        ddm_lat = string.sub(ddm_lat, 2, #ddm_lat) -- remove the negative sign
        ddm_lat = Fwd_string_fill(ddm_lat, "0", 6)
        ddm_lat_degrees = tonumber(string.sub(ddm_lat, 1, 2))
        ddm_lat_minutes = tonumber(string.sub(ddm_lat, 3, 6))/60
        output_lat = -(ddm_lat_degrees + ddm_lat_minutes)
    end

    if ddm_lon > 0 then
        ddm_lon = Round_fill(ddm_lon, 1)
        ddm_lon = Fwd_string_fill(ddm_lon, "0", 7)
        ddm_lon_degrees = tonumber(string.sub(ddm_lon, 1, 3))
        ddm_lon_minutes = tonumber(string.sub(ddm_lon, 4, 7))/60
        output_lon = ddm_lon_degrees  + ddm_lon_minutes
    else
        ddm_lon = Round_fill(ddm_lon, 1)
        ddm_lon = string.sub(ddm_lon, 2, #ddm_lon) -- remove the negative sign
        ddm_lon = Fwd_string_fill(ddm_lon, "0", 7)
        ddm_lon_degrees = tonumber(string.sub(ddm_lon, 1, 3))
        ddm_lon_minutes = tonumber(string.sub(ddm_lon, 4, 7))/60
        output_lon = -(ddm_lon_degrees + ddm_lon_minutes)
    end

    return output_lat, output_lon
end

function convert_dd_to_ddm(lat, lon) -- to check if it works
    local lat_decimals = lat - math.floor(math.abs(lat)) * (lat >= 0 and 1 or -1)
    local lat_minutes = lat_decimals * 60 / 100
    local lat_degrees = math.floor(math.abs(lat)) * (lat >= 0 and 1 or -1)
    local output_lat = (lat_degrees + lat_minutes)

    local lon_decimals = lon - math.floor(math.abs(lon)) * (lon >= 0 and 1 or -1)
    local lon_minutes = lon_decimals * 60 / 100
    local lon_degrees = math.floor(math.abs(lon)) * (lon >= 0 and 1 or -1)
    local output_lon = (lon_degrees + lon_minutes)

    return output_lat, output_lon
end

function crosstrack_error(lat1, lon1, lat2, lon2, ppos_lat, ppos_lon)
    angular_dist_AD = GC_distance_km(lat1, lon1, ppos_lat, ppos_lon) * 1000 / 6378137
    crs_AD = get_earth_bearing(lat1,lon1,ppos_lat,ppos_lon)
    crs_AB = get_earth_bearing(lat1,lon1, lat2, lon2)
    diff = heading_difference(crs_AB, crs_AD)
    diff = mrad(diff)
    XTD = (masin(msin((angular_dist_AD))*msin(diff))) * 6378137 / 1000  -- to km
    XTD = XTD / 1.852
    return XTD
end
