local Translations = {
    error = {
        to_far_from_door = 'Jsi příliš daleko od zvonku',
        nobody_home = 'Nikdo není doma..',
        nobody_at_door = 'Nikdo není u dveří...'
    },
    success = {
        receive_apart = 'Získal jsi byt',
        changed_apart = 'Přestěhoval jsi se',
    },
    info = {
        at_the_door = 'Někdo je u dveří!',
    },
    text = {
        menu_header = 'Byty',
        door_outside = '[E] - Byty',
        enter = 'Vstoupit do bytu',
        ring_doorbell = 'Zazvonit',
        logout = '[E] - Odhlásit postavu',
        change_outfit = '[E] - Změnit oblečení',
        open_stash = '[E] - Otevřít schránku',
        move_here = 'Přestěhovat se sem',
        open_door = 'Otevřít dveře',
        door_inside = '[E] - Dveře',
        leave = 'Opustit byt',
        close_menu = '⬅ Zavřít menu',
        tenants = 'Nájemníci',
}

if GetConvar('qb_locale', 'en') == 'cs' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
--translate by stepan_valic
