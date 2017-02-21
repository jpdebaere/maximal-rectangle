object frmMain: TfrmMain
  Left = 202
  Top = 115
  AlphaBlendValue = 128
  ClientHeight = 293
  ClientWidth = 289
  Color = clWindow
  ParentFont = True
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblHello: TLabel
    Left = 0
    Top = 0
    Width = 289
    Height = 293
    Align = alClient
    Alignment = taCenter
    AutoSize = False
    Caption = 'Hello'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -64
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Layout = tlCenter
    ExplicitWidth = 142
    ExplicitHeight = 77
  end
  object tmrFinder: TTimer
    Interval = 2500
    OnTimer = tmrFinderTimer
    Left = 16
    Top = 16
  end
end
