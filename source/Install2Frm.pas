unit Install2Frm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ScrollBox, FMX.Memo, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  FMX.Layouts, FMX.ListBox, FMX.Memo.Types,

  System.IOUtils,

  Winapi.Windows, Winapi.ShellAPI,
  System.Win.ComObj, Winapi.ActiveX, Winapi.ShlObj,
  System.Win.Registry,

  CoreClasses,
  PascalStrings,
  UnicodeMixedLib,
  MemoryStream64,
  DoStatusIO,
  CoreCipher,
  DataFrameEngine,
  TextDataEngine,
  zDrawEngine, zDrawEngineInterface_SlowFMX, MemoryRaster, NotifyObjectBase,
  ZDB2_FileEncoder, ZDB2_Core, zExpression, ListEngine;

const
  C_Software = 'ZInstallerDemo';
  C_DestDirectory = 'c:\' + C_Software + '\';

type
  TInstall2Form = class(TForm)
    btnLayout: TLayout;
    InstallButton: TButton;
    destDirLayout: TLayout;
    Label2: TLabel;
    DirectoryEdit: TEdit;
    BrowseDirEditButton: TEditButton;
    confLayout: TLayout;
    Label1: TLabel;
    confEdit: TEdit;
    browseConfEditButton: TEditButton;
    OpenDialog: TOpenDialog;
    Memo: TMemo;
    ProgressBar: TProgressBar;
    StatusLabel: TLabel;
    Timer: TTimer;
    cliLayout: TLayout;
    titleLabel: TLabel;
    procedure TimerTimer(Sender: TObject);
    procedure browseConfEditButtonClick(Sender: TObject);
    procedure BrowseDirEditButtonClick(Sender: TObject);
    procedure InstallButtonClick(Sender: TObject);
  private
    procedure DoStatus_Backcall(Text_: SystemString; const ID: Integer);
    procedure ZDB2_File_OnProgress(State_: SystemString; Total, Current1, Current2: Int64);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // install before, plan code here
    procedure DoInstallBefore(const DestDirectory: U_String);

    // done for install, plan code here
    procedure DoInstallAfter(const DestDirectory: U_String);
  end;

var
  Install2Form: TInstall2Form;
  InstallLog: TPascalStringList;

procedure BuildShellLinkToDesktop(const fileName, workDirectory, shortCutName: WideString);
procedure BuildShellLinkToProgram(const fileName, workDirectory, shortCutName: WideString);
procedure BuildShellLinkToStartup(const fileName, workDirectory, param, shortCutName: WideString);
procedure ShellRun(ExeFile, param: U_String);

implementation

{$R *.fmx}


uses StyleModuleUnit;

procedure BuildShellLinkToDesktop(const fileName, workDirectory, shortCutName: WideString);
var
  AnObj: IUnknown;
  ShLink: IShellLink;
  PFile: IPersistFile;
  WFileName: WideString;
  Reg: TRegIniFile;
begin
  AnObj := CreateComObject(CLSID_ShellLink);
  ShLink := AnObj as IShellLink;
  PFile := AnObj as IPersistFile;
  ShLink.SetPath(PWideChar(fileName));
  ShLink.SetWorkingDirectory(PWideChar(workDirectory));
  Reg := TRegIniFile.Create('Software\MicroSoft\Windows\CurrentVersion\Explorer');
  WFileName := Reg.ReadString('Shell Folders', 'Desktop', '') + '\' + shortCutName + '.lnk';
  Reg.Free;
  PFile.Save(PWideChar(WFileName), False);
  InstallLog.Add(WFileName);
  DoStatus('create shortcut: %s', [WFileName]);
  AnObj := nil;
end;

procedure BuildShellLinkToProgram(const fileName, workDirectory, shortCutName: WideString);
var
  AnObj: IUnknown;
  ShLink: IShellLink;
  PFile: IPersistFile;
  WFileName: WideString;
  Reg: TRegIniFile;
begin
  AnObj := CreateComObject(CLSID_ShellLink);
  ShLink := AnObj as IShellLink;
  PFile := AnObj as IPersistFile;
  ShLink.SetPath(PWideChar(fileName));
  ShLink.SetWorkingDirectory(PWideChar(workDirectory));
  Reg := TRegIniFile.Create('Software\MicroSoft\Windows\CurrentVersion\Explorer');
  WFileName := Reg.ReadString('Shell Folders', 'Programs', '') + '\' + shortCutName + '.lnk';
  Reg.Free;
  PFile.Save(PWideChar(WFileName), False);
  InstallLog.Add(WFileName);
  DoStatus('create shortcut: %s', [WFileName]);
  AnObj := nil;
end;

procedure BuildShellLinkToStartup(const fileName, workDirectory, param, shortCutName: WideString);
var
  AnObj: IUnknown;
  ShLink: IShellLink;
  PFile: IPersistFile;
  WFileName: WideString;
  Reg: TRegIniFile;
begin
  AnObj := CreateComObject(CLSID_ShellLink);
  ShLink := AnObj as IShellLink;
  PFile := AnObj as IPersistFile;
  ShLink.SetPath(PWideChar(fileName));
  ShLink.SetWorkingDirectory(PWideChar(workDirectory));
  ShLink.SetArguments(PWideChar(param));
  Reg := TRegIniFile.Create('Software\MicroSoft\Windows\CurrentVersion\Explorer');
  WFileName := Reg.ReadString('Shell Folders', 'Startup', '') + '\' + shortCutName + '.lnk';
  Reg.Free;
  PFile.Save(PWideChar(WFileName), False);
  InstallLog.Add(WFileName);
  DoStatus('create shortcut: %s', [WFileName]);
  AnObj := nil;
