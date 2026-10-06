local requirement_keywords = {
    "MUST NOT",
    "MUST",
    "NOT REQUIRED",
    "REQUIRED",
    "SHALL NOT",
    "SHALL",
    "SHOULD NOT",
    "SHOULD",
    "NOT RECOMMENDED",
    "RECOMMENDED",
    "MAY NOT",
    "MAY",
    "NOT OPTIONAL",
    "OPTIONAL",
}

local streams = {
    "Internet Engineering Task Force (IETF)",
    "Internet Engineering Task Force",
    "Internet Architecture Board (IAB)",
    "Internet Architecture Board",
    "Internet Research Task Force (IRTF)",
    "Internet Research Task Force",
    "Independent Submission",
    "Network Working Group",
}

local http_methods = {
    "GET",
    "HEAD",
    "PUT",
    "DELETE",
    "PATCH",
    "POST",
    "CONNECT",
    "OPTIONS",
    "TRACE",
}

---@param group string
---@param target string
---@param colour? string
local function bold_link(group, target, colour)
    local hl = vim.api.nvim_get_hl(0, { name = target, link = false })
    vim.api.nvim_set_hl(0, group, { fg = colour or hl.fg, bold = true, default = true })
end

-- parsing always starts one line above what's being drawn
-- related to the requirement keywords vs. hard wrapping
vim.cmd([[syntax sync minlines=1]])

-- page footers
vim.cmd([[syntax match rfcPage /\[Page\s\d\+\]/]])
vim.cmd([[highlight default link rfcPage Comment]])

-- headings in ToC and main body
vim.cmd([[syntax match rfcBodyHeading /^[0-9\.]\+.*$/]])
vim.cmd([[syntax match rfcBodyHeading /^\u\(\S\| \S\)*$/]])
vim.cmd([[highlight default link rfcBodyHeading @markup.heading]])

-- requirement keywords :)
local requirement_alternates = table.concat(requirement_keywords, "\\|")
-- let a match continue running over hard wrapped lines
requirement_alternates = requirement_alternates:gsub(" ", "\\_s\\+")
local requirement_keywords_pattern = "\\<\\(" .. requirement_alternates .. "\\)\\>"
vim.cmd("syntax match rfcRequirementKeywords /" .. requirement_keywords_pattern .. "/")
bold_link("rfcRequirementKeywords", "Type")

-- http methods
vim.cmd("syntax keyword rfcHttpMethods " .. table.concat(http_methods, " "))
bold_link("rfcHttpMethods", "String")

-- references
vim.cmd([[syntax match rfcReference /\[\(RFC\)\=\d\+\]/]])

-- section references
vim.cmd([[syntax match rfcReference /[Ss]ection\s\d\+\(\.\d\+\)*/]])

-- rfc mentions
vim.cmd([[syntax match rfcReference /RFC\s*\d\+/]])

-- named citations
vim.cmd([[syntax match rfcReference /\[\u[A-Za-z0-9/.-]\+\]/]])
vim.cmd([[highlight default link rfcReference @markup.link]])

-- page headers
vim.cmd([[syntax match rfcPageHeader /^RFC\s\d\+.*$/]])
vim.cmd([[highlight default link rfcPageHeader @label]])

-- first-page header block section
-- header labels
vim.cmd([[syntax match rfcHeaderLabel /^\u.\+:/]])
vim.cmd([[highlight default link rfcHeaderLabel @property]])

-- streams
local streams_pattern = "^\\(" .. table.concat(streams, "\\|") .. "\\)"
vim.cmd("syntax match rfcStreams /" .. streams_pattern .. "/")
vim.cmd([[highlight default link rfcStreams @property]])
