local M = {}

---@class must.IndexEntry
---@field rfc_num string
---@field rfc_label string
---@field obsoleted_by string|nil
---@field obsoletes string|nil

---@param lines string[]
---@return string[]
local function join_blocks(lines)
    local res = {}
    local entry = ""
    for _, line in ipairs(lines) do
        if line ~= "" then
            -- trim leading/trailing whitespace
            -- from line before appending to entry
            line = line:match("^%s*(.-)%s*$")
            -- when entry already contains line
            -- from first pass add a whitespace
            -- separator
            if entry == "" then
                entry = entry .. line
            else
                entry = entry .. " " .. line
            end
        else
            table.insert(res, entry)
            entry = ""
        end
    end
    return res
end

---@param lines string[]
---@return must.IndexEntry[]
function M.parse(lines)
    local entries = {}
    for _, line in ipairs(join_blocks(lines)) do
        local rfc_num = line:match("^(%d+)")
        local rfc_label = line:match("^%d+ (.-%u%l+ %d%d%d%d%.)")
        local obsoleted_by = line:match("%([O]bsoleted%sby%s*(.-)%)")
        local obsoletes = line:match("%([O]bsoletes%s*(.-)%)")
        if rfc_num and rfc_label then
            table.insert(entries, {
                rfc_num = rfc_num,
                rfc_label = rfc_label,
                obsoleted_by = obsoleted_by,
                obsoletes = obsoletes,
            })
        end
    end
    return entries
end

return M
