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
        assert.are.equal("Spec", L["Spec"])
    end)

    it("returns the translation when the locale has one", function()
        local L = loadLocale("esES")
        assert.are.equal("Espec.", L["Spec"])
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
        assert.are.equal("Top 3", L["Top %d"]:format(3))
        assert.are.equal("Auto (Nivel 30)", L["Auto (%s)"]:format("Nivel 30"))
    end)

    it("shows translated UI text but leaves slot names from the data alone", function()
        WowStub.load({ class = "rogue", build = "pve" })
        WowStub.ns.openWindow()
        assert.is_true(WowStub.hasText("SPEC"))
        WowStub.locale = "esES"
        WowStub.load({ class = "rogue", build = "pve" })
        WowStub.ns.openWindow()
        local route = WowStub.ns.Settings.route()
        local firstSlot = ForeverBiSModel.gridSlots(route, "lvl30")[1].slot
        assert.is_true(WowStub.hasText(firstSlot))
        assert.is_true(WowStub.hasText("ESPEC."))
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
        assert.is_true(#sourceKeys() > 15)
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
