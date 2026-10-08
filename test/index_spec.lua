local index = require("must.index")
local fixtures = require("test.fixtures")

describe("parse", function()
    it("extracts all fields correctly (266)", function()
        local lines = fixtures.read(fixtures.rfc_index)
        local entries = index.parse(lines)
        local entry = fixtures.find_entry(entries, "rfc_num", "266")
        assert.are.same({
            rfc_num = "266",
            rfc_label = "Network host status. E. Westheimer. November 1971.",
            obsoleted_by = "RFC267",
            obsoletes = "RFC255",
        }, entry)
    end)
    it("extracts all fields correctly (61)", function()
        local lines = fixtures.read(fixtures.rfc_index)
        local entries = index.parse(lines)
        local entry = fixtures.find_entry(entries, "rfc_num", "61")
        assert.are.same({
            rfc_num = "61",
            rfc_label = "Note on Interprocess Communication in a"
                .. " Resource Sharing Computer Network. D.C. Walden. July 1970.",
            obsoleted_by = "RFC62",
        }, entry)
    end)
    it("doesn't extract 'Not Issued' RFCs", function()
        local lines = fixtures.read(fixtures.rfc_index)
        local entries = index.parse(lines)
        local entry = fixtures.find_entry(entries, "rfc_num", "14")
        assert.are.equal(nil, entry)
    end)
    it("extracts a list of 'obsoleted_by' and 'obsoletes' when available", function()
        local lines = fixtures.read(fixtures.rfc_index)
        local entries = index.parse(lines)
        local entry = fixtures.find_entry(entries, "rfc_num", "2616")
        assert.are.same({
            rfc_num = "2616",
            rfc_label = "Hypertext Transfer Protocol -- HTTP/1.1. R."
                .. " Fielding, J. Gettys, J. Mogul, H. Frystyk, L. Masinter,"
                .. " P. Leach, T. Berners-Lee. June 1999.",
            obsoleted_by = "RFC7230, RFC7231, RFC7232, RFC7233, RFC7234, RFC7235",
            obsoletes = "RFC2068",
        }, entry)
    end)
    it("extracts correctly even when initial input was wrapped", function()
        local lines = fixtures.read(fixtures.rfc_index)
        local entries = index.parse(lines)
        local entry = fixtures.find_entry(entries, "rfc_num", "31")
        assert.are.same({
            rfc_num = "31",
            rfc_label = "Binary Message Forms in Computer. D."
                .. " Bobrow, W.R. Sutherland. February 1968.",
        }, entry)
    end)
    it("skips header and 'Not Issued' blocks", function()
        local lines = fixtures.read(fixtures.rfc_index)
        local entries = index.parse(lines)
        assert.are.equal(4, #entries)
    end)
end)
