position= {0 , 0 , 1400 , 500}
size = {1400 , 500}

local what_to_plot = {
    {
        drf = "sim/flightmodel2/controls/pitch_ratio",
        colour = {1,1,0,1},
        scale_factor = 6,
        offset = 0,
    },
    {
        drf = "sim/flightmodel/forces/g_nrml",
        colour = {1,0,1,1},
        scale_factor = 4,
        offset = -1,
    },
    {
        drf = "sim/flightmodel/position/Q",
        colour = {0,1,1,1},
        scale_factor = 1,
        offset = 0,
    },
}

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

local function prelim_prep()
    for i=1, #what_to_plot do

        what_to_plot[i].drf = globalProperty(what_to_plot[i].drf)

    fader = function(colour) 
        foo = {}
        for i=1, #colour do
            foo[i] = colour[i] * 0.7
        end
        return foo
    end
        colour = what_to_plot[i].colour
        what_to_plot[i]["faded_colour"] = fader(what_to_plot[i]["colour"])
    end
end
prelim_prep()

---------------------------------------------------------------------------------------------------

local range = {x=6, y=1}
local graph_data_points = {}
local cursor_x, cursor_y = 0,0
local crosshair_enabled = false


function onMouseMove(_, x, y)
	cursor_x = x
    cursor_y = y
end

function onMouseWheel( component,x ,y ,button ,parentX ,parentY ,value)

    local rescale_x = within(x, 80, 1340) and within(y, 282, 190)
    local rescale_y = within(x, 20, 134) and within(y, 33, 471)

    if rescale_y then
        range.y = math.max(range.y + value, 1) -- prioritising rescaling the vertical axis
    elseif rescale_x then
        range.x = math.max(range.x + value, 1)
    end
end

function onMouseDown( component,  x,  y, button,  parentX,  parentY)

    if within(x, 1160, 1160+120) and within(y, 20, 20+50) then -- clear graph
        for k, v in pairs(graph_data_points) do
            graph_data_points[k] = nil
        end
    end

    if within(x,  1400-30, 1400) and within(y, 500-30, 500) then -- the top right cross exit
        UI:setIsVisible(false)
    end

    if within(x,  1160-160, 1160-160+150) and within(y, 20, 20+50) then -- the cursor toggle
        crosshair_enabled = not crosshair_enabled
    end
end


local function proportionally_resize()
    if UI:isVisible() then
        local window_x, window_y, window_width, window_height = UI:getPosition()
        UI:setPosition ( window_x , window_y , window_width, window_width)
    end
end

local function draw_x_axis()
    sasl.gl.drawWideLine(100 , 250 , 1300, 250,2,  {1,1,1,0.5})

    local last_drawn_height = 100
    for i=0, range.x do

        local marking_height = i/range.x * 1200 + 100

        dist = marking_height - last_drawn_height

        if dist > 150 then
            sasl.gl.drawWideLine( marking_height, 260 , marking_height, 240, 2, {1,1,1,0.5})
            sasl.gl.drawText(sevenseg_font, marking_height, 215, i, 20, false, false, TEXT_ALIGN_CENTER, {1,1,1,0.5})       
            last_drawn_height = marking_height
        end
    end

end

local function draw_y_axis()
    sasl.gl.drawWideLine(100 , 50 , 100, 450,2,  {1,1,1,0.5})
    local last_drawn_height = 250
    for i=0, range.y do

        local marking_height = i/range.y * 200 + 250
        local marking_height_opposite = -i/range.y * 200 + 250

        dist = marking_height - last_drawn_height

        if dist > 30 then
            sasl.gl.drawWideLine( 90, marking_height , 105, marking_height, 2, {1,1,1,0.5})
            sasl.gl.drawText(sevenseg_font, 75, marking_height - 20/2, i, 20, false, false, TEXT_ALIGN_RIGHT, {1,1,1,0.5})       
            if i ~= 0 then
                sasl.gl.drawWideLine( 90, marking_height_opposite , 105, marking_height_opposite, 2, {1,1,1,0.5})
                sasl.gl.drawText(sevenseg_font, 75, marking_height_opposite - 20/2, -i, 20, false, false, TEXT_ALIGN_RIGHT, {1,1,1,0.5})    
            end
            last_drawn_height = marking_height
        end
    end
    sasl.gl.drawWideLine( 90, 250 , 105, 250, 2, {1,1,1,0.5})
    sasl.gl.drawText(sevenseg_font, 75, 250 - 20/2, 0, 20, false, false, TEXT_ALIGN_RIGHT, {1,1,1,0.5})    
end

local function time2x(time)
    return time/range.x * 1200 + 100
end

