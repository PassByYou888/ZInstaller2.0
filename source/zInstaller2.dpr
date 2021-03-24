program zInstaller2;

uses
  System.StartUpCopy,
  FMX.Forms,
  Install2Frm in 'Install2Frm.pas' {Install2Form},
  StyleModuleUnit in 'StyleModuleUnit.pas' {StyleDataModule: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TInstall2Form, Install2Form);
  Application.CreateForm(TStyleDataModule, StyleDataModule);
  Application.Run;
end.
