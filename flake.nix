{
  description = "0WM Server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ocamlPackages = pkgs.ocaml-ng.ocamlPackages_5_2;
      in
      {
        packages = pkgs.callPackage ./nix/packages/default.nix { inherit ocamlPackages; };

        devShells.default = pkgs.mkShell {
          # build tools
          nativeBuildInputs = with ocamlPackages; [
            dune_3
            findlib
            ocaml
            ocaml-lsp
            pkgs.opam
          ];

          # dependencies
          buildInputs = with ocamlPackages; [
            base64
            camlimages
            dream
            lwt_ppx
            self.packages.gendarme-yojson
            self.packages.ppx_marshal
            uuidm
          ];
        };
      }
    );
}
