object Settings: TSettings
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
  ClientHeight = 165
  ClientWidth = 367
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object PanelBtns: TPanel
    Left = 0
    Top = 124
    Width = 367
    Height = 41
    Align = alBottom
    BevelOuter = bvSpace
    TabOrder = 4
    object OkBtn: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1050
      TabOrder = 0
      OnClick = OkBtnClick
    end
    object CancelBtn: TButton
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 1
      OnClick = CancelBtnClick
    end
  end
  object CheckLogCB: TCheckBox
    Left = 8
    Top = 8
    Width = 225
    Height = 17
    Caption = #1055#1088#1086#1089#1084#1086#1090#1088' '#1079#1072#1076#1072#1095' '#1087#1077#1088#1077#1076' '#1086#1087#1077#1088#1072#1094#1080#1103#1084#1080
    Checked = True
    State = cbChecked
    TabOrder = 0
  end
  object CheckSumVerificationCopyCB: TCheckBox
    Left = 8
    Top = 39
    Width = 313
    Height = 17
    Caption = #1055#1088#1086#1074#1077#1088#1082#1072' '#1082#1086#1085#1090#1088#1086#1083#1100#1085#1086#1081' '#1089#1091#1084#1084#1099' '#1087#1086#1089#1083#1077' '#1082#1086#1087#1080#1088#1086#1074#1072#1085#1080#1103
    TabOrder = 1
  end
  object CopyCreationDateCB: TCheckBox
    Left = 8
    Top = 70
    Width = 313
    Height = 17
    Caption = #1057#1086#1093#1088#1072#1085#1103#1090#1100' '#1076#1072#1090#1091' '#1089#1086#1079#1076#1072#1085#1080#1103' '#1092#1072#1081#1083#1086#1074' '#1087#1088#1080' '#1082#1086#1087#1080#1088#1086#1074#1072#1085#1080#1080
    TabOrder = 2
  end
  object CopyFileAttrCB: TCheckBox
    Left = 8
    Top = 101
    Width = 281
    Height = 17
    Caption = #1057#1086#1093#1088#1072#1085#1103#1090#1100' '#1072#1090#1088#1080#1073#1091#1090#1099' '#1092#1072#1081#1083#1086#1074' '#1087#1088#1080' '#1082#1086#1087#1080#1088#1086#1074#1072#1085#1080#1080
    TabOrder = 3
  end
end
