local Translations = {
    error = {
        to_far_from_door = 'Estás muito longe da Campainha',
        nobody_home = 'Não está ninguém em casa..',
        nobody_at_door = 'Não está ninguém à porta...'
    },
    success = {
        receive_apart = 'Recebeste um apartamento',
        changed_apart = 'Mudaste de apartamento',
    },
    info = {
        at_the_door = 'Alguém está à porta!',
    },
    text = {
        menu_header = 'Apartamentos',
        door_outside = '[E] - Apartamentos',
        enter = 'Entrar no Apartamento',
        ring_doorbell = 'Tocar na Campainha',
        logout = '[E] - Terminar Sessão de Personagem',
        change_outfit = '[E] - Mudar Roupa',
        open_stash = '[E] - Abrir Armazém',
        move_here = 'Mudar para Aqui',
        open_door = 'Abrir Porta',
        door_inside = '[E] - Porta',
        leave = 'Sair do Apartamento',
        close_menu = '⬅ Fechar Menu',
        tennants = 'Inquilinos',
    },
}

if GetConvar('qb_locale', 'en') == 'pt' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