end;

procedure ShellRun(ExeFile, param: U_String);
begin
  ShellExecute(0, 'Open',
    PWideChar(ExeFile.Text),
    PWideChar(param.Text),
    PWideChar(umlGetFilePath(ExeFile).Text),
    SW_SHOW);
end;

procedure TInstall2Form.TimerTimer(Sender: TObject);
begin
  CheckThreadSynchronize;
end;

procedure TInstall2Form.browseConfEditButtonClick(Sender: TObject);
begin
  OpenDialog.fileName := confEdit.Text;
  if not OpenDialog.Execute then
      exit;
  confEdit.Text := OpenDialog.fileName;
end;

procedure TInstall2Form.BrowseDirEditButtonClick(Sender: TObject);
var
  d: string;
begin
  d := DirectoryEdit.Text;
  if SelectDirectory('install directory', d, d) then
      DirectoryEdit.Text := d;
end;

procedure TInstall2Form.InstallButtonClick(Sender: TObject);
begin
  TCompute.RunP_NP(procedure
    var
      sourDir: U_String;
      destDir: U_String;
      te: THashTextEngine;
      confn: U_String;
      sl: TPascalStringList;
      i, j: Integer;
      Successed: Boolean;

      packageFile: U_String;
      packageOwnerDir: U_String;
      packagePassword: U_String;
      cipher: TZDB2_Cipher;
      dec: TZDB2_File_Decoder;
    begin
      TCompute.Sync(procedure
        begin
          destDir := DirectoryEdit.Text;
          confn := confEdit.Text;
        end);

      sourDir := umlGetFilePath(confn);
      if not umlFileExists(confn) then
        begin
          DoStatus('no exists zInstall2.conf', []);
          exit;
        end;

      te := THashTextEngine.Create;
      te.LoadFromFile(confn);

      sl := TPascalStringList.Create;
      te.GetSectionList(sl);

      Successed := True;
      for i := 0 to sl.Count - 1 do
        if not umlFileExists(umlCombineFileName(sourDir, sl[i])) then
          begin
            DoStatus('no exists package: %s', [sl[i].Text]);
            Successed := False;
          end;

      if Successed then
        begin
          umlCreateDirectory(destDir);
          TCompute.Sync(procedure
            begin
              confLayout.Enabled := False;
              destDirLayout.Enabled := False;
              btnLayout.Enabled := False;
              DoInstallBefore(destDir);
            end);
          InstallLog.Clear;
          for i := 0 to sl.Count - 1 do
            begin
              packageFile := umlCombineFileName(sourDir, sl[i]);
              packageOwnerDir := te.GetDefaultText(sl[i], 'Directory', umlChangeFileExt(sl[i], ''));
              packagePassword := te.GetDefaultText(sl[i], 'password', '');

              if packagePassword.L > 0 then
                  cipher := TZDB2_Cipher.Create(TCipherSecurity.csRijndael, packagePassword, 1, True, True)
              else
                  cipher := nil;

              if TZDB2_File_Decoder.CheckFile(cipher, packageFile) then
                begin
                  try
                    dec := TZDB2_File_Decoder.CreateFile(cipher, packageFile, CpuCount);
                    dec.OnProgress := ZDB2_File_OnProgress;
                    for j := 0 to dec.Files.Count - 1 do
                      begin
                        dec.DecodeToDirectory(dec.Files[j], umlCombinePath(destDir, packageOwnerDir));
                      end;
                    InstallLog.AddStrings(dec.FileLog);
                    disposeObject(dec);
                    ZDB2_File_OnProgress('done.', 100, 0, 0);
                  except
                  end;
                end
              else
                begin
                  DoStatus('password error %s', [umlGetFileName(packageFile).Text]);
                end;
            end;
          TCompute.Sync(procedure
            begin
              DoInstallAfter(destDir);
              confLayout.Enabled := True;
              destDirLayout.Enabled := True;
              btnLayout.Enabled := True;
            end);
          InstallLog.Add(umlCombineFileName(destDir, 'uninstall.conf'));
          InstallLog.SaveToFile(umlCombineFileName(destDir, 'uninstall.conf'));
        end;

      disposeObject(sl);
      disposeObject(te);
    end);
end;

procedure TInstall2Form.DoStatus_Backcall(Text_: SystemString; const ID: Integer);
begin
  Memo.Lines.Add(Text_);
  Memo.GoToTextEnd;
end;

procedure TInstall2Form.ZDB2_File_OnProgress(State_: SystemString; Total, Current1, Current2: Int64);
begin
  TCompute.Sync(procedure
    begin
      ProgressBar.Max := 100;
      ProgressBar.Value := umlPercentageToInt64(Total, Current1);
      StatusLabel.Text := State_;
    end);
end;

constructor TInstall2Form.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  StatusThreadID := False;
  AddDoStatusHook(self, DoStatus_Backcall);
  confEdit.Text := umlCombineFileName(TPath.GetLibraryPath, 'zInstall2.conf');
  confLayout.Visible := not umlFileExists(confEdit.Text);

  titleLabel.Text := C_Software + '...';
  DirectoryEdit.Text := C_DestDirectory;
  InstallLog := TPascalStringList.Create;
end;

destructor TInstall2Form.Destroy;
begin
  disposeObject(InstallLog);
  DeleteDoStatusHook(self);
  inherited Destroy;
end;

procedure TInstall2Form.DoInstallBefore(const DestDirectory: U_String);
begin

end;

procedure TInstall2Form.DoInstallAfter(const DestDirectory: U_String);
begin

end;

end.
