{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, hyprlock           # Added
, bluez  # Added
}:

rustPlatform.buildRustPackage rec {
  pname = "hyprproxlock";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "Da4ndo";
    repo = pname;
    rev = "${version}";
    hash = "sha256-8XxDFcIKiGQ4CvEl3+4Jh4EBU4R08i1ylVbWfNjkj6o="; # Update after first build
  };

  cargoHash = "sha256-O93RfRO2d1Wonv8yK1eKdR8nwDw0nUTf1UKBF1ugc1A="; # Update after first build

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ hyprlock bluez ]; # Both are required

  meta = with lib; {
    description = "A proximity-based daemon for Hyprland that triggers screen locking via Bluetooth device proximity";
    homepage = "https://github.com/Da4ndo/hyprproxlock";
    license = licenses.bsd3;
    maintainers = [];
    platforms = platforms.linux;
  };
}
