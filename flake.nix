{
  description = "Lean 4 Nix Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  } : flake-parts.lib.mkFlake { inherit inputs; } {
    flake = (import ./overlay.nix) // {
      templates = {
        lib = {
          path = ./templates/lib;
          description = "Example Lean Project";
        };
        default = self.templates.lib;
      };
    };
    systems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    perSystem = { system, pkgs, ... }: let
      overlay = import ./overlay.nix;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay.tags."v4.12.0" ];
      };
      checks = pkgs.callPackage ./checks.nix {};
    in {
      checks = {
        inherit (checks) example;
      };
    };
  };
}
