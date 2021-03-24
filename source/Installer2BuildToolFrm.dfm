object Installer2BuildToolForm: TInstaller2BuildToolForm
  Left = 0
  Top = 0
  AutoSize = True
  BorderStyle = bsDialog
  BorderWidth = 30
  Caption = 'Installer2.0 Build Tool.'
  ClientHeight = 289
  ClientWidth = 689
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object InfoLabel: TLabel
    Left = 164
    Top = 74
    Width = 517
    Height = 25
    AutoSize = False
    Caption = '...'
    Layout = tlBottom
    WordWrap = True
  end
  object DirectoryEdit: TLabeledEdit
    Left = 0
    Top = 16
    Width = 625
    Height = 21
    EditLabel.Width = 48
    EditLabel.Height = 13
    EditLabel.Caption = 'Directory:'
    TabOrder = 0
  end
  object DirBrowseButton: TButton
    Left = 631
    Top = 14
    Width = 26
    Height = 25
    Caption = '..'
    TabOrder = 1
    OnClick = DirBrowseButtonClick
  end
  object buildButton: TButton
    Left = 0
    Top = 43
    Width = 75
    Height = 25
    Caption = 'Build.'
    TabOrder = 2
    OnClick = buildButtonClick
  end
  object ThNumEdit: TLabeledEdit
    Left = 125
    Top = 47
    Width = 33
    Height = 21
    EditLabel.Width = 38
    EditLabel.Height = 13
    EditLabel.Caption = 'Thread:'
    LabelPosition = lpLeft
    TabOrder = 3
  end
  object ChunkEdit: TLabeledEdit
    Left = 204
    Top = 47
    Width = 98
    Height = 21
    EditLabel.Width = 34
    EditLabel.Height = 13
    EditLabel.Caption = 'Chunk:'
    LabelPosition = lpLeft
    TabOrder = 4
  end
  object BlockEdit: TLabeledEdit
    Left = 349
    Top = 47
    Width = 81
    Height = 21
    EditLabel.Width = 28
    EditLabel.Height = 13
    EditLabel.Caption = 'Block:'
    LabelPosition = lpLeft
    TabOrder = 5
  end
  object Memo: TMemo
    Left = 0
    Top = 105
    Width = 689
    Height = 184
    ScrollBars = ssVertical
    TabOrder = 7
    WordWrap = False
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 82
    Width = 150
    Height = 17
    TabOrder = 6
  end
  object CheckBox_Encrypt: TCheckBox
    Left = 436
    Top = 51
    Width = 64
    Height = 17
    Caption = 'Encrypt'
    TabOrder = 8
  end
  object Timer: TTimer
    Interval = 500
    OnTimer = TimerTimer
    Left = 325
    Top = 45
  end
end
