---@diagnostic disable: undefined-global

--local new = function(weights)
NewWeights = function(weights)
    local instance = {
        item_pool = weights or {},
    }
    function instance:total_weight()
        local weight_sum = 0
        for _,item in ipairs(self.item_pool) do
            weight_sum = weight_sum + item.weight
        end
        return weight_sum
    end

    function instance:random()
        local weight_sum = self:total_weight()
        --print("WR", weight_sum)
        local weight_remaining = RandomFloat(0, weight_sum)
        for _,item in ipairs(self.item_pool) do
            weight_remaining = weight_remaining - item.weight
            if weight_remaining < 0 then
                --print("WR", "returning random", item)
                return item
            end
        end
    end

    return instance
end

--return {
--    new = new
--}