-- ==========================================================================
-- lua/bell/init.lua
-- Modulo principal do plugin bell.nvim
-- Baixa e compila 'bellc' a partir do GitHub em stdpath("data")/bell.nvim
-- ==========================================================================

local M = {}

local ns_id = vim.api.nvim_create_namespace("bell_syntax_highlight")
local data_dir = vim.fn.stdpath("data") .. "/bell.nvim"
local src_dir = data_dir .. "/src"
local default_bin = src_dir .. "/bellc"

M.config = {
    repo_url = "https://github.com/gabrielmusskopf/bell-lang.git",
    branch = "main",
    bin = default_bin,
    auto_install = true,
    highlights = {
        TIPO              = "Type",
        PALAVRA_RESERVADA = "Keyword",
        IDENTIFICADOR     = "Identifier",
        LITERAL_INT       = "Number",
        LITERAL_FLOAT     = "Float",
        OP_ARITMETICO     = "Operator",
        OP_RELACIONAL     = "Operator",
        OP_ATRIBUICAO     = "Operator",
        DELIMITADOR       = "Delimiter",
        COMENTARIO        = "Comment",
        ERRO_LEXICO       = "Error",
    },
}

local instalando = false

-- Clona (ou atualiza) o repositorio do GitHub e compila o binario 'bellc'
function M.install_compiler(callback)
    if instalando then
        return
    end
    instalando = true
    vim.fn.mkdir(data_dir, "p")

    local cmd
    if vim.fn.isdirectory(src_dir .. "/.git") == 1 then
        cmd = string.format(
            "git -C %s fetch origin && git -C %s checkout %s && git -C %s pull origin %s && make -C %s clean && make -C %s TARGET=bellc",
            vim.fn.shellescape(src_dir),
            vim.fn.shellescape(src_dir),
            vim.fn.shellescape(M.config.branch),
            vim.fn.shellescape(src_dir),
            vim.fn.shellescape(M.config.branch),
            vim.fn.shellescape(src_dir),
            vim.fn.shellescape(src_dir)
        )
    else
        vim.fn.delete(src_dir, "rf")
        cmd = string.format(
            "git clone --branch %s %s %s && make -C %s TARGET=bellc",
            vim.fn.shellescape(M.config.branch),
            vim.fn.shellescape(M.config.repo_url),
            vim.fn.shellescape(src_dir),
            vim.fn.shellescape(src_dir)
        )
    end

    vim.notify("[bell.nvim] Baixando e compilando 'bellc' do GitHub (bell-lang)...", vim.log.levels.INFO)

    vim.fn.jobstart({ "sh", "-c", cmd }, {
        on_exit = function(_, code)
            instalando = false
            if code == 0 and vim.fn.executable(M.config.bin) == 1 then
                vim.notify("[bell.nvim] Compilador 'bellc' compilado com sucesso em: " .. M.config.bin, vim.log.levels.INFO)
                if callback then
                    vim.schedule(callback)
                end
            else
                vim.notify("[bell.nvim] Falha ao baixar/compilar 'bellc' do GitHub (verifique se o branch ja foi enviado com git push).", vim.log.levels.WARN)
            end
        end,
    })
end

function M.highlight(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return
    end

    -- Se o binario 'bellc' ainda nao foi baixado/compilado, instala do GitHub automaticamente
    if vim.fn.executable(M.config.bin) ~= 1 then
        if M.config.auto_install then
            M.install_compiler(function()
                M.highlight(bufnr)
            end)
        end
        return
    end

    -- 1. Limpa destaques anteriores deste buffer
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    -- 2. Obtém o texto atual do buffer
    local linhas = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local codigo_fonte = table.concat(linhas, "\n") .. "\n"

    -- 3. Executa 'bellc --tokens'
    local saida = vim.fn.system({ M.config.bin, "--tokens" }, codigo_fonte)
    if vim.v.shell_error ~= 0 then
        return
    end

    -- 4. Lê cada linha '<linha> <col_ini> <col_fim> <categoria> <lexema>'
    for linha_saida in saida:gmatch("[^\r\n]+") do
        local lin, col_ini, col_fim, categoria =
            linha_saida:match("^(%d+)%s+(%d+)%s+(%d+)%s+(%S+)")

        if lin and col_ini and col_fim and categoria then
            local hl_group = M.config.highlights[categoria]
            if hl_group then
                local l = tonumber(lin) - 1
                local c_ini = tonumber(col_ini) - 1
                local c_fim = tonumber(col_fim)

                pcall(vim.api.nvim_buf_set_extmark, bufnr, ns_id, l, c_ini, {
                    end_row = l,
                    end_col = c_fim,
                    hl_group = hl_group,
                })
            end
        end
    end
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

return M
