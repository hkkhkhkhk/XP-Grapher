--DEFAULT DATAREFS

override = globalProperty("sim/operation/override/override_flightcontrol")
elevator = globalProperty("sim/flightmodel2/controls/pitch_ratio")
aileron = globalProperty("sim/flightmodel2/controls/roll_ratio")
rudder = globalProperty("sim/flightmodel2/controls/heading_ratio")

pitch_trim = globalProperty("sim/flightmodel/controls/elv_trim")
throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio_all")
slip = globalProperty("sim/cockpit2/gauges/indicators/sideslip_degrees")
ra = globalProperty("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_copilot")

gs_dot = globalProperty("sim/cockpit/radios/nav1_vdef_dot")

pitch = globalProperty("sim/cockpit2/gauges/indicators/pitch_AHARS_deg_pilot")
roll = globalProperty("sim/cockpit2/gauges/indicators/roll_AHARS_deg_pilot")
roll_rate = globalProperty("sim/flightmodel/position/P")	
pitch_rate = globalProperty("sim/flightmodel/position/Q")	
yaw_rate = globalProperty("sim/flightmodel/position/R")

load_factor = globalProperty("sim/flightmodel/forces/g_nrml")

DELTA_TIME = globalProperty("sim/operation/misc/frame_rate_period")
TIME = globalProperty("sim/time/total_running_time_sec")

APDIAL_vs = globalProperty("sim/cockpit2/autopilot/vvi_dial_fpm")
APDIAL_hdg = globalProperty("sim/cockpit/autopilot/heading_mag")

ias = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
accel = globalProperty("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_copilot")
gs = globalProperty("sim/flightmodel/position/groundspeed")
alpha = globalProperty("sim/flightmodel/position/alpha")
alt = globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
vvi = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
hdg = globalProperty("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")

mains_on_ground = globalProperty("sim/flightmodel2/gear/on_ground[1]")
paused = globalProperty("sim/time/sim_speed")

ppos_lat = globalProperty("sim/flightmodel/position/latitude")
ppos_lon = globalProperty("sim/flightmodel/position/longitude")

---DEFAULT COMMANDS

---CUSTOM DATAREFS

master_rotary_position = createGlobalPropertyf("simpleins/master_rot_pos", 0, false, true, false)
big_rotary_position = createGlobalPropertyf("simpleins/big_rot_pos", 0, false, true, false)
scroller_position = createGlobalPropertyf("simpleins/scroller", 0, false, true, false)
