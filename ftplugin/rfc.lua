-- gd registered to jump to other RFCs (cursor on RFC) and
-- section headings via ToC entries
vim.keymap.set("n", "gd", function()
    local line = vim.api.nvim_get_current_line()
    local pos = vim.api.nvim_win_get_cursor(0)
    local first, last, rfc_num = line:find("RFC%s*(%d+)")
    while first do
        if pos[2] + 1 >= first and pos[2] + 1 <= last then
            require("must.client").request(rfc_num)
            return
        end
        first, last, rfc_num = line:find("RFC%s*(%d+)", last + 1)
    end
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local entries = require("must.toc").get_entries(lines)
    if entries then
        for _, e in ipairs(entries) do
            if e.toc_line == pos[1] then
                vim.api.nvim_win_set_cursor(0, { e.line, 0 })
                return
            end
        end
    end
    vim.notify("must: nothing to follow under cursor", vim.log.levels.WARN)
end, { buf = 0 })
