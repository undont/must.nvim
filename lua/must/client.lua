local M = {}

local base_url = "https://www.rfc-editor.org/rfc/"

-- TODO: add a caching layer to the client

--- the only network request in the plugin
--- handles tab/buffer creation, and jumping to
--- already open RFCs
---@param rfc_num string
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
                if err:match("404") then
                    vim.notify("must: requested RFC does not exist", vim.log.levels.WARN)
                else
                    vim.notify(err, vim.log.levels.ERROR)
                end
                return
            end
            -- remove the unnecessary form feed
            local body = res.body:gsub("\f", "")
            -- remove the byte-order marks from the top of the file
            body = body:gsub("^\u{FEFF}", "")
            local contents = vim.split(body, "\n")
            buf = vim.api.nvim_create_buf(true, true)
            -- set the bufhidden opt to 'wipe' so buf is removed
            -- from :ls! when it's closed
            vim.bo[buf].bufhidden = "wipe"
            vim.bo[buf].filetype = "rfc"
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
            -- create a new tab initialised with the contents
            -- and an appropriate name
            vim.cmd(":tab sbuffer " .. buf)
            vim.api.nvim_buf_set_name(buf, "RFC " .. rfc_num)
        end)
    )
end

return M
