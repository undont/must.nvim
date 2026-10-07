local M = {}

local base_url = "https://www.rfc-editor.org/rfc/"
local must_tab = nil

-- create a new tab initialised with the contents
-- and an appropriate name, shared between all RFCs
---@param buf integer
local function show(buf)
    if must_tab and vim.api.nvim_tabpage_is_valid(must_tab) then
        vim.api.nvim_set_current_tabpage(must_tab)
        vim.api.nvim_set_current_buf(buf)
    else
        vim.cmd(":tab sbuffer " .. buf)
        must_tab = vim.api.nvim_get_current_tabpage()
    end
end

---@param rfc_num string
---@param contents string[]
---@param on_open fun()|nil
local function open(rfc_num, contents, on_open)
    local buf = vim.api.nvim_create_buf(true, true)
    vim.bo[buf].filetype = "rfc"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
    vim.api.nvim_buf_set_name(buf, "must://RFC " .. rfc_num)
    show(buf)
    if on_open then
        on_open()
    end
    -- modifiable must be set false AFTER writing content
    vim.bo[buf].modifiable = false
end

--- the only network request in the plugin
--- handles tab/buffer creation, and jumping to
--- already open RFCs
---@param rfc_num string
---@param on_open fun()|nil
function M.request(rfc_num, on_open)
    local buf = vim.fn.bufnr("^must://RFC " .. rfc_num .. "$")
    -- check if this RFC is already open
    if buf ~= -1 then
        show(buf)
        if on_open then
            on_open()
        end
        return
    end
    local cache_dir = vim.fn.stdpath("cache") .. "/must/"
    local file_name = "rfc" .. rfc_num .. ".txt"
    local file_path = cache_dir .. file_name
    if vim.fn.filereadable(file_path) == 1 then
        local contents = vim.fn.readfile(file_path)
        open(rfc_num, contents, on_open)
    else
        vim.net.request(
            base_url .. file_name,
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
                -- mkdir -p and write the RFC to cache
                vim.fn.mkdir(cache_dir, "p")
                if vim.fn.writefile(contents, file_path) == -1 then
                    vim.notify(
                        ("must: failed to write %s to cache"):format(file_name),
                        vim.log.levels.WARN
                    )
                end
                open(rfc_num, contents, on_open)
            end)
        )
    end
end

return M
