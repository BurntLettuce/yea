{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, makeWrapper  # <-- ADD THIS
, hyprlock
, bluez
, dbus
}:

rustPlatform.buildRustPackage rec {
  pname = "hyprproxlock";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "Da4ndo";
    repo = pname;
    rev = version;
    hash = "sha256-EoMxYMQBRP1fDfUorrkrgKDrVI88Ctusp2+1a7tnSU0=";
  };

  cargoHash = "sha256-rBZ3acHStmUzEU+lsFhNYvLVPeeZe6P+4OHyxHRe4CU="; # Will be updated

 # Add makeWrapper here
  nativeBuildInputs = [ pkg-config makeWrapper dbus ];
  buildInputs = [ hyprlock bluez dbus ];
  
  preFixup = ''
    wrapProgram $out/bin/hyprproxlock \
      --prefix PATH : "${lib.makeBinPath [ bluez ]}"
  '';

  meta = with lib; {
    description = "A proximity-based daemon for Hyprland that triggers screen locking via Bluetooth device proximity";
    homepage = "https://github.com/Da4ndo/hyprproxlock";
    license = licenses.bsd3;
    maintainers = [];
    platforms = platforms.linux;
  };
}
