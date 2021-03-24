program zInstaller2BuildTool;

uses
  Vcl.Forms,
  Installer2BuildToolFrm in 'Installer2BuildToolFrm.pas' {Installer2BuildToolForm},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 Dark');
  Application.CreateForm(TInstaller2BuildToolForm, Installer2BuildToolForm);
  Application.Run;
end.
