{
  description = "0WM Server";

  nixConfig = {
    ## Enable NGIpkgs binary cache
    # extra-substituters = [ "https://ngi.cachix.org/" ];
    # extra-trusted-public-keys = [ "ngi.cachix.org-1:n+CAL72ROC3qQuLxIHpV+Tw5t42WhXmMhprAGkRSrOw=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    ngipkgs.url = "github:ngi-nix/ngipkgs";
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
      ngipkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        ocamlPackages = pkgs.ocaml-ng.ocamlPackages_5_2;
        projectPackages = pkgs.callPackage ./nix/packages/default.nix { inherit ocamlPackages; };
        projectTests = pkgs.callPackage ./nix/tests/default.nix { inherit pkgs ngipkgs; };

        # nix build .#_0wm-server-optimized -L
        projectPackagesOptimized =
          with pkgs.lib;
          mapAttrs' (name: value: nameValuePair (name + "-optimized") value) (
            projectPackages.override {
              ocamlPackages = ocamlPackages.overrideScope (
                self: super: { ocaml = super.ocaml.override { flambdaSupport = true; }; }
              );
            }
          );

        # Flake packages need to be derivations
        filterPkgs = attrs: with pkgs.lib; filterAttrs (n: isDerivation) attrs;
      in
      {
        packages = filterPkgs (projectPackages // projectPackagesOptimized // projectTests);

        # nix flake check
        checks = {
          inherit (projectPackages) _0wm-server;
          inherit (projectTests) test;
        };

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
            domainslib
            dream
            lwt_ppx
            projectPackages.gendarme
            projectPackages.gendarme-yojson
            projectPackages.ppx_marshal
            uuidm
          ];
        };
      }
    );
}
