{
  description = "MacOS-specific config";
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; };
  outputs = { nixpkgs, self }:
    { shared, system, username }: {
      environment = {
        shellAliases.nixos-rebuild =
          "darwin-rebuild --flake .#macbook-macos --keep-going -j auto";
        systemPackages = (shared {
          inherit shared system username;
        }).users.users.${username}.packages;
      };
      nix.linux-builder.enable = true;
      security.pam.enableSudoTouchIdAuth = true;
      services.nix-daemon.enable = true;
    };
}