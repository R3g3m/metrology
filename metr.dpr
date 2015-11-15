program metr;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  RegExpr in '..\RegEx\Source\RegExpr.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
