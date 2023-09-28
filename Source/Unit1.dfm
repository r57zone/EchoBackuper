object Main: TMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'EchoBackuper'
  ClientHeight = 366
  ClientWidth = 576
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  TextHeight = 13
  object CurOperationLbl: TLabel
    Left = 8
    Top = 303
    Width = 100
    Height = 13
    Caption = #1058#1077#1082#1091#1097#1072#1103' '#1086#1087#1077#1088#1072#1094#1080#1103':'
  end
  object AllOperationsLbl: TLabel
    Left = 8
    Top = 263
    Width = 72
    Height = 13
    Caption = #1042#1089#1077' '#1086#1087#1077#1088#1072#1094#1080#1080':'
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 347
    Width = 576
    Height = 19
    Panels = <>
    ParentShowHint = False
    ShowHint = True
    SimplePanel = True
    ExplicitTop = 346
    ExplicitWidth = 572
  end
  object RunBtn: TButton
    Left = 88
    Top = 233
    Width = 75
    Height = 25
    Caption = #1047#1072#1087#1091#1089#1090#1080#1090#1100
    TabOrder = 2
    OnClick = RunBtnClick
  end
  object ListView: TListView
    Left = 8
    Top = 8
    Width = 560
    Height = 217
    Checkboxes = True
    Columns = <
      item
        Caption = #1040#1082#1090#1080#1074#1085#1099#1081
        Width = 65
      end
      item
        Caption = #1048#1084#1103
        Width = 152
      end
      item
        Caption = #1051#1077#1074#1072#1103' '#1087#1072#1087#1082#1072
        Width = 161
      end
      item
        Caption = #1055#1088#1072#1074#1072#1103' '#1087#1072#1087#1082#1072
        Width = 161
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = ListViewDblClick
    OnKeyDown = ListViewKeyDown
    OnMouseDown = ListViewMouseDown
  end
  object ProgressBar: TProgressBar
    Left = 8
    Top = 280
    Width = 560
    Height = 17
    TabOrder = 5
  end
  object StopBtn: TButton
    Left = 169
    Top = 233
    Width = 75
    Height = 25
    Caption = #1054#1089#1090#1072#1085#1086#1074#1080#1090#1100
    Enabled = False
    TabOrder = 3
    OnClick = StopBtnClick
  end
  object OpenBtn2: TButton
    Left = 7
    Top = 233
    Width = 75
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100
    TabOrder = 1
    OnClick = OpenBtn2Click
  end
  object ProgressBar2: TProgressBar
    Left = 8
    Top = 320
    Width = 560
    Height = 17
    TabOrder = 6
  end
  object OpenDialog: TOpenDialog
    Filter = 'Backup paths|*.ebp'
    Left = 32
    Top = 40
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'Backup paths|*.ebp'
    Filter = 'Backup paths|*.ebp'
    Left = 104
    Top = 40
  end
  object ListViewPM: TPopupMenu
    Left = 176
    Top = 40
    object RemSelectionBtn: TMenuItem
      Caption = #1057#1085#1103#1090#1100' '#1074#1099#1076#1077#1083#1077#1085#1080#1077
      OnClick = RemSelectionBtnClick
    end
    object ChooseAllBtn: TMenuItem
      Caption = #1042#1099#1073#1088#1072#1090#1100' '#1074#1089#1077
      OnClick = ChooseAllBtnClick
    end
    object LineNoneBtn31: TMenuItem
      Caption = '-'
    end
    object OpenFolderBtn: TMenuItem
      Caption = #1054#1090#1082#1088#1099#1090#1100
      object LeftFolderBtn: TMenuItem
        Caption = #1051#1077#1074#1072#1103' '#1087#1072#1087#1082#1072
        OnClick = LeftFolderBtnClick
      end
      object RightFolderBtn: TMenuItem
        Caption = #1055#1088#1072#1074#1072#1103' '#1082#1085#1086#1087#1082#1072
        OnClick = RightFolderBtnClick
      end
    end
    object AddBtn2: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      OnClick = AddBtn2Click
    end
    object LineNoneBtn32: TMenuItem
      Caption = '-'
    end
    object MoveBtn: TMenuItem
      Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100
      object UpBtn: TMenuItem
        Caption = #1042#1099#1096#1077
        OnClick = UpBtnClick
      end
      object DownBtn: TMenuItem
        Caption = #1053#1080#1078#1077
        OnClick = DownBtnClick
      end
    end
    object LineNoneBtn33: TMenuItem
      Caption = '-'
    end
    object RemBtn2: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = RemBtn2Click
    end
  end
  object MainMenu: TMainMenu
    Left = 248
    Top = 40
    object FileBtn: TMenuItem
      Caption = #1060#1072#1081#1083
      object OpenBtn: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100
        ShortCut = 16463
        OnClick = OpenBtnClick
      end
      object CreateBtn: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100
        ShortCut = 16462
        OnClick = CreateBtnClick
      end
      object LineNoneBtn1: TMenuItem
        Caption = '-'
      end
      object SettingsBtn: TMenuItem
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
        OnClick = SettingsBtnClick
      end
      object LineNoneBtn2: TMenuItem
        Caption = '-'
      end
      object ExitBtn: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        ShortCut = 32883
        OnClick = ExitBtnClick
      end
    end
    object FoldersBtn: TMenuItem
      Caption = #1055#1072#1087#1082#1080
      object AddBtn: TMenuItem
        Caption = #1044#1086#1073#1072#1074#1080#1090#1100
        ShortCut = 16449
        OnClick = AddBtnClick
      end
      object LineNoneBtn3: TMenuItem
        Caption = '-'
      end
      object ExcludeBtn: TMenuItem
        Caption = #1048#1089#1082#1083#1102#1095#1080#1090#1100
        ShortCut = 16453
        OnClick = ExcludeBtnClick
      end
      object LineNone4: TMenuItem
        Caption = '-'
      end
      object RemBtn: TMenuItem
        Caption = #1059#1076#1072#1083#1080#1090#1100
        ShortCut = 16466
        OnClick = RemBtnClick
      end
    end
    object HelpBtn: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object AboutBtn: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077'...'
        OnClick = AboutBtnClick
      end
    end
  end
end
