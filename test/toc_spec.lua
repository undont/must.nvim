local toc = require("must.toc")

local rfc2616 = "rfc2616.txt"
local rfc9110 = "rfc9110.txt"
local rfc1945 = "rfc1945.txt"
local rfc3986 = "rfc3986.txt"
local rfc791 = "rfc791.txt"

---@param name string
---@return string[]
local function read_fixture(name)
    local lines = {}
    for line in io.lines("test/fixtures/" .. name) do
        table.insert(lines, line)
    end
    return lines
end

---@param entries must.TocEntry[]
---@param field string
---@param value string
---@return must.TocEntry|nil
local function find_entry(entries, field, value)
    for _, e in ipairs(entries) do
        if e[field] == value then
            return e
        end
    end
end

describe("find_toc_start", function()
    it("finds a real header line", function()
        local lines = read_fixture(rfc2616)
        assert.are.equal(63, toc.find_toc_start(lines))
    end)
    it("finds an indented header", function()
        local lines = {
            "Status of this Memo",
            "   ",
            "   Table of Contents",
        }
        assert.are.equal(3, toc.find_toc_start(lines))
    end)
end)

describe("find_body_heading", function()
    it("correctly skips the ToC row", function()
        local lines = read_fixture(rfc2616)
        assert.are.equal(628, toc.find_body_heading(lines, 69, "1.4", "Overall Operation"))
    end)
    it("needs the title to tell `1` from `1.1` etc", function()
        local lines = read_fixture(rfc2616)
        assert.are.equal(359, toc.find_body_heading(lines, 65, "1", "Introduction"))
    end)
end)

describe("get_entries", function()
    it("gives each entry its body line", function()
        local content = read_fixture(rfc2616)
        local entries = assert(toc.get_entries(content))
        assert.are.equal(628, entries[5].line)
        assert.are.equal(253, #entries)
    end)
    it("matches rows without dot leaders", function()
        local content = read_fixture(rfc9110)
        local entries = assert(toc.get_entries(content))
        assert.are.equal(305, #entries)
    end)
    it("finds the body line for a wrapped row", function()
        local content = read_fixture(rfc9110)
        local entries = assert(toc.get_entries(content))
        local line = find_entry(entries, "number", "8.8.3.3.").line
        assert.are.equal(3672, line)
    end)
    it("joins a wrapped row's title", function()
        local content = read_fixture(rfc9110)
        local entries = assert(toc.get_entries(content))
        local title = find_entry(entries, "number", "8.8.3.3.").title
        assert.are.equal("Example: Entity Tags Varying on Content-Negotiated Resources", title)
    end)
    it("finds the body line for an appendix row", function()
        local content = read_fixture(rfc9110)
        local entries = assert(toc.get_entries(content))
        local line = find_entry(entries, "number", "Appendix A.").line
        assert.are.equal(9748, line)
    end)
    it("finds the body line for an appendix subsection", function()
        local content = read_fixture(rfc9110)
        local entries = assert(toc.get_entries(content))
        local line = find_entry(entries, "number", "B.1.").line
        assert.are.equal(9980, line)
    end)
    it("finds the body line for a back-matter row", function()
        local content = read_fixture(rfc9110)
        local entries = assert(toc.get_entries(content))
        local line = find_entry(entries, "title", "Index").line
        assert.are.equal(10217, line)
    end)
    it("matches rows with a gap before the page number", function()
        local content = read_fixture(rfc1945)
        local entries = assert(toc.get_entries(content))
        local line = find_entry(entries, "number", "1.1").line
        assert.are.equal(177, line)
    end)
    it("matches rows with spaced dot leaders", function()
        local content = read_fixture(rfc3986)
        local entries = assert(toc.get_entries(content))
        local line = find_entry(entries, "number", "1.1.").line
        assert.are.equal(203, line)
    end)
    it("matches column-0 rows with a page number", function()
        local content = read_fixture(rfc791)
        local entries = assert(toc.get_entries(content))
        local line = find_entry(entries, "number", "2.").line
        assert.are.equal(475, line)
    end)
end)
