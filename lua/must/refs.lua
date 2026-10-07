local M = {}

---@param line string
---@param pos [integer, integer]
---@return string|nil
function M.citation_under_cursor(line, pos)
    local first, last, citation = line:find("(%[[%w/%.%-]+%])")
    while first do
        if pos[2] + 1 >= first and pos[2] + 1 <= last then
            return citation
        end
        first, last, citation = line:find("(%[[%w/%.%-]+%])", last + 1)
    end
end

---@param line string
---@param pos [integer, integer]
---@return string|nil
function M.rfc_under_cursor(line, pos)
    local rfc_regex = "RFC%s*(%d+)"
    local first, last, rfc_num = line:find(rfc_regex)
    while first do
        if pos[2] + 1 >= first and pos[2] + 1 <= last then
            return rfc_num
        end
        first, last, rfc_num = line:find(rfc_regex, last + 1)
    end
end

---@param entries must.TocEntry[]
---@return integer|nil
function M.reference_line(entries)
    for _, e in ipairs(entries) do
        if e.title == "References" then
            return e.line
        end
    end
end

---@param lines string[]
---@param from integer
---@param citation string
---@return integer|nil
function M.find_citation_entry(lines, from, citation)
    for i = from, #lines do
        local line = lines[i]:match("^%s*(.*)")
        if line:sub(1, #citation) == citation then
            return i
        end
    end
end

---@param lines string[]
---@param entries must.TocEntry[]
---@param citation string
function M.citation_rfc(lines, entries, citation)
    local from = M.reference_line(entries)
    if not from then
        return
    end
    local start = M.find_citation_entry(lines, from, citation)
    if not start then
        return
    end
    for i = start, #lines do
        local line = lines[i]
        if line:match("^%s*$") then
            return nil
        end
        local rfc = line:match("RFC%s*(%d+)")
        if rfc then
            return rfc
        end
    end
end

---@param line string
---@param pos [integer, integer]
---@param entries must.TocEntry[]
---@param lines string[]
---@return string|nil, string|nil
function M.section_ref(line, pos, entries, lines)
    local section_regex = "[Ss]ection%s+(%d[%d%.]*)"
    local first, last, section = line:find(section_regex)
    while first and last do
        if pos[2] + 1 >= first and pos[2] + 1 <= last then
            section = section:gsub("%.$", "")
            local new_rfc = line:match("^%s+of%s+RFC%s*(%d+)", last + 1)
            if not new_rfc then
                local citation = line:match("^%s+of%s+(%[[%w/%.%-]+%])", last + 1)
                if citation then
                    new_rfc = M.citation_rfc(lines, entries, citation)
                end
            end
            return section, new_rfc
        end
        first, last, section = line:find(section_regex, last + 1)
    end
end

return M
