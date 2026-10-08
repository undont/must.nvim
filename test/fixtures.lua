local M = {}

M.rfc2616 = "rfc2616.txt"
M.rfc9110 = "rfc9110.txt"
M.rfc1945 = "rfc1945.txt"
M.rfc3986 = "rfc3986.txt"
M.rfc791 = "rfc791.txt"
M.rfc_index = "rfc-index.txt"

---@param name string
---@return string[]
function M.read(name)
    local lines = {}
    for line in io.lines("test/fixtures/" .. name) do
        table.insert(lines, line)
    end
    return lines
end

---@generic T
---@param entries T[]
---@param field string
---@param value string
---@return T|nil
function M.find_entry(entries, field, value)
    for _, e in ipairs(entries) do
        if e[field] == value then
            return e
        end
    end
end

return M
