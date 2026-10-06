---@param line string
---@param pos [integer, integer]
---@return boolean|nil
local function follow_rfc_mention(line, pos)
    local rfc_regex = "RFC%s*(%d+)"
    local first, last, rfc_num = line:find(rfc_regex)
    while first do
        if pos[2] + 1 >= first and pos[2] + 1 <= last then
            require("must.client").request(rfc_num)
            return true
        end
        first, last, rfc_num = line:find("RFC%s*(%d+)", last + 1)
    end
end

---@param entries must.TocEntry[]
---@param pos [integer, integer]
---@return boolean|nil
local function follow_toc_entry(entries, pos)
    if entries then
        for _, e in ipairs(entries) do
            if e.toc_line == pos[1] then
                vim.api.nvim_win_set_cursor(0, { e.line, 0 })
                return true
            end
        end
    end
end

---@param entries must.TocEntry[]
---@param section string
---@return boolean|nil
local function jump_to_section(entries, section)
    for _, e in ipairs(entries) do
        local entry = e.section:gsub("%.$", "")
        if entry == section then
            vim.api.nvim_win_set_cursor(0, { e.line, 0 })
            return true
        end
    end
end

---@param line string
---@param pos [integer, integer]
---@param entries must.TocEntry[]
---@return boolean|nil
local function follow_section_ref(line, pos, entries)
    local section_regex = "[Ss]ection%s+(%d[%d%.]*)"
    local first, last, section = line:find(section_regex)
    while first and last do
        if pos[2] + 1 >= first and pos[2] + 1 <= last then
            section = section:gsub("%.$", "")
            local new_rfc = line:match("^%s+of%s+RFC%s*(%d+)", last + 1)
            if new_rfc then
                require("must.client").request(new_rfc, function()
                    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                    local new_rfc_entries = require("must.toc").get_entries(lines)
                    if new_rfc_entries then
                        if jump_to_section(new_rfc_entries, section) then
                            return
                        end
                    end
                end)
                return true
            end
            if jump_to_section(entries, section) then
                return true
            end
        end
        first, last, section = line:find(section_regex, last + 1)
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
        if follow_section_ref(line, pos, entries) then
            return
        end
    end
    vim.notify("must: nothing to follow under cursor", vim.log.levels.WARN)
end, { buf = 0 })

-- keymap for opening/closing ToC
vim.keymap.set("n", "\\", function()
    vim.cmd(":Must toc")
end, { buf = 0 })
