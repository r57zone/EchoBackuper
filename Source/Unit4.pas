unit Unit4;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, IniFiles;

type
  TSettings = class(TForm)
    PanelBtns: TPanel;
    CheckLogCB: TCheckBox;
    OkBtn: TButton;
    CancelBtn: TButton;
    CheckSumVerificationCopyCB: TCheckBox;
    CopyCreationDateCB: TCheckBox;
    CopyFileAttrCB: TCheckBox;
    procedure OkBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Settings: TSettings;

implementation

{$R *.dfm}

uses Unit1;

procedure TSettings.OkBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  CheckLogShow:=CheckLogCB.Checked;
  CRCCopyCheck:=CheckSumVerificationCopyCB.Checked;
  WriteCreationDate:=CopyCreationDateCB.Checked;
  WriteAttributes:=CopyFileAttrCB.Checked;

  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  Ini.WriteBool('Main', 'LookTasks', CheckLogShow);
  Ini.WriteBool('Main', 'CRCCopyCheck', CRCCopyCheck);
  Ini.WriteBool('Main', 'WriteCreationDate', WriteCreationDate);
  Ini.WriteBool('Main', 'WriteAttributes', WriteAttributes);

  Ini.Free;

  Close;
end;

procedure TSettings.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TSettings.FormCreate(Sender: TObject);
begin
  Caption:=Main.SettingsBtn.Caption;
  CheckLogCB.Caption:=IDS_VIEW_TASKS;
  OkBtn.Caption:=IDS_OK;
  CancelBtn.Caption:=IDS_CANCEL;

  CheckSumVerificationCopyCB.Caption:=IDS_CHECKSUM_VERIFICATION_COPY;
  CopyCreationDateCB.Caption:=IDS_COPY_CREATION_DATE;
  CopyFileAttrCB.Caption:=IDS_COPY_FILE_ATTRIBUTES;
end;

procedure TSettings.FormShow(Sender: TObject);
begin
  CheckLogCB.Checked:=CheckLogShow;
  CheckSumVerificationCopyCB.Checked:=CRCCopyCheck;
  CopyCreationDateCB.Checked:=WriteCreationDate;
  CopyFileAttrCB.Checked:=WriteAttributes;
end;

end.
