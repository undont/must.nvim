require("must.toc")
require("must.client")

local toc_win = nil

vim.api.nvim_create_user_command("Must", function(cmd)
    if cmd.args == "toc" then
        local t = require("must.toc")
        -- toggle and reset if win already exists
        if toc_win then
            vim.api.nvim_win_close(toc_win, true)
            toc_win = nil
            return
        end
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local toc_entries = t.extract_toc_entries(lines, t.find_toc_start(lines))
        local entries = {}
        for _, e in ipairs(toc_entries) do
            -- build entries into the table
            table.insert(entries, e.number .. " " .. e.title)
        end
        local rfc_win = vim.api.nvim_get_current_win()
        local toc_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(toc_buf, 0, -1, false, entries)
        toc_win = vim.api.nvim_open_win(toc_buf, true, { split = "right", width = 55 })
        -- set toc_win back to nil if the user closed the ToC
        -- with a different method than :Must toc
        vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(toc_win),
            callback = function()
                toc_win = nil
            end,
        })
        -- keymap for jumping to body heading from ToC
        vim.keymap.set("n", "<CR>", function()
            local pos = vim.api.nvim_win_get_cursor(toc_win)
            local line = { toc_entries[pos[1]].line, 0 }
            vim.api.nvim_win_set_cursor(rfc_win, line)
        end, { buf = toc_buf })
        -- fetch if :Must is followed by <number>
    elseif cmd.args:match("^%d+$") then
        local c = require("must.client")
        c.request(cmd.args)
    end
end, { nargs = 1 })
