local Translations = {
    error = {
        to_far_from_door = 'Jste příliš daleko od zvonku',
        nobody_home = 'Nikdo není doma.',
        nobody_at_door = 'U dveří nikdo není...'
    },
    success = {
        receive_apart = 'Máš plochou',
        changed_apart = 'Přesunuli jste se',
    },
    info = {
        at_the_door = 'Někdo je u dveří!',
    },
    text = {
        menu_header = 'Byty',
        door_outside = '[E] - Byty',
        enter = 'Zadejte byt',
        ring_doorbell = 'Kroužek',
        logout = '[E] - Odhlášení postavy',
        change_outfit = '[E] - Změna oblečení',
        open_stash = '[E] - Otevřená skrýš',
        move_here = 'Přesun sem',
        open_door = 'Otevřené dveře',
        door_inside = '[E] - Dveře',
        leave = 'Ponechat plochý',
        close_menu = '⬅ Zavřít nabídku',
        tennants = 'Nájemce',
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