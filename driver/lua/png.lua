local driver = require"driver"
local image = require"image"
local chronos = require"chronos"
local blue = require"blue"

local unpack = unpack or table.unpack
local floor = math.floor

-- Output formatted string to stderr
local function stderr(...)
    io.stderr:write(string.format(...))
end

-- Create driver with all Lua functions needed to build
-- the scene description
local _M = driver.new()

-- This is one of the functions you must implement. It
-- receives a scene and a viewport. It returns an
-- acceleration datastructure that contains all scene
-- information in a form that enables fast sampling.
-- For now, it simply returns the scene itself.
function _M.accelerate(scene, viewport)
    return scene
end

--  This is the other function you have to implement.
--  It receives the acceleration datastructure, the sampling pattern,
--  and a sampling position. It returns the color at that position.
local function supersample(accel, pattern, x, y)
    -- Implement your own version
    return 0,0,0,1
end

local function parseargs(args)
    local parsed = {
        pattern = blue[1],
        tx = 0,
        ty = 0,
        p = nil,
        dumpcellsprefix = nil,
    }
    -- Available options
    local options = {
        -- Selects a supersampling pattern
        { "^(%-pattern:(%d+)(.*))$", function(all, n, e)
            if not n then return false end
            assert(e == "", "trail invalid option " .. all)
            n = assert(tonumber(n), "number invalid option " .. all)
            assert(blue[n], "non exist invalid option " .. all)
            parsed.pattern = blue[n]
            return true
        end },
        -- Select a single path for rendering
        { "^(%-p:(%d+)(.*))$", function(all, n, e)
            if not n then return false end
            assert(e == "", "trail invalid option " .. all)
            parsed.p = assert(tonumber(n), "number invalid option " .. all)
            return true
        end },
        -- Translates scene by tx,ty pixels before rendering
        { "^(%-tx:(%-?%d+)(.*))$", function(all, n, e)
            if not n then return false end
            assert(e == "", "trail invalid option " .. all)
            parsed.tx = assert(tonumber(n), "number invalid option " .. all)
            return true
        end },
        { "^(%-ty:(%-?%d+)(.*))$", function(all, n, e)
            if not n then return false end
            assert(e == "", "trail invalid option " .. all)
            parsed.ty = assert(tonumber(n), "number invalid option " .. all)
            return true
        end },
        -- Dump cells matching a given prefix
        { "^%-dumpcells:(.*)$", function(n)
            if not n then return false end
            parsed.dumpcellsprefix = n
            return true
        end },
        -- Catch all unrecognized options and throw error
        { ".*", function(all)
            error("unrecognized option " .. all)
        end }
    }
    -- Process options
    for i, arg in ipairs(args) do
        for j, option in ipairs(options) do
            if option[2](arg:match(option[1])) then
                break
            end
        end
    end
    -- Return parsed values
    return parsed
end

-- In theory, you don't have to change this function.
-- It simply allocates the image, samples each pixel center,
-- and saves the image into the file.
function _M.render(scene, viewport, file, args)
    local parsed = parseargs(args)
    local pattern = parsed.pattern
    -- Get viewport
    local vxmin, vymin, vxmax, vymax = unpack(viewport, 1, 4)
    -- Get image width and height from viewport
    local width, height = vxmax-vxmin, vymax-vymin
    -- Allocate output image
    local img = image.image(width, height, 4)
local time = chronos.chronos()
    -- Rendering loop
    for i = 1, height do
stderr("\r%5g%%", floor(1000*i/height)/10)
        local y = vymin+i-1.+.5
        for j = 1, width do
            local x = vxmin+j-1.+.5
            img:set_pixel(j, i, supersample(scene, pattern, x, y))
        end
    end
stderr("\n")
stderr("rendering in %.3fs\n", time:elapsed())
time:reset()
    -- store output image
    image.png.store8(file, img)
stderr("saved in %.3fs\n", time:elapsed())
end

return _M
