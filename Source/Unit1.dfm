object Main: TMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'EchoBackaper'
  ClientHeight = 332
  ClientWidth = 537
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 313
    Width = 537
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object RunBtn: TButton
    Left = 8
    Top = 232
    Width = 75
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100
    TabOrder = 1
    OnClick = RunBtnClick
  end
  object ListView: TListView
    Left = 8
    Top = 8
    Width = 521
    Height = 217
    Checkboxes = True
    Columns = <
      item
        Caption = #1040#1082#1090#1080#1074#1085#1099#1081
        Width = 65
      end
      item
        AutoSize = True
        Caption = #1048#1084#1103
      end
      item
        AutoSize = True
        Caption = #1051#1077#1074#1072#1103' '#1087#1072#1087#1082#1072
      end
      item
        AutoSize = True
        Caption = #1055#1088#1072#1074#1072#1103' '#1087#1072#1087#1082#1072
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = ListViewDblClick
  end
  object AddBtn: TButton
    Left = 88
    Top = 232
    Width = 75
    Height = 25
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 2
    OnClick = AddBtnClick
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 288
    Width = 521
    Height = 17
    TabOrder = 9
  end
  object RemBtn: TButton
    Left = 167
    Top = 231
    Width = 75
    Height = 25
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 3
    OnClick = RemBtnClick
  end
  object AboutBtn: TButton
    Left = 504
    Top = 232
    Width = 27
    Height = 25
    Caption = '?'
    TabOrder = 7
    OnClick = AboutBtnClick
  end
  object CBCheckLog: TCheckBox
    Left = 8
    Top = 264
    Width = 209
    Height = 17
    Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1079#1072#1076#1072#1095' '#1087#1077#1088#1077#1076' '#1086#1087#1077#1088#1072#1094#1080#1103#1084#1080
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = CBCheckLogClick
  end
  object ExcludeBtn: TButton
    Left = 248
    Top = 231
    Width = 75
    Height = 25
    Caption = #1048#1089#1082#1083#1102#1095#1080#1090#1100
    TabOrder = 4
    OnClick = ExcludeBtnClick
  end
  object StopBtn: TButton
    Left = 328
    Top = 232
    Width = 75
    Height = 25
    Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100
    Enabled = False
    TabOrder = 5
    OnClick = StopBtnClick
  end
end
