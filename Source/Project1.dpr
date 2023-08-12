program Project1;

{$R *.dres}

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Main},
  Unit2 in 'Unit2.pas' {ExcludeFoldersForm},
  Unit3 in 'Unit3.pas' {LogsForm},
  Unit4 in 'Unit4.pas' {Settings};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TExcludeFoldersForm, ExcludeFoldersForm);
  Application.CreateForm(TLogsForm, LogsForm);
  Application.CreateForm(TSettings, Settings);
  Application.Run;
end.