local function x2time(x)
    return Math_clamp((x - 100)/1200*range.x, 0, range.x)
end

local function val2y(val)
    return val/range.y * 200 + 250
end

local function return_graph_values()

    local results = {}

    for j=1, #graph_data_points do -- how many graphs are there
        if graph_data_points[j] ~= nil then -- graph data exists
            buff = {}
            
            for i=1, #graph_data_points[j] do 
                buff[j] = buff[j] or {}
                buff[j][i] = graph_data_points[j][i].time -- copy time onto buffer table
                --print(graph_data_points[1][i].time)
            end
                -- we now have a table called "buff" full of times
            if buff[j] ~= nil then
                if #buff[j] ~= 0 then
                    local idx, diff, closest = find_closest(buff[j], get(TIME) - x2time(cursor_x)) 
                    results[j] =  graph_data_points[j][idx].val
                end
            end
        end
    end
    return results
end

local function draw_crosshair(tbl)
    if crosshair_enabled then
        local crosshair_x = Math_clamp(cursor_x, 100, 1300)
        local crosshair_y = Math_clamp(cursor_y, 50, 450)
        sasl.gl.drawWideLine(100 , crosshair_y , 1300, crosshair_y,2,  {1,1,1,0.8})
        sasl.gl.drawWideLine(crosshair_x , 50 , crosshair_x, 450,2,  {1,1,1,0.8})

        graph_values = return_graph_values()

        for i=1, #graph_values do
            sasl.gl.drawText(sevenseg_font, crosshair_x-17, crosshair_y-40 - (i-1) * 23, Round(graph_values[i]/tbl[i].scale_factor, 2), 20, false, false, TEXT_ALIGN_RIGHT, tbl[i].colour)  
        end
    end
end

local function draw_graph(tbl)

    for j=1, #tbl do

        graph_data_points[j] = graph_data_points[j] or {}

        if get(DELTA_TIME) > 0 then
            table.insert(graph_data_points[j], {time = get(TIME), val = tbl[j].scale_factor * (get(tbl[j].drf) + tbl[j].offset)})  
        end

        for i=1, #graph_data_points[j] do
            if get(TIME)-graph_data_points[j][1].time > range.x then
                table.remove(graph_data_points[j], 1)
            end
        end
        --print(graph_data_points[table_insert_pos].time, graph_data_points[table_insert_pos].val)
        for i=1, #graph_data_points[j] do
            if i-1 ~= 0 then
                sasl.gl.drawWideLine(time2x(get(TIME)-graph_data_points[j][i].time), val2y(graph_data_points[j][i].val) ,time2x(get(TIME)-graph_data_points[j][i-1].time), val2y(graph_data_points[j][i-1].val),  6, tbl[j].faded_colour)
                sasl.gl.drawWideLine(time2x(get(TIME)-graph_data_points[j][i].time), val2y(graph_data_points[j][i].val) ,time2x(get(TIME)-graph_data_points[j][i-1].time), val2y(graph_data_points[j][i-1].val),  2, tbl[j].colour)
            end
        end
    end
end

local function draw_popup_elements()
    sasl.gl.drawRectangle ( 0 , 0 , 1400-30, 500 , {0,0,0,0.3} )
    sasl.gl.drawRectangle ( 1400-30 , 0 , 30, 500-30 , {0,0,0,0.3} )
    sasl.gl.drawRectangle ( 1160 ,20 ,120 ,50 , {0.6,0.6,0.6,0.6} )
    Sasl_DrawWideFrame(1160 ,20 ,120 ,50 , 2, 0, {1,1,1,0.6})
    sasl.gl.drawRectangle ( 1160-160 ,20 ,150 ,50 , {0.6,0.6,0.6,0.6} )
    Sasl_DrawWideFrame(1160-160 ,20 ,150 ,50 , 2, 0, {1,1,1,0.6})
    sasl.gl.drawRectangle ( 1400-30 , 500-30 , 30, 30 , {1,0,0,0.7} )

    sasl.gl.drawWideLine(1400-30+2 , 500-30+2 , 1400-2, 500-2,2,  {1,1,1,0.5})
    sasl.gl.drawWideLine(1400-30+2 , 500-2 , 1400-2, 500-30+2,2,  {1,1,1,0.5})

    draw_x_axis()
    draw_y_axis()
end

function draw()
    proportionally_resize()
    draw_popup_elements()
    draw_graph(what_to_plot)
    draw_crosshair(what_to_plot)
end

function update()
    return_graph_values()
    --print(cursor_x, cursor_y)
    -- local foo = return_graph_values()
    -- for i=1, #foo do
    --     print(foo[i])
    -- end
end