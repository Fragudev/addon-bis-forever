local function loadLocale(locale)
    WowStub.reset()
    WowStub.locale = locale
    return WowStub.loadFiles({ "ForeverBiS_Locale.lua" }).L
end

describe("Locale", function()
    after_each(function()
        WowStub.locale = "enUS"
    end)

    it("returns the English key on an English client", function()
        local L = loadLocale("enUS")
        assert.are.equal("Clear filters", L["Clear filters"])
    end)

    it("returns the translation when the locale has one", function()
        local L = loadLocale("esES")
        assert.are.equal("Borrar filtros", L["Clear filters"])
    end)

    it("falls back to English for a key the locale does not translate", function()
        local L = loadLocale("esES")
        assert.are.equal("Maker: all", L["Maker: all"])
    end)

    it("falls back to English for a locale without translations", function()
        local L = loadLocale("deDE")
        assert.are.equal("Class", L["Class"])
    end)

    it("keeps format placeholders usable", function()
        local L = loadLocale("esES")
        assert.are.equal("En bolsas: 3", L["In bags: %d"]:format(3))
        assert.are.equal("In bags: 3", loadLocale("enUS")["In bags: %d"]:format(3))
    end)

    it("shows translated UI text but leaves item names from the data alone", function()
        WowStub.load({ class = "rogue", build = "pve" })
        assert.is_true(WowStub.hasText("Search item, boss or zone"))
        WowStub.locale = "esES"
        WowStub.load({ class = "rogue", build = "pve" })
        local firstItem = ForeverBiSLists["rogue"].slots[1][2][1][1]
        assert.is_true(WowStub.hasText(firstItem))
        assert.is_true(WowStub.hasText("Buscar objeto, jefe o zona"))
    end)
end)
