local client = require("must.client")
local toc = require("must.toc")
local index = require("must.index")
local config = require("must.config")

--- namespace for the section extmark in open_toc
local toc_ns = vim.api.nvim_create_namespace("must_toc")

---@type table<integer, integer>
local toc_map = {}

---@type table<integer, [integer, integer]>
local cursor_pos = {}

---@param section string
local function depth(section)
    local n = 0
    for _ in section:gmatch("[^.]+") do
        n = n + 1
    end
    return n
end

---@param tabpage integer
local function close_toc(tabpage)
    vim.api.nvim_win_close(toc_map[tabpage], true)
    toc_map[tabpage] = nil
end

--- opens up ToC and handles assigning the `<CR>` keymap and
--- the "\" keymap for toggling CLOSED
---@param tabpage integer
---@param focus boolean
local function open_toc(tabpage, focus)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local buf_name = vim.api.nvim_buf_get_name(0)
    local toc_entries = toc.get_entries(lines)
    if not toc_entries then
        vim.notify("must: no Table of Contents found", vim.log.levels.WARN)
        return
    end
    ---@type table<integer, string>
    local entries = {}
    ---@type table<integer, integer>
    local indents = {}
    for _, e in ipairs(toc_entries) do
        -- calculate indent (leading whitespace)
        -- multiplier is for indent size
        local indent = string.rep(" ", (depth(e.section) - 1) * 2)
        table.insert(indents, #indent)
        -- build entries into the table
        table.insert(entries, indent .. e.section .. " " .. e.title)
    end
    local rfc_win = vim.api.nvim_get_current_win()
    local rfc_buf = vim.api.nvim_get_current_buf()
    local toc_buf = vim.api.nvim_create_buf(false, true)
    -- set the bufhidden opt to 'wipe' so buf is removed
    -- from :ls! when it's closed
    vim.bo[toc_buf].bufhidden = "wipe"
    vim.api.nvim_buf_set_name(toc_buf, buf_name .. " ToC")
    vim.api.nvim_buf_set_lines(toc_buf, 0, -1, false, entries)
    for i, e in ipairs(toc_entries) do
        vim.api.nvim_buf_set_extmark( -- ToC section
            toc_buf,
            toc_ns,
            i - 1,
            indents[i],
            { end_col = indents[i] + #e.section, hl_group = "@markup.heading" }
        )
    end
    -- modifiable must be set false AFTER writing content
    vim.bo[toc_buf].modifiable = false
    toc_map[tabpage] = vim.api.nvim_open_win(
        toc_buf,
        focus,
        { split = config.toc.split, width = config.toc.width }
    )
    -- set spellcheck to false in the ToC
    vim.wo[toc_map[tabpage]].spell = false
    if cursor_pos[rfc_buf] then
        vim.api.nvim_win_set_cursor(toc_map[tabpage], cursor_pos[rfc_buf])
    end
    -- close plugin if only ToC left behind
    -- rfc + ToC is valid
    -- rfc on its own is valid
    -- ToC on its own is INVALID
    vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(rfc_win),
        callback = vim.schedule_wrap(function()
            if toc_map[tabpage] then
                vim.api.nvim_win_close(toc_map[tabpage], true)
            end
        end),
    })
    -- set toc_map[tabpage] back to nil if the user
    -- closed the ToC with a different method than :Must toc
    vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(toc_map[tabpage]),
        callback = function()
            cursor_pos[rfc_buf] = vim.api.nvim_win_get_cursor(toc_map[tabpage])
            toc_map[tabpage] = nil
        end,
    })

    if config.open_toc_entry then
        -- keymap for jumping to body heading from ToC
        vim.keymap.set("n", config.open_toc_entry, function()
            local pos = vim.api.nvim_win_get_cursor(toc_map[tabpage])
            local line = { toc_entries[pos[1]].line, 0 }
            vim.api.nvim_win_set_cursor(rfc_win, line)
        end, { buf = toc_buf })
    end

    if config.toggle_toc then
        -- keymap for opening/closing ToC
        vim.keymap.set("n", config.toggle_toc, function()
            vim.cmd(":Must toc")
        end, { buf = toc_buf })
    end
end

-- refresh the ToC on BufWinEnter to ensure ToC
-- always stays in sync with content
vim.api.nvim_create_autocmd("BufWinEnter", {
    nested = true,
    callback = function(args)
        if vim.bo[args.buf].filetype == "rfc" then
            local tabpage = vim.api.nvim_get_current_tabpage()
            if not toc_map[tabpage] then
                return
            end
            close_toc(tabpage)
            open_toc(tabpage, false)
        end
    end,
})

vim.api.nvim_create_user_command("Must", function(cmd)
    if cmd.args == "toc" then
        local tabpage = vim.api.nvim_get_current_tabpage()
        -- toggle and reset if win already exists
        if toc_map[tabpage] then
            close_toc(tabpage)
            return
        end
        open_toc(tabpage, true)
        -- fetch if :Must is followed by <number>
    elseif cmd.args:match("^%d+$") then
        client.request(cmd.args)
    elseif cmd.args == "" then
        client.load_index(function(lines)
            local items = index.parse(lines)
            vim.ui.select(items, {
                kind = "must",
                prompt = "search/select an RFC",
                format_item = function(item)
                    return item.rfc_num .. " " .. item.rfc_label
                end,
            }, function(item, _)
                if not item then
                    return
                end
                client.request(item.rfc_num)
            end)
        end)
    end
end, { nargs = "?" })
