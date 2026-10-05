local toc = require("must.toc")

local rfc2616 = "rfc2616.txt"
local rfc9110 = "rfc9110.txt"

local function read_fixture(name)
    local lines = {}
    for line in io.lines("test/fixtures/" .. name) do
        table.insert(lines, line)
    end
    return lines
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

describe("extract_toc_entries", function()
    it("gives each entry its body line", function()
        local content = read_fixture(rfc2616)
        local start_idx = toc.find_toc_start(content)
        local entries = toc.extract_toc_entries(content, start_idx)
        assert.are.equal(628, entries[5].line)
    end)
    it("matches rows without dot leaders", function()
        local content = read_fixture(rfc9110)
        local start_idx = toc.find_toc_start(content)
        local entries = toc.extract_toc_entries(content, start_idx)
        assert.are.equal(291, #entries)
    end)
    it("finds the body line for a wrapped row", function()
        local content = read_fixture(rfc9110)
        local start_idx = toc.find_toc_start(content)
        local entries = toc.extract_toc_entries(content, start_idx)
        local line = nil
        for _, e in ipairs(entries) do
            if e.number == "8.8.3.3." then
                line = e.line
            end
        end
        assert.are.equal(3672, line)
    end)
    it("joins a wrapped row's title", function()
        local content = read_fixture(rfc9110)
        local start_idx = toc.find_toc_start(content)
        local entries = toc.extract_toc_entries(content, start_idx)
        local title = nil
        for _, e in ipairs(entries) do
            if e.number == "8.8.3.3." then
                title = e.title
            end
        end
        assert.are.equal("Example: Entity Tags Varying on Content-Negotiated Resources", title)
    end)
end)
