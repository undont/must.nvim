local refs = require("must.refs")

---@param line string
---@param pos [integer, integer]
---@return boolean|nil
local function follow_rfc_mention(line, pos)
    local rfc_num = refs.rfc_under_cursor(line, pos)
    if rfc_num then
        require("must.client").request(rfc_num)
        return true
    end
end

--- small wrapper around nvim_win_set_cursor that
--- adds a normal mark to add last pos to the
--- jumplist; use instead of nvim_win_set_cursor
---@param line integer
local function jump_to(line)
    vim.cmd("normal! m'")
    vim.api.nvim_win_set_cursor(0, { line, 0 })
end

---@param entries must.TocEntry[]
---@param pos [integer, integer]
---@return boolean|nil
local function follow_toc_entry(entries, pos)
    if entries then
        for _, e in ipairs(entries) do
            if e.toc_line == pos[1] then
                jump_to(e.line)
                return true
            end
        end
    end
end

---@param line string
---@param pos [integer, integer]
---@param entries must.TocEntry[]
---@param lines string[]
---@return boolean|nil
local function follow_citation(line, pos, entries, lines)
    local from = refs.reference_line(entries)
    if not from then
        return
    end
    local citation = refs.citation_under_cursor(line, pos)
    if not citation then
        return
    end
    local target = refs.find_citation_entry(lines, from, citation)
    if not target then
        return
    end
    jump_to(target)
    return true
end

---@param entries must.TocEntry[]
---@param section string
---@return boolean|nil
local function jump_to_section(entries, section)
    for _, e in ipairs(entries) do
        local entry = e.section:gsub("%.$", "")
        if entry == section then
            jump_to(e.line)
            return true
        end
    end
end

---@param line string
---@param pos [integer, integer]
---@param entries must.TocEntry[]
---@param lines string[]
---@return boolean|nil
local function follow_section_ref(line, pos, entries, lines)
    local section, new_rfc = refs.section_ref(line, pos, entries, lines)
    if section and new_rfc then
        require("must.client").request(new_rfc, function()
            local new_rfc_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            local new_rfc_entries = require("must.toc").get_entries(new_rfc_lines)
            if new_rfc_entries then
                if jump_to_section(new_rfc_entries, section) then
                    return
                end
            end
        end)
        return true
    end
    if section then
        if jump_to_section(entries, section) then
            return true
        end
    end
end

-- gd registered to jump to other RFCs (cursor on RFC) and
-- section headings via ToC entries
vim.keymap.set("n", "gd", function()
    local line = vim.api.nvim_get_current_line()
    local pos = vim.api.nvim_win_get_cursor(0)
    if follow_rfc_mention(line, pos) then
        return
    end
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local entries = require("must.toc").get_entries(lines)
    if entries then
        if follow_toc_entry(entries, pos) then
            return
        end
        if follow_section_ref(line, pos, entries, lines) then
            return
        end
        if follow_citation(line, pos, entries, lines) then
            return
        end
    end
    vim.notify("must: nothing to follow under cursor", vim.log.levels.WARN)
end, { buf = 0 })

-- keymap for opening/closing ToC
vim.keymap.set("n", "\\", function()
    vim.cmd(":Must toc")
end, { buf = 0 })
