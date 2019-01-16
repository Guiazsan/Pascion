{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit PascionPack;

{$warn 5023 off : no warning about unused units}
interface

uses
  ResizeablePanel, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ResizeablePanel', @ResizeablePanel.Register);
end;

initialization
  RegisterPackage('PascionPack', @Register);
end.
