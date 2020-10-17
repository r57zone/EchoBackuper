unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, ShlObj, Registry,
  IniFiles;

type
  TMain = class(TForm)
    StatusBar: TStatusBar;
    RunBtn: TButton;
    ListView: TListView;
    AddBtn: TButton;
    ProgressBar: TProgressBar;
    RemBtn: TButton;
    AboutBtn: TButton;
    CBCheckLog: TCheckBox;
    ExcludeBtn: TButton;
    StopBtn: TButton;
    OpenBtn: TButton;
    OpenDialog: TOpenDialog;
    CreateBtn: TButton;
    SaveDialog: TSaveDialog;
    procedure FormCreate(Sender: TObject);
    procedure RunBtnClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure RemBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListViewDblClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure CBCheckLogClick(Sender: TObject);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OpenBtnClick(Sender: TObject);
    procedure CreateBtnClick(Sender: TObject);
    procedure CheckRemoteFilesToMove;
  private
    procedure LoadBackupPaths(FileName: string);
    { Private declarations }
  public
    procedure SaveBackupPaths;
    function BrowseFolderDialog(Title: PChar): string;
    { Public declarations }
  end;

var
  Main: TMain;
  Actions, ExcludePaths, ExcludeRenameFiles: TStringList;
  CurrentBackupFilePath: string; //Текущий файл путей для резервной копии

  FilesCounter, ActionGoodCounter, GoodCopyFilesCounter, GoodMoveFilesCounter, GoodRenameFilesCounter, GoodDeleteFilesCounter,
  GoodMakeFoldersCounter, GoodRemoveFoldersCounter, BadCopyFilesCounter, BadMoveFilesCounter, BadRenameFilesCounter,
  BadDeleteFilesCounter, BadMakeFoldersCounter, BadRemoveFoldersCounter: integer;

  StopRequest: boolean;
  SilentMode: boolean;
  NotificationApp: string;

  ID_LOOKING_CHANGES, ID_FILE_RENAMED, ID_FOUND_NEW_FILE, ID_FILE_UPDATED, ID_FOUND_OLD_FILE,
  ID_COPY_FILE, ID_MOVE_FILE, ID_RENAME_FILE, ID_REMOVE_FILE, ID_CREATE_FOLDER, ID_REMOVE_FOLDER, ID_CHECK_MOVE_FILES: string;
  ID_COMPLETED, ID_COMPLETED_ERROR, ID_BACKUP_COMPLETED, ID_BACKUP_FAILED, ID_CHECK_FILES, ID_TOTAL_OPERATIONS,
  ID_SUCCESS_COPY_FILES, ID_SUCCESS_MOVE_FILES, ID_SUCCESS_RENAME_FILES, ID_SUCCESS_REMOVE_FILES,
  ID_SUCCESS_CREATE_FOLDERS, ID_SUCCESS_REMOVE_FOLDERS, ID_FAIL_COPY_FILES, ID_FAIL_MOVE_FILES, ID_FAIL_RENAME_FILES,
  ID_FAIL_REMOVE_FILES, ID_FAIL_CREATE_FOLDERS, ID_FAIL_REMOVE_FOLDERS: string;
  ID_PERFORM_OPERATIONS, ID_ENTER_NAME_PARE_FOLDERS, ID_CHOOSE_LEFT_FOLDER,
  ID_CHOOSE_RIGHT_FOLDER, ID_CHOOSE_FOLDER_ERROR, ID_SUCCESS_NOTIFICATION_MESSAGE,
  ID_FAIL_NOTIFICATION_MESSAGE: string;
  ID_ABOUT_TITLE, ID_LAST_UPDATE: string;
  ID_EXCLUDE_TITLE, ID_SELECT_EXCLUDE_FOLDER, ID_OK, ID_CANCEL: string;

const
  //Название файла путей для резеревной копии по умолчанию
  BACKUP_PATHS_FILE_NAME = 'BackupPaths.ebp';
  //Зарезервированные фразы для файла
  PAIR_FOLDERS_FILE = 'PAIR FOLDERS:';
  EXCLUDE_PATHS_FILE = 'EXCLUDE PATHS:';

implementation

{$R *.dfm}

uses Unit2, Unit3;

{ TMain }

function CutStr(Str: string; CharCount: integer): string;
begin
  if Length(Str) > CharCount then
    Result:=Copy(Str, 1, CharCount - 3) + '...'
  else
    Result:=Str;
end;

procedure StatusText(Str: string);
begin
  Main.StatusBar.SimpleText:=' ' + CutStr(Str, 70);
end;

procedure CheckFilesDiff(LocalFolder, RemoteFolder: string);
var
  LocalFile, RemoteFile: TSearchRec;
  i: integer;
  FoundCurrentFile: boolean;
