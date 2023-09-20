{ lib, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    withPython3 = true;
    extraPackages = with pkgs; [
      (python3.withPackages (ps: with ps; [
        ruff-lsp
      ]))
    ];
    plugins = with pkgs.vimPlugins; [
      {
        plugin = vim-airline;
        config = ''
          let g:airline_theme='base16'
          let g:airline_powerline_fonts = 1
          let g:airline#extensions#tabline#enabled = 1
        '';
      }
      vim-airline-themes
      nerdtree-git-plugin
      {
        plugin = ctrlp-vim;
        config = "let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']";
      }
      vim-gitgutter
      ale
      editorconfig-nvim
      vim-commentary
      vim-polyglot
      base16-vim
      nvim-tree-lua
      nvim-web-devicons
      nvim-treesitter.withAllGrammars
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp_luasnip
      luasnip
    ];
    extraConfig = builtins.readFile ./init.vim;
    extraLuaConfig = builtins.readFile ./init.lua;
  };
}
