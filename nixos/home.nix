{ config, pkgs, ... }:
let
  rcloneRemote = "gdrive";
  rcloneMount = "${config.home.homeDirectory}/gdrive";
  techLabScript = "${config.home.homeDirectory}/TechLabLocal/watcher.sh";
in
{
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    rclone
    pandoc
    pi-coding-agent
  ];

  home.username = "pocket";
  home.homeDirectory = "/home/pocket";
  programs.home-manager.enable = true;

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

  # ssh
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/keys/git";
      };
      "loshad los*" = {
        hostname = "ssh.sausage.house";
        port = 22;
        user = "pavan";
        identityFile = "~/.ssh/keys/ai-classmate";
      };
    };
  };

  # git
  programs.git = {
    enable = true;
    settings = {
      user.name = "pocket-98";
      user.email = "dayalpavan@gmail.com";
      init.defaultBranch = "main";
    };
  };

  # rclone
  programs.rclone.enable = true;
  programs.rclone.remotes = {
    "${rcloneRemote}" = {
      config = {
        type = "drive";
        scope = "drive";
        config_is_local = true;
        disable_http2 = true;
        hard_delete = true;
      };
      secrets = {
        client_id = "10--REDACTED--mp.apps.googleusercontent.com";
        client_secret = "GOC--REDACTED--d2L";
        token = "{}";
      };
      mounts."" = {
        enable = true;
        mountPoint = rcloneMount;
        options = {
          allow-non-empty = true;
          allow-other = true;
        };
      };
    };
  };

  systemd.user.services.rclone-mount = {
    Unit = {
      Description = "Rclone mount for ${rcloneRemote}";
      After = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${rcloneMount}";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount ${rcloneRemote}: ${rcloneMount} \
          --vfs-cache-mode writes \
          --no-check-certificate
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -u ${rcloneMount}";
      Restart = "always";
      RestartSec = "5s";
    };
  };

  systemd.user.services.tech-lab-watcher = {
    Unit = {
      Description = "systemd unit for ${techLabScript}";
      After = [ "network-online.target" ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScript "run-external" (builtins.readFile "${techLabScript}") }";
      User = "${config.home.username}";
      WorkingDirectory = "${builtins.dirOf "${techLabScript}"}";
      Restart = "always";
      RestartSec = "60s";
    };
  };
}
