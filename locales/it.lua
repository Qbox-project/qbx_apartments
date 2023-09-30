local Translations = {
    error = {
        to_far_from_door = 'Sei troppo lontano dal campanello',
        nobody_home = 'Nessuno è a casa..',
        nobody_at_door = 'There is nobody at the door...'
    },
    success = {
        receive_apart = 'You got a apartment',
        changed_apart = 'You moved apartments',
    },
    info = {
        at_the_door = 'Someone is at the door!',
    },
    text = {
        menu_header = 'Apartments',
        door_outside = '[E] - Apartments',
        enter = 'Enter Apartment',
        ring_doorbell = 'Ring Doorbell',
        logout = '[E] - Character Logout',
        change_outfit = '[E] - Change Outfit',
        open_stash = '[E] - Open Stash',
        move_here = 'Move Here',
        open_door = 'Apri porta',
        door_inside = '[E] - Door',
        leave = 'Leave Apartment',
        close_menu = '⬅ Close Menu',
        tennants = 'Tennants',
    },
}

if GetConvar('qb_locale', 'en') == 'it' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
