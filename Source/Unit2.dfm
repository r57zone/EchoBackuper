object ExcludeFoldersForm: TExcludeFoldersForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = #1048#1089#1082#1083#1102#1095#1080#1090#1100' '#1087#1072#1087#1082#1080
  ClientHeight = 297
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ListBox: TListBox
    Left = 0
    Top = 0
    Width = 378
    Height = 256
    Align = alClient
    ItemHeight = 13
    TabOrder = 0
  end
  object Panel: TPanel
    Left = 0
    Top = 256
    Width = 378
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object AddBtn: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
      OnClick = AddBtnClick
    end
    object RemBtn: TButton
      Left = 168
      Top = 8
      Width = 75
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 2
      OnClick = RemBtnClick
    end
    object OKBtn: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1050
      TabOrder = 0
      OnClick = OKBtnClick
    end
    object CancelBtn: TButton
      Left = 248
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 3
      OnClick = CancelBtnClick
    end
  end
end
