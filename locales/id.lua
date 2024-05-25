local Translations = {
    error = {
        to_far_from_door = 'Anda terlalu jauh dari Bel Pintu',
        nobody_home = 'Tidak ada orang di rumah..',
        nobody_at_door = 'Tidak ada seorang pun di pintu...'
    },
    success = {
        receive_apart = 'Anda mendapatkan apartemen',
        changed_apart = 'Anda pindah apartemen',
    },
    info = {
        at_the_door = 'Seseorang ada di depan pintu!',
    },
    text = {
        menu_header = 'Apartemen',
        door_outside = '[E] - Apartemen',
        enter = 'Masuk Apartemen',
        ring_doorbell = 'Ketuk Pintu',
        logout = '[E] - Logout Karakter',
        change_outfit = '[E] - Ganti Pakaian',
        open_stash = '[E] - Buka Penyimpanan',
        move_here = 'Pindah Kesini',
        open_door = 'Buka Pintu',
        door_inside = '[E] - Pintu',
        leave = 'Keluar Apartemen',
        close_menu = '⬅ Tutup Menu',
        tennants = 'Penyewa',
    },
}

if GetConvar('qb_locale', 'en') == 'id' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
