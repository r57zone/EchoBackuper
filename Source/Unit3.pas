unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus;

type
  TLogsForm = class(TForm)
    LogsMemo: TMemo;
    MainMenu: TMainMenu;
    FileBtn: TMenuItem;
    SaveAsBtn: TMenuItem;
    N3: TMenuItem;
    ExitBtn: TMenuItem;
    SaveDialog: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure SaveAsBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LogsForm: TLogsForm;

implementation

{$R *.dfm}

uses Unit1;

procedure TLogsForm.ExitBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TLogsForm.FormCreate(Sender: TObject);
begin
  Caption:=Main.Caption;
  FileBtn.Caption:=Main.FileBtn.Caption;
  SaveAsBtn.Caption:=IDS_SAVE_AS;
  ExitBtn.Caption:=Main.ExitBtn.Caption;
  SaveDialog.Filter:=IDS_LOGS_FILE_DIALOG_FILTER;
  SaveDialog.DefaultExt:=SaveDialog.Filter;
end;

procedure SaveUTF8File(const FileName: string; Str: string);
var
  FS: TFileStream;
  UTF8Str: UTF8String;
begin
  UTF8Str:=UTF8Encode(Str);
  if FileExists(FileName) then DeleteFile(FileName);
  FS:=TFileStream.Create(FileName, fmCreate);
  try
    FS.WriteBuffer(PAnsiChar(UTF8Str)^, Length(UTF8Str));
  finally
    FS.Free;
  end;
end;

procedure TLogsForm.SaveAsBtnClick(Sender: TObject);
var
  AddPauseCommand: boolean;
begin
  AddPauseCommand:=false;
  if not SaveDialog.Execute then Exit;

  if SaveDialog.FilterIndex = 1 then begin
    LogsMemo.Lines.Insert(0, 'chcp 65001');
    case MessageBox(Handle, PChar(IDS_ADD_PAUSE_TO_FILE), PChar(Caption), 35) of
      6: begin AddPauseCommand:=true; LogsMemo.Lines.Add('pause'); end;
    end;
  end;

  //LogsMemo.Lines.SaveToFile(SaveDialog.FileName, TEncoding.UTF8); // BOM
  SaveUTF8File(SaveDialog.FileName, LogsMemo.Text); // Без BOM

  if AddPauseCommand then
    LogsMemo.Lines.Delete(LogsMemo.Lines.Count - 1);

  if SaveDialog.FilterIndex = 1 then
    LogsMemo.Lines.Delete(0);
end;

end.
