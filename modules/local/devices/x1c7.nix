# This is the module is dedicated to configuration options of user ash's profile.

{ lib, ... }:

{
  options.local.devices.x1c7 = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description =
        "Whether to enable ThinkPad X1 Carbon 7th Gen device profile.";
    };

    bio-auth = mkOption {
      type = with types; nullOr (enum [ "howdy" "fprintd" ]);
      default = null;
      example = "howdy";
      description = "Biometric authentication method.";
    };
  };
}
