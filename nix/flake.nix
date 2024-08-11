{
  description = "System flakes";
  inputs = {
    home = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "path:./home";
    };
    linux = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "path:./os/linux";
    };
    mac.url = "path:./os/mac";
    nix-darwin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:LnL7/nix-darwin";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    shared = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "path:./os/shared";
    };
  };
  outputs =
    {
      home,
      linux,
      mac,
      shared,
      nix-darwin,
      nixpkgs,
      self,
    }:
    let
      linux-system = "x86_64-linux";
      mac-system = "x86_64-darwin";
      systems = [
        linux-system
        mac-system
      ];
      is-linux = nixpkgs.lib.strings.hasSuffix "linux";
      is-mac = nixpkgs.lib.strings.hasSuffix "darwin";
      linux-mac =
        system: on-linux: on-mac:
        if is-linux system then
          on-linux
        else if is-mac system then
          on-mac
        else
          throw ''Unrecognized OS "${system}"'';
      nixpkgs-config = system: {
        inherit system;
        config = {
          allowBroken = true;
          allowUnfree = true;
          allowUnsupportedSystem = true;
        };
      };
      stateVersion = "23.05";
      laptop-name = system: "mbp-" + (linux-mac system "nixos" "macos");
      username = system: linux-mac system "will" "willsturgeon";
      config-args = system: {
        inherit home stateVersion system;
        laptop-name = laptop-name system;
        linux-mac = linux-mac system;
        locale = "fr_FR.UTF-8";
        nixpkgs-config = nixpkgs-config system;
        username = username system;
      };
      on = system: module: {
        inherit system;
        modules = builtins.concatMap (flake: (flake.lib.configure (config-args system)).modules) [
          shared
          module
          home
        ];
      };
    in
    {
      apps =
        let
          rebuild-on =
            system:
            let
              pkgs = import nixpkgs (nixpkgs-config system);
              chmod = "${pkgs.coreutils}/bin/chmod";
              echo = "${pkgs.coreutils}/bin/echo";
              git = "${pkgs.git}/bin/git";
              mkdir = "${pkgs.coreutils}/bin/mkdir";
            in
            {
              type = "app";
              program = "${
                let
                  rebuild-script =
                    ''
                      #!${pkgs.bash}/bin/bash

                      set -eux
                    ''
                    + (linux-mac system ''
                      cd /etc/nixos
                      sudo ${git} pull
                    '' "")
                    + ''
                        ${
                          linux-mac system "sudo nixos-rebuild" "nix-darwin"
                        } switch --flake . --keep-going -v -j auto --show-trace # --install-bootloader

                      # Collect garbage
                      nix-collect-garbage -j auto --delete-older-than 14d > /dev/null 2>&1 &
                    '';
                in
                pkgs.stdenv.mkDerivation {
                  name = "reload";
                  src = ./.;
                  buildPhase = ":";
                  installPhase = ''
                    ${mkdir} -p $out/bin
                    ${echo} '${rebuild-script}' > $out/bin/rebuild
                    ${chmod} +x $out/bin/rebuild
                  '';
                }
              }/bin/rebuild";
            };
        in
        builtins.foldl' (
          acc: system:
          acc
          // {
            ${system} = {
              rebuild = rebuild-on system;
              default = self.apps.${system}.rebuild;
            };
          }
        ) { } systems;
      darwinConfigurations =
        let
          system = mac-system;
        in
        {
          ${laptop-name system} = nix-darwin.lib.darwinSystem (on system mac);
        };
      devShells =
        let
          shell-on =
            system:
            let
              pkgs = import nixpkgs (nixpkgs-config system);
            in
            {
              default = pkgs.mkShell {
                packages = with pkgs; [
                  lua-language-server
                  stylua
                ];
              };
            };
        in
        builtins.listToAttrs (
          builtins.map (name: {
            inherit name;
            value = shell-on name;
          }) systems
        );
      nixosConfigurations =
        let
          system = linux-system;
        in
        {
          ${laptop-name system} = nixpkgs.lib.nixosSystem (on system linux);
        };
    };
}
