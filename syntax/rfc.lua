local requirement_keywords = {
    "MUST",
    "MUST NOT",
    "REQUIRED",
    "NOT REQUIRED",
    "SHALL",
    "SHALL NOT",
    "SHOULD",
    "SHOULD NOT",
    "RECOMMENDED",
    "NOT RECOMMENDED",
    "MAY",
    "MAY NOT",
    "OPTIONAL",
    "NOT OPTIONAL",
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

-- page footers
vim.cmd([[syntax match rfcPage /\[Page\s\d\+\]/]])
vim.cmd([[highlight default link rfcPage Comment]])

-- headings in ToC and main body
vim.cmd([[syntax match rfcBodyHeading /^[0-9\.]\+.*$/]])
vim.cmd([[syntax match rfcBodyHeading /^\u\(\S\| \S\)*$/]])
vim.cmd([[highlight default link rfcBodyHeading @markup.heading]])

-- requirement keywords :)
vim.cmd("syntax keyword rfcRequirementKeywords " .. table.concat(requirement_keywords, " "))
vim.cmd([[highlight default link rfcRequirementKeywords @markup.strong]])

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
