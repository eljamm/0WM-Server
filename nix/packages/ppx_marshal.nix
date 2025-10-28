{
  lib,
  writableTmpDirAsHomeHook,
  ocamlPackages,
  gendarme,
  gendarme-ezjsonm,
  gendarme-toml,
  gendarme-yaml,
  gendarme-yojson,
}:

ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "ppx_marshal";
  inherit (gendarme) version src;

  minimalOCamlVersion = "4.13";

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    gendarme
    ocamlPackages.ppxlib
  ];

  checkInputs = [
    gendarme-ezjsonm
    gendarme-toml
    gendarme-yaml
    gendarme-yojson
    ocamlPackages.alcotest
  ];

  doCheck = true;

  meta = {
    description = "Preprocessor extension to automatically define marshallers for OCaml types";
    homepage = "https://github.com/bensmrs/gendarme";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
  };
})
