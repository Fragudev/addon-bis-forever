describe("Help credits", function()
    before_each(function()
        WowStub.load({ class = "druid", build = "" })
    end)

    it("credits the wowsims data the lists are generated from", function()
        assert.is_true(WowStub.hasText("CREDITS"))
        assert.is_true(WowStub.hasText("wowsims (https://github.com/wowsims/forever), MIT License"))
    end)

    it("ships the EG Link attribution for the drop chances", function()
        assert.is_true(
            WowStub.hasText("Data from Efficient Games (https://efficient.games), licensed under CC BY 4.0.")
        )
    end)
end)
