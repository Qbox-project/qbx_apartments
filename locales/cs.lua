local Translations = {
    error = {
        to_far_from_door = 'Du bist zu weit von der Klingel entfernt',
        nobody_home = 'Niemand ist zuhause..',
        nobody_at_door = 'Niemand ist an der Tür...'
    },
    success = {
        receive_apart = 'Du hast eine Wohnung bekommen',
        changed_apart = 'Du bist umgezogen',
    },
    info = {
        at_the_door = 'Jemand ist an der Tür!',
    },
    text = {
        menu_header = 'Wohnungen',
        door_outside = '[E] - Wohnungen',
        enter = 'Wohnung betreten',
        ring_doorbell = 'Klingeln',
        logout = '[E] - Charakter ausloggen',
        change_outfit = '[E] - Outfit ändern',
        open_stash = '[E] - Stash öffnen',
        move_here = 'Hierher ziehen',
        open_door = 'Tür öffnen',
        door_inside = '[E] - Tür',
        leave = 'Wohnung verlassen',
        close_menu = '⬅ Menü schließen',
        tennants = 'Mieter',
    },
}

if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
--translate by stepan_valic