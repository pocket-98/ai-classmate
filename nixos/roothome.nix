{ config, pkgs, inputs, ... }:
{
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
  ];

  home.username = "root";
  home.homeDirectory = "/root";
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.home-manager.enable = true;

  home.file.".vim/tmp/.keep".text = "";

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      jellybeans-vim
    ];
    extraConfig = ''
      set nocompatible
      set backupdir=~/.vim/tmp/
      set directory=~/.vim/tmp/
      syntax on
      colorscheme jellybeans
      set t_Co=256
      highlight ExtraWhitespace ctermbg=green guibg=green
      match ExtraWhitespace /\s\+$/
      set autochdir
      set mouse=a
      set showmode
      set showcmd
      set cursorline
      "set rulerformat=%(%5l,%-6(%c%)\ %P%)
      "set ruler
      set autoindent
      set smartindent
      set tabstop=4
      set shiftwidth=4
      set expandtab
      set smartcase
      set ignorecase
      inoremap jj <ESC>
      "map <CR> o<Esc>
      command SudoW :execute ':silent w !sudo tee % > /dev/null' | :edit!
      command Xclip :execute ':silent w !xclip -selection c'
      if has("multi_byte")
          set encoding=utf-8
          setglobal fileencoding=utf-8
          "setglobal bomb
          set fileencodings=ucs-bom,utf-8,latin1
          if &termencoding == ""
              let &termencoding = &encoding
          endif
      endif
      " switch buffers with \1 \2 \3 \4 \5 \b
      nnoremap <Leader>b :bn<CR>
      nnoremap <Leader>1 :b1<CR>
      nnoremap <Leader>2 :b2<CR>
      nnoremap <Leader>3 :b3<CR>
      nnoremap <Leader>4 :b4<CR>
      nnoremap <Leader>5 :b5<CR>
      " be able to do `di$` delete inner dollar signs
      xnoremap i$ :<C-u> normal! T$vt$<CR>
      onoremap i$ :normal vi$<CR>
      xnoremap a$ :<C-u> normal!F$vf$<CR>
      onoremap a$ :normal va$<CR>
    '';
  };

}
