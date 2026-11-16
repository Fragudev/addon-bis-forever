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
        assert.are.equal("Sort by rank", L["Sort by rank"])
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

describe("Locale coverage", function()
    local Toc = dofile("tests/support/toc.lua")

    --- Every distinct L["..."] literal in the addon's Lua sources, in .toc order.
    local function sourceKeys()
        local keys, seen = {}, {}
        for _, path in ipairs(Toc.files()) do
            local handle = assert(io.open("ForeverBiS/" .. path, "rb"))
            local contents = handle:read("*a")
            handle:close()
            for key in contents:gmatch('L%["([^"\n]-)"%]') do
                if not seen[key] then
                    seen[key] = true
                    table.insert(keys, key)
                end
            end
        end
        return keys
    end

    it("finds the literal keys in the addon sources", function()
        assert.is_true(#sourceKeys() > 50)
    end)

    it("has every literal in enUS, which is the English key itself", function()
        local L = loadLocale("enUS")
        local missing = {}
        for _, key in ipairs(sourceKeys()) do
            if L[key] ~= key then
                table.insert(missing, key)
            end
        end
        assert.are.same({}, missing)
    end)

    it("has an esES translation for every literal", function()
        WowStub.reset()
        local translations = WowStub.loadFiles({ "ForeverBiS_Locale.lua" }).translations
        local missing = {}
        for _, key in ipairs(sourceKeys()) do
            if translations.esES[key] == nil then
                table.insert(missing, key)
            end
        end
        assert.are.same({}, missing)
    end)

    it("gives esMX the same translations as esES", function()
        WowStub.reset()
        local translations = WowStub.loadFiles({ "ForeverBiS_Locale.lua" }).translations
        assert.are.equal(translations.esES, translations.esMX)
    end)
end)
