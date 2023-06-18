local Translations = {
    error = {
        to_far_from_door = 'Estás muy lejos del timbre',
        nobody_home = 'No hay nadie en casa..',
        nobody_at_door = 'No hay nadie en la puerta..'
    },
    success = {
        receive_apart = 'Has obtenido un apartamento',
        changed_apart = 'Te has mudado de apartamento'
    },
    info = {
        at_the_door = '¡Hay alguien en la puerta!',
    },
    text = {
        menu_header = 'Apartamentos',
        door_outside = '[E] - Apartamentos',
        enter = 'Entrar al apartamento',
        ring_doorbell = 'Tocar timbre',
        logout = '[E] - Salir de personaje',
        change_outfit = '[E] - Cambiar ropa',
        open_stash = '[E] - Abrir almacenamiento',
        move_here = 'Moverse aquí',
        open_door = 'Abrir puerta',
        door_inside = '[E] - Puerta',
        leave = 'Salir del apartamento',
        close_menu = '⬅ Cerrar menú',
        tennants = 'Inquilinos',
    },
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
