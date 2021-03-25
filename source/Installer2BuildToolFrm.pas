unit Installer2BuildToolFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls,

  Vcl.FileCtrl, System.IOUtils,

{$IFDEF FPC}
  FPCGenericStructlist,
{$ENDIF FPC}
  CoreClasses, PascalStrings, UnicodeMixedLib, DoStatusIO, MemoryStream64,
  ZDB2_FileEncoder, ZDB2_Core, CoreCipher, zExpression, ListEngine, TextDataEngine;

type
  TInstaller2BuildToolForm = class(TForm)
    DirectoryEdit: TLabeledEdit;
    DirBrowseButton: TButton;
    buildButton: TButton;
    ThNumEdit: TLabeledEdit;
    ChunkEdit: TLabeledEdit;
    BlockEdit: TLabeledEdit;
    InfoLabel: TLabel;
    Memo: TMemo;
    Timer: TTimer;
    ProgressBar: TProgressBar;
    CheckBox_Encrypt: TCheckBox;
    SoftEdit: TLabeledEdit;
    procedure TimerTimer(Sender: TObject);
    procedure DirBrowseButtonClick(Sender: TObject);
    procedure buildButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    Busy: Boolean;
    procedure DoStatus_Backcall(Text_: SystemString; const ID: Integer);
    procedure ZDB2_File_OnProgress(State_: SystemString; Total, Current1, Current2: Int64);
    function EncodeDirectory(Directory_, ZDB2File_, Password_: U_String; ThNum_: Integer; chunkSize_: Int64; CM: TSelectCompressionMethod; BlockSize_: Word): Int64;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Installer2BuildToolForm: TInstaller2BuildToolForm;

implementation

{$R *.dfm}


procedure TInstaller2BuildToolForm.TimerTimer(Sender: TObject);
begin
  CheckThreadSynchronize;
end;

procedure TInstaller2BuildToolForm.DirBrowseButtonClick(Sender: TObject);
var
  dir_: String;
begin
  dir_ := DirectoryEdit.Text;
  if SelectDirectory('select source directory.', '/', dir_, [sdNewFolder, sdShowShares, sdNewUI]) then
    begin
      DirectoryEdit.Text := dir_;
      if SoftEdit.Text = '' then
          SoftEdit.Text := umlGetLastStr(DirectoryEdit.Text, '/\');
    end;
end;

procedure TInstaller2BuildToolForm.buildButtonClick(Sender: TObject);
begin
  if not umlDirectoryExists(DirectoryEdit.Text) then
      exit;
  Busy := True;
  TCompute.RunP_NP(procedure
    var
      dir_: U_String;
      software_: U_String;
      nArry: U_StringArray;
      n: U_SystemString;
      dirName: U_String;
      zdb2fn: U_String;
      passwd: U_String;
      te: THashTextEngine;
      sour: Int64;
    begin
      TCompute.Sync(procedure
        begin
          DirectoryEdit.Enabled := False;
          DirBrowseButton.Enabled := False;
          buildButton.Enabled := False;
          SoftEdit.Enabled := False;
          ThNumEdit.Enabled := False;
          ChunkEdit.Enabled := False;
          BlockEdit.Enabled := False;
          CheckBox_Encrypt.Enabled := False;
          dir_ := DirectoryEdit.Text;
          software_ := SoftEdit.Text;
        end);

      if software_.L = 0 then
          software_ := umlGetLastStr(dir_, '/\');

      te := THashTextEngine.Create;
      te.SetDefaultText('Main___', 'Software', software_);

      nArry := umlGetDirListWithFullPath(dir_);
      for n in nArry do
        begin
          if CheckBox_Encrypt.Checked then
            begin
              passwd := TPascalString.RandomString(64).DeleteChar(#32'=:[]');
            end
          else
              passwd := '';

          dirName := umlGetLastStr(n, '/\');

          if CheckBox_Encrypt.Checked then
              zdb2fn := dirName + '.POX2'
          else
              zdb2fn := dirName + '.OX2';

          sour := EncodeDirectory(
            n,
            umlCombineFileName(dir_, zdb2fn),
            passwd,
            EStrToInt(ThNumEdit.Text, cpuCount),
            EStrToInt(ChunkEdit.Text, 1024 * 1024),
            TSelectCompressionMethod.scmZLIB,
            EStrToInt(BlockEdit.Text, 4096));

          DoStatus('finish %s %s -> %s',
            [zdb2fn.Text, umlSizetoStr(sour).Text, umlSizetoStr(umlGetFileSize(umlCombineFileName(dir_, zdb2fn))).Text]);

          if CheckBox_Encrypt.Checked then
              te.SetDefaultText(zdb2fn, 'password', passwd);
          te.SetDefaultText(zdb2fn, 'Directory', dirName);
        end;

      te.SaveToFile(umlCombineFileName(dir_, 'zInstall2.conf'));
      disposeObject(te);

      ZDB2_File_OnProgress('...', 100, 0, 0);
      DoStatus('all finish.');

      TCompute.Sync(procedure
        begin
          DirectoryEdit.Enabled := True;
          DirBrowseButton.Enabled := True;
          buildButton.Enabled := True;
          SoftEdit.Enabled := True;
          ThNumEdit.Enabled := True;
          ChunkEdit.Enabled := True;
          BlockEdit.Enabled := True;
          CheckBox_Encrypt.Enabled := True;
        end);
      Busy := False;
    end);
end;

procedure TInstaller2BuildToolForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TInstaller2BuildToolForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Busy;
end;

procedure TInstaller2BuildToolForm.DoStatus_Backcall(Text_: SystemString; const ID: Integer);
begin
  Memo.Lines.Add(Text_);
end;

function TInstaller2BuildToolForm.EncodeDirectory(Directory_, ZDB2File_, Password_: U_String; ThNum_: Integer; chunkSize_: Int64; CM: TSelectCompressionMethod; BlockSize_: Word): Int64;
var
  cipher: TZDB2_Cipher;
  enc: TZDB2_File_Encoder;
begin
  if CheckBox_Encrypt.Checked then
      cipher := TZDB2_Cipher.Create(TCipherSecurity.csRijndael, Password_, 1, True, True)
  else
      cipher := nil;
  enc := TZDB2_File_Encoder.CreateFile(cipher, ZDB2File_, ThNum_);
  enc.OnProgress := ZDB2_File_OnProgress;
  enc.EncodeFromDirectory(Directory_, True, '\', chunkSize_, CM, BlockSize_);
  Result := enc.Flush;
  disposeObject(enc);
  if CheckBox_Encrypt.Checked then
      disposeObject(cipher);
end;

procedure TInstaller2BuildToolForm.ZDB2_File_OnProgress(State_: SystemString; Total, Current1, Current2: Int64);
begin
  TCompute.Sync(procedure
    begin
      ProgressBar.Max := 100;
      ProgressBar.Position := umlPercentageToInt64(Total, Current1);
      InfoLabel.Caption := State_;
    end);
end;

constructor TInstaller2BuildToolForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AddDoStatusHook(self, DoStatus_Backcall);
  StatusThreadID := False;
  ThNumEdit.Text := IntToStr(cpuCount);
  ChunkEdit.Text := '1024*1024';
  BlockEdit.Text := '4*1024';
  Busy := False;
end;

destructor TInstaller2BuildToolForm.Destroy;
begin
  DeleteDoStatusHook(self);
  inherited Destroy;
end;

end.
