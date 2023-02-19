local new, registerClass, registerClassHandler, registerClassFunction, exportClass, importClass = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/classes/main/classHandler.lua"))()
local signalClass = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/classes/main/signal/export.lua"))()

importClass(signalClass)

-- https://www.desmos.com/calculator/m8myals511
local wrap = coroutine.wrap
local wait = task.wait
local find, remove, clone = table.find, table.remove, table.clone
local sqrt, sin, pi, halfpi, doublepi = math.sqrt, math.sin, math.pi, math.pi / 2, math.pi * 2

-- math constants
local s = 1.70158
local s1 = 2.5949095

local p = 0.3
local p1 = 0.45

-- easing formulas
local easingStyles={linear={["in"]=function(x)return x end,out=function(x)return x end,inOut=function(x)return x end},cubic={["in"]=function(x)return x^3 end,out=function(x)return(x-1)^3+1 end,inOut=function(x)if x<=0.5 then return(4*x)^3 else return(4*(x-1))^3+1 end end},quad={["in"]=function(x)return x^2 end,out=function(x)return-(x-1)^2+1 end,inOut=function(x)if x<=0.5 then return(2*x)^2 else return(-2*(x-1))^2+1 end end},quart={["in"]=function(x)return x^4 end,out=function(x)return-(x-1)^4+1 end,inOut=function(x)if x<=0.5 then return(8*x)^4 else return(-8*(x-1))^4+1 end end},quint={["in"]=function(x)return x^5 end,out=function(x)return(x-1)^5+1 end,inOut=function(x)if x<=0.5 then return(16*x)^5 else return(16*(x-1))^5+1 end end},sine={["in"]=function(x)return sin(halfpi*x-halfpi)end,out=function(x)return sin(halfpi*x)end,inOut=function(x)return 0.5*sin(pi*x-pi/2)+0.5 end},exponential={["in"]=function(x)return 2^(10*x-10)-0.001 end,out=function(x)return 1.001*-2^(-10*x)+1 end,inOut=function(x)if x<=0.5 then return 0.5*2^(20*x-10)-0.0005 else return 0.50025*-2^(-20*x+10)+1 end end},back={["in"]=function(x)return x^2*(x*(s+1)-s)end,out=function(x)return(x-1)^2*((x-1)*(s+1)+s)+1 end,inOut=function(x)if x<=0.5 then return(2*x*x)*((2*x)*(s1+1)-s1)else return 0.5*((x*2)-2)^2*((x*2-2)*(s1+1)+s1)+1 end end},bounce={["in"]=function(x)if x<=0.25/2.75 then return-7.5625*(1-x-2.625/2.75)^2+0.015625 elseif x<=0.75/2.75 then return-7.5625*(1-x-2.25/2.75)^2+0.0625 elseif x<=1.75/2.75 then return-7.5625*(1-x-1.5/2.75)^2+0.25 else return 1-7.5625*(1-x)^2 end end,out=function(x)if x<=1/2.75 then return 7.5625*(x*x)elseif x<=2/2.75 then return 7.5625*(x-1.5/2.75)^2+0.75 elseif x<=2.5/2.75 then return 7.5625*(x-2.25/2.75)^2+0.9375 else return 7.5625*(x-2.625/2.75)^2+0.984375 end end,inOut=function(x)if x<=0.125/2.75 then return 0.5*(-7.5625*(1-x*2-2.625/2.75)^2+0.015625)elseif x<=0.375/2.75 then return 0.5*(-7.5625*(1-x*2-2.25/2.75)^2+0.0625)elseif x<=0.875/2.75 then return 0.5*(-7.5625*(1-x*2-1.5/2.75)^2+0.25)elseif x<=0.5 then return 0.5*(1-7.5625*(1-x*2)^2)elseif x<=1.875/2.75 then return 0.5+3.78125*(2*x-1)^2 elseif x<=2.375/2.75 then return 3.78125*(2*x-4.25/2.75)^2+0.875 elseif x<=2.625/2.75 then return 3.78125*(2*x-5/2.75)^2+0.96875 else return 3.78125*(2*x-5.375/2.75)^2+0.9921875 end end},elastic={["in"]=function(x)return-2^(10*(x-1))*sin(doublepi*(x-1-p/4)/p)end,out=function(x)return 2^(-10*x)*sin(doublepi*(x-p/4)/p)+1 end,inOut=function(x)if x<=0.5 then return-0.5*2^(20*x-10)*sin(doublepi*(x*2-1.1125)/p1)else return 0.5*2^(-20*x+10)*sin(doublepi*(x*2-1.1125)/p1)+1 end end},circular={["in"]=function(x)return-(1-x^2)^0.5+1 end,out=function(x)return(-(x-1)^2+1)^0.5 end,inOut=function(x)if x<=0.5 then return-(-x^2+0.25)^0.5+0.5 else return(-(x-1)^2+0.25)^0.5+0.5 end end}}

-- tweening
local render = game:GetService("RunService").RenderStepped

local function lerp(value1, value2, alpha)
    if type(value1) == "number" then
        return value1 + ((value2 - value1) * alpha)
    end
        
    return value1:lerp(value2, alpha)
end

registerClass("Tween", {completed = new "Signal", cancelled = false, object = nil, time = 1, style = "linear", direction = "out", properties = {}})

registerClassFunction("Tween", "play", function(self)
    local easingFunction = easingStyles[self.style][self.direction]
    local propertyCount = 0

    for _, _ in next, self.properties do
        propertyCount++
    end

    local currentIndex = 0
    for property, value in next, self.properties do
        currentIndex++
        local start_value = self.object[property]

        wrap(function()
            local elapsed = 0
            while elapsed <= self.time and not self.cancelled do            
                local delta = elapsed / self.time

                -- Do the chosen EasingStyle's math
                local alpha = easingFunction(delta)

                wrap(function()
                    self.object[property] = lerp(start_value, value, alpha)
                end)()
                print(self.object[property])

                elapsed += render:Wait()
            end
            
            if not self.cancelled then
                self.object[property] = value
            end

            if currentIndex == propertyCount and not self.cancelled then
                self.completed.fire()
            end
        end)()
    end
end)

registerClassFunction("Tween", "cancel", function(self)
    self.cancelled = true
end)

return exportClass("Tween")
