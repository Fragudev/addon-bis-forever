-- User-facing strings. Keys are the English text; a locale table overrides the ones it translates and every
-- other key falls back to English. Names that come from the data (items, bosses, zones, slots) are not translated.
local _, ns = ...

local translations = {
    -- Partial on purpose: untranslated keys show in English.
    esES = {
        ["Class"] = "Clase",
        ["Build"] = "Build",
        ["Auto (%s)"] = "Auto (%s)",
        ["Clear filters"] = "Borrar filtros",
        ["No items match the current search and filters."] = "Ningún objeto coincide con la búsqueda y los filtros.",
        ["Search item, boss or zone"] = "Buscar objeto, jefe o zona",
        ["Equipped Only: On"] = "Solo equipado: Sí",
        ["Equipped Only: Off"] = "Solo equipado: No",
        ["Currently equipped"] = "Equipado actualmente",
        ["In bags: %d"] = "En bolsas: %d",
        ["Source: %s"] = "Origen: %s",
        ["Not listed"] = "No listado",
        ["Click to open or close"] = "Clic para abrir o cerrar",
        ["Drag to move the button"] = "Arrastra para mover el botón",
    },
}

local L = {}
local locale = GetLocale and GetLocale() or "enUS"
local overrides = translations[locale] or {}

setmetatable(L, {
    __index = function(_, key)
        return overrides[key] or key
    end,
})

ns.L = L
