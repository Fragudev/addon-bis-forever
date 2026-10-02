-- Loads addon files the way the client does: in .toc order, each chunk receiving ("ForeverBiS", ns).

local Toc = {}

local ADDON = "ForeverBiS"

--- File paths listed in a .toc, in load order. Blank lines and "#" lines (comments and metadata) are skipped.
function Toc.parse(contents)
    local files = {}
    for rawLine in (contents .. "\n"):gmatch("(.-)\r?\n") do
        local line = rawLine:match("^%s*(.-)%s*$")
        if line ~= "" and line:sub(1, 1) ~= "#" then
            table.insert(files, (line:gsub("\\", "/")))
        end
    end
    return files
end

--- Files listed in the addon .toc, relative to the addon folder.
function Toc.files(tocPath)
    local handle = assert(io.open(tocPath or (ADDON .. "/" .. ADDON .. ".toc"), "rb"))
    local contents = handle:read("*a")
    handle:close()
    return Toc.parse(contents)
end

--- Loads every listed file into a fresh (or the given) namespace and returns it.
--- options.after maps a listed path to a function run right after that file loads.
--- options.only is a list of listed paths; every other file is left out (still in .toc order).
function Toc.load(options)
    options = options or {}
    local ns = options.ns or {}
    local only
    if options.only then
        only = {}
        for _, path in ipairs(options.only) do
            only[path] = true
        end
    end
    for _, path in ipairs(Toc.files(options.toc)) do
        if not only or only[path] then
            assert(loadfile(ADDON .. "/" .. path))(ADDON, ns)
            if options.after and options.after[path] then
                options.after[path](ns)
            end
        end
    end
    return ns
end

return Toc
