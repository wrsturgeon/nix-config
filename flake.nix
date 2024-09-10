{
  description = "System flakes";
  inputs = {
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    github-dark-nvim-src = {
      flake = false;
      url = "github:vv9k/vim-github-dark";
    };
    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };
    nixos-hardware = {
      flake = false;
      url = "github:kekrby/nixos-hardware";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      inputs = {
        nix-darwin.follows = "nix-darwin";
        nixpkgs.follows = "nixpkgs";
      };
      url = "github:nix-community/nixvim/2ef974182ef62a6a6992118f0beb54dce812ae9b";
    };
  };
  outputs =
    {
      fenix,
      flake-utils,
      github-dark-nvim-src,
      nix-darwin,
      nixos-hardware,
      nixpkgs,
      nixvim,
      self,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let

        # `lib.strings`
        inherit (nixpkgs.lib) strings;

        # Nixpkgs
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [ "electron-27.3.11" ];
          };
        };

        # OS introspection utils
        on-linux = strings.hasSuffix "linux" system;
        on-mac = strings.hasSuffix "darwin" system;
        linux-mac =
          if on-linux then
            (a: b: a)
          else if on-mac then
            (a: b: b)
          else
            throw "Unrecognized OS in system `${system}`!";

        # Usernames
        usernames = [
          "willsturgeon"
          "Figments-MacBook-Pro"
        ];
        eachUsername =
          f:
          builtins.listToAttrs (
            builtins.map (name: {
              inherit name;
              value = f name;
            }) usernames
          );

        # Terminal emulator(s)
        wezterm = laptop-name: import config/programs/wezterm (cfg-args laptop-name);
        terminal-settings = rec {
          font-size = 13;
          dark = true;
          # weight = if dark then "Light" else "Regular";
          # italic = if dark then "Light Italic" else "Italic";
          weight = "Regular";
          italic = "Italic";
          theme = if dark then "ayu" else "ayu-light";
        };

        # Custom fonts
        iosevka = pkgs.iosevka.override {
          # <https://github.com/be5invis/Iosevka/blob/main/doc/language-specific-ligation-sets.md>
          privateBuildPlan = {
            exportGlyphNames = true;
            family = "Iosevka Custom";
            # <https://github.com/be5invis/Iosevka?tab=readme-ov-file#ligations>
            ligations = {
              # enable all those not enabled by `dlig` below
              # (see the above link for a visual depiction):
              enables = [
                "eqexeq"
                "eqslasheq"
                "slasheq"
                "tildeeq"
              ];
              inherits = "dlig";
            };
            noCvSs = false;
            noLigation = false;
            spacing = "fontconfig-mono";
            variants.inherits = "ss08";
            webfontFormats = [ ]; # i.e. none
          };
          set = "custom";
        };

        # GitHub Dark theme for Neovim
        github-dark-nvim = pkgs.stdenvNoCC.mkDerivation {
          name = "github-dark-nvim";
          version = "git";
          src = github-dark-nvim-src;
          buildPhase = ":";
          installPhase = ''
            cp -r . $out
          '';
        };

        # Print deeply evaluated attribute sets
        print = print-indent 0;
        print-indent =
          indent: x:
          if builtins.isAttrs x then
            ''
              {
              ${concat-lines (
                builtins.attrValues (
                  builtins.mapAttrs (k: v: "${spaces indent}${k} = ${print-indent (indent + 2) v};") x
                )
              )}
              ${spaces indent}}''
          else if builtins.isString x then
            ''"${x}"''
          else if builtins.isNull x then
            "<null>"
          else if builtins.isBool x then
            if x then "true" else "false"
          else if builtins.isList x then
            ''
              [
              ${concat-lines (
                builtins.map (z: ''
                  ${spaces indent}(${print-indent (indent + 2) z})
                '') x
              )}
              ${spaces indent}]''
          else
            builtins.toString x;
        concat-lines = builtins.concatStringsSep "\n";
        spaces = n: builtins.concatStringsSep "" (builtins.genList (_: " ") n);

        # Recursively delete null bindings
        nonnull =
          s:
          if builtins.isAttrs s then
            # builtins.mapAttrs (_: nonnull)
            (builtins.removeAttrs s (builtins.filter (x: builtins.isNull s.${x}) (builtins.attrNames s)))
          else
            s;

        # Config
        cfg-args = laptop-name: {
          inherit
            github-dark-nvim
            iosevka
            laptop-name
            linux-mac
            nixos-hardware
            nixvim
            pkgs
            print
            self
            system
            terminal-settings
            ;
          dock-apps =
            (builtins.map (f: f laptop-name) [
              wezterm
            ])
            ++ (
              with pkgs;
              [
                discord
                logseq
                signal-desktop
                slack
                spotify
              ]
              ++ linux-mac [ firefox ] [ arc-browser ]
            );
          emacs = import config/programs/emacs (cfg-args laptop-name);
          git = pkgs.gitFull;
          hardware-configuration = import config/hardware-configuration.nix;
          rust = fenix.packages.${system}.minimal;
          vim = nixvim.legacyPackages.${system}.makeNixvim (
            import config/programs/neovim (cfg-args laptop-name)
          );
        };
        cfg = laptop-name: {
          inherit system;
          modules =
            let
              all-files = builtins.attrNames (builtins.readDir config/system);
              all-nix = builtins.filter (strings.hasSuffix ".nix") all-files;
              all-configs = builtins.map (filename: {
                name = strings.removeSuffix ".nix" filename;
                value = import config/system/${filename} (cfg-args laptop-name);
              }) all-nix;
              configs = builtins.listToAttrs all-configs;
              relevant = nonnull configs;
            in
            [ relevant ];
        };
      in
      {
        apps.default = {
          type = "app";
          program = ./rebuild;
        };
        packages = {
          nixosConfigurations = eachUsername (laptop-name: nixpkgs.lib.nixosSystem (cfg laptop-name));
          darwinConfigurations = eachUsername (laptop-name: nix-darwin.lib.darwinSystem (cfg laptop-name));
        };
      }
    );
}
