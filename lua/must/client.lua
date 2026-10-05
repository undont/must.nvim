local M = {}

local base_url = "https://www.rfc-editor.org/rfc/"

function M.request(rfc_num)
    local buf = vim.fn.bufnr("^RFC " .. rfc_num .. "$")
    -- check if this RFC is already open
    if buf ~= -1 then
        local win_num = vim.fn.win_findbuf(buf)
        vim.api.nvim_set_current_win(win_num[1])
        return
    end
    vim.net.request(
        base_url .. "rfc" .. rfc_num .. ".txt",
        {},
        vim.schedule_wrap(function(err, res)
            if err then
                return
            end
            -- remove the unnecessary form feed
            local body = res.body:gsub("\f", "")
            local contents = vim.split(body, "\n")
            buf = vim.api.nvim_create_buf(true, true)
            vim.bo[buf].bufhidden = "wipe"
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
            -- create a new tab initialised with the contents
            -- and an appropriate name
            vim.cmd(":tab sbuffer " .. buf)
            vim.api.nvim_buf_set_name(buf, "RFC " .. rfc_num)
        end)
    )
end

return M
