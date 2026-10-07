local refs = require("must.refs")
local toc = require("must.toc")
local fixtures = require("test.fixtures")

describe("citation_under_cursor", function()
    it("returns the citation when cursor is on its [", function()
        local line = fixtures.read(fixtures.rfc9110)[673]
        local ref = refs.citation_under_cursor(line, { 673, 3 })
        assert.are.equal("[CACHING]", ref)
    end)
    it("returns the citation when cursor is on its ]", function()
        local line = fixtures.read(fixtures.rfc9110)[673]
        local ref = refs.citation_under_cursor(line, { 673, 11 })
        assert.are.equal("[CACHING]", ref)
    end)
    it("returns the second citation on one line when cursor is on its [", function()
        local line = fixtures.read(fixtures.rfc9110)[673]
        local ref = refs.citation_under_cursor(line, { 673, 29 })
        assert.are.equal("[HTTP/1.1]", ref)
    end)
    it("returns nil when not standing on a citation", function()
        local line = fixtures.read(fixtures.rfc9110)[673]
        local ref = refs.citation_under_cursor(line, { 673, 18 })
        assert.are.equal(nil, ref)
    end)
end)

describe("section_ref", function()
    it("returns the correct section and new_rfc for 'section N of RFC'", function()
        local line = fixtures.read(fixtures.rfc9110)[38]
        local section, new_rfc = refs.section_ref(line, { 38, 38 }, {}, {})
        assert.are.equal("2", section)
        assert.are.equal("7841", new_rfc)
    end)
    it("returns the correct section for the current RFC", function()
        local line = fixtures.read(fixtures.rfc9110)[458]
        local section, new_rfc = refs.section_ref(line, { 458, 4 }, {}, {})
        assert.are.equal("3.1", section)
        assert.are.equal(nil, new_rfc)
    end)
    it("returns the correct section for 'section N of citation'", function()
        local lines = fixtures.read(fixtures.rfc9110)
        local line = lines[1914]
        local entries = assert(toc.get_entries(lines))
        local section, new_rfc = refs.section_ref(line, { 1914, 43 }, entries, lines)
        assert.are.equal("4.2", section)
        assert.are.equal("9111", new_rfc)
    end)
end)

describe("rfc_under_cursor", function()
    it("returns the rfc when cursor is on its start", function()
        local line = fixtures.read(fixtures.rfc9110)[27]
        local ref = refs.rfc_under_cursor(line, { 27, 25 })
        assert.are.equal("3864", ref)
    end)
    it("returns the rfc when cursor is on its end", function()
        local line = fixtures.read(fixtures.rfc9110)[27]
        local ref = refs.rfc_under_cursor(line, { 27, 32 })
        assert.are.equal("3864", ref)
    end)
    it("returns nil when not stood on a real RFC", function()
        local line = fixtures.read(fixtures.rfc9110)[27]
        local ref = refs.rfc_under_cursor(line, { 27, 48 })
        assert.are.equal(nil, ref)
    end)
    it("returns correct rfc when multiple are on one line", function()
        local line = fixtures.read(fixtures.rfc9110)[435]
        local ref = refs.rfc_under_cursor(line, { 435, 31 })
        assert.are.equal("2616", ref)
    end)
end)
