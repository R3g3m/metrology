object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = #1052#1077#1090#1088#1080#1082#1072' '#1061#1086#1083#1089#1090#1077#1076#1072', Java'
  ClientHeight = 453
  ClientWidth = 568
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblOperatorDict: TLabel
    Left = 8
    Top = 317
    Width = 106
    Height = 13
    Caption = #1057#1083#1086#1074#1072#1088#1100' '#1086#1087#1077#1088#1072#1090#1086#1088#1086#1074
    Visible = False
  end
  object lblOperandDict: TLabel
    Left = 303
    Top = 317
    Width = 101
    Height = 13
    Caption = #1057#1083#1086#1074#1072#1088#1100' '#1086#1087#1077#1088#1072#1085#1076#1086#1074
    Visible = False
  end
  object btnOpenFile: TButton
    Left = 8
    Top = 14
    Width = 153
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100' '#1092#1072#1081#1083' '#1089' '#1082#1086#1076#1086#1084
    TabOrder = 0
    OnClick = btnOpenFileClick
  end
  object btnStart: TButton
    Left = 8
    Top = 271
    Width = 153
    Height = 25
    Caption = #1055#1088#1086#1080#1079#1074#1077#1089#1090#1080' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
    Enabled = False
    TabOrder = 1
    OnClick = btnStartClick
  end
  object memSource: TMemo
    Left = 8
    Top = 45
    Width = 281
    Height = 220
    TabOrder = 2
    OnChange = memSourceChange
  end
  object memResult: TMemo
    Left = 303
    Top = 45
    Width = 249
    Height = 220
    Lines.Strings = (
      '')
    TabOrder = 3
  end
  object memOperators: TMemo
    Left = 8
    Top = 336
    Width = 249
    Height = 105
    TabOrder = 4
    Visible = False
  end
  object memOperands: TMemo
    Left = 303
    Top = 336
    Width = 249
    Height = 105
    TabOrder = 5
    Visible = False
  end
  object dlOpenFile: TOpenDialog
    DefaultExt = '*.java'
    Filter = #1060#1072#1081#1083' java|*.java'
    Left = 216
  end
end
