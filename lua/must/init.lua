local M = {}

local config = require("must.config")

function M.setup(opts)
    local merged = vim.tbl_deep_extend("force", config, opts or {})
    for k, v in pairs(merged) do
        config[k] = v
    end
end

return M
