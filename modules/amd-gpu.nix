{pkgs, ...}: {
  # ── AMD GPU ───────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # VA-API for hardware video acceleration
  environment.variables = {
    LIBVA_DRIVER_NAME = "radeonsi";
  };

  # Unlock all power-play features (fan curves, overclocking headroom, etc.)
  boot.kernelParams = ["amdgpu.ppfeaturemask=0xffffffff"];

  environment.systemPackages = [pkgs.corectrl];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.corectrl.helper.init" ||
           action.id == "org.corectrl.helperkiller.init") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # ── CPU microcode ─────────────────────────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = true;
}
