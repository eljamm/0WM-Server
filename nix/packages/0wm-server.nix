{
  lib,
  fetchFromGitHub,
  makeWrapper,
  writableTmpDirAsHomeHook,

  # dependencies
  ocamlPackages,
  gendarme,
  gendarme-yojson,
  ppx_marshal,

  # passthru
  deps,
  nix-update-script,
}:
ocamlPackages.buildDunePackage (finalAttrs: {
  pname = "0wm-server";
  version = "0-unstable";

  duneVersion = "3";

  src = ../../.;

  nativeBuildInputs = [
    makeWrapper
    writableTmpDirAsHomeHook
  ];

  buildInputs = with ocamlPackages; [
    base64
    camlimages
    domainslib
    dream
    gendarme
    gendarme-yojson
    lwt_ppx
    ppx_marshal
    uuidm
  ];

  postBuild = ''
    dune build src/zwm.exe
  '';

  postInstall = ''
    mkdir -p $out/{bin,share/examples}

    cp -r _build/default/src/zwm.exe $out/bin/0wm-server
    cp config.json $out/share/examples

    # The server only reads the config file from its work directory and there
    # is no flag to override this.
    #
    # As a workaround, we set the default work dir as the example config, so
    # this package works standalone. Then, in the module, we set "WORKDIR" as
    # the systemd state directory (where the config is copied to).
    wrapProgram $out/bin/0wm-server \
      --set-default "WORKDIR" "$out/share/examples" \
      --run 'cd "$WORKDIR"'
  '';

  passthru = {
    inherit deps;
    updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };
  };

  meta = {
    description = "0WM Server";
    homepage = "https://github.com/lab0-cc/0WM-Server";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    teams = with lib.teams; [ ngi ];
    mainProgram = "0wm-server";
  };
})
