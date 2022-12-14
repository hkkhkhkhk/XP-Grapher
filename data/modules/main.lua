-- main.lua


sasl.options.setAircraftPanelRendering(true)
sasl.options.setInteractivity(true)
sasl.options.set3DRendering(true)

-- devel
sasl.options.setLuaErrorsHandling(SASL_STOP_PROCESSING)

-- Initialize the random seed for math.random
math.randomseed( os.time() )

include("functions.lua")
include("datarefs.lua")
include("constants.lua")
include("libs/geo-helpers.lua")
include("libs/global_functions.lua")
include("libs/graphics_helpers.lua")


components = {
	--ins_window{},
}


function Show_hide_UI()
    UI:setIsVisible(not UI:isVisible())
end

 Menu_master	= sasl.appendMenuItem (PLUGINS_MENU_ID, "Graphs" )
 Menu_main	= sasl.createMenu ("", PLUGINS_MENU_ID, Menu_master)
 ShowHideFBWUI	= sasl.appendMenuItem(Menu_main, "Show/Hide Graph Display", Show_hide_UI)

 UI = contextWindow {
     name = "ACCELEROMETER";
     position = { (1920-1400)/2 , 30 , 1400 , 500};
     noBackground = true ;
     proportional = false ;
     maximumSize = {1400 , 500};
     minimumSize = {1400 , 500};
     noDecore = true ;
     gravity = { 0 , 1 , 0 , 1 };
     visible = true ;
     components = {
		graphing_window {position = { 0 , 0 , 1400 , 500}}
     };
   }