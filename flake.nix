{
  description = "Modern Elisp package development system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin"];

      imports = [inputs.treefmt-nix.flakeModule];

      perSystem = {system, ...}: let
        overlay = _: prev: let
          emacs = prev.emacs30;
        in {
          inherit emacs;
        };
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [overlay];
        };
        keg = pkgs.writeShellScriptBin "keg" ''
          exec ${pkgs.emacs}/bin/emacs --batch -l ${./.}/bin/keg -- "$@"
        '';
      in {
        packages.default = keg;
        packages.keg = keg;

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.emacs
            pkgs.gnumake
            keg
          ];
        };

        treefmt = {
          programs.alejandra.enable = true;
        };
      };
    };
}
