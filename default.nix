{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name="test-lab";    
  
  buildInputs = with pkgs; [
    vagrant
  ];

  shellHook = 
    ''
    export VAGRANT_EXPERIMENTAL="disks"
    echo "local test lab"
    '';
} 