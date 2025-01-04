object LogsForm: TLogsForm
  Left = 0
  Top = 0
  ClientHeight = 230
  ClientWidth = 400
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
  object LogsMemo: TMemo
    Left = 0
    Top = 0
    Width = 400
    Height = 230
    Align = alClient
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    ExplicitWidth = 396
    ExplicitHeight = 229
  end
  object MainMenu: TMainMenu
    Left = 24
    Top = 8
    object FileBtn: TMenuItem
      Caption = #1060#1072#1081#1083
      object SaveAsBtn: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082'...'
        ShortCut = 24659
        OnClick = SaveAsBtnClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object ExitBtn: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        ShortCut = 32883
        OnClick = ExitBtnClick
      end
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'Batch files (*.bat)|*.bat|Text files (*.txt)|*.txt'
    Filter = 'Batch files (*.bat)|*.bat|Text files (*.txt)|*.txt'
    Left = 92
    Top = 8
  end
end
