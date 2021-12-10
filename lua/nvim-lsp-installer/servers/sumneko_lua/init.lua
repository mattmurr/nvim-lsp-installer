local server = require "nvim-lsp-installer.server"
local path = require "nvim-lsp-installer.path"
local platform = require "nvim-lsp-installer.platform"
local Data = require "nvim-lsp-installer.data"
local installers = require "nvim-lsp-installer.installers"
local std = require "nvim-lsp-installer.installers.std"
local context = require "nvim-lsp-installer.installers.context"
local shell = require "nvim-lsp-installer.installers.shell"

return function(name, root_dir)
    local bin_dir = Data.coalesce(
        Data.when(platform.is_mac, "macOS"),
        Data.when(platform.is_linux, "Linux"),
        Data.when(platform.is_win, "Windows")
    )

    return server.Server:new {
        name = name,
        root_dir = root_dir,
        languages = { "lua" },
        homepage = "https://github.com/sumneko/lua-language-server",
        installer = {
            std.git_clone "https://github.com/sumneko/lua-language-server",
            std.git_submodule_update(),
            installers.on {
                unix = shell.bash [[
                pushd 3rd/luamake
                ./compile/install.sh
                popd
                ./3rd/luamake/luamake rebuild
                ]],
            },
            std.chmod(
                "+x",
                { path.concat { root_dir, "bin", bin_dir, "lua-language-server" } }
            ),
        },
        default_options = {
            cmd = { path.concat { root_dir, "bin", bin_dir, "lua-language-server" } },
        },
    }
end
