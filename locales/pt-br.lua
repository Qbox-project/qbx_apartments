local Translations = {
    error = {
        to_far_from_door = 'Você está muito longe do interfone',
        nobody_home = 'Não há ninguém em casa..',
        nobody_at_door = 'Não há ninguém na porta...'
    },
    success = {
        receive_apart = 'Você conseguiu um apartamento',
        changed_apart = 'Você mudou de apartamento',
    },
    info = {
        at_the_door = 'Alguém está na porta!',
    },
    text = {
        menu_header = 'Apartamentos',
        door_outside = '[E] - Apartamentos',
        enter = 'Entrar no Apartamento',
        ring_doorbell = 'Tocar Interfone',
        logout = '[E] - Sair do Personagem',
        change_outfit = '[E] - Trocar de Roupa',
        open_stash = '[E] - Abrir Esconderijo',
        move_here = 'Mudar para cá',
        open_door = 'Destrancar porta',
        door_inside = '[E] - Porta',
        leave = 'Sair do Apartamento',
        close_menu = '⬅ Fechar Menu',
        tennants = 'Inquilinos',
    },
}


if GetConvar('qb_locale', 'en') == 'pt-br' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end