unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus;

type
  TExcludeFoldersForm = class(TForm)
    ListBox: TListBox;
    Panel: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    PopupMenu: TPopupMenu;
    AddBtn2: TMenuItem;
    RemBtn2: TMenuItem;
    LineNoneBtn: TMenuItem;
    MainMenu: TMainMenu;
    FileBtn: TMenuItem;
    ExitBtn: TMenuItem;
    FoldersBtn: TMenuItem;
    AddBtn: TMenuItem;
    RemBtn: TMenuItem;
    procedure AddBtn2Click(Sender: TObject);
    procedure RemBtn2Click(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ListBoxKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ListBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure AddBtnClick(Sender: TObject);
    procedure RemBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
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

procedure TExcludeFoldersForm.AddBtn2Click(Sender: TObject);
begin
  AddBtn.Click;
end;

procedure TExcludeFoldersForm.RemBtn2Click(Sender: TObject);
begin
  RemBtn.Click;
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

procedure TExcludeFoldersForm.AddBtnClick(Sender: TObject);
var
  ExcludePath: string;
begin
  ExcludePath:=Main.BrowseFolderDialog(PChar(ID_SELECT_EXCLUDE_FOLDER));
  if ExcludePath <> '' then
    ListBox.Items.Add(ExcludePath);
end;

procedure TExcludeFoldersForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TExcludeFoldersForm.ExitBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TExcludeFoldersForm.FormCreate(Sender: TObject);
begin
  ListBox.Items.Text:=ExcludePaths.Text;
  Caption:=ID_EXCLUDE_TITLE;
  FileBtn.Caption:=Main.FileBtn.Caption;
  ExitBtn.Caption:=Main.ExitBtn.Caption;
  FoldersBtn.Caption:=Main.FoldersBtn.Caption;
  AddBtn.Caption:=Main.AddBtn.Caption;
  AddBtn2.Caption:=AddBtn.Caption;
  RemBtn.Caption:=Main.RemBtn.Caption;
  RemBtn2.Caption:=RemBtn.Caption;
  OkBtn.Caption:=ID_OK;
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

procedure TExcludeFoldersForm.ListBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    PopupMenu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

end.
