--- A UTF-8 string is valid when every lead byte is followed by the right number of continuation bytes.
local function isValidUtf8(text)
    local index = 1
    while index <= #text do
        local byte = text:byte(index)
        local extra = byte < 0x80 and 0 or byte >= 0xF0 and 3 or byte >= 0xE0 and 2 or byte >= 0xC0 and 1 or nil
        if extra == nil then
            return false
        end
        for offset = 1, extra do
            local continuation = text:byte(index + offset)
            if not continuation or continuation < 0x80 or continuation >= 0xC0 then
                return false
            end
        end
        index = index + extra + 1
    end
    return true
end

describe("Progress tooltip", function()
    --- The pending line of the one missing slot, as the tooltip shows it, for a source with the given text.
    local function pendingLineFor(source)
        WowStub.load(nil)
        -- rawset: the model table is read-only for luacheck; the spec reloads it on every load anyway.
        rawset(ForeverBiSModel, "progress", function()
            return {
                total = 1,
                bis = 0,
                listed = 1,
                slots = {
                    { slot = "Head", done = false, target = { name = "Helm", source = source } },
                },
            }
        end)
        local parent = _G.CreateFrame("Frame", nil, _G.UIParent)
        WowStub.ns.Progress.create(parent)
        local owner
        for _, frame in ipairs(WowStub.frames) do
            if frame.kind == "Frame" and frame.scripts.OnEnter then
                owner = frame
            end
        end
        WowStub.ns.Progress.refresh({ data = { slots = {} } })
        WowStub.fire(owner, "OnEnter")
        for _, line in ipairs(WowStub.tooltip.lines) do
            if line:sub(1, 6) == "Head: " then
                return line
            end
        end
    end

    it("shortens a long source with an ellipsis", function()
        local line = pendingLineFor(string.rep("a", 60))
        assert.are.equal("Head: Helm (" .. string.rep("a", 33) .. "...)", line)
    end)

    it("cuts a long source between characters, never inside a multibyte one", function()
        local line = pendingLineFor(string.rep("a", 32) .. "é" .. string.rep("z", 20))
        assert.is_true(isValidUtf8(line), "invalid UTF-8 in: " .. line)
        assert.are.equal("Head: Helm (" .. string.rep("a", 32) .. "...)", line)
    end)

    it("leaves a short multibyte source whole", function()
        local line = pendingLineFor("Ruinas de Ahn'Qiraj é")
        assert.are.equal("Head: Helm (Ruinas de Ahn'Qiraj é)", line)
    end)
end)
