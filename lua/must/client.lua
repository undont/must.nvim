local M = {}

local base_url = "https://www.rfc-editor.org/rfc/"

function M.request(rfc_num)
    vim.net.request(
        base_url .. "rfc" .. rfc_num .. ".txt",
        {},
        vim.schedule_wrap(function(err, res)
            if err then
                return
            end
            local body = res.body:gsub("\f", "")
            local contents = vim.split(body, "\n")
            local new_buf = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, contents)
            vim.api.nvim_set_current_buf(new_buf)
        end)
    )
end

return M
