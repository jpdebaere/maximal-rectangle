unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Math, ComCtrls, ExtCtrls, MaximalRectangle, Utils;

type
  TfrmMain = class(TForm)
    tmrFinder: TTimer;
    lblHello: TLabel;
    procedure tmrFinderTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DoFindMaximalWhiteSpace;
  end;

var
  frmMain: TfrmMain;
  Maximal: TMaximalRectangle;
  SelfHandle: HWND;

function EnumWindowsProc(Wnd: HWnd; Param: lParam): boolean; stdcall;

implementation

{$R *.dfm}

{ TfrmMain }

function EnumWindowsProc(Wnd: HWnd; Param: lParam): boolean; stdcall;
var
  WINFO: tagWINDOWINFO;
  Name: PChar;
  Rect: TRect;
begin
  Result := True; // carry on enumerating

  if IsWindowReallyVisible(Wnd) then begin
    Name := StrAlloc(102);
    GetWindowText(Wnd, Name, 100);
    GetWindowInfo(Wnd, WINFO);
    Rect := GetWindowRect(WINFO);
    Rect := FixExclusivePixels(Rect);

    if Wnd <> SelfHandle then begin
      if Assigned(Maximal) then begin
        if Length(Name)>0 then Maximal.AddObstacle(Rect);
      end;
    end;
    StrDispose(Name);
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  SelfHandle := Self.Handle;
end;

procedure TfrmMain.tmrFinderTimer(Sender: TObject);
begin
  tmrFinder.Enabled := false;
  try
    DoFindMaximalWhiteSpace;
  finally
    tmrFinder.Enabled := true;
  end;
end;

procedure TfrmMain.DoFindMaximalWhiteSpace;
var
  BoundingRect : TRect;
  MaximalRect : TRect;
begin
  BoundingRect := FixExclusivePixels(GetWorkAreaRect);
  Maximal := TMaximalRectangle.Create(BoundingRect);
  try
    Maximal.ClearObstacles;

    // Enumerate application windows handles and get their TRects
    // Based on example to demonstrate the usage of EnumWindows
    // By Christoph Handel October 1998
    EnumWindows(@EnumWindowsProc, self.Handle);

    if Maximal.GetMaxWhitespace(MaximalRect) then begin
      Self.BoundsRect := MaximalRect;
    end;
  finally
    Maximal.Free;
  end;
end;

end.
