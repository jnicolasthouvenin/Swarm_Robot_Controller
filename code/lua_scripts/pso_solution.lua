
-----------------------------------------------------------------------------
------------------------------ README ---------------------------------------
-----------------------------------------------------------------------------

--[[ ATTENTION

    The code is structured as the following :

    > GENERAL TOOLS : basic functions used in the code to read
    files, construct rgb colors, computes angles... These are not important
    for understanding the controller.

    > GLOBAL VARIABLES : parameters and variables that are used globally for
    the robot. If you don't understand a variable, I hope the usage of this
    variable in the controller will clarify it.

    > COLLECTING INFORMATION : functions that read sensors and modify the
    global variables. For instance reading proximity sensors...

    > STATES AND JOBS : functions that switch from a job to another, and a
    state to another.

    > ACTION : function that make the robot do things. Moving and grabing
    mostly.

    > CONTROLLER : a big tree of conditions on the job and the state of the
    robot. Each combination of job and state has a set of instructions.
]]

-----------------------------------------------------------------------------
------------------------------ GENERAL TOOLS --------------------------------
-----------------------------------------------------------------------------

function init()
end

------------------------------ FILES ----------------------------------------

-- test if the given file exists
function file_exists(file)
    local f = io.open(file, "rb")
    if f then
        f:close()
    else
        log("[ERR] Can't open file " .. file)
    end
    return f ~= nil
end

