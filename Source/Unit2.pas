unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus, ShlObj;

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
    EditBtn: TMenuItem;
    N1: TMenuItem;
    EditBtn2: TMenuItem;
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
    procedure EditBtnClick(Sender: TObject);
    procedure EditBtn2Click(Sender: TObject);
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
  ExcludePath:=Main.BrowseFolderDialog(PChar(IDS_SELECT_EXCLUDE_FOLDER), BIF_RETURNONLYFSDIRS or BIF_USENEWUI);
  if (ExcludePath <> '') and (Pos(ExcludePath + #13#10, ListBox.Items.Text) = 0) then
    ListBox.Items.Add(ExcludePath);
end;

procedure TExcludeFoldersForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TExcludeFoldersForm.EditBtn2Click(Sender: TObject);
begin
  EditBtn.Click;
end;

procedure TExcludeFoldersForm.EditBtnClick(Sender: TObject);
var
  ExcludePath: string;
begin
  if ListBox.ItemIndex = -1 then Exit;
  ExcludePath:=Main.BrowseFolderDialog(PChar(IDS_SELECT_EXCLUDE_FOLDER), BIF_RETURNONLYFSDIRS or BIF_USENEWUI);
  if (ExcludePath <> '') and (Pos(ExcludePath + #13#10, ListBox.Items.Text) = 0) then
    ListBox.Items.Strings[ListBox.ItemIndex]:=ExcludePath;
end;

procedure TExcludeFoldersForm.ExitBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TExcludeFoldersForm.FormCreate(Sender: TObject);
begin
  ListBox.Items.Text:=ExcludePaths.Text;
  Caption:=IDS_EXCLUDE_TITLE;
  FileBtn.Caption:=Main.FileBtn.Caption;
  ExitBtn.Caption:=Main.ExitBtn.Caption;
  FoldersBtn.Caption:=Main.FoldersBtn.Caption;
  AddBtn.Caption:=Main.AddBtn.Caption;
  AddBtn2.Caption:=AddBtn.Caption;
  EditBtn.Caption:=Main.EditBtn.Caption;
  EditBtn2.Caption:=EditBtn.Caption;
  RemBtn.Caption:=Main.RemBtn.Caption;
  RemBtn2.Caption:=RemBtn.Caption;
  OkBtn.Caption:=IDS_OK;
  CancelBtn.Caption:=IDS_CANCEL;
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
