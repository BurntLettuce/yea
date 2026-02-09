{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, hyprlock
, bluez
, dbus  # <-- ADD THIS
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

  cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Will be updated

  # Add dbus here for pkg-config to find dbus-1.pc
  nativeBuildInputs = [ pkg-config dbus ];
  
  # Add dbus here for linking
  buildInputs = [ hyprlock bluez dbus ];
  
  # Ensure bluez binaries are in PATH at runtime
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
