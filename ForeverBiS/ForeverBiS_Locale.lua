-- User-facing strings. Keys are the English text; a locale table overrides the ones it translates and every
-- other key falls back to English. Names that come from the data (items, bosses, zones, slots) are not translated.
local _, ns = ...

local translations = {
    -- Partial on purpose: untranslated keys show in English.
    esES = {
        ["Class"] = "Clase",
        ["Spec"] = "Espec.",
        ["Auto (%s)"] = "Auto (%s)",
        ["Top %d"] = "Top %d",
        ["Inspecting %s"] = "Inspeccionando a %s",
        ["BiS"] = "BiS",
        ["Click to open or close"] = "Clic para abrir o cerrar",
        ["Drag to move the button"] = "Arrastra para mover el botón",
        ["%d BiS items in %s - click to view"] = "%d objetos BiS en %s: haz clic para verlos",
        ["%s BiS: "] = "%s BiS: ",
        ["+%d more"] = "+%d más",
        ["BiS #%d %s - %s (%s)"] = "BiS nº %d %s - %s (%s)",
        ["BiS Forever"] = "BiS Forever",
        ["Forever BiS"] = "Forever BiS",
        ["BiS Forever Help"] = "Ayuda de BiS Forever",
        ["Forever BiS alerts: "] = "Alertas de Forever BiS: ",
        ["Forever BiS dungeon notice: "] = "Aviso de mazmorra de Forever BiS: ",
        ["Forever BiS minimap button: "] = "Botón del minimapa de Forever BiS: ",
        ["Forever BiS tooltips: "] = "Tooltips de Forever BiS: ",
        ["Forever BiS stars: "] = "Estrellas de Forever BiS: ",
        ["No BiS list is loaded for this build."] = "No hay ninguna lista BiS cargada para esta build.",
        ["Unknown slot '%s'. Valid slots: %s"] = "Ranura desconocida '%s'. Ranuras válidas: %s",
        ["all classes"] = "todas las clases",
        ["off"] = "inactivo",
        ["on"] = "activo",
        ["your class only"] = "solo tu clase",
        -- Item tooltip blocks and their /bis tooltip toggles.
        ["BiS #%d for %s (%s)"] = "BiS nº %d para %s (%s)",
        ["BiS for %s at %s"] = "BiS para %s en %s",
        ["Not BiS for %s"] = "No es BiS para %s",
        ["Source: %s"] = "Origen: %s",
        ["Also for: %s"] = "También para: %s",
        ["Your class: %s"] = "Tu clase: %s",
        ["+%d more - hold Shift"] = "+%d más (mantén Mayús)",
        ["Forever BiS tooltip, %s: "] = "Tooltip de Forever BiS, %s: ",
        ["your spec"] = "tu especialización",
        ["your other specs"] = "tus otras especializaciones",
        ["other classes"] = "otras clases",
        ["compact mode"] = "modo compacto",
        -- Dynamic keys: looked up through a variable, so they are not literals in the sources.
        ["Horde"] = "Horda",
        ["Alliance"] = "Alianza",
    },
}
-- Regional Spanish shares the neutral Spanish table.
translations.esMX = translations.esES

local L = {}
local locale = GetLocale and GetLocale() or "enUS"
local overrides = translations[locale] or {}

setmetatable(L, {
    __index = function(_, key)
        return overrides[key] or key
    end,
})

ns.L = L
-- The per-locale tables, so the specs can tell a real translation from the English fallback.
ns.translations = translations
