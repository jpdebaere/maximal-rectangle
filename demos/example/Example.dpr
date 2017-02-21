program Example;

uses
  Forms,
  Main in 'Main.pas' {frmMain},
  MaximalRectangle.Queue in '..\..\src\MaximalRectangle.Queue.pas',
  MaximalRectangle in '..\..\src\MaximalRectangle.pas',
  Utils in 'Utils.pas';

begin
  ReportMemoryLeaksOnShutdown := true;

  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
