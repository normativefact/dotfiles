 { config, lib, inputs, pkgs, ... }: {

 boot.initrd.kernelModules = [ "amdgpu" ];


 hardware.graphics = { 
  enable = true;
  enable32Bit = true;
  };
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   powerManagement.finegrained = false;
  #   open = true;
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };
  # services.xserver.videoDrivers = ["nvidia"];

  services.xserver.videoDrivers = ["amdgpu"];

  }
