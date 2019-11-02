unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TExcludeFoldersForm = class(TForm)
    ListBox: TListBox;
    Panel: TPanel;
    AddBtn: TButton;
    RemBtn: TButton;
    OKBtn: TButton;
    CancelBtn: TButton;
    procedure AddBtnClick(Sender: TObject);
    procedure RemBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExcludeFoldersForm: TExcludeFoldersForm;

implementation

{$R *.dfm}

uses Unit1;

procedure TExcludeFoldersForm.AddBtnClick(Sender: TObject);
var
  ExcludePath: string;
begin
  ExcludePath:=Main.BrowseFolderDialog(PChar(ID_SELECT_EXCLUDE_FOLDER));
  if ExcludePath <> '' then
    ListBox.Items.Add(ExcludePath);
end;

procedure TExcludeFoldersForm.RemBtnClick(Sender: TObject);
begin
  if ListBox.ItemIndex <> -1 then
    ListBox.DeleteSelected;
end;

procedure TExcludeFoldersForm.OKBtnClick(Sender: TObject);
begin
  ExcludePaths.Text:=ListBox.Items.Text;
  Main.SaveBackupPaths;
  Close;
end;

procedure TExcludeFoldersForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TExcludeFoldersForm.FormCreate(Sender: TObject);
begin
  ListBox.Items.Text:=ExcludePaths.Text;
  Caption:=ID_EXCLUDE_TITLE;
  OkBtn.Caption:=ID_OK;
  AddBtn.Caption:=Main.AddBtn.Caption;
  RemBtn.Caption:=Main.RemBtn.Caption;
  CancelBtn.Caption:=ID_CANCEL;
end;

procedure TExcludeFoldersForm.ListBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then begin
    RemBtn.Click;
    Main.SaveBackupPaths;
  end;
end;

end.
