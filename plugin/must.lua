require("must.toc")
require("must.client")

vim.api.nvim_create_user_command("Must", function(cmd)
    if cmd.args == "toc" then
        local t = require("must.toc")
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        local toc_entries = t.extract_toc_entries(lines, t.find_toc_start(lines))
        local entries = {}
        for _, e in ipairs(toc_entries) do
            table.insert(entries, e.number .. " " .. e.title)
        end
        local rfc_win = vim.api.nvim_get_current_win()
        local toc_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(toc_buf, 0, -1, false, entries)
        local toc_win = vim.api.nvim_open_win(toc_buf, true, { split = "right", width = 55 })
        vim.keymap.set("n", "<CR>", function()
            local pos = vim.api.nvim_win_get_cursor(toc_win)
            local line = { toc_entries[pos[1]].line, 0 }
            vim.api.nvim_win_set_cursor(rfc_win, line)
        end, { buf = toc_buf })
    elseif cmd.args:match("^%d+$") then
        local c = require("must.client")
        c.request(cmd.args)
    end
end, { nargs = 1 })
