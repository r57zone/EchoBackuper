object ExcludeFoldersForm: TExcludeFoldersForm
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = #1048#1089#1082#1083#1102#1095#1077#1085#1080#1077' '#1087#1072#1087#1086#1082
  ClientHeight = 297
  ClientWidth = 378
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 13
  object ListBox: TListBox
    Left = 0
    Top = 0
    Width = 378
    Height = 256
    Align = alClient
    ItemHeight = 13
    TabOrder = 0
    OnKeyDown = ListBoxKeyDown
    OnMouseDown = ListBoxMouseDown
    ExplicitWidth = 374
    ExplicitHeight = 255
  end
  object Panel: TPanel
    Left = 0
    Top = 256
    Width = 378
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 255
    ExplicitWidth = 374
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
      Left = 89
      Top = 8
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 1
      OnClick = CancelBtnClick
    end
  end
  object PopupMenu: TPopupMenu
    Left = 104
    Top = 16
    object AddBtn2: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      OnClick = AddBtn2Click
    end
    object LineNoneBtn: TMenuItem
      Caption = '-'
    end
    object RemBtn2: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100
      OnClick = RemBtn2Click
    end
  end
  object MainMenu: TMainMenu
    Left = 32
    Top = 16
    object FileBtn: TMenuItem
      Caption = #1060#1072#1081#1083
      object ExitBtn: TMenuItem
        Caption = #1042#1099#1093#1086#1076
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
      object RemBtn: TMenuItem
        Caption = #1059#1076#1072#1083#1080#1090#1100
        ShortCut = 16466
        OnClick = RemBtnClick
      end
    end
  end
end
