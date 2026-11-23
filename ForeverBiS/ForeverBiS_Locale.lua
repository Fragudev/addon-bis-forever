-- User-facing strings. Keys are the English text; a locale table overrides the ones it translates and every
-- other key falls back to English. Names that come from the data (items, bosses, zones, slots) are not translated.
local _, ns = ...

local translations = {
    -- Partial on purpose: untranslated keys show in English.
    esES = {
        ["Class"] = "Clase",
        ["%s has no list for this class yet."] = "%s aún no tiene lista para esta clase.",
        ["Build"] = "Build",
        ["PvE"] = "JcE",
        ["PvP"] = "JcJ",
        ["DPS"] = "DPS",
        ["Auto (%s)"] = "Auto (%s)",
        ["Clear filters"] = "Borrar filtros",
        ["No items match the current search and filters."] = "Ningún objeto coincide con la búsqueda y los filtros.",
        ["Try a different search, or clear the filters."] = "Prueba otra búsqueda o borra los filtros.",
        ["Search item, boss or zone"] = "Buscar objeto, jefe o zona",
        ["Equipped Only: On"] = "Solo equipado: Sí",
        ["Equipped Only: Off"] = "Solo equipado: No",
        ["Currently equipped"] = "Equipado actualmente",
        ["In bags: %d"] = "En bolsas: %d",
        ["Source: %s"] = "Origen: %s",
        ["Not listed"] = "No listado",
        ["Click to open or close"] = "Clic para abrir o cerrar",
        ["Drag to move the button"] = "Arrastra para mover el botón",
        ["#%d"] = "#%d",
        ["%d BiS items in %s - click to view"] = "%d objetos BiS en %s: haz clic para verlos",
        ["%d items"] = "%d objetos",
        ["%s BiS: "] = "%s BiS: ",
        ["+%d more"] = "+%d más",
        ["All dungeons"] = "Todas las mazmorras",
        ["BEST IN SLOT"] = "MEJOR EN RANURA",
        ["Best in slot: %s"] = "Mejor en ranura: %s",
        ["BiS #%d %s - %s (%s)"] = "BiS nº %d %s - %s (%s)",
        ["BiS %d/%d"] = "BiS %d/%d",
        ["BiS Forever"] = "BiS Forever",
        ["BiS"] = "BiS",
        ["Forever BiS"] = "Forever BiS",
        ["BiS Forever Help"] = "Ayuda de BiS Forever",
        ["BiS: %d/%d slots - Listed: %d/%d"] = "BiS: %d/%d ranuras - Listadas: %d/%d",
        ["Both"] = "Ambas",
        ["ENCHANTS"] = "ENCANTAMIENTOS",
        ["Equip: "] = "Equipar: ",
        ["Equipped Only"] = "Solo equipado",
        ["Faction"] = "Facción",
        ["Forever BiS alerts: "] = "Alertas de Forever BiS: ",
        ["Forever BiS dungeon notice: "] = "Aviso de mazmorra de Forever BiS: ",
        ["Forever BiS minimap button: "] = "Botón del minimapa de Forever BiS: ",
        ["Forever BiS tooltips: "] = "Tooltips de Forever BiS: ",
        ["Forever BiS stars: "] = "Estrellas de Forever BiS: ",
        ["Item %d"] = "Objeto %d",
        ["Level %s"] = "Nivel %s",
        ["Maker-only items"] = "Objetos solo para su creador",
        ["Maker: all"] = "Creador: todos",
        ["Maker: hide"] = "Creador: ocultar",
        ["Maker: only"] = "Creador: solo",
        ["No BiS list is loaded for this build."] = "No hay ninguna lista BiS cargada para esta build.",
        ["No equipped BiS items found."] = "No se encontraron objetos BiS equipados.",
        ["Remaining: %s"] = "Restante: %s",
        ["Show items for your faction only. Click to show both factions."] = "Muestra solo los objetos de tu facción. Haz clic para mostrar ambas facciones.",
        ["Show only %s sources. Select several to combine them."] = "Muestra solo las fuentes de %s. Selecciona varias para combinarlas.",
        ["Show only BiS items already equipped in their matching slots."] = "Muestra solo los objetos BiS ya equipados en su ranura correspondiente.",
        ["Some profession items can only be worn by the player who crafted them. Click to cycle: all items, only those maker-only items, or hide them. Items any player can use are treated as normal."] = "Algunos objetos de profesión solo puede usarlos quien los fabricó. Haz clic para alternar entre todos los objetos, solo esos objetos de creador u ocultarlos. Los objetos que cualquier jugador puede usar se tratan como normales.",
        ["This installed version does not include the selected BiS list yet."] = "Esta versión instalada aún no incluye la lista BiS seleccionada.",
        ["Unknown slot '%s'. Valid slots: %s"] = "Ranura desconocida '%s'. Ranuras válidas: %s",
        ["all classes"] = "todas las clases",
        ["off"] = "inactivo",
        ["on"] = "activo",
        ["x%d"] = "x%d",
        ["your class only"] = "solo tu clase",
        -- Item tooltip blocks and their /bis tooltip toggles.
        ["BiS #%d for %s (%s)"] = "BiS nº %d para %s (%s)",
        ["BiS for %s at %s"] = "BiS para %s en %s",
        ["Not BiS for %s"] = "No es BiS para %s",
        ["Also for: %s"] = "También para: %s",
        ["Your class: %s"] = "Tu clase: %s",
        ["+%d more - hold Shift"] = "+%d más (mantén Mayús)",
        ["Forever BiS tooltip, %s: "] = "Tooltip de Forever BiS, %s: ",
        ["your spec"] = "tu especialización",
        ["your other specs"] = "tus otras especializaciones",
        ["other classes"] = "otras clases",
        ["compact mode"] = "modo compacto",
        -- Dynamic keys: looked up through a variable, so they are not literals in the sources.
        ["Quest"] = "Misión",
        ["Dungeon"] = "Mazmorra",
        ["World"] = "Mundo",
        ["Profession"] = "Profesión",
        ["Quests"] = "Misiones",
        ["Dungeons and raids"] = "Mazmorras y bandas",
        ["Professions"] = "Profesiones",
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
