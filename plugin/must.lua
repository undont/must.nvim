require("must.toc")
require("must.client")

local toc_map = {}
local cursor_pos = nil

vim.api.nvim_create_user_command("Must", function(cmd)
    if cmd.args == "toc" then
        local toc = require("must.toc")
        local toc_tabpage = vim.api.nvim_get_current_tabpage()
        -- toggle and reset if win already exists
        if toc_map[toc_tabpage] then
            cursor_pos = vim.api.nvim_win_get_cursor(toc_map[toc_tabpage])
            vim.api.nvim_win_close(toc_map[toc_tabpage], true)
            toc_map[toc_tabpage] = nil
            return
        end
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local toc_entries = toc.get_entries(lines)
        if not toc_entries then
            vim.notify("must: no Table of Contents found", vim.log.levels.WARN)
            return
        end
        local entries = {}
        for _, e in ipairs(toc_entries) do
            -- build entries into the table
            table.insert(entries, e.section .. " " .. e.title)
        end
        local rfc_win = vim.api.nvim_get_current_win()
        local toc_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(toc_buf, 0, -1, false, entries)
        toc_map[toc_tabpage] = vim.api.nvim_open_win(toc_buf, true, { split = "right", width = 55 })
        if cursor_pos then
            vim.api.nvim_win_set_cursor(toc_map[toc_tabpage], cursor_pos)
        end
        -- close plugin if only ToC left behind
        -- rfc + ToC is valid
        -- rfc on its own is valid
        -- ToC on its own is INVALID
        vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(rfc_win),
            callback = vim.schedule_wrap(function()
                if toc_map[toc_tabpage] then
                    vim.api.nvim_win_close(toc_map[toc_tabpage], true)
                end
            end),
        })
        -- set toc_map[toc_tabpage] back to nil if the user
        -- closed the ToC with a different method than :Must toc
        vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(toc_map[toc_tabpage]),
            callback = function()
                cursor_pos = vim.api.nvim_win_get_cursor(toc_map[toc_tabpage])
                toc_map[toc_tabpage] = nil
            end,
        })
        -- keymap for jumping to body heading from ToC
        vim.keymap.set("n", "<CR>", function()
            local pos = vim.api.nvim_win_get_cursor(toc_map[toc_tabpage])
            local line = { toc_entries[pos[1]].line, 0 }
            vim.api.nvim_win_set_cursor(rfc_win, line)
        end, { buf = toc_buf })

        -- keymap for opening/closing ToC
        vim.keymap.set("n", "\\", function()
            vim.cmd(":Must toc")
        end, { buf = toc_buf })

        -- fetch if :Must is followed by <number>
    elseif cmd.args:match("^%d+$") then
        local c = require("must.client")
        c.request(cmd.args)
    end
end, { nargs = 1 })
