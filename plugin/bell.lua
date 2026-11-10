-- ==========================================================================
-- plugin/bell.lua
-- Carregado automaticamente pelo Neovim na inicializacao
-- ==========================================================================

if vim.g.loaded_bell_nvim then
    return
end
vim.g.loaded_bell_nvim = true

-- Garante que 'require("bell")' funcione mesmo quando instalado via symlink
-- em ~/.config/nvim/plugin/bell.lua:
local plugin_file = vim.fn.resolve(debug.getinfo(1, "S").source:sub(2))
local plugin_root = vim.fn.fnamemodify(plugin_file, ":p:h:h")
if not vim.tbl_contains(vim.opt.rtp:get(), plugin_root) then
    vim.opt.rtp:append(plugin_root)
end

-- Registra a extensao '.bell' como filetype = 'bell'
vim.filetype.add({
    extension = {
        bell = "bell",
    },
})

local bell = require("bell")
local grupo = vim.api.nvim_create_augroup("BellSyntaxHighlighter", { clear = true })

local function ativar_no_buffer(buf)
    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    vim.bo[buf].syntax = "off"
    vim.bo[buf].commentstring = "// %s"
    bell.highlight(buf)
end

-- Ativa automaticamente em qualquer arquivo '*.bell' ou filetype = 'bell'
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = grupo,
    pattern = "bell",
    callback = function(ev)
        ativar_no_buffer(ev.buf)
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "InsertLeave" }, {
    group = grupo,
    pattern = "*.bell",
    callback = function(ev)
        if vim.bo[ev.buf].filetype ~= "bell" then
            vim.bo[ev.buf].filetype = "bell"
        end
        ativar_no_buffer(ev.buf)
    end,
})

-- Comando manual ':BellHighlight' para destacar o buffer atual
vim.api.nvim_create_user_command("BellHighlight", function()
    ativar_no_buffer(vim.api.nvim_get_current_buf())
end, {})

-- Comando ':BellUpdate' para baixar/atualizar e recompilar o 'bellc' do GitHub
vim.api.nvim_create_user_command("BellUpdate", function()
    bell.install_compiler(function()
        ativar_no_buffer(vim.api.nvim_get_current_buf())
    end)
end, {})
