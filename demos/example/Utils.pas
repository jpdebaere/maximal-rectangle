unit Utils;

{********************************************************************}
{ Utilities function for Windows                                     }
{                                                                    }
{ Written by                                                         }
{   Misel Krstovic                                                   }
{   copyright © 2007-2011, 2017                                      }
{                                                                    }
{ The source code is given as is. The author is not responsible      }
{ for any possible damage done due to the use of this code.          }
{ The class can be freely used in any application. The source        }
{ code remains property of the writer and may not be distributed     }
{ freely as such.                                                    }
{********************************************************************}

interface

Uses Windows, SysUtils;

function FixExclusivePixels(Rect: TRect): TRect;
function GetWorkAreaRect: TRect;
function GetWindowRect(WINFO: tagWINDOWINFO): TRect;
function IsWindow8: Boolean;
function IsWindowReallyVisible(Wnd: HWND): Boolean;

implementation

function IsWindowReallyVisible(Wnd: HWND): Boolean;
var
  IsVisible,
  IsOwned,
  IsAppWindow,
  IsAppFrameWindow: Boolean;
  Name: array[0..100] of WideChar;
begin
  result := false;

  // Code sample was based on an answer on stackoverflow by David Heffernan
  // added IsIconic() check, to ignore minimized windows
  IsVisible := IsWindowVisible(Wnd);
  if not IsVisible then exit;

  // Ignore owned windows
  IsOwned := GetWindow(Wnd, GW_OWNER)<>0;
  if IsOwned then exit;

  IsAppWindow := GetWindowLongPtr(Wnd, GWL_STYLE) and WS_EX_APPWINDOW<>0;
  if not IsAppWindow then exit;

  if IsIconic(Wnd) then exit;

  // Ignore cloaked windows
  if IsWindow8 then begin
    GetClassName(wnd, Addr(Name), 100);
    IsAppFrameWindow := Name = 'ApplicationFrameWindow';
    if IsAppFrameWindow then begin
      // We should check whether window is cloaked or not, but
      // that is outside the scope of this example
      exit;
    end;
  end;

  result := true;
end;

function IsWindow8: Boolean;
begin
  result := CheckWin32Version(6, 2); // 6.2 is Windows 8
end;

function FixExclusivePixels(Rect: TRect): TRect;
begin
  // We are not using the TRect(s) for painting therefore we shall remove extra
  // one pixel at the right and bottom edges.
  // https://msdn.microsoft.com/en-us/library/windows/desktop/dd162897(v=vs.85).aspx
  Rect.Right := Rect.Right - 1;
  Rect.Bottom := Rect.Bottom - 1;

  result := Rect;
end;

function GetWorkAreaRect: TRect;
begin
  // https://msdn.microsoft.com/en-us/library/windows/desktop/ms724947(v=vs.85).aspx
  SystemParametersInfo(
    SPI_GETWORKAREA, // Retrieves the size of the work area on the primary display monitor
    0,               // Not used
    @Result,
    0                // Not used
  );
end;

function GetWindowRect(WINFO: tagWINDOWINFO): TRect;
begin
  result := WINFO.rcWindow;

  // Remove window borders
  result.Left := result.Left + Integer(WINFO.cxWindowBorders);
  result.Top := result.Top + Integer(WINFO.cyWindowBorders);
  result.Right := result.Right - Integer(WINFO.cxWindowBorders);
  result.Bottom := result.Bottom - Integer(WINFO.cyWindowBorders);
end;

end.
