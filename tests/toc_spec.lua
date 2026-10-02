local Toc = dofile("tests/support/toc.lua")

describe("TOC loader", function()
    describe("parse", function()
        it("returns the listed files in order", function()
            assert.are.same({ "A.lua", "B.lua" }, Toc.parse("A.lua\nB.lua\n"))
        end)

        it("skips metadata, comment and blank lines", function()
            local contents = "## Title: Test\n# a comment\n\nA.lua\n   \nB.lua"
            assert.are.same({ "A.lua", "B.lua" }, Toc.parse(contents))
        end)

        it("accepts CRLF line endings and trims whitespace", function()
            assert.are.same({ "A.lua", "B.lua" }, Toc.parse("## Version: 1\r\n  A.lua  \r\nB.lua\r\n"))
        end)

        it("turns backslashes in paths into slashes", function()
            assert.are.same({ "Core/Catalog.lua" }, Toc.parse("Core\\Catalog.lua"))
        end)
    end)

    describe("files", function()
        it("lists the addon files with the data first and the entry file after the modules", function()
            local files = Toc.files()
            assert.are.equal("ForeverBiS_Data.lua", files[1])
            for _, path in ipairs(files) do
                local handle = io.open("ForeverBiS/" .. path, "rb")
                assert.is_truthy(handle, path .. " is listed in the .toc but missing")
                handle:close()
            end
        end)
    end)

    describe("load", function()
        it("passes the addon name and one shared namespace to every chunk", function()
            local ns = Toc.load({ only = { "ForeverBiS_Data.lua", "ForeverBiS_Model.lua" } })
            assert.is_table(ns)
            assert.is_table(ForeverBiSModel)
            assert.is_table(ForeverBiSLists)
        end)
    end)
end)