-- return the lines from a given file as a table
function lines_from(file)
    if not file_exists(file) then
        return {}
    end
    lines = {}
    for line in io.lines(file) do
        lines[#lines + 1] = line
    end
    return lines
end

------------------------------ COLOR ----------------------------------------

-- convert a blob color table into a rgb color in string format
function blob_color_to_string_color(color)
    local red_str = tostring(color.red)
    local red_str = string.sub(red_str,1,string.len(red_str)-2)
    local green_str = tostring(color.green)
    local green_str = string.sub(green_str,1,string.len(green_str)-2)
    local blue_str = tostring(color.blue)
    local blue_str = string.sub(blue_str,1,string.len(blue_str)-2)
    local alpha_str = '0'
    return red_str .. ',' .. green_str .. ',' .. blue_str .. ',' .. alpha_str
end

-- test if the given color is the color of a robot
function is_robot(color)
    for i = 1,#ALL_ROBOTS_COLORS do
        if color == ALL_ROBOTS_COLORS[i] then
            return true
        end
    end
    return false
end

------------------------------ ANGLES ----------------------------------------

-- convert 2D vector to angle
-- used for computing the angles of the floor color censors
function coord_to_angle(x,y)
    return math.atan2(y, x)
end

-- convert an angle (1:24) in radians 
function to_radian(a)
    if a <= 12 then
        return ((a/12.5)*PI)
    else
        return (-((25-a)/12.5)*PI)
    end
end

------------------------------ TESTING IF INFORMATION IS USED IN THE STEP -----

--[[
    These functions test if the iteration needs collecting a specific information
    
    If the robot is in the STATE CACHING_NESTING, he won't need to read the ground
    color so we don't want to waste anytime reading the sensors
]]

function need_ground_color()
    return not(STATE == CACHING_NESTING or STATE == CACHING_NESTING_BACK or STATE == UNLOADING)
end

function need_closest_obstacle()
    return (STATE == READY or STATE == EXPLORING or STATE == WALK_AWAY or STATE == WAIT or STATE == WALK_AWAY_NESTING or CPT.global.current < PARAM.reach_light)
end

function need_closest_robot()
    return not(STATE == CACHING_NESTING or STATE == CACHING_NESTING_BACK or STATE == GRABING_NESTING or STATE == UNLOADING or STATE == FINISHING)
end

function need_closest_occupied_robot()
    return (STATE == EXPLORING or STATE == WAIT)
end

function need_closest_object()
    return (STATE == EXPLORING or STATE == WALK_AWAY or (JOB == NESTER and STATE == READY) or STATE == WAIT or STATE == CACHING_NESTING)
end

function need_light()
    return (STATE == GRABING or STATE == WALK_AWAY or STATE == WAIT or STATE == WALK_AWAY_NESTING or STATE == FINISHING or CPT.global.current < PARAM.reach_light)
end

function need_touching_object()
    return (STATE == EXPLORING or STATE == WAIT or STATE == CACHING_NESTING)
end

-----------------------------------------------------------------------------
------------------------------ GLOBAL VARIABLES -----------------------------
-----------------------------------------------------------------------------

------------------------------ CONSTANTS ------------------------------------
PI = 3.14159265359

-- angles in radians of the ground sensors
GROUND_ANGLES = { coord_to_angle(6.3,1.16), coord_to_angle(-6.3,1.16), coord_to_angle(-6.3,-1.16), coord_to_angle(6.3,-1.16)}

UNKNOWN = 'UNKNOWN'

-- JOBS
HUNTER = 'HUNTER'
NESTER = 'NESTER'
-- STATES
READY = 'READY' -- ready to start the job
-- STATES FOR HUNTERS
EXPLORING = 'EXPLORING' -- looking for objects to bring to the cache
HUNTING = 'HUNTING' -- found an object, hunting it
GRABING = 'GRABING' -- grabing object and bringing it to the cache
-- STATES FOR NESTERS
WAIT = 'WAIT' -- wait for objects to apear in the cache
CACHING_NESTING = 'CACHING_NESTING' -- walk into cache to get the object
CACHING_NESTING_BACK = 'CACHING_NESTING_BACK' -- walk back off the cache
GRABING_NESTING = 'GRABING_NESTING' -- grabing object and bringing it to the nest
WALK_AWAY_NESTING = 'WALK_AWAY_NESTING' -- walk at random to avoid tunnel vision on the object
UNLOADING = 'UNLOADING' -- unload the object in the nest in a proper robust way
FINISHING = 'FINISHING' -- walk around nest and put the items that are not in it, in it

-- COLORS
COLOR = {
    hunter = '255,255,255,0',
    nester = '0,255,0,0',
    do_not_disturb = '0,255,255,0',
    object = '255,0,0,0'
}

ALL_ROBOTS_COLORS = {COLOR.hunter,COLOR.nester}

------------------------------ PARAMETERS ------------------------------------
--[[
    True parameters are the 8 parameters assign by PSO
    The derivated parameters are parameters that have values that vary depending on the 8 true parameters

    Example : PARAM.distance_avoid_robot is a true parameter set by PSO.
    But DISTANCE_AVOID_ROBOT.close = PARAM.distance_avoid_robot/3.

    The derivated parameters are assigned during the first iteration, in the function load_parameters()
]]

-- TRUE PARAMETERS
PARAM = {
    speed,
    speed_walk_away,
    light_value_finishing,
    distance_avoid_robot,
    reach_light,
    start_job,
    to_finishing,
    to_waiter
}

-- SPEED PARAMETERS
SPEED_REVERSE = 200

-- SLOWDOWN RATIOS
SLOWDOWN = {
    turn_carrying_object = 0.7,
    walking_in_cache = 0.2,
    hunting = 0.4,
    in_nest = 0.5
}

-- DISTANCE PARAMETERS
DISTANCE_AVOID_ROBOT = {
    close,
    medium,
    high
}

-- LIGHT
LIGHT_VALUE_DROP = 0.95

-- Counters
CPT = {
    grabing          = { current = 0, max_for_hunter, max_for_nester },
    walk_away        = { current = 0, max },
    global           = { current = 0 },
    steping_in_cache = { current = 0, max },
    leaving_cache    = { current = 0, max },
    unloading        = { current = 0, backwards = 1, turn = 1+30, drop = 1+30+1, advance },
    reach_object     = { current = 0, max },
    finishing        = { current = 0 } -- set to 0 everytime an object is grabed, incremented every time 
}

function load_parameters()
    log("[INFO] Loading parameters")
    lines = lines_from("input/parameters.csv")

    -- Importing parameters
    PARAM.speed                 = math.floor(tonumber(lines[1]))
    PARAM.speed_walk_away       = math.floor(tonumber(lines[2]))
    PARAM.light_value_finishing = tonumber(lines[3])
    PARAM.distance_avoid_robot  = tonumber(lines[4])
    PARAM.reach_light           = tonumber(lines[5])
    PARAM.start_job             = math.floor(tonumber(lines[6]))
    PARAM.to_finishing          = math.floor(tonumber(lines[7]))
    PARAM.to_waiter             = math.floor(tonumber(lines[8]))

    -- Instanciating derivated parameters
    CPT.grabing.max_for_hunter = math.floor(5000/PARAM.speed)
    CPT.grabing.max_for_nester = math.floor(10000/PARAM.speed)
    CPT.walk_away.max          = math.floor(3600/PARAM.speed_walk_away)
    CPT.steping_in_cache.max   = math.floor(225/(PARAM.speed*SLOWDOWN.walking_in_cache))
    CPT.leaving_cache.max      = math.floor(600/(PARAM.speed*SLOWDOWN.walking_in_cache))
    CPT.unloading.advance      = 1+30+math.floor(500/PARAM.speed)
    CPT.reach_object.max       = math.floor(3000/PARAM.speed)

    DISTANCE_AVOID_ROBOT.close  = PARAM.distance_avoid_robot/3
    DISTANCE_AVOID_ROBOT.medium = PARAM.distance_avoid_robot/2
    DISTANCE_AVOID_ROBOT.high   = PARAM.distance_avoid_robot*2
end

------------------------------ VARIABLES ------------------------------------

STATE = READY
JOB = NESTER -- the robot first think he is a nester, it will transform if it sees an object

-- Pseudo constants : they will be assign once the robot will be sure of their value
FLOOR = {
    cache = UNKNOWN, -- color/value of the cache
    nest  = UNKNOWN,
    temp  = UNKNOWN -- color/value stored by the robot when it only has seen one floor color
}

-- Obstacle avoidance
OBSTACLE = {
    sensed   = false, -- if an obstacle is sensed
    angle    = 0, -- angle of the closest obstacle
    distance = 0 -- distance of the closest obstacle
}

-- Robot avoidance
ROBOT = {
    sensed   = false, -- if an robot is sensed
    angle    = 0, -- angle of the closest robot
    distance = 0 -- distance of the closest robot
}

-- Occupied robot avoidance
OCCUPIED_ROBOT = {
    sensed   = false,
    angle    = 0,
    distance = 0
}

-- Object foraging
OBJECT = {
    sensed   = false,
    angle    = 0,
    distance = 0
}

-- Light detection
LIGHT = {
    sensed = false,
    angle  = 0,
    value  = 0
}

-- grey areas detection
GREY = {
    sensed = false,
    angles = {false,false,false,false},
    value  = 0
}

-- Object gripping
IS_TOUCHING_OBJECT_WITH_GRIPPER = false
IS_GRABING_OBJECT = false

-----------------------------------------------------------------------------------
------------------------------ Collecting information -----------------------------
-----------------------------------------------------------------------------------

--[[
    The next functions are used to collect information on specific sensors.
    They are called at the beginning of each step and store their results in global variables.
    For example, after calling check_closest_obstacle(), OBSTACLE.sensed is equal to true if
    an obstacle is detected.

    The "check" functions don't make any actions. They only read the sensors of the robots and
    store the information found.
]]

------------------------------ PROXIMITY ------------------------------------------

-- Gives information on the closest obstacle detected
function check_closest_obstacle()
    OBSTACLE.sensed = false
    OBSTACLE.angle = 0
    OBSTACLE.distance = 0

    for i = 1,24 do
        if robot.proximity[i].value > OBSTACLE.distance then
            OBSTACLE.distance = robot.proximity[i].value
            OBSTACLE.sensed = true
            OBSTACLE.angle = to_radian(i)
        end
    end
end

------------------------------ OMNIDIRECTION CAMERA -------------------------------

-- Gives information on the closest robot detected
function check_closest_robot()
    ROBOT.sensed = false
    ROBOT.angle = 0
    ROBOT.distance = 1000000

    local blob
    local rgb_color

    for i = 1,#robot.colored_blob_omnidirectional_camera do
        blob = robot.colored_blob_omnidirectional_camera[i]
        rgb_color = blob_color_to_string_color(blob.color)
        if is_robot(rgb_color) then
            if blob.distance < ROBOT.distance then
                ROBOT.distance = blob.distance
                ROBOT.sensed = true
                ROBOT.angle = blob.angle
            end
        end
    end
end

-- Gives information on the closest robot detected that is carrying an object
function check_closest_occupied_robot()
    OCCUPIED_ROBOT.sensed = false
    OCCUPIED_ROBOT.angle = 0
    OCCUPIED_ROBOT.distance = 1000000

    local blob
    local rgb_color

    for i = 1,#robot.colored_blob_omnidirectional_camera do
        blob = robot.colored_blob_omnidirectional_camera[i]
        rgb_color = blob_color_to_string_color(blob.color)
        if rgb_color == COLOR.do_not_disturb then
            if blob.distance < OCCUPIED_ROBOT.distance then
                OCCUPIED_ROBOT.sensed = true
                OCCUPIED_ROBOT.angle = blob.angle
                OCCUPIED_ROBOT.distance = blob.distance
            end
        end
    end
end

-- Gives information on the closest object detected
function check_closest_object()
    OBJECT.sensed = false
    OBJECT.angle = 0
    OBJECT.distance = 1000000

    local blob
    local rgb_color

    for i = 1,#robot.colored_blob_omnidirectional_camera do
        blob = robot.colored_blob_omnidirectional_camera[i]
        rgb_color = blob_color_to_string_color(blob.color)
        if rgb_color == COLOR.object then
            if blob.distance < OBJECT.distance then
                OBJECT.sensed = true
                OBJECT.angle = blob.angle
                OBJECT.distance = blob.distance
            end
        end
    end
end

-- Test if the robot is touching an object with it's gripper (necessary before locking the gripper)
function check_touch_object_with_gripper()
    IS_TOUCHING_OBJECT_WITH_GRIPPER = false

    local min_distance = 1000000
    local blob
    local rgb_color

    for i = 1,#robot.colored_blob_omnidirectional_camera do
        blob = robot.colored_blob_omnidirectional_camera[i]
        rgb_color = blob_color_to_string_color(blob.color)
        if rgb_color == COLOR.object then -- we see an object
            if math.abs(blob.angle-robot.turret.rotation) < 0.3 then -- it's in front of the robot
                if blob.distance < min_distance then -- it's the closest (for now)
                    min_distance = blob.distance
                end
            end
        end
    end

    if min_distance < 19 then
        IS_TOUCHING_OBJECT_WITH_GRIPPER = true
    end
end

------------------------------ LIGHT ----------------------------------------

-- Measure ambiant light
function check_light()
    LIGHT.sensed = false
    LIGHT.angle = 0
    LIGHT.value = 0
    for i = 1,24 do
        if robot.light[i].value > LIGHT.value then
            LIGHT.value = robot.light[i].value
            LIGHT.sensed = true
            LIGHT.angle = to_radian(i)
        end
    end
end

------------------------------ COLOR GROUND ---------------------------------

-- Measure ground color
function check_ground_color()
    GREY.sensed = false
    GREY.angles = {false,false,false,false}
    GREY.value = 0

    for i = 1,4 do
        if robot.motor_ground[i].value < 1 then
            GREY.sensed = true
            GREY.value = robot.motor_ground[i].value
            GREY.angles[i] = true
        end
    end
end

----------------------------------------------------------------------------
------------------------------ STATES AND JOBS -----------------------------
----------------------------------------------------------------------------

--[[
    Here are the basic functions to switch from a job (resp. state) to the other.
    Each switch change the corresponding global variable and reset counters when it is necessary.
    In addition, the velocity of robot is set to (0,0) to encure a precise control over it's movements.

    We don't comment those functions because they are self explanatory
]]

-- Launch the robot job
function start_job(job)
    job = job or JOB
    if JOB == HUNTER then
        switch_state_exploring()
    elseif JOB == NESTER then
        switch_state_wait()
    end
end

------------------------------ HUNTERS -----------------------------

function switch_job_hunter()
    JOB = HUNTER
    STATE = READY
    robot.wheels.set_velocity(0,0)
end

function switch_state_exploring()
    STATE = EXPLORING
    robot.wheels.set_velocity(0,0)
end

function switch_state_grabing()
    STATE = GRABING
    CPT.grabing.current = 0
    robot.wheels.set_velocity(0,0)
end

function switch_state_walk_away()
    STATE = WALK_AWAY
    CPT.walk_away.current = 0
    robot.wheels.set_velocity(0,0)
end

------------------------------ NESTERS -----------------------------

function switch_job_nester()
    JOB = NESTER
    STATE = READY
    robot.wheels.set_velocity(0,0)
end

function switch_state_wait()
    STATE = WAIT
    CPT.finishing.current = 0
    robot.wheels.set_velocity(0,0)
end

function switch_state_grabing_nesting()
    STATE = GRABING_NESTING
    CPT.grabing.current = 0
    CPT.finishing.current = 0 -- The robot has grabed an object so he won't be a finishing soon
    robot.wheels.set_velocity(0,0)
end

function switch_state_caching_nesting()
    STATE = CACHING_NESTING
    CPT.steping_in_cache.current = 0
    robot.wheels.set_velocity(0,0)
end

function switch_state_caching_nesting_back()
    STATE = CACHING_NESTING_BACK
    CPT.leaving_cache.current = 0
    robot.wheels.set_velocity(0,0)
end

function switch_state_unloading()
    STATE = UNLOADING
    CPT.unloading.current = 0
    robot.wheels.set_velocity(0,0)
end

function switch_state_walk_away_nesting()
    STATE = WALK_AWAY_NESTING
    CPT.walk_away.current = 0
    robot.wheels.set_velocity(0,0)
end

function switch_state_finishing()
    STATE = FINISHING
    CPT.finishing.current = 0
    robot.wheels.set_velocity(0,0)
end

-------------------------------------------------------------------
------------------------------ ACTION -----------------------------
-------------------------------------------------------------------

--[[
    The action functions make the robot do actual things : move, rotate, lock and unlock gripper.
]]

--[[ ON THE USAGE OF ACTION METHODS AND SWITCHS
    Note that some action functions use the same robots attributs (e.g. avoid() and reach() use the wheels)
    In every step, it is crucial to not use more than one function that uses the same attribut.
    If in the controller we call avoid() and then reach(). The modifications of the wheels velocity made
    by avoid() will thus be canceled.

    It's however possible to use in the same step functions that don't strongly interact with each
    other (e.g reach() and reach_with_gripper()). In fact, reach_with_gripper() is the only function that
    can be called in the same step of another action method, because it doesn't set the wheels velocity.

    In addition, it is depreciated to use a "move" method in the same step as a switch function as the switch
    will cancel the move and set the velocity to (0,0).

    In the actual controller, switchs are called alone or following static action methods like drop_object() or grab_object()
]]

-- Make the robot turn to avoid the given angle
function avoid(angle,slowdown_ratio)
    slowdown_ratio = slowdown_ratio or 1 -- default value

    local slowdown_near_cache = 1

    if LIGHT.sensed and LIGHT.value > LIGHT_VALUE_DROP then
        slowdown_near_cache = 0.5
    end

    local_speed = PARAM.speed*slowdown_ratio*slowdown_near_cache
    
    if angle == 0 then -- the obstacle is in front of the robot, no time to turn, we do a almost complete 180
        robot.wheels.set_velocity(SPEED_REVERSE,-SPEED_REVERSE)
    elseif angle >= 0 then --the thing to avoid comes from the left
        if angle <= (PI/2) then
            robot.wheels.set_velocity(local_speed,-local_speed*(angle)/PI)
        else
            robot.wheels.set_velocity(local_speed,local_speed*(PI-angle)/PI)
        end
    else
        if angle >= (-PI/2) then
            robot.wheels.set_velocity(local_speed*(-angle)/PI,local_speed)
        else
            robot.wheels.set_velocity(local_speed*(PI+angle)/PI,local_speed)
        end
    end
end

-- Make the robot turn to avoid grey area
-- The many conditions make it difficult to understand the function but it is actually very basic
-- The robot looks at which parts of it's body are in the grey area and turn in a way that's gonna
-- help him get out of it.
function avoid_grey()
    if (GREY.angles[1]) and (GREY.angles[2]) and (GREY.angles[3]) and (GREY.angles[4]) then -- middle of grey spot
        if OBSTACLE.sensed then avoid(OBSTACLE.angle)
        else walk_foward()
        end
    elseif (GREY.angles[1]) and (GREY.angles[2]) and (GREY.angles[3]) then avoid(3*PI/4)
    elseif (GREY.angles[2]) and (GREY.angles[3]) and (GREY.angles[4]) then avoid(-3*PI/4)
    elseif (GREY.angles[3]) and (GREY.angles[4]) and (GREY.angles[1]) then avoid(-PI/4)
    elseif (GREY.angles[4]) and (GREY.angles[1]) and (GREY.angles[2]) then avoid(PI/4)
    elseif (GREY.angles[1]) and (GREY.angles[2]) then avoid(-PI/2)
    elseif (GREY.angles[2]) and (GREY.angles[3]) then walk_foward()
    elseif (GREY.angles[3]) and (GREY.angles[4]) then avoid(PI/2)
    elseif (GREY.angles[4]) and (GREY.angles[1]) then avoid(0)
    elseif GREY.angles[1] then avoid(PI/4)
    elseif GREY.angles[2] then avoid(3*PI/4)
    elseif GREY.angles[3] then avoid(-3*PI/4)
    elseif GREY.angles[4] then avoid(-PI/4)
    else
        if OBSTACLE.sensed then avoid(OBSTACLE.angle)
        else walk_foward()
        end
    end
end

-- The opposite of avoid: the robot turns towards the angle
function reach(angle,slowdown_ratio)
    slowdown_ratio = slowdown_ratio or 1 -- default value
    
    local_speed = PARAM.speed*slowdown_ratio

    -- to be able to turn quickly, when abs(angle) > PI/2, one wheel go backwards
    if angle >= 0 then --the thing to reach comes from the left
        robot.wheels.set_velocity((PI-2*angle)*local_speed/PI,local_speed)
    else
        robot.wheels.set_velocity(local_speed,(PI+2*angle)*local_speed/PI)
    end
end

-- Rotate the gripper to target the given angle (important to grab an object eficiently)
function reach_with_gripper(angle)
    robot.turret.set_position_control_mode()
    robot.turret.set_rotation(angle)
end

-- Just makes the robot advance in a straight line
function walk_foward()
    if STATE == WALK_AWAY or STATE == WALK_AWAY_NESTING then
        robot.wheels.set_velocity(PARAM.speed_walk_away,PARAM.speed_walk_away)
    else
        robot.wheels.set_velocity(PARAM.speed,PARAM.speed)
    end
end

-- Makes the robot go backwards in a straight line
function walk_backwards(slowdown_ratio)
    slowdown_ratio = slowdown_ratio or 1
    robot.wheels.set_velocity(-PARAM.speed*slowdown_ratio,-PARAM.speed*slowdown_ratio)
end

-- Lock the gripper of the robot
function grab_object()
    if (not(IS_GRABING_OBJECT)) and (IS_TOUCHING_OBJECT_WITH_GRIPPER) then
        robot.wheels.set_velocity(0,0)
        robot.gripper.lock_negative()
        IS_GRABING_OBJECT = true
        CPT.grabing.current = 0
    end
end

-- Unlock the gripper to drop the object
function drop_object()
    robot.wheels.set_velocity(0,0)
    robot.gripper.unlock()
    IS_GRABING_OBJECT = false
    CPT.grabing.current = 0
end

------------------------------------------------------------------------
------------------------------ Controllers -----------------------------
------------------------------------------------------------------------

function script_1()
    robot.colored_blob_omnidirectional_camera.enable() -- enable camera
    robot.turret.set_passive_mode()

    -- Turning on the leds
    if JOB == HUNTER then robot.leds.set_single_color(13,COLOR.hunter) end
    if JOB == NESTER then robot.leds.set_single_color(13,COLOR.hunter) end
    if STATE == GRABING or STATE == GRABING_NESTING or STATE == CACHING_NESTING or STATE == CACHING_NESTING_BACK or STATE == UNLOADING then
        robot.leds.set_single_color(13,COLOR.do_not_disturb)
    end
    
    -- Collecting information : we don't read all the sensors all the time, only the one we need for the current iteration. This allows to save a little bit of computation time
    if need_ground_color()           then check_ground_color() end
    if need_closest_obstacle()       then check_closest_obstacle() end
    if need_closest_robot()          then check_closest_robot() end
    if need_closest_occupied_robot() then check_closest_occupied_robot() end
    if need_closest_object()         then check_closest_object() end
    if need_light()                  then check_light() end
    if need_touching_object()        then check_touch_object_with_gripper() end

    -- Passing through the router
    CPT.global.current = CPT.global.current + 1 -- update global counter
    ------------------------------------------------------------------------------------------------------------
    ------------------------------------------ SHUFFLE ROBOTS --------------------------------------------------
    ------------------------------------------------------------------------------------------------------------
    if CPT.global.current < PARAM.reach_light then -- first try reaching the light, avoid having robots stuck behind the nest
        if OBSTACLE.sensed then
            avoid(OBSTACLE.angle)
        elseif LIGHT.sensed then
            reach(LIGHT.angle)
        else
            walk_foward()
        end
    ------------------------------------------------------------------------------------------------------------
    ------------------------------------------ START WORKING ---------------------------------------------------
    ------------------------------------------------------------------------------------------------------------
    elseif CPT.global.current == PARAM.start_job then
        start_job()
    ------------------------------------------------------------------------------------------------------------
    ---------------------------------------- HUNTER CONTROLLER -------------------------------------------------
    ------------------------------------------------------------------------------------------------------------
    elseif JOB == HUNTER then


        -- Secure the fact that he is truly a hunter (if he sees a second floor color, he's a nester, not a hunter)
        if (STATE ~= READY) and (GREY.sensed) and (FLOOR.cache == UNKNOWN) then
            if not(FLOOR.temp == UNKNOWN) then
                if FLOOR.temp > GREY.value then -- the new value is the nest but this means that the robot is a nester
                    FLOOR.nest = GREY.value
                    FLOOR.cache = FLOOR.temp
                    start_job(NESTER)
                elseif FLOOR.temp < GREY.value then -- the new value is the cache but this means that the robot is a nester
                    FLOOR.cache = GREY.value
                    FLOOR.nest = FLOOR.temp
                    start_job(NESTER)
                end
            end
        end


        -- The job hasn't started yet, the hunter operate a simple obstacle and robot avoidance
        if STATE == READY then
            if CPT.global.current >= PARAM.start_job then
                start_job()
            elseif GREY.sensed then
                avoid_grey()
            elseif OBSTACLE.sensed then
                avoid(OBSTACLE.angle)
            elseif (ROBOT.sensed) and (ROBOT.distance < DISTANCE_AVOID_ROBOT.close) then
                avoid(ROBOT.angle)
            else
                walk_foward()
            end


        -- The hunter explores the search space, go towards objects and grab them if it is in front of them
        elseif STATE == EXPLORING then
            if GREY.sensed then
                avoid_grey()
            elseif not(OBJECT.sensed) then -- not object detected, just avoid every thing
                if OBSTACLE.sensed then
                    avoid(OBSTACLE.angle)
                elseif (ROBOT.sensed) and (ROBOT.distance < PARAM.distance_avoid_robot) then
                    avoid(ROBOT.angle)
                else
                    walk_foward()
                end
            elseif not(IS_TOUCHING_OBJECT_WITH_GRIPPER) then -- object detected, try to reach it, avoiding the robots
                if OCCUPIED_ROBOT.sensed and OCCUPIED_ROBOT.distance < DISTANCE_AVOID_ROBOT.high then
                    avoid(OCCUPIED_ROBOT.angle)
                elseif ROBOT.sensed and ROBOT.distance < OBJECT.distance then -- if another robot is behind the object, just avoid it
                    avoid(ROBOT.angle)
                else -- no obstacles, go towards the object
                    reach(OBJECT.angle,SLOWDOWN.hunting) -- move towards the object
                    reach_with_gripper(OBJECT.angle) -- rotate the gripper towards the object
                end
            else -- object touch from the front, we now need to grab it
                grab_object()
                switch_state_grabing()
            end


        -- The hunter has grabed the object and needs now to bring it to the middle of the arena (where the light is located)
        elseif STATE == GRABING then
            CPT.grabing.current = CPT.grabing.current + 1
            reach_with_gripper(0) -- rotate the gripper in front of the hunter to put it right in the middle

            if GREY.sensed then -- the hunter touched the cache zone, drops the object and walk away
                drop_object()
                switch_state_walk_away()
            elseif CPT.grabing.current > CPT.grabing.max_for_hunter then -- time limit exceeded, the robot drops the object
                drop_object()
                switch_state_walk_away()
            elseif LIGHT.sensed then -- there is light ! follow it !
                if ROBOT.sensed and ROBOT.distance < DISTANCE_AVOID_ROBOT.medium then
                    avoid(ROBOT.angle,SLOWDOWN.turn_carrying_object)
                else
                    reach(LIGHT.angle,SLOWDOWN.turn_carrying_object)
                end
            else -- no light... walk foward
                if ROBOT.sensed and ROBOT.distance < DISTANCE_AVOID_ROBOT.medium then
                    avoid(ROBOT.angle,SLOWDOWN.turn_carrying_object)
                else
                    walk_foward()
                end
            end


        -- The hunter just droped an object and needs to walk away from it (to avoid staying stuck on it)
        elseif STATE == WALK_AWAY then
            CPT.walk_away.current = CPT.walk_away.current + 1
            if GREY.sensed then
                avoid_grey()
            elseif CPT.walk_away.current < CPT.walk_away.max then
                if OBSTACLE.sensed then
                    avoid(OBSTACLE.angle)
                elseif ROBOT.sensed and ROBOT.distance < PARAM.distance_avoid_robot then
                    avoid(ROBOT.angle)
                elseif LIGHT.sensed then
                    avoid(LIGHT.angle)
                else
                    walk_foward()
                end
            else -- the walk away phase ends, the hunter can explore again
                switch_state_exploring()
            end
        end


    ------------------------------------------------------------------------------------------------------------
    ---------------------------------------- NESTER CONTROLLER -------------------------------------------------
    ------------------------------------------------------------------------------------------------------------
    elseif JOB == NESTER then


        -- The nester is ready to start it's job, proceed to a basic obstacle and robot avoidance walk
        if STATE == READY then -- every robot starts here
            reach_with_gripper(0)
            if CPT.global.current >= PARAM.start_job then
                start_job()
            elseif GREY.sensed then
                -- Can the robot figure out if it is the cache or the nest yet ?
                if FLOOR.temp == UNKNOWN then -- first time we see a color on the floor, we can't know yet
                    FLOOR.temp = GREY.value
                elseif FLOOR.temp > GREY.value then -- the new value is the nest
                    FLOOR.nest = GREY.value
                    FLOOR.cache = FLOOR.temp
                elseif FLOOR.temp < GREY.value then -- the new value is the cache
                    FLOOR.cache = GREY.value
                    FLOOR.nest = FLOOR.temp
                end
                -- Figure out where to go to avoid the grey area (we don't want the robots to leave their space)
                avoid_grey()
            elseif not(OBJECT.sensed) then
                if OBSTACLE.sensed then
                    avoid(OBSTACLE.angle)
                elseif (ROBOT.sensed) and (ROBOT.distance < DISTANCE_AVOID_ROBOT.close) then
                    avoid(ROBOT.angle)
                else
                    walk_foward()
                end
            else -- object detected, becomes a hunter
                switch_job_hunter()
            end


        -- The nester waits for objects to appear in the cache
        elseif STATE == WAIT then
            CPT.finishing.current = CPT.finishing.current + 1
            reach_with_gripper(0)
            if CPT.finishing.current > PARAM.to_finishing then
                switch_state_finishing()
            elseif GREY.sensed then -- grey area
                if GREY.value == FLOOR.nest then
                    if OBSTACLE.sensed then
                        avoid(OBSTACLE.angle,SLOWDOWN.in_nest)
                    elseif LIGHT.sensed then
                        reach(LIGHT.angle)
                    else
                        walk_foward()
                    end
                elseif (not(OBJECT.sensed)) or (FLOOR.cache == UNKNOWN) then -- avoid empty cache
                    avoid_grey()
                else -- step in cache if there is an object in it
                    switch_state_caching_nesting()
                end
            elseif not(OBJECT.sensed) then -- not object detected, just avoid every thing and reach light
                if OBSTACLE.sensed then
                    avoid(OBSTACLE.angle)
                elseif (OCCUPIED_ROBOT.sensed) and (OCCUPIED_ROBOT.distance < DISTANCE_AVOID_ROBOT.high) then
                    avoid(OCCUPIED_ROBOT.angle)
                elseif (ROBOT.sensed) and (ROBOT.distance < PARAM.distance_avoid_robot) then
                    avoid(ROBOT.angle)
                elseif LIGHT.sensed then
                    reach(LIGHT.angle)
                else
                    walk_foward()
                end
            elseif not(IS_TOUCHING_OBJECT_WITH_GRIPPER) then -- object detected, try to reach it, avoiding the robots
                CPT.reach_object.current = CPT.reach_object.current + 1
                if (CPT.reach_object.current < CPT.reach_object.max) then
                    if (OCCUPIED_ROBOT.sensed) and (OCCUPIED_ROBOT.distance < DISTANCE_AVOID_ROBOT.medium) then
                        avoid(OCCUPIED_ROBOT.angle, SLOWDOWN.hunting)
                    elseif (ROBOT.sensed) and (ROBOT.distance < OBJECT.distance) then
                        avoid(ROBOT.angle, SLOWDOWN.hunting)
                    else
                        reach(OBJECT.angle,SLOWDOWN.hunting) -- move towards the object
                        reach_with_gripper(OBJECT.angle) -- rotate the gripper towards the object
                    end
                else
                    CPT.reach_object.current = 0
                    switch_state_walk_away_nesting()
                end
            else -- object touch from the front, we now need to grab it
                grab_object()
                switch_state_grabing_nesting()
            end


        -- The nester step into the cache to reach the object, grab it if he can
        elseif STATE == CACHING_NESTING then
            CPT.steping_in_cache.current = CPT.steping_in_cache.current + 1
            if CPT.steping_in_cache.current > CPT.steping_in_cache.max then
                switch_state_caching_nesting_back()
            elseif not(IS_TOUCHING_OBJECT_WITH_GRIPPER) then
                reach(OBJECT.angle,SLOWDOWN.walking_in_cache)
                reach_with_gripper(OBJECT.angle)
            else
                grab_object()
                switch_state_caching_nesting_back()
            end


        -- The nester leaves cache walking backwards, if he has an object he switches to grabing_nesting, otherwise switch to wait
        elseif STATE == CACHING_NESTING_BACK then
            CPT.leaving_cache.current = CPT.leaving_cache.current + 1
            if CPT.leaving_cache.current > CPT.leaving_cache.max then
                if IS_GRABING_OBJECT then
                    switch_state_grabing_nesting()
                else
                    switch_state_wait()
                end
            else
                walk_backwards(SLOWDOWN.walking_in_cache)
            end


        -- The nester has grabed an object and proceed to reach the nest
        elseif STATE == GRABING_NESTING then
            CPT.grabing.current = CPT.grabing.current + 1
            if GREY.sensed then -- the nest ! unload properly
                switch_state_unloading()
            elseif CPT.grabing.current > CPT.grabing.max_for_nester then -- it's time to drop the object, we won't find the nest anyway
                drop_object()
                switch_state_walk_away_nesting()
            else
                walk_backwards()
            end


        -- The nester has reached the nest and start unloading the object in a robust way
        elseif STATE == UNLOADING then
            CPT.unloading.current = CPT.unloading.current + 1
            if CPT.unloading.current <= CPT.unloading.backwards then -- first phase of unloading, walk backwards into the nest
                walk_backwards()
            elseif CPT.unloading.current <= CPT.unloading.turn then -- second phase, turning turret around
                robot.wheels.set_velocity(0,0)
                reach_with_gripper(PI)
            elseif CPT.unloading.current <= CPT.unloading.drop then -- third phase, droping object
                drop_object()
            elseif CPT.unloading.current <= CPT.unloading.advance then -- walk foward
                walk_foward()
            else
                switch_state_walk_away_nesting()
            end


        -- The nester needs to walk away from an object for a period of time
        elseif STATE == WALK_AWAY_NESTING then
            reach_with_gripper(0)
            CPT.walk_away.current = CPT.walk_away.current + 1
            if CPT.walk_away.current >= CPT.walk_away.max then
                switch_state_wait()
            elseif GREY.sensed then
                avoid_grey()
            else
                if OBSTACLE.sensed then
                    avoid(OBSTACLE.angle)
                elseif (ROBOT.sensed) and (ROBOT.distance < PARAM.distance_avoid_robot) then
                    avoid(ROBOT.angle)
                elseif (LIGHT.sensed) then
                    reach(LIGHT.angle)
                else
                    walk_foward()
                end
            end

            
        -- The nester has waited a lot for nothing and decides to come near the nest, see if he can find objects to put in it
        elseif STATE == FINISHING then
            CPT.finishing.current = CPT.finishing.current + 1
            if CPT.finishing.current > PARAM.to_waiter then
                switch_state_wait()
            elseif GREY.sensed then
                avoid_grey()
            elseif LIGHT.sensed and LIGHT.value > PARAM.light_value_finishing then
                avoid(LIGHT.angle)
            else
                walk_foward()
            end
        end
    end
end
 
function step()
    if CPT.global.current == 0 then
        load_parameters()
    end
    script_1()
end

function reset()
end

function destroy()
end