begin
  if StopRequest then Exit;

  //Игнорируемые папки
  for i:=0 to ExcludePaths.Count - 1 do
    if ExcludePaths.Strings[i] = LocalFolder then Exit;

  if LocalFolder[Length(LocalFolder)] <> '\' then
    LocalFolder:=LocalFolder + '\';
  if RemoteFolder[Length(RemoteFolder)] <> '\' then
    RemoteFolder:=RemoteFolder + '\';

  StatusText(ID_LOOKING_CHANGES + ' ' + LocalFolder);

  if FindFirst(LocalFolder + '*.*', faAnyFile, LocalFile) = 0 then
  repeat
    Application.ProcessMessages;

    if (LocalFile.Name = '.') or (LocalFile.Name = '..') then Continue;   //Не обрабатываем возвраты папок

    //Проверка файлов
    if (LocalFile.Attr and faDirectory) <> faDirectory then begin

      Inc(FilesCounter);

      //Если файл отсуствует, то копируем, а если во вторичной папке есть этот файл, то переименовываем
      if not FileExists(RemoteFolder + LocalFile.Name) then begin

        //Проверяем все файлы во вторичной папке, на случай если файл переименовали
        FoundCurrentFile:=false;
        if FindFirst(RemoteFolder + '*.*', faAnyFile, RemoteFile) = 0 then
        repeat
          Application.ProcessMessages;

          //Если время файла, размер совпадает и такого файла нет в первичной папке, то переименовываем файл во вторичной папке
          //Файл переименован
          if (LocalFile.Time = RemoteFile.Time) and (LocalFile.Size = RemoteFile.Size) and (FileExists(LocalFolder + RemoteFile.Name) = false) then begin
            Actions.Add('RENAME ' + RemoteFolder + RemoteFile.Name + #9 + RemoteFolder + LocalFile.Name);
            //Добавляем в список игнориемых файлов, чтобы он не удалился (до переименования)
            ExcludeRenameFiles.Add(RemoteFolder + RemoteFile.Name);
            StatusText(ID_FILE_RENAMED + ' ' + LocalFolder + LocalFile.Name);
            FoundCurrentFile:=true;
            Break;
          end;

        until FindNext(RemoteFile) <> 0;
        FindClose(RemoteFile);

        //Если во вторичной папке схожих файлов не найдено, то просто копируем новый файл
        //Найден новый файл
        if FoundCurrentFile = false then begin
          Actions.Add('COPY ' + LocalFolder + LocalFile.Name + #9 + RemoteFolder + LocalFile.Name);
          StatusText(ID_FOUND_NEW_FILE + ' ' + LocalFolder + LocalFile.Name);
        end;

      //Если файл есть
      end else if FindFirst(RemoteFolder + LocalFile.Name, faAnyFile, RemoteFile) = 0 then begin

          //Если время файла или размер не совпадает, то копируем
          //Файл обновлён
          if (LocalFile.Time <> RemoteFile.Time) or (LocalFile.Size <> RemoteFile.Size) then begin
            Actions.Add('COPY ' + LocalFolder + LocalFile.Name + #9 + RemoteFolder + LocalFile.Name);
            StatusText(ID_FILE_UPDATED + ' ' + LocalFolder + LocalFile.Name);
          end;

          FindClose(RemoteFile);
      end;

    //Проверка папок
    end else begin
      //Создаём папку если её не существует и её нет в списке игнорируемых
      if (not DirectoryExists(RemoteFolder + LocalFile.Name)) and (Pos(LocalFolder + LocalFile.Name, ExcludePaths.Text) = 0) then
        Actions.Add('MKDIR ' + RemoteFolder + LocalFile.Name);

      //Сравниваем файлы
      CheckFilesDiff(LocalFolder + LocalFile.Name, RemoteFolder + LocalFile.Name);
    end;

  until FindNext(LocalFile) <> 0;
  FindClose(LocalFile);
end;

procedure CheckRemoteFilesToRemove(LocalFolder, RemoteFolder: string);
var
  LocalFile, RemoteFile: TSearchRec;
  i: integer;
begin
  if StopRequest then Exit;

  //Игнорируемые папки
  for i:=0 to ExcludePaths.Count - 1 do
    if ExcludePaths.Strings[i] = LocalFolder then Exit;

  if LocalFolder[Length(LocalFolder)] <> '\' then
    LocalFolder:=LocalFolder + '\';
  if RemoteFolder[Length(RemoteFolder)] <> '\' then
    RemoteFolder:=RemoteFolder + '\';

  if FindFirst(RemoteFolder + '*.*', faAnyFile, RemoteFile) = 0 then
  repeat
    Application.ProcessMessages;
    if (RemoteFile.Name <> '.') and (RemoteFile.Name <> '..') then
      if (RemoteFile.Attr and faDirectory) <> faDirectory then begin

        //Проверяем наличие файлов и исключаем файлы для переименования
        //Найден старый файл
        if (FileExists(LocalFolder + RemoteFile.Name) = false) and (Pos(RemoteFolder + RemoteFile.Name, ExcludeRenameFiles.Text) = 0) then begin
          Actions.Add('DELETE ' + RemoteFolder + RemoteFile.Name);
          StatusText(ID_FOUND_OLD_FILE + ' ' + RemoteFolder + RemoteFile.Name);
        end;

      end else begin
        CheckRemoteFilesToRemove(LocalFolder + RemoteFile.Name, RemoteFolder + RemoteFile.Name);

        //После проверки файлов проверяем наличие папки
        if not DirectoryExists(LocalFolder + RemoteFile.Name) then
          Actions.Add('RMDIR ' + RemoteFolder + RemoteFile.Name);
      end;
    until FindNext(RemoteFile) <> 0;

  FindClose(RemoteFile);
end;

//Сравнение двух файлов на соотвествие, по дате и размеру
function CompareFileIdentity(FirstFilePath, SecondFilePath: string): boolean;
var
  FirstFile, SecondFile: TSearchRec;
begin
  Result:=false;
  if FindFirst(FirstFilePath, faAnyFile, FirstFile) = 0 then begin

    if FindFirst(SecondFilePath, faAnyFile, SecondFile) = 0 then begin

      if (FirstFile.Time = SecondFile.Time) and (FirstFile.Size = SecondFile.Size) then
        Result:=true;

      FindClose(SecondFile);
    end;

    FindClose(FirstFile);
  end;
end;

procedure TMain.CheckRemoteFilesToMove; //Если файл был перемещён в другую папку, то перемещаем файл, а не удаляем и копируем снова
var
	i, j: integer;
  ActionStr, DeleteFilePath, FirstCopyFilePath, SecondCopyFilePath: string;
begin
  if Actions.Count = 0 then Exit;
  StatusText(ID_CHECK_MOVE_FILES);

  for i:=0 to Actions.Count -1 do
		if Copy(Actions.Strings[i], 1, 7) = 'DELETE ' then begin
      ActionStr:=Actions.Strings[i];
		  Delete(ActionStr, 1, 7);
      DeleteFilePath:=ActionStr;

			for j:=0 to Actions.Count - 1 do begin
				if i = j then Continue; //Пропускаем DELETE

        //Ищем копируемые файлы
        if Copy(Actions.Strings[j], 1, 5) = 'COPY ' then begin
          ActionStr:=Actions.Strings[j];
          Delete(ActionStr, 1, 5);

          FirstCopyFilePath:=Copy(ActionStr, 1, Pos(#9, ActionStr) - 1);
          SecondCopyFilePath:=Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr));

          //Проверка на соответствие файлов
          if CompareFileIdentity(DeleteFilePath, FirstCopyFilePath) then begin
            Actions.Strings[j]:='MOVE ' + DeleteFilePath + #9 + SecondCopyFilePath;
            Actions.Strings[i]:='FIXED';
            Break;
          end;
        end;

			end;
		end;

  //Убираем исправленные действия
  Actions.Text:=StringReplace(Actions.Text, 'FIXED' + #13#10, '', [rfReplaceAll]);
end;

procedure ActionsRun;
var
  i: integer; ActionStr: string;
begin
  Main.ProgressBar.Max:=Actions.Count;
  for i:=0 to Actions.Count - 1 do begin

    if StopRequest then Break;

    ActionStr:=Actions.Strings[i];

    if Copy(Actions.Strings[i], 1, 5) = 'COPY ' then begin
      Delete(ActionStr, 1, 5);
      try
        StatusText(ID_COPY_FILE + ' ' + Copy(ActionStr, 1, Pos(#9, ActionStr) - 1));
        if CopyFile( PChar( Copy(ActionStr, 1, Pos(#9, ActionStr) - 1) ),
                     PChar( Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr)) ), false) then begin
          Inc(GoodCopyFilesCounter);
          Actions.Strings[i]:='';
        end else
          Inc(BadCopyFilesCounter);
      except
        Inc(BadCopyFilesCounter);
      end;
    end;

    if Copy(Actions.Strings[i], 1, 5) = 'MOVE ' then begin
      Delete(ActionStr, 1, 5);
      try
        StatusText(ID_MOVE_FILE + ' ' + Copy(ActionStr, 1, Pos(#9, ActionStr) - 1));
        if MoveFile( PChar( Copy(ActionStr, 1, Pos(#9, ActionStr) - 1) ),
                     PChar( Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr)) ) ) then begin
          Inc(GoodMoveFilesCounter);
          Actions.Strings[i]:='';
        end else
          Inc(BadMoveFilesCounter);
      except
        Inc(BadMoveFilesCounter);
      end;
    end;

    if Copy(Actions.Strings[i], 1, 7) = 'RENAME ' then begin
      Delete(ActionStr, 1, 7);
      try
        StatusText(ID_RENAME_FILE + ' ' + Copy(ActionStr, 1, Pos(#9, ActionStr) - 1));
        if RenameFile( PChar( Copy(ActionStr, 1, Pos(#9, ActionStr) - 1) ),
                     PChar( Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr)) ) ) then begin
          Inc(GoodRenameFilesCounter);
          Actions.Strings[i]:='';
        end else
          Inc(BadRenameFilesCounter);
      except
        Inc(BadRenameFilesCounter);
      end;
    end;

    if Copy(Actions.Strings[i], 1, 7) = 'DELETE ' then begin
      Delete(ActionStr, 1, 7);
      try
        StatusText(ID_REMOVE_FILE + ' ' + ActionStr);
        if DeleteFile(ActionStr) then begin
          Inc(GoodDeleteFilesCounter);
          Actions.Strings[i]:='';
        end else
          Inc(BadDeleteFilesCounter);
      except
        Inc(BadDeleteFilesCounter);
      end;
    end;

    if Copy(Actions.Strings[i], 1, 6) = 'MKDIR ' then begin
      Delete(ActionStr, 1, 6);
      try
        StatusText(ID_CREATE_FOLDER + ' ' + ActionStr);
        if CreateDir(ActionStr) then begin
          Inc(GoodMakeFoldersCounter);
          Actions.Strings[i]:='';
        end else
          Inc(BadMakeFoldersCounter);
      except
        Inc(BadMakeFoldersCounter);
      end;
    end;

    if Copy(Actions.Strings[i], 1, 6) = 'RMDIR ' then begin
      Delete(ActionStr, 1, 6);
      try
        StatusText(ID_REMOVE_FOLDER + ' ' + ActionStr);
        if RemoveDir(ActionStr) then begin
          Inc(GoodRemoveFoldersCounter);
          Actions.Strings[i]:='';
        end else
        Inc(BadRemoveFoldersCounter);
      except
        Inc(BadRemoveFoldersCounter);
      end;
    end;

    Main.ProgressBar.Position:=i + 1;
  end;
end;

function GetNotificationAppPath: string;
var
  Reg: TRegistry;
begin
  Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CURRENT_USER;
  if Reg.OpenKey('\Software\r57zone\Notification', false) then begin
      Result:=Reg.ReadString('Path');
    Reg.CloseKey;
  end;
  Reg.Free;
end;

function GetLocaleInformation(Flag: integer): string;
var
  pcLCA: array [0..20] of Char;
begin
  if GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, Flag, pcLCA, 19) <= 0 then
    pcLCA[0]:=#0;
  Result:=pcLCA;
end;

procedure TMain.FormCreate(Sender: TObject);
var
  Ini: TIniFile; i: integer; CustomBackupFile: string;
begin
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  CBCheckLog.Checked:=Ini.ReadBool('Main', 'LookTasks', true);
  Ini.Free;

  //Перевод
  if FileExists(ExtractFilePath(ParamStr(0)) + 'Languages\' + GetLocaleInformation(LOCALE_SENGLANGUAGE) + '.ini') then
    Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Languages\' + GetLocaleInformation(LOCALE_SENGLANGUAGE) + '.ini')
  else
    Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Languages\English.ini');

  ListView.Columns[0].Caption:=Ini.ReadString('Main', 'ID_ACTIVE', '');
  ListView.Columns[1].Caption:=Ini.ReadString('Main', 'ID_NAME', '');
  ListView.Columns[2].Caption:=Ini.ReadString('Main', 'ID_LEFT_FOLDER', '');
  ListView.Columns[3].Caption:=Ini.ReadString('Main', 'ID_RIGHT_FOLDER', '');
  RunBtn.Caption:=Ini.ReadString('Main', 'ID_RUN', '');
  CreateBtn.Caption:=Ini.ReadString('Main', 'ID_CREATE', '');
  OpenBtn.Caption:=Ini.ReadString('Main', 'ID_OPEN', '');
  AddBtn.Caption:=Ini.ReadString('Main', 'ID_ADD', '');
  RemBtn.Caption:=Ini.ReadString('Main', 'ID_REMOVE', '');
  ExcludeBtn.Caption:=Ini.ReadString('Main', 'ID_EXCLUDE', '');
  StopBtn.Caption:=Ini.ReadString('Main', 'ID_STOP', '');
  CBCheckLog.Caption:=Ini.ReadString('Main', 'ID_VIEW_TASKS', '');

  ID_LOOKING_CHANGES:=Ini.ReadString('Main', 'ID_LOOKING_CHANGES', '');
  ID_FILE_RENAMED:=Ini.ReadString('Main', 'ID_FILE_RENAMED', '');
  ID_FOUND_NEW_FILE:=Ini.ReadString('Main', 'ID_FOUND_NEW_FILE', '');
  ID_FILE_UPDATED:=Ini.ReadString('Main', 'ID_FILE_UPDATED', '');
  ID_FOUND_OLD_FILE:=Ini.ReadString('Main', 'ID_FOUND_OLD_FILE', '');
  ID_COPY_FILE:=Ini.ReadString('Main', 'ID_COPY_FILE', '');
  ID_MOVE_FILE:=Ini.ReadString('Main', 'ID_MOVE_FILE', '');
  ID_RENAME_FILE:=Ini.ReadString('Main', 'ID_RENAME_FILE', '');
  ID_REMOVE_FILE:=Ini.ReadString('Main', 'ID_REMOVE_FILE', '');
  ID_CREATE_FOLDER:=Ini.ReadString('Main', 'ID_CREATE_FOLDER', '');
  ID_REMOVE_FOLDER:=Ini.ReadString('Main', 'ID_REMOVE_FOLDER', '');
  ID_CHECK_MOVE_FILES:=Ini.ReadString('Main', 'ID_CHECK_MOVE_FILES', '');
  ID_COMPLETED:=Ini.ReadString('Main', 'ID_COMPLETED', '');
  ID_COMPLETED_ERROR:=Ini.ReadString('Main', 'ID_COMPLETED_ERROR', '');
  ID_BACKUP_COMPLETED:=Ini.ReadString('Main', 'ID_BACKUP_COMPLETED', '');
  ID_BACKUP_FAILED:=Ini.ReadString('Main', 'ID_BACKUP_FAILED', '');
  ID_CHECK_FILES:=Ini.ReadString('Main', 'ID_CHECK_FILES', '');
  ID_TOTAL_OPERATIONS:=Ini.ReadString('Main', 'ID_TOTAL_OPERATIONS', '');
  ID_SUCCESS_COPY_FILES:=Ini.ReadString('Main', 'ID_SUCCESS_COPY_FILES', '');
  ID_SUCCESS_MOVE_FILES:=Ini.ReadString('Main', 'ID_SUCCESS_MOVE_FILES', '');
  ID_SUCCESS_RENAME_FILES:=Ini.ReadString('Main', 'ID_SUCCESS_RENAME_FILES', '');
  ID_SUCCESS_REMOVE_FILES:=Ini.ReadString('Main', 'ID_SUCCESS_REMOVE_FILES', '');
  ID_SUCCESS_CREATE_FOLDERS:=Ini.ReadString('Main', 'ID_SUCCESS_CREATE_FOLDERS', '');
  ID_SUCCESS_REMOVE_FOLDERS:=Ini.ReadString('Main', 'ID_SUCCESS_REMOVE_FOLDERS', '');
  ID_FAIL_COPY_FILES:=Ini.ReadString('Main', 'ID_FAIL_COPY_FILES', '');
  ID_FAIL_MOVE_FILES:=Ini.ReadString('Main', 'ID_FAIL_MOVE_FILES', '');
  ID_FAIL_RENAME_FILES:=Ini.ReadString('Main', 'ID_FAIL_RENAME_FILES', '');
  ID_FAIL_REMOVE_FILES:=Ini.ReadString('Main', 'ID_FAIL_REMOVE_FILES', '');
  ID_FAIL_CREATE_FOLDERS:=Ini.ReadString('Main', 'ID_FAIL_CREATE_FOLDERS', '');
  ID_FAIL_REMOVE_FOLDERS:=Ini.ReadString('Main', 'ID_FAIL_REMOVE_FOLDERS', '');
  ID_PERFORM_OPERATIONS:=Ini.ReadString('Main', 'ID_PERFORM_OPERATIONS', '');
  ID_ENTER_NAME_PARE_FOLDERS:=Ini.ReadString('Main', 'ID_ENTER_NAME_PARE_FOLDERS', '');
  ID_CHOOSE_LEFT_FOLDER:=Ini.ReadString('Main', 'ID_CHOOSE_LEFT_FOLDER', '');
  ID_CHOOSE_RIGHT_FOLDER:=Ini.ReadString('Main', 'ID_CHOOSE_RIGHT_FOLDER', '');
  ID_CHOOSE_FOLDER_ERROR:=Ini.ReadString('Main', 'ID_CHOOSE_FOLDER_ERROR', '');
  ID_SUCCESS_NOTIFICATION_MESSAGE:=Ini.ReadString('Main', 'ID_SUCCESS_NOTIFICATION_MESSAGE', '');
  ID_FAIL_NOTIFICATION_MESSAGE:=Ini.ReadString('Main', 'ID_FAIL_NOTIFICATION_MESSAGE', '');
  ID_ABOUT_TITLE:=Ini.ReadString('Main', 'ID_ABOUT_TITLE', '');
  ID_LAST_UPDATE:=Ini.ReadString('Main', 'ID_LAST_UPDATE', '');
  ID_EXCLUDE_TITLE:=Ini.ReadString('Main', 'ID_EXCLUDE_TITLE', '');
  ID_SELECT_EXCLUDE_FOLDER:=Ini.ReadString('Main', 'ID_SELECT_EXCLUDE_FOLDER', '');
  ID_OK:=Ini.ReadString('Main', 'ID_OK', '');
  ID_CANCEL:=Ini.ReadString('Main', 'ID_CANCEL', '');
  Ini.Free;

  Application.Title:=Caption;

  for i:=1 to ParamCount do begin
    if ParamStr(i) = '-b' then
      CustomBackupFile:=ParamStr(i + 1);
    if ParamStr(i) = '-s' then
      SilentMode:=true;
  end;

  ExcludePaths:=TStringList.Create; //Создаём до загрузки путей для исключения

  if CustomBackupFile = '' then
    LoadBackupPaths(ExtractFilePath(ParamStr(0)) + BACKUP_PATHS_FILE_NAME)
  else
    LoadBackupPaths(ExtractFilePath(ParamStr(0)) + CustomBackupFile);

  Actions:=TStringList.Create;
  ExcludeRenameFiles:=TStringList.Create;

  if SilentMode then begin
    NotificationApp:=GetNotificationAppPath;
    RunBtn.Click;
    Halt(0);
  end;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Actions.Free;
  ExcludePaths.Free;
  ExcludeRenameFiles.Free;
end;

procedure TMain.RunBtnClick(Sender: TObject);
var
  i: integer;
  Item: TListItem;

  BackupStatusTitle: string;
begin
  StopRequest:=false;
  ProgressBar.Position:=0;
  RunBtn.Enabled:=false;
  CreateBtn.Enabled:=false;
  OpenBtn.Enabled:=false;
  AddBtn.Enabled:=false;
  RemBtn.Enabled:=false;
  ExcludeBtn.Enabled:=false;
  StopBtn.Enabled:=true;
  FilesCounter:=0;
  ActionGoodCounter:=0;
  GoodCopyFilesCounter:=0;
  GoodMoveFilesCounter:=0;
  GoodRenameFilesCounter:=0;
  GoodDeleteFilesCounter:=0;
  GoodMakeFoldersCounter:=0;
  GoodRemoveFoldersCounter:=0;
  BadCopyFilesCounter:=0;
  BadMoveFilesCounter:=0;
  BadRenameFilesCounter:=0;
  BadDeleteFilesCounter:=0;
  BadMakeFoldersCounter:=0;
  BadRemoveFoldersCounter:=0;
  Actions.Clear;
  ExcludeRenameFiles.Clear;

  for i:=0 to ListView.Items.Count - 1 do begin
    Item:=ListView.Items.Item[i];
    if Item.Checked then begin
      CheckFilesDiff(Item.SubItems[1], Item.SubItems[2]);
      CheckRemoteFilesToRemove(Item.SubItems[1], Item.SubItems[2]);
    end;
  end;
  CheckRemoteFilesToMove;

  if SilentMode = false then begin

    StatusText(ID_PERFORM_OPERATIONS);

    //Подтверждение выполнения операций
    if CBCheckLog.Checked then begin
      if Actions.Count > 0 then begin

        //Показываем логи
        LogsForm.Show;
        LogsForm.LogsMemo.Text:=Actions.Text;

        //Подтверждение операции
        case MessageBox(Handle, PChar(ID_PERFORM_OPERATIONS), PChar(Caption), 35) of
          6:begin
              //Если окно не закрыто, то закрываем его
              if LogsForm.Showing then
                LogsForm.Close;
              ActionsRun;
            end;

        end;

      end;
    end else
      if Actions.Count > 0 then begin
        ActionsRun;
        ActionGoodCounter:=Actions.Count;
      end;

  end else
    if Actions.Count > 0 then ActionsRun;

  if (BadCopyFilesCounter > 0) or (BadMoveFilesCounter > 0) or (BadDeleteFilesCounter > 0) or (BadMakeFoldersCounter > 0) or (BadRemoveFoldersCounter > 0) then begin
    ProgressBar.Position:=0;
    StatusText(ID_COMPLETED_ERROR);
  end else begin
    StatusText(ID_COMPLETED);
    Actions.Clear;
  end;

  RunBtn.Enabled:=true;
  CreateBtn.Enabled:=true;
  OpenBtn.Enabled:=true;
  RunBtn.Enabled:=true;
  AddBtn.Enabled:=true;
  RemBtn.Enabled:=true;
  ExcludeBtn.Enabled:=true;

  StopBtn.Enabled:=false;

  if SilentMode = false then begin

    if (BadCopyFilesCounter = 0) and (BadMoveFilesCounter = 0) and (BadDeleteFilesCounter = 0) and (BadRenameFilesCounter = 0) and (BadRemoveFoldersCounter = 0) then
      BackupStatusTitle:=ID_BACKUP_COMPLETED
    else
      BackupStatusTitle:=ID_BACKUP_FAILED;

    Application.MessageBox(PChar(BackupStatusTitle + #13#10 + #13#10 +
                                 ID_CHECK_FILES + ' ' + IntToStr(FilesCounter) + #13#10 + ID_TOTAL_OPERATIONS + ' ' + IntToStr(ActionGoodCounter) + #13#10#13#10 +
                                 ID_SUCCESS_COPY_FILES + ' ' + IntToStr(GoodCopyFilesCounter) + #13#10 +
                                 ID_SUCCESS_MOVE_FILES + ' ' + IntToStr(GoodMoveFilesCounter) + #13#10 +
                                 ID_SUCCESS_RENAME_FILES + ' ' + IntToStr(GoodRenameFilesCounter) + #13#10 +
                                 ID_SUCCESS_REMOVE_FILES + ' ' + IntToStr(GoodDeleteFilesCounter) + #13#10 +
                                 ID_SUCCESS_CREATE_FOLDERS + ' ' + IntToStr(GoodMakeFoldersCounter) + #13#10 +
                                 ID_SUCCESS_REMOVE_FOLDERS + ' ' + IntToStr(GoodRemoveFoldersCounter) + #13#10#13#10 +
                                 ID_FAIL_COPY_FILES + ' ' + IntToStr(BadCopyFilesCounter) + #13#10 +
                                 ID_FAIL_MOVE_FILES + ' ' + IntToStr(BadMoveFilesCounter) + #13#10 +
                                 ID_FAIL_RENAME_FILES + ' ' + IntToStr(BadRenameFilesCounter) + #13#10 +
                                 ID_FAIL_REMOVE_FILES + ' ' + IntToStr(BadDeleteFilesCounter) + #13#10 +
                                 ID_FAIL_CREATE_FOLDERS + ' ' + IntToStr(BadMakeFoldersCounter) + #13#10 +
                                 ID_FAIL_REMOVE_FOLDERS + ' ' + IntToStr(BadRemoveFoldersCounter) ),
                            PChar(Caption), MB_ICONINFORMATION);

  end else if Trim(NotificationApp) <> '' then begin

    if (BadCopyFilesCounter = 0) and (BadMoveFilesCounter = 0) and (BadDeleteFilesCounter = 0) and (BadRenameFilesCounter = 0) and (BadRemoveFoldersCounter = 0) then
      WinExec(PAnsiChar(NotificationApp + ' -t "' + Caption + '" -d "' + ID_SUCCESS_NOTIFICATION_MESSAGE + '" -b EchoBackaper.png -c 1'), SW_SHOWNORMAL)
    else
      WinExec(PAnsiChar(NotificationApp + ' -t "' + Caption + '" -d "' + ID_FAIL_NOTIFICATION_MESSAGE + '" -b EchoBackaper.png -c 1'), SW_SHOWNORMAL);

  end;
end;

function TMain.BrowseFolderDialog(Title: PChar): string;
var
  TitleName: string;
  lpItemid: pItemIdList;
  BrowseInfo: TBrowseInfo;
  DisplayName: array[0..MAX_PATH] of Char;
  TempPath: array[0..MAX_PATH] of Char;
begin
  FillChar(BrowseInfo, SizeOf(TBrowseInfo), #0);
  BrowseInfo.hwndOwner:=GetDesktopWindow;
  BrowseInfo.pSzDisplayName:=@DisplayName;
  TitleName:=Title;
  BrowseInfo.lpSzTitle:=PChar(TitleName);
  BrowseInfo.ulFlags:=BIF_RETURNONLYFSDIRS;
  lpItemId:=shBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin
    shGetPathFromIdList(lpItemId, TempPath);
    Result:=TempPath;
    GlobalFreePtr(lpItemId);
  end;
end;

procedure TMain.OpenBtnClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    LoadBackupPaths(OpenDialog.FileName);
end;

procedure TMain.CBCheckLogClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  Ini.WriteBool('Main', 'LookTasks', CBCheckLog.Checked);
  Ini.Free;
end;

procedure TMain.CreateBtnClick(Sender: TObject);
begin
  if SaveDialog.Execute then begin
    CurrentBackupFilePath:=SaveDialog.FileName;
    //Очищаем текущие пути
    ListView.Clear;
    ExcludePaths.Clear;
  end;
end;

procedure TMain.LoadBackupPaths(FileName: string);
var
  i: integer;
  Item: TListItem; BackupPaths: TStringList; Str: string;
  LoadExcludePaths: boolean;
begin
  //Очищаем текущие пути
  ListView.Clear;
  ExcludePaths.Clear;

  BackupPaths:=TStringList.Create;
  LoadExcludePaths:=false;

  if FileExists(FileName) then begin
    BackupPaths.LoadFromFile(FileName);

    //Сохраняем текущий путь для сохранения
    CurrentBackupFilePath:=FileName;
  end else
    //Если файл не найден, то читаем дефолтный файл
    CurrentBackupFilePath:=ExtractFilePath(ParamStr(0)) + BACKUP_PATHS_FILE_NAME;


  for i:=1 to BackupPaths.Count - 1 do begin //Первая строка зарезервирована под "PAIR FOLDERS:"
    if BackupPaths.Strings[i] = EXCLUDE_PATHS_FILE then begin
      LoadExcludePaths:=true;
      Continue;
    end;

    if LoadExcludePaths = false then begin
      Str:=BackupPaths.Strings[i];
      Item:=Main.ListView.Items.Add;
      Item.Caption:='';
      Item.SubItems.Add(Copy(Str, 1, Pos(#9, Str) - 1));
      Delete(Str, 1, Pos(#9, Str));
      Item.SubItems.Add(Copy(Str, 1, Pos(#9, Str) - 1));
      Delete(Str, 1, Pos(#9, Str));
      Item.SubItems.Add(Str);
      Item.Checked:=true;
    end else
      if Trim(BackupPaths.Strings[i]) <> '' then
        ExcludePaths.Add(BackupPaths.Strings[i]);
  end;
  BackupPaths.Free;
end;

procedure TMain.SaveBackupPaths;
var
  i: integer;
  Item: TListItem;
  BackupPaths: TStringList;
begin
  BackupPaths:=TStringList.Create;

  //Добавляем связанные папки
  BackupPaths.Add(PAIR_FOLDERS_FILE);
  for i:=0 to ListView.Items.Count - 1 do begin
    Item:=ListView.Items.Item[i];
    BackupPaths.Add(Item.SubItems[0]+ #9 + Item.SubItems[1] + #9 + Item.SubItems[2]);
  end;

  //Добавляем исключённые пути
  BackupPaths.Add(EXCLUDE_PATHS_FILE);
  BackupPaths.Add(Trim(ExcludePaths.Text));

  BackupPaths.SaveToFile(CurrentBackupFilePath); //Сохраняем в текущий открытый файл
  BackupPaths.Free;
end;

procedure TMain.AddBtnClick(Sender: TObject);
var
  Item: TListItem; NameFolders, LeftFolder, RightFolder: string;
begin
  NameFolders:='';
  LeftFolder:='';
  RightFolder:='';

  InputQuery(Caption, ID_ENTER_NAME_PARE_FOLDERS, NameFolders);

  if Trim(NameFolders) <> '' then begin
    LeftFolder:=BrowseFolderDialog(PChar(ID_CHOOSE_LEFT_FOLDER));

    if LeftFolder <> '' then
      RightFolder:=BrowseFolderDialog(PChar(ID_CHOOSE_RIGHT_FOLDER));
  end;

  if (Trim(NameFolders) <> '') and (LeftFolder <> '') and (RightFolder <> '') then begin
    Item:=Main.ListView.Items.Add;
    Item.Caption:='';
    Item.SubItems.Add(NameFolders);
    Item.SubItems.Add(LeftFolder);
    Item.SubItems.Add(RightFolder);
    Item.Checked:=true;
  end else
    Application.MessageBox(PChar(ID_CHOOSE_FOLDER_ERROR), PChar(Caption), MB_ICONERROR);

  SaveBackupPaths;
end;

procedure TMain.RemBtnClick(Sender: TObject);
begin
  if ListView.ItemIndex <> -1 then begin
    ListView.DeleteSelected;
    SaveBackupPaths;
  end;
end;

procedure TMain.ListViewDblClick(Sender: TObject);
var
  Item: TListItem;
begin
  if ListView.ItemIndex <> -1 then begin
    Item:=ListView.Items.Item[ListView.ItemIndex];
    Application.MessageBox(PChar(ListView.Columns[2].Caption + ': ' + Item.SubItems[1] + #13#10 + ListView.Columns[3].Caption + ': ' + Item.SubItems[2]), PChar(Item.SubItems[0]), MB_ICONINFORMATION);
  end;
end;

procedure TMain.ListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then begin
    RemBtn.Click;
    SaveBackupPaths;
  end;
end;

procedure TMain.ExcludeBtnClick(Sender: TObject);
begin
  ExcludeFoldersForm.ShowModal;
end;

procedure TMain.StopBtnClick(Sender: TObject);
begin
  StopRequest:=true;
  RunBtn.Enabled:=true;
  StopBtn.Enabled:=false;
end;

procedure TMain.AboutBtnClick(Sender: TObject);
begin
  Application.MessageBox(PChar(Caption + ' 0.7' + #13#10 +
  ID_LAST_UPDATE + ' 17.10.2020' + #13#10 +
  'https://r57zone.github.io' + #13#10 +
  'r57zone@gmail.com'), PChar(ID_ABOUT_TITLE), MB_ICONINFORMATION);
end;

end.
