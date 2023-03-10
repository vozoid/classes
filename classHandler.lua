local clone = table.clone

-- class registrarion
local classRegistry = {}
local classFunctions = {}
local classHandlers = {}
local classKeeps = {}

local function registerClass(class, default, removeMt)
    classRegistry[class] = default
    classFunctions[class] = {}
    classKeeps[class] = not removeMt
end

local function registerClassFunction(class, name, handler)
    classFunctions[class][name] = handler
end

local function registerClassHandler(class, handler)
    classHandlers[class] = handler
end

local function cloneClass(classToClone, class, defaultsToMerge)
    classRegistry[class] = classRegistry[classToClone]

    for i, v in next, defaultsToMerge do
        classRegistry[class][i] = v
    end

    classFunctions[class] = classFunctions[classToClone]
    classKeeps[class] =  classKeeps[classToClone]
    classHandlers[class] = classHandlers[classToClone]
end

local function new(class)
    local object

    -- why so unclean :(
    if classKeeps[class] then
        object = setmetatable(clone(classRegistry[class]), {__index = function(self, key)
            return rawget(self, key) or (classFunctions[class][key] and function(...)
                classFunctions[class][key](self, ...)
            end)
        end})
    else
        object = clone(classRegistry[class])
    end

    if classHandlers[class] then
        classHandlers[class](object)
    end

    return object
end

local function exportClass(class)
    return {name = class, default = classRegistry[class], functions = classFunctions[class], handler = classHandlers[class], keepsMt = classKeeps[class]}
end

local function importClass(class)
    registerClass(class.name, class.default, not class.keepsMt)

    for name, handler in next, class.functions do
        registerClassFunction(class.name, name, handler)
    end

    registerClassHandler(class.name, class.handler)
end

return new, registerClass, registerClassHandler, registerClassFunction, exportClass, importClass, cloneClass
