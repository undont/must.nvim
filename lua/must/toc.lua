local M = {}

---@param lines string[]
function M.find_toc_start(lines)
    for i, line in ipairs(lines) do
        line = line:lower()
        line = line:match("^%s*(.-)%s*$")
        if line:match("^contents$") or line:match("^table of contents$") then
            return i
        end
    end
end

---@param content string[]
---@param start_idx integer
---@return table
function M.extract_toc_entries(content, start_idx)
    local res = {}
    for i = start_idx, #content do
        local line = content[i]
        local number, title = line:match("^%s*([%d%.]+)%s+(.-)[%s%.]*%d*$")
        if not number then
            number, title = line:match("^%s*(Appendix%s*%u%.)%s+(.-)[%s%.]*%d*$")
        end
        if not number then
            number, title = line:match("^%s*(%u%.[%d%.]+)%s+(.-)%s*%.*$")
        end
        if not number then
            title = line:match("^%s%s%s(%u.+)$")
            number = title and ""
        end
        local prev = content[i - 1]
        local indented_more = #line:match("^%s*") > #prev:match("^%s*")
        local prev_numbered = prev:match("^%s*%d") ~= nil
        local numbered = line:match("^%s*%d") ~= nil
        if line:match("^%d") and not line:match("%d$") then
            break
        end
        if number and title then
            local target = M.find_body_heading(content, i, number, title)
            if target then
                table.insert(res, { number = number, title = title, line = target })
            end
        elseif indented_more and prev_numbered and not numbered then
            line = line:match("^%s*(.-)%s*$")
            res[#res].title = res[#res].title .. " " .. line
        end
    end
    return res
end

---@param content string[]
---@param after_index integer
---@param section_num string
---@param title string
function M.find_body_heading(content, after_index, section_num, title)
    for i = after_index + 1, #content do
        local line = content[i]
        line = line:match("^%s*(.*)")
        if line:sub(1, #section_num) == section_num then
            line = line:sub(#section_num + 1)
            line = line:match("^[%s%.:]*(.*)")
            if line:sub(1, #title) == title then
                return i
            end
        end
    end
end

return M
