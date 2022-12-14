function Math_clamp(val, min, max)
    if min > max then LogWarning("Min is larger than Max invalid") end
    if val < min then
        return min
    elseif val > max then
        return max
    elseif val <= max and val >= min then
        return val
    end
end

function Math_clamp_lower(val, min)
    if val < min then
        return min
    elseif val >= min then
        return val
    end
end

function Math_clamp_higer(val, max)
    if val > max then
        return max
    elseif val <= max then
        return val
    end
end

function Table_interpolate(tab, x)
    local a = 1
    local b = #tab
    assert(b > 1)

    -- Simple cases
    if x <= tab[a][1] then
        return tab[a][2]
    end
    if x >= tab[b][1] then
        return tab[b][2]
    end

    local middle = 1

    while b-a > 1 do
        middle = math.floor((b+a)/2)
        local val = tab[middle][1]
        if val == x then
            break
        elseif val < x then
            a = middle
        else
            b = middle
        end
    end

    if x == tab[middle][1] then
        -- Found a perfect value
        return tab[middle][2]
    else
        -- (y-y0) / (y1-y0) = (x-x0) / (x1-x0)
        return tab[a][2] + ((x-tab[a][1])*(tab[b][2]-tab[a][2]))/(tab[b][1]-tab[a][1])
    end
end

function Table_extrapolate(tab, x)  -- This works like Table_interpolate, but it estimates the values
    -- even if x < minimum value of x > maximum value according to the
    -- last segment available

local a = 1
local b = #tab

assert(b > 1)

if x < tab[a][1] then
return Math_rescale_no_lim(tab[a][1], tab[a][2], tab[a+1][1], tab[a+1][2], x) 
end
if x > tab[b][1] then
return Math_rescale_no_lim(tab[b][1], tab[b][2], tab[b-1][1], tab[b-1][2], x) 
end

return Table_interpolate(tab, x)

end

function Set_anim_value(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
    end

end

function Set_anim_value_no_lim(current_value, target, speed)
    return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
end

function Math_cycle(val, start, finish)
    if start > finish then logWarning("start is larger than finish, invalid") end

    if val < start then
        return finish
    elseif val > finish then
        return start
    elseif val <= finish and val >= start then
        return val
    end
end

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Round_fill(num, numDecimalPlaces)
    return string.format("%."..numDecimalPlaces.."f", Round(num, numDecimalPlaces))
end

function Fwd_string_fill(string_to_fill, string_to_fill_it_with, to_what_length)
    assert(type(string_to_fill) == "string", "string_to_fill is a " .. type(string_to_fill) .. "!")
    assert(type(string_to_fill_it_with) == "string", "string_to_fill_it_with is a " .. type(string_to_fill_it_with) .. "!")
    assert(type(to_what_length) == "number", "to_what_length is a " .. type(to_what_length) .. "!")
    local curr_length = UTF8_str_len(string_to_fill)
    for i = curr_length, to_what_length - 1 do
        string_to_fill = string_to_fill_it_with .. string_to_fill
    end

    return string_to_fill
end

--append string_to_fill_it_with to the end of a string to achive the length of to_what_length
function Aft_string_fill(string_to_fill, string_to_fill_it_with, to_what_length)
    assert(type(string_to_fill) == "string", "string_to_fill is a " .. type(string_to_fill) .. "!")
    assert(type(string_to_fill_it_with) == "string", "string_to_fill_it_with is a " .. type(string_to_fill_it_with) .. "!")
    assert(type(to_what_length) == "number", "to_what_length is a " .. type(to_what_length) .. "!")

    local curr_length = UTF8_str_len(string_to_fill)
    for i = curr_length, to_what_length - 1 do
        string_to_fill = string_to_fill .. string_to_fill_it_with
    end

    return string_to_fill
end


function drawTextCentered(font, x, y, string, size, isbold, isitalic, alignment, colour)
    sasl.gl.drawText (font, x, y - (size/3),string, size, isbold, isitalic, alignment, colour)
end

function heading_difference(hdg1,hdg2) -- range -180 to 180, difference between 2 bearings, +ve is right turn, -ve is left.
    local turn = 0
        turn =  (hdg1-hdg2)%360
    turn = turn > 180 and (360-turn) or -turn
    return turn
end

function SASL_rotated_center_img_center_aligned(image, x, y, width, height, angle, center_x_offset, center_y_offset, color)
    sasl.gl.drawRotatedTextureCenter (image, angle, x, y, x - width / 2 + center_x_offset, y - height / 2 + center_y_offset, width, height, color)
end

function within(x, val1, val2)
    larger = math.max(val1, val2)
    smaller = math.min(val1, val2)
    within_bool = x >= smaller and x <= larger
    return within_bool
end

function find_closest(tbl, val)
    local stored_index = 1
    local best_difference = val-tbl[1]
    local closest = tbl[1]
    for i=2, #tbl do
      local new_difference = tbl[i]-val
      if math.abs(new_difference) < math.abs(best_difference) then
        best_difference = new_difference
        stored_index = i
        closest = tbl[i]
      end
    end
    return stored_index, best_difference, closest
  end

  function table_dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. table_dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
