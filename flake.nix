{
  description = "for working on Dungeons & Gardens";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus/master";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      utils,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tex = pkgs.texliveSmall.withPackages (
          ps: with ps; [
            scheme-small
            collection-fontsextra
            etbb
            xstring
          ]
        ) ;
        dnd-cards = pkgs.callPackage ./package.nix { inherit tex; };
      in
      rec {
        packages = {
          inherit dnd-cards tex;
          default = dnd-cards;
        };
        devShells = {
          default = pkgs.mkShell {
            name = "dnd-cards-shell";
            shellHook = ''
              export src=${./.}
              export texfiles="${dnd-cards.texfiles}";
            '';
            nativeBuildInputs = with pkgs; [
              nixfmt-rfc-style
              dnd-cards.nativeBuildInputs
            ];
          };
        };
      }
    );
}
