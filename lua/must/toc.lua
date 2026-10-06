local M = {}

---@class must.TocEntry
---@field section string
---@field title string
---@field line integer
---@field toc_line integer

--- ToC headers can vary in casing/whitespace, this function
--- normalises and then returns the starting line number
---@param lines string[]
---@return integer|nil
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
---@return must.TocEntry[]
local function extract_toc_entries(content, start_idx)
    local res = {}
    -- entry rows are captured in the order they appear, each `not section`
    -- branch of this loop is checking for a different type of row
    -- 1. "1. Introduction"
    -- 2. "Appendix A. Collected ABNF"
    -- 3. "B.1. Changes from RFC ..."
    -- 4. "Index"
    for i = start_idx, #content do
        local line = content[i]
        local section, title = line:match("^%s*([%d%.]+)%s+(.-)[%s%.]*%d*$") -- 1
        if not section then -- 2
            section, title = line:match("^%s*(Appendix%s*%u%.)%s+(.-)[%s%.]*%d*$")
        end
        if not section then -- 3
            section, title = line:match("^%s*(%u%.[%d%.]+)%s+(.-)%s*%.*$")
        end
        if not section then -- 4
            title = line:match("^%s%s%s(%u.+)$")
            section = title and ""
        end
        local prev = content[i - 1]
        local indented_more = #line:match("^%s*") > #prev:match("^%s*")
        local prev_numbered = prev:match("^%s*%d") ~= nil
        local numbered = line:match("^%s*%d") ~= nil
        -- break out of the loop if the ToC is finished, i.e.
        -- concluding line is starting with a digit
        -- in column 0 unless it ends in a page number
        if line:match("^%d") and not line:match("%d$") then
            break
        end
        if section and title then
            local target = M.find_body_heading(content, i, section, title)
            if target then
                table.insert(res, {
                    section = section,
                    title = title,
                    line = target,
                    toc_line = i,
                })
            end
            -- if a ToC entry spans over two lines,
            -- append it to the previous entry's title
        elseif indented_more and prev_numbered and not numbered then
            line = line:match("^%s*(.-)%s*$")
            res[#res].title = res[#res].title .. " " .. line
        end
    end
    return res
end

--- starts after its own ToC entry and searches for
--- the heading in the body of the RFC
---@param content string[]
---@param after_index integer
---@param section string
---@param title string
---@return integer|nil
function M.find_body_heading(content, after_index, section, title)
    for i = after_index + 1, #content do
        local line = content[i]
        line = line:match("^%s*(.*)")
        if line:sub(1, #section) == section then
            line = line:sub(#section + 1)
            line = line:match("^[%s%.:]*(.*)")
            if line:sub(1, #title) == title then
                return i
            end
        end
    end
end

--- wrapper function for find_toc_start and extract_toc_entries
--- this should be the only way those are used outside of this
--- module
---@param lines string[]
---@return must.TocEntry[]|nil
function M.get_entries(lines)
    local toc_start = M.find_toc_start(lines)
    if not toc_start then
        return nil
    end
    return extract_toc_entries(lines, toc_start)
end

return M
