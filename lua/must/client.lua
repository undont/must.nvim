local M = {}

local base_url = "https://www.rfc-editor.org/"
local must_tab = nil
local cache_dir = vim.fn.stdpath("cache") .. "/must/"
local index_file_name = "rfc-index.txt"
local index_max_age = 24 * 60 * 60 -- 1 day
local index_timeout = 5 * 1000 -- 5 seconds

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

---@return boolean
local function is_index_stale()
    local path = cache_dir .. index_file_name
    local readable = vim.fn.filereadable(path) == 1
    if not readable then
        return true
    end
    return index_max_age < (os.time() - vim.uv.fs_stat(path).mtime.sec)
end

---@param on_load fun(lines: string[])
function M.load_index(on_load)
    vim.fn.mkdir(cache_dir, "p")
    local path = cache_dir .. index_file_name
    local tmp_path = path .. ".tmp"
    ---@type uv.uv_timer_t
    local timer
    if not is_index_stale() then
        on_load(vim.fn.readfile(path))
    else
        local req = vim.net.request(
            base_url .. "rfc-index.txt",
            { outpath = tmp_path },
            vim.schedule_wrap(function(err, _)
                timer:stop()
                if err then
                    vim.uv.fs_unlink(tmp_path)
                    if vim.fn.filereadable(path) ~= 1 then
                        vim.notify("must: no local RFC index found: " .. err, vim.log.levels.ERROR)
                        return
                    end
                    vim.notify(
                        "must: RFC index could not be refreshed (might be stale)",
                        vim.log.levels.WARN
                    )
                else
                    local _, msg = vim.uv.fs_rename(tmp_path, path)
                    if msg then
                        vim.notify("must: " .. msg, vim.log.levels.ERROR)
                        return
                    end
                end
                on_load(vim.fn.readfile(path))
            end)
        )
        timer = vim.defer_fn(req.close, index_timeout)
    end
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
    local file_name = "rfc" .. rfc_num .. ".txt"
    local file_path = cache_dir .. file_name
    if vim.fn.filereadable(file_path) == 1 then
        local contents = vim.fn.readfile(file_path)
        open(rfc_num, contents, on_open)
    else
        vim.net.request(
            base_url .. "rfc/" .. file_name,
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
