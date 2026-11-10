-- ==========================================================================
-- ftdetect/bell.lua
-- Registra automaticamente qualquer arquivo '*.bell' como filetype = 'bell'
-- ==========================================================================

vim.filetype.add({
    extension = {
        bell = "bell",
    },
})
