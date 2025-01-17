﻿unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, ShlObj, Registry,
  IniFiles, Vcl.Menus, ShellAPI, IdHashCRC, System.Generics.Collections, LangFile;

type
  TMain = class(TForm)
    StatusBar: TStatusBar;
    RunBtn: TButton;
    ListView: TListView;
    ProgressBar: TProgressBar;
    StopBtn: TButton;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ListViewPM: TPopupMenu;
    RemSelectionBtn: TMenuItem;
    SelectAllBtn: TMenuItem;
    LineNoneBtn31: TMenuItem;
    OpenFolderBtn: TMenuItem;
    LeftFolderBtn: TMenuItem;
    RightFolderBtn: TMenuItem;
    LineNoneBtn32: TMenuItem;
    MoveBtn: TMenuItem;
    UpBtn: TMenuItem;
    DownBtn: TMenuItem;
    MainMenu: TMainMenu;
    FileBtn: TMenuItem;
    OpenBtn: TMenuItem;
    CreateBtn: TMenuItem;
    LineNoneBtn1: TMenuItem;
    ExitBtn: TMenuItem;
    OpenBtn2: TButton;
    FoldersBtn: TMenuItem;
    AddBtn: TMenuItem;
    AddBtn2: TMenuItem;
    LineNoneBtn33: TMenuItem;
    LineNoneBtn3: TMenuItem;
    RemBtn: TMenuItem;
    LineNone4: TMenuItem;
    RemBtn2: TMenuItem;
    ExcludeBtn: TMenuItem;
    HelpBtn: TMenuItem;
    AboutBtn: TMenuItem;
    ProgressBar2: TProgressBar;
    CurOperationLbl: TLabel;
    AllOperationsLbl: TLabel;
    LineNoneBtn2: TMenuItem;
    SettingsBtn: TMenuItem;
    EditBtn: TMenuItem;
    EditBtn2: TMenuItem;
    LineNoneBtn34: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure RunBtnClick(Sender: TObject);
    procedure AddBtn2Click(Sender: TObject);
    procedure RemBtn2Click(Sender: TObject);
    procedure ListViewDblClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure AboutBtnClick(Sender: TObject);
    procedure ListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OpenBtnClick(Sender: TObject);
    procedure CreateBtnClick(Sender: TObject);
    procedure CheckRemoteFilesToMove;
    procedure ListViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RemSelectionBtnClick(Sender: TObject);
    procedure SelectAllBtnClick(Sender: TObject);
    procedure LeftFolderBtnClick(Sender: TObject);
    procedure RightFolderBtnClick(Sender: TObject);
    procedure UpBtnClick(Sender: TObject);
    procedure DownBtnClick(Sender: TObject);
    procedure OpenBtn2Click(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure RemBtnClick(Sender: TObject);
    procedure ExcludeBtnClick(Sender: TObject);
    procedure SettingsBtnClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditBtnClick(Sender: TObject);
    procedure EditBtn2Click(Sender: TObject);
  private
    procedure LoadBackupPaths(FileName: string);
    { Private declarations }
  public
    procedure SaveBackupPaths;
    function BrowseFolderDialog(Title: PChar; Flags: Cardinal): string;
    { Public declarations }
  end;

type
  TFSOperation = (ID_OPERATION_NONE, ID_OPERATION_COPY, ID_OPERATION_RENAME, ID_OPERATION_MOVE, ID_OPERATION_DELETE, ID_OPERATION_MKDIR, ID_OPERATION_RMDIR);
const
  FSOperationStr: array[0..6] of string = ('NONE', 'COPY', 'RENAME', 'MOVE', 'DEL', 'MKDIR', 'RMDIR');

type
  TFSAction = packed record
    ActionType: TFSOperation;
    FirstPath, SecondPath: string;
    FirstFileSize: int64;
    FirstFileTime: integer; // Не менять, Time именно в Integer
    //SecondFileSize, SecondFileTime: int64;
  end;

var
  Main: TMain;

  FSActions: TList<TFSAction>;
  //Actions,
  ExcludePaths, ExcludeRenameFiles: TStringList;
  CurrentBackupFilePath: string; //Текущий файл путей для резервной копии

  FilesCounter, ActionGoodCounter, GoodCopyFilesCounter, GoodMoveFilesCounter, GoodRenameFilesCounter, GoodDeleteFilesCounter,
  GoodMakeFoldersCounter, GoodRemoveFoldersCounter, BadCopyFilesCounter, BadMoveFilesCounter, BadRenameFilesCounter,
  BadDeleteFilesCounter, BadMakeFoldersCounter, BadRemoveFoldersCounter: integer;

  StopRequest: boolean; AllowAppClose: boolean = true; RequestCloseApp: boolean = false;
  SilentMode: boolean;
  NotificationApp: string;

  CheckLogShow, CRCCopyCheck, WriteCreationDate, WriteAttributes: boolean;

  IDS_LOOKING_CHANGES, IDS_FILE_RENAMED, IDS_FOUND_NEW_FILE, IDS_FILE_UPDATED, IDS_FOUND_OLD_FILE,
  IDS_COPY_FILE, IDS_MOVE_FILE, IDS_RENAME_FILE, IDS_REMOVE_FILE, IDS_CREATE_FOLDER, IDS_REMOVE_FOLDER, IDS_CHECK_MOVE_FILES: string;
  IDS_COMPLETED, IDS_COMPLETED_ERROR, IDS_BACKUP_COMPLETED, IDS_BACKUP_FAILED, IDS_CHECK_FILES, IDS_TOTAL_OPERATIONS,
  IDS_SUCCESS_COPY_FILES, IDS_SUCCESS_MOVE_FILES, IDS_SUCCESS_RENAME_FILES, IDS_SUCCESS_REMOVE_FILES,
  IDS_SUCCESS_CREATE_FOLDERS, IDS_SUCCESS_REMOVE_FOLDERS, IDS_FAIL_COPY_FILES, IDS_FAIL_MOVE_FILES, IDS_FAIL_RENAME_FILES,
  IDS_FAIL_REMOVE_FILES, IDS_FAIL_CREATE_FOLDERS, IDS_FAIL_REMOVE_FOLDERS: string;
  IDS_PERFORM_OPERATIONS, IDS_ENTER_NAME_PAIR_FOLDERS, IDS_CHOOSE_LEFT_FOLDER,
  IDS_CHOOSE_RIGHT_FOLDER, IDS_CHOOSE_FOLDER_ERROR, IDS_SUCCESS_NOTIFICATION_MESSAGE,
  IDS_FAIL_NOTIFICATION_MESSAGE: string;
  IDS_ABOUT_TITLE, IDS_LAST_UPDATE: string;
  IDS_EXCLUDE_TITLE, IDS_SELECT_EXCLUDE_FOLDER, IDS_OK, IDS_CANCEL: string;

  IDS_VIEW_TASKS, IDS_CHECKSUM_VERIFICATION_COPY, IDS_COPY_CREATION_DATE, IDS_COPY_FILE_ATTRIBUTES: string;

  IDS_SAVE_AS, IDS_LOGS_FILE_DIALOG_FILTER, IDS_ADD_PAUSE_TO_FILE: string;

const
  // Название файла путей для резеревной копии по умолчанию
  BACKUP_PATHS_FILE_NAME = 'BackupPaths.ebp';
  // Зарезервированные фразы для файла
  PAIR_FOLDERS_FILE = 'PAIR FOLDERS:';
  EXCLUDE_PATHS_FILE = 'EXCLUDE PATHS:';

implementation

{$R *.dfm}

uses Unit2, Unit3, Unit4;

{ TMain }

function CutStr(Str: string; CharCount: integer): string;
begin
  if Length(Str) > CharCount then
    Result:=Copy(Str, 1, CharCount - 3) + '...'
  else
    Result:=Str;
end;

procedure StatusText(FullStr, SmallStr: string);
begin
  Main.StatusBar.Hint:=SmallStr;
  Main.StatusBar.SimpleText:=' ' + CutStr(FullStr, 80);
end;

function FileCreatedAge(const FileName: string): Integer;
var
  SearchRec: TSearchRec;
  LocalTime: TFileTime;
  DOSFileTime: DWORD;
begin
  Result:=-1;
  if FindFirst(FileName, faAnyFile, SearchRec) = 0 then begin
    FileTimeToLocalFileTime(SearchRec.FindData.ftCreationTime, LocalTime);
    if FileTimeToDosDateTime(LocalTime,LongRec(DOSFileTime).Hi,LongRec(DOSFileTime).Lo) then
      Result:=DOSFileTime;
    FindClose(SearchRec);
  end;
end;

function FileSetCreatedDate(FileName: string; Age: Integer): Integer;
var
  SourceFile: THandle;
  LocalFileTime, FileTime: TFileTime;
begin
  SourceFile:=FileOpen(FileName, fmOpenWrite or fmShareDenyNone);
  if SourceFile=THandle(-1) then
    Result:=GetLastError
  else if DosDateTimeToFileTime(LongRec(Age).Hi, LongRec(Age).Lo, LocalFileTime) and LocalFileTimeToFileTime(LocalFileTime, FileTime) then begin
    Result:=0;
    SetFileTime(SourceFile, @FileTime, nil, nil);
    FileClose(SourceFile);
  end;
end;

function CalculateCRC32(const FileName: string): Cardinal;
var
  Stream: TFileStream;
  Hash: TIdHashCRC32;
begin
  Result:=0;
  Stream:=TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Hash:=TIdHashCRC32.Create;
    try
      Result:=Hash.HashValue(Stream);
    finally
      Hash.Free;
    end;
  finally
    Stream.Free;
  end;
end;

function CPFile(const SourceFileName, TargetFileName: string): boolean; // Самостоятельное копирование файла
const
  BufferSize = 4096;
var
  SourceFile, TargetFile: THandle;
  NumRead, NumWritten: LongWord; // DWORD тоже самое
  SourceFileSize, CopySize: int64;
  Buffer: array[0..BufferSize-1] of Byte;
  SameSizes: boolean;
begin
  Result:=false;
  try
    SourceFile:=CreateFile(PChar(SourceFileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if SourceFile = INVALID_HANDLE_VALUE then Exit;

    if not GetFileSizeEx(SourceFile, SourceFileSize) then Exit;

    if FileExists(TargetFileName) then if DeleteFile(PChar(TargetFileName)) = false then Exit; // Удаляем файл, если существует

    try
      TargetFile:=CreateFile(PChar(TargetFileName), GENERIC_WRITE, FILE_SHARE_WRITE or FILE_SHARE_READ, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
      if TargetFile = INVALID_HANDLE_VALUE then begin
        CloseHandle(SourceFile);
        Exit;
      end;

      try
        CopySize:=0;
        Main.ProgressBar2.Position:=0;
        repeat
          if (not ReadFile(SourceFile, Buffer, BufferSize, NumRead, nil)) or (NumRead = 0) then break; // NumRead = 0 для пустых файлов
          if not WriteFile(TargetFile, Buffer, NumRead, NumWritten, nil) then break;
          CopySize:=CopySize + NumWritten; // Inc(CopySize, NumWritten);
          StatusText(IDS_COPY_FILE + ' ' + IntToStr(Trunc(CopySize / SourceFileSize * 100)) + '% - ' + SourceFileName, SourceFileName);
          Main.ProgressBar2.Position:=Trunc(CopySize / SourceFileSize * 100);
          if StopRequest then break;
          Application.ProcessMessages;
        until (NumRead = 0) or (NumWritten <> NumRead);
      finally
        FileClose(TargetFile);
        StatusText(IDS_COPY_FILE + ' 100% - ' + SourceFileName, SourceFileName);
        Main.ProgressBar2.Max:=101; // Прогресс бар отображается с задержкой, поэтому такой обходной путь
        Main.ProgressBar2.Position:=101;
        Main.ProgressBar2.Max:=100;
        SameSizes := (CopySize = SourceFileSize);  // Оверхед - if not GetFileSizeEx(TargetFile, TargetFileSize) then Exit; SameSizes:=(SourceFileSize = TargetFileSize);
      end;
    finally
      FileClose(SourceFile);
    end;
  finally
    Application.ProcessMessages;

    if (StopRequest = false) and (SameSizes) and (FileSetDate( TargetFileName, FileAge(SourceFileName) ) = 0) and
       ( (WriteCreationDate = false) or (FileSetCreatedDate( TargetFileName, FileCreatedAge(SourceFileName) ) = 0) ) and
       ( (CRCCopyCheck = false) or (CalculateCRC32(SourceFileName) = CalculateCRC32(TargetFileName)) ) and
       ( (WriteAttributes = false) or (FileSetAttr(TargetFileName, FileGetAttr(SourceFileName)) = 0) ) then Result:=true; // Атрибуты присваиваем в последнюю очередь, потому что еще нужно обновить даты создания и изменения

  end;

  Main.ProgressBar2.Position:=0;

  if (StopRequest) or (Result = false) then DeleteFile(PChar(TargetFileName));
end;

procedure AddFSAction(const ActionType: TFSOperation; FirstPath, SecondPath: string; FirstFileSize: int64; FirstFileTime: integer);
var
  NewAction: TFSAction;
begin
  NewAction.ActionType:=ActionType;
  NewAction.FirstPath:=FirstPath;
  NewAction.SecondPath:=SecondPath;
  NewAction.FirstFileSize:=FirstFileSize;
  NewAction.FirstFileTime:=FirstFileTime;
  FSActions.Add(NewAction);
end;

procedure EdiTFSAction(Index: Integer; const ActionType: TFSOperation; FirstPath, SecondPath: string);
var
  EditedAction: TFSAction;
begin
  if (Index > -1) and (Index < FSActions.Count) then begin
    EditedAction.ActionType:=ActionType;
    EditedAction.FirstPath:=FirstPath;
    EditedAction.SecondPath:=SecondPath;
    EditedAction.FirstFileSize:=0; // Пока не нужно
    EditedAction.FirstFileTime:=0; // Пока не нужно
    FSActions[Index] := EditedAction;
  end;
end;

{procedure RemoveFSAction(Index: Integer);
begin
  if (Index > -1) and (Index < FSActions.Count) then
    FSActions.Delete(Index);
end;}

procedure CheckFilesDiff(LocalFolder, RemoteFolder: string);
var
  LocalFile, RemoteFile: TSearchRec;
  i: integer;
  FoundCurrentFile: boolean;
begin
  if StopRequest then Exit;

  // Игнорируемые папки
  for i:=0 to ExcludePaths.Count - 1 do
    if ExcludePaths.Strings[i] = LocalFolder then Exit;

  if LocalFolder[Length(LocalFolder)] <> '\' then
    LocalFolder:=LocalFolder + '\';
  if RemoteFolder[Length(RemoteFolder)] <> '\' then
    RemoteFolder:=RemoteFolder + '\';

  StatusText(IDS_LOOKING_CHANGES + ' ' + LocalFolder, LocalFolder);

  if FindFirst(LocalFolder + '*.*', faAnyFile, LocalFile) = 0 then
  repeat
    Application.ProcessMessages;

    if (LocalFile.Name = '.') or (LocalFile.Name = '..') then Continue;   // Не обрабатываем возвраты папок

    // Проверка файлов
    if (LocalFile.Attr and faDirectory) <> faDirectory then begin

      Inc(FilesCounter);

      // Если файл отсуствует, то копируем, а если во вторичной папке есть этот файл, то переименовываем
      if not FileExists(RemoteFolder + LocalFile.Name) then begin

        // Проверяем все файлы во вторичной папке, на случай если файл переименовали
        FoundCurrentFile:=false;
        if FindFirst(RemoteFolder + '*.*', faAnyFile, RemoteFile) = 0 then
        repeat
          Application.ProcessMessages;

          // Если время файла, размер совпадает и такого файла нет в первичной папке, то переименовываем файл во вторичной папке
          // Файл переименован
          if (LocalFile.Time = RemoteFile.Time) and (LocalFile.Size = RemoteFile.Size) and (FileExists(LocalFolder + RemoteFile.Name) = false) then begin
            //Actions.Add('RENAME ' + RemoteFolder + RemoteFile.Name + #9 + RemoteFolder + LocalFile.Name);
            AddFSAction(ID_OPERATION_RENAME, RemoteFolder + RemoteFile.Name, RemoteFolder + LocalFile.Name, 0, 0);
            // Добавляем в список игнориемых файлов, чтобы он не удалился (до переименования)
            ExcludeRenameFiles.Add(RemoteFolder + RemoteFile.Name);
            StatusText(IDS_FILE_RENAMED + ' ' + LocalFolder + LocalFile.Name, LocalFolder + LocalFile.Name);
            FoundCurrentFile:=true;
            Break;
          end;

        until FindNext(RemoteFile) <> 0;
        FindClose(RemoteFile);

        // Если во вторичной папке схожих файлов не найдено, то просто копируем новый файл
        // Найден новый файл
        if FoundCurrentFile = false then begin
          //Actions.Add('COPY ' + LocalFolder + LocalFile.Name + #9 + RemoteFolder + LocalFile.Name);
          AddFSAction(ID_OPERATION_COPY, LocalFolder + LocalFile.Name, RemoteFolder + LocalFile.Name, LocalFile.Size, LocalFile.Time);
          StatusText(IDS_FOUND_NEW_FILE + ' ' + LocalFolder + LocalFile.Name, LocalFolder + LocalFile.Name);
        end;

      // Если файл есть
      end else if FindFirst(RemoteFolder + LocalFile.Name, faAnyFile, RemoteFile) = 0 then begin

          // Если время файла или размер не совпадает, то копируем
          // Файл обновлён
          if (LocalFile.Time <> RemoteFile.Time) or (LocalFile.Size <> RemoteFile.Size) then begin
            //Actions.Add('COPY ' + LocalFolder + LocalFile.Name + #9 + RemoteFolder + LocalFile.Name);
            AddFSAction(ID_OPERATION_COPY, LocalFolder + LocalFile.Name, RemoteFolder + LocalFile.Name, LocalFile.Size, LocalFile.Time);
            StatusText(IDS_FILE_UPDATED + ' ' + LocalFolder + LocalFile.Name, LocalFolder + LocalFile.Name);
          end;

          FindClose(RemoteFile);
      end;

    // Проверка папок
    end else begin
      // Создаём папку если её не существует и её нет в списке игнорируемых
      if (not DirectoryExists(RemoteFolder + LocalFile.Name)) and (Pos(LocalFolder + LocalFile.Name, ExcludePaths.Text) = 0) then
        //Actions.Add('MKDIR ' + RemoteFolder + LocalFile.Name);
        AddFSAction(ID_OPERATION_MKDIR, RemoteFolder + LocalFile.Name, '', 0, 0);

      // Сравниваем файлы
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

  // Игнорируемые папки
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

        // Проверяем наличие файлов и исключаем файлы для переименования
        // Найден старый файл
        if (FileExists(LocalFolder + RemoteFile.Name) = false) and (Pos(RemoteFolder + RemoteFile.Name, ExcludeRenameFiles.Text) = 0) then begin
          //Actions.Add('DELETE ' + RemoteFolder + RemoteFile.Name);
          AddFSAction(ID_OPERATION_DELETE, RemoteFolder + RemoteFile.Name, '', RemoteFile.Size, RemoteFile.Time);
          StatusText(IDS_FOUND_OLD_FILE + ' ' + RemoteFolder + RemoteFile.Name, RemoteFolder + RemoteFile.Name);
        end;

      end else begin
        CheckRemoteFilesToRemove(LocalFolder + RemoteFile.Name, RemoteFolder + RemoteFile.Name);

        // После проверки файлов проверяем наличие папки
        if not DirectoryExists(LocalFolder + RemoteFile.Name) then
          //Actions.Add('RMDIR ' + RemoteFolder + RemoteFile.Name);
          AddFSAction(ID_OPERATION_RMDIR, RemoteFolder + RemoteFile.Name, '', 0, 0);
      end;
    until FindNext(RemoteFile) <> 0;

  FindClose(RemoteFile);
end;

// Сравнение двух файлов на соотвествие, по дате и размеру
{function CompareFileIdentity(FirstFilePath, SecondFilePath: string): boolean;
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
end;}

procedure TMain.CheckRemoteFilesToMove; // Если файл был перемещён в другую папку, то перемещаем файл, а не удаляем и копируем снова
var
  i, j: integer;
  //ActionStr, DeleteFilePath, FirstCopyFilePath, SecondCopyFilePath: string;
begin
  //if Actions.Count = 0 then Exit;
  if FSActions.Count = 0 then Exit;
  StatusText(IDS_CHECK_MOVE_FILES, IDS_CHECK_MOVE_FILES);

  ProgressBar.Max:=FSActions.Count;

  for i:=0 to FSActions.Count - 1 do begin
  //for i:=0 to Actions.Count - 1 do begin
    if StopRequest then Break;

    if FSActions[i].ActionType = ID_OPERATION_DELETE then begin
		//if Copy(Actions.Strings[i], 1, 7) = 'DELETE ' then begin
      //ActionStr:=Actions.Strings[i];
		  //Delete(ActionStr, 1, 7);
      //DeleteFilePath:=ActionStr;

      for j:=0 to FSActions.Count - 1 do begin
      //for j:=0 to Actions.Count - 1 do begin
        Application.ProcessMessages;
        if i = j then Continue; // Пропускаем DELETE

        // Ищем копируемые файлы
        if FSActions[j].ActionType = ID_OPERATION_COPY then begin
        //if Copy(Actions.Strings[j], 1, 5) = 'COPY ' then begin
          //ActionStr:=Actions.Strings[j];
          //Delete(ActionStr, 1, 5);

          //FirstCopyFilePath:=Copy(ActionStr, 1, Pos(#9, ActionStr) - 1);
          //SecondCopyFilePath:=Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr));

          // Сравнение двух файлов на соотвествие, по дате и размеру
          //if CompareFileIdentity(DeleteFilePath, FirstCopyFilePath) then begin
          //if CompareFileIdentity(FSActions[i].FirstPath, FSActions[j].FirstPath) then begin // новое

          if (FSActions[i].FirstFileTime = FSActions[j].FirstFileTime) and (FSActions[i].FirstFileSize = FSActions[j].FirstFileSize) then begin

            EdiTFSAction(j, ID_OPERATION_MOVE, FSActions[i].FirstPath, FSActions[j].SecondPath);
            EdiTFSAction(i, ID_OPERATION_NONE, '', '');

            //Actions.Strings[j]:='MOVE ' + DeleteFilePath + #9 + SecondCopyFilePath;
            //Actions.Strings[i]:='FIXED';
            Break;
          end;
        end;

      end;
    end;
    ProgressBar.Position:=i + 1; // Отображаем прогресс
  end;

  // Убираем исправленные действия
  //Actions.Text:=StringReplace(Actions.Text, 'FIXED' + #13#10, '', [rfReplaceAll]);

  // Пропуск ID_OPERATION_NONE в конце быстрее, чем удаление
  {for i:=FSActions.Count - 1 downto 0 do
    if FSActions[i].ActionType = ID_OPERATION_NONE then
      FSActions.Delete(i);}

  ProgressBar.Position:=0;
end;

procedure TMain.SelectAllBtnClick(Sender: TObject);
var
  i: integer;
  Item: TListItem;
begin
  for i:=0 to ListView.Items.Count - 1 do begin
    Item:=ListView.Items.Item[i];
    Item.Checked:=true;
  end;
end;

procedure ActionsRun;
var
  i: integer; //ActionStr: string;
begin
  Main.ProgressBar.Max:=FSActions.Count;
  //for i:=0 to Actions.Count - 1 do begin
  for i:=0 to FSActions.Count - 1 do begin

    Main.ProgressBar.Position:=i + 1;

    if StopRequest then Break;

    //ActionStr:=Actions.Strings[i];

    //if Copy(Actions.Strings[i], 1, 5) = 'COPY ' then begin
    case FSActions[i].ActionType of
    ID_OPERATION_COPY: begin
      //Delete(ActionStr, 1, 5);
      try
        //StatusText(ID_COPY_FILE + ' ' + Copy(ActionStr, 1, Pos(#9, ActionStr) - 1));
        StatusText(IDS_COPY_FILE + ' ' + FSActions[i].FirstPath, FSActions[i].FirstPath);
        //if CopyFile( PChar( Copy(ActionStr, 1, Pos(#9, ActionStr) - 1) ),
        //             PChar( Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr)) ), false) then begin
        if CPFile( FSActions[i].FirstPath, FSActions[i].SecondPath ) then begin
          Inc(GoodCopyFilesCounter);
          EdiTFSAction(i, ID_OPERATION_NONE, '', '');
          //Actions.Strings[i]:='';
        end else
          Inc(BadCopyFilesCounter);
        Application.ProcessMessages;
      except
        Inc(BadCopyFilesCounter);
      end;
    end;

    //if Copy(Actions.Strings[i], 1, 5) = 'MOVE ' then begin
    ID_OPERATION_MOVE: begin
      //Delete(ActionStr, 1, 5);
      try
        //StatusText(ID_MOVE_FILE + ' ' + Copy(ActionStr, 1, Pos(#9, ActionStr) - 1));
        StatusText(IDS_MOVE_FILE + ' ' + FSActions[i].FirstPath, FSActions[i].FirstPath);
        //if FileExists( Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr)) ) then
        if FileExists( FSActions[i].SecondPath ) then // Если старый, конечный файл существует, то удаляем его перед перемещением нового
          //DeleteFile( Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr)) );
          DeleteFile( FSActions[i].SecondPath );
        //if MoveFile( PChar( Copy(ActionStr, 1, Pos(#9, ActionStr) - 1) ),
        if MoveFile( PChar( FSActions[i].FirstPath ),
        //PChar( Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr)) ) ) then begin
                     PChar( FSActions[i].SecondPath ) ) then begin
          Inc(GoodMoveFilesCounter);
          //Actions.Strings[i]:='';
          EdiTFSAction(i, ID_OPERATION_NONE, '', '');
        end else
          Inc(BadMoveFilesCounter);
      except
        Inc(BadMoveFilesCounter);
      end;
    end;

    //if Copy(Actions.Strings[i], 1, 7) = 'RENAME ' then begin
    ID_OPERATION_RENAME: begin
      //Delete(ActionStr, 1, 7);
      try
        //StatusText(ID_RENAME_FILE + ' ' + Copy(ActionStr, 1, Pos(#9, ActionStr) - 1));
        StatusText(IDS_RENAME_FILE + ' ' + FSActions[i].FirstPath, FSActions[i].FirstPath);
        // if RenameFile( PChar( Copy(ActionStr, 1, Pos(#9, ActionStr) - 1) ),
        //             PChar( Copy(ActionStr, Pos(#9, ActionStr) + 1, Length(ActionStr)) ) ) then begin
        if RenameFile( PChar( FSActions[i].FirstPath ),
                     PChar( FSActions[i].SecondPath ) ) then begin
          Inc(GoodRenameFilesCounter);
          //Actions.Strings[i]:='';
          EdiTFSAction(i, ID_OPERATION_NONE, '', '');
        end else
          Inc(BadRenameFilesCounter);
      except
        Inc(BadRenameFilesCounter);
      end;
    end;

    //if Copy(Actions.Strings[i], 1, 7) = 'DELETE ' then begin
    ID_OPERATION_DELETE: begin
      //Delete(ActionStr, 1, 7);
        try
          //StatusText(ID_REMOVE_FILE + ' ' + ActionStr);
          StatusText(IDS_REMOVE_FILE + ' ' + FSActions[i].FirstPath, FSActions[i].FirstPath);
          //if DeleteFile(ActionStr) then begin
          if DeleteFile(FSActions[i].FirstPath) then begin
            Inc(GoodDeleteFilesCounter);
            //Actions.Strings[i]:='';
            EdiTFSAction(i, ID_OPERATION_NONE, '', '');
          end else
            Inc(BadDeleteFilesCounter);
        except
          Inc(BadDeleteFilesCounter);
        end;
      end;

    //if Copy(Actions.Strings[i], 1, 6) = 'MKDIR ' then begin
      ID_OPERATION_MKDIR: begin
        //Delete(ActionStr, 1, 6);
        try
          //StatusText(ID_CREATE_FOLDER + ' ' + ActionStr);
          StatusText(IDS_CREATE_FOLDER + ' ' + FSActions[i].FirstPath, FSActions[i].FirstPath);
          //if CreateDir(ActionStr) then begin
          if CreateDir(FSActions[i].FirstPath) then begin
            Inc(GoodMakeFoldersCounter);
            //Actions.Strings[i]:='';
            EdiTFSAction(i, ID_OPERATION_NONE, '', '');
          end else
            Inc(BadMakeFoldersCounter);
        except
          Inc(BadMakeFoldersCounter);
        end;
      end;

      //if Copy(Actions.Strings[i], 1, 6) = 'RMDIR ' then begin
      ID_OPERATION_RMDIR: begin
        //Delete(ActionStr, 1, 6);
        try
          //StatusText(ID_REMOVE_FOLDER + ' ' + ActionStr);
          StatusText(IDS_REMOVE_FOLDER + ' ' + FSActions[i].FirstPath, FSActions[i].FirstPath);
          //if RemoveDir(ActionStr) then begin
          if RemoveDir(FSActions[i].FirstPath) then begin
            Inc(GoodRemoveFoldersCounter);
            //Actions.Strings[i]:='';
            EdiTFSAction(i, ID_OPERATION_NONE, '', '');
          end else
          Inc(BadRemoveFoldersCounter);
        except
          Inc(BadRemoveFoldersCounter);
        end;
      end;
    end;

    if StopRequest then Main.ProgressBar.Position:=0;
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
  LangFileName: string; LangFile: TLangFile;
begin
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  CheckLogShow:=Ini.ReadBool('Main', 'LookTasks', true);
  OpenDialog.InitialDir:=Ini.ReadString('Main', 'BackupFilesFolder', '');
  CRCCopyCheck:=Ini.ReadBool('Main', 'CRCCopyCheck', false);
  WriteCreationDate:=Ini.ReadBool('Main', 'WriteCreationDate', false);
  WriteAttributes:=Ini.ReadBool('Main', 'WriteAttributes', false);
  Ini.Free;

  //Width:=588;
  //Height:=424;

  // Перевод
  LangFileName:=GetLocaleInformation(LOCALE_SENGLANGUAGE) + '.txt';
  if not FileExists(ExtractFilePath(ParamStr(0)) + 'Languages\' + LangFileName) then
    LangFileName:='English.txt';
  //LangFileName:='English.txt';
  //LangFileName:='Chinese.txt';
  //LangFileName:='Spanish.txt';
  //LangFileName:='Portuguese.txt';
  //LangFileName:='French.txt';
  //LangFileName:='German.txt';
  //LangFileName:='Japanese.txt';
  //LangFileName:='Italian.txt';
  //LangFileName:='Korean.txt';

  LangFile:=TLangFile.Create(ExtractFilePath(ParamStr(0)) + 'Languages\' + LangFileName);
  try
    ListView.Columns[0].Caption:=LangFile.GetString('ACTIVE', '');
    ListView.Columns[1].Caption:=LangFile.GetString('NAME', '');
    ListView.Columns[2].Caption:=LangFile.GetString('LEFT_FOLDER', '');
    ListView.Columns[3].Caption:=LangFile.GetString('RIGHT_FOLDER', '');
    RemSelectionBtn.Caption:=LangFile.GetString('REM_SELECTION', '');
    SelectAllBtn.Caption:=LangFile.GetString('SELECT_ALL', '');
    MoveBtn.Caption:=LangFile.GetString('MOVE', '');
    UpBtn.Caption:=LangFile.GetString('UP', '');
    DownBtn.Caption:=LangFile.GetString('DOWN', '');
    FileBtn.Caption:=LangFile.GetString('FILE', '');
    OpenFolderBtn.Caption:=LangFile.GetString('OPEN', '');
    LeftFolderBtn.Caption:=LangFile.GetString('LEFT_FOLDER', '');
    RightFolderBtn.Caption:=LangFile.GetString('RIGHT_FOLDER', '');
    RunBtn.Caption:=LangFile.GetString('RUN', '');
    CreateBtn.Caption:=LangFile.GetString('CREATE', '');
    OpenBtn.Caption:=OpenFolderBtn.Caption;
    OpenBtn2.Caption:=OpenBtn.Caption;
    ExitBtn.Caption:=LangFile.GetString('EXIT', '');
    FoldersBtn.Caption:=LangFile.GetString('FOLDERS', '');
    AddBtn.Caption:=LangFile.GetString('ADD', '');
    AddBtn2.Caption:=AddBtn.Caption;
    EditBtn.Caption:=LangFile.GetString('EDIT', '');
    EditBtn2.Caption:=EditBtn.Caption;
    RemBtn.Caption:=LangFile.GetString('REMOVE', '');
    RemBtn2.Caption:=RemBtn.Caption;
    ExcludeBtn.Caption:=LangFile.GetString('EXCLUDE', '');
    StopBtn.Caption:=LangFile.GetString('STOP', '');
    AllOperationsLbl.Caption:=LangFile.GetString('ALL_OPERATIONS', '');
    CurOperationLbl.Caption:=LangFile.GetString('CURRENT_OPERATION', '');
    HelpBtn.Caption:=LangFile.GetString('HELP', '');
    OpenDialog.Filter:=LangFile.GetString('FILE_DIALOG_FILTER', '');
    SaveDialog.Filter:=OpenDialog.Filter;
    SaveDialog.DefaultExt:=SaveDialog.Filter;

    IDS_VIEW_TASKS:=LangFile.GetString('VIEW_TASKS', '');
    SettingsBtn.Caption:=LangFile.GetString('SETTINGS', '');
    IDS_CHECKSUM_VERIFICATION_COPY:=LangFile.GetString('CHECKSUM_VERIFICATION_COPY', '');
    IDS_COPY_CREATION_DATE:=LangFile.GetString('COPY_CREATION_DATE', '');
    IDS_COPY_FILE_ATTRIBUTES:=LangFile.GetString('COPY_FILE_ATTRIBUTES', '');

    IDS_LOOKING_CHANGES:=LangFile.GetString('LOOKING_CHANGES', '');
    IDS_FILE_RENAMED:=LangFile.GetString('FILE_RENAMED', '');
    IDS_FOUND_NEW_FILE:=LangFile.GetString('FOUND_NEW_FILE', '');
    IDS_FILE_UPDATED:=LangFile.GetString('FILE_UPDATED', '');
    IDS_FOUND_OLD_FILE:=LangFile.GetString('FOUND_OLD_FILE', '');
    IDS_COPY_FILE:=LangFile.GetString('COPY_FILE', '');
    IDS_MOVE_FILE:=LangFile.GetString('MOVE_FILE', '');
    IDS_RENAME_FILE:=LangFile.GetString('RENAME_FILE', '');
    IDS_REMOVE_FILE:=LangFile.GetString('REMOVE_FILE', '');
    IDS_CREATE_FOLDER:=LangFile.GetString('CREATE_FOLDER', '');
    IDS_REMOVE_FOLDER:=LangFile.GetString('REMOVE_FOLDER', '');
    IDS_CHECK_MOVE_FILES:=LangFile.GetString('CHECK_MOVE_FILES', '');
    IDS_COMPLETED:=LangFile.GetString('COMPLETED', '');
    IDS_COMPLETED_ERROR:=LangFile.GetString('COMPLETED_ERROR', '');
    IDS_BACKUP_COMPLETED:=LangFile.GetString('BACKUP_COMPLETED', '');
    IDS_BACKUP_FAILED:=LangFile.GetString('BACKUP_FAILED', '');
    IDS_CHECK_FILES:=LangFile.GetString('CHECK_FILES', '');
    IDS_TOTAL_OPERATIONS:=LangFile.GetString('TOTAL_OPERATIONS', '');
    IDS_SUCCESS_COPY_FILES:=LangFile.GetString('SUCCESS_COPY_FILES', '');
    IDS_SUCCESS_MOVE_FILES:=LangFile.GetString('SUCCESS_MOVE_FILES', '');
    IDS_SUCCESS_RENAME_FILES:=LangFile.GetString('SUCCESS_RENAME_FILES', '');
    IDS_SUCCESS_REMOVE_FILES:=LangFile.GetString('SUCCESS_REMOVE_FILES', '');
    IDS_SUCCESS_CREATE_FOLDERS:=LangFile.GetString('SUCCESS_CREATE_FOLDERS', '');
    IDS_SUCCESS_REMOVE_FOLDERS:=LangFile.GetString('SUCCESS_REMOVE_FOLDERS', '');
    IDS_FAIL_COPY_FILES:=LangFile.GetString('FAIL_COPY_FILES', '');
    IDS_FAIL_MOVE_FILES:=LangFile.GetString('FAIL_MOVE_FILES', '');
    IDS_FAIL_RENAME_FILES:=LangFile.GetString('FAIL_RENAME_FILES', '');
    IDS_FAIL_REMOVE_FILES:=LangFile.GetString('FAIL_REMOVE_FILES', '');
    IDS_FAIL_CREATE_FOLDERS:=LangFile.GetString('FAIL_CREATE_FOLDERS', '');
    IDS_FAIL_REMOVE_FOLDERS:=LangFile.GetString('FAIL_REMOVE_FOLDERS', '');

    IDS_PERFORM_OPERATIONS:=LangFile.GetString('PERFORM_OPERATIONS', '');
    IDS_ENTER_NAME_PAIR_FOLDERS:=LangFile.GetString('ENTER_NAME_PAIR_FOLDERS', '');
    IDS_CHOOSE_LEFT_FOLDER:=LangFile.GetString('CHOOSE_LEFT_FOLDER', '');
    IDS_CHOOSE_RIGHT_FOLDER:=LangFile.GetString('CHOOSE_RIGHT_FOLDER', '');
    IDS_CHOOSE_FOLDER_ERROR:=LangFile.GetString('CHOOSE_FOLDER_ERROR', '');
    IDS_SUCCESS_NOTIFICATION_MESSAGE:=LangFile.GetString('SUCCESS_NOTIFICATION_MESSAGE', '');
    IDS_FAIL_NOTIFICATION_MESSAGE:=LangFile.GetString('FAIL_NOTIFICATION_MESSAGE', '');

    IDS_ABOUT_TITLE:=LangFile.GetString('ABOUT_TITLE', '');
    IDS_LAST_UPDATE:=LangFile.GetString('LAST_UPDATE', '');

    IDS_EXCLUDE_TITLE:=LangFile.GetString('EXCLUDE_TITLE', '');
    IDS_SELECT_EXCLUDE_FOLDER:=LangFile.GetString('SELECT_EXCLUDE_FOLDER', '');
    IDS_OK:=LangFile.GetString('OK', '');
    IDS_CANCEL:=LangFile.GetString('CANCEL', '');

    AboutBtn.Caption:=IDS_ABOUT_TITLE;

    IDS_SAVE_AS:=LangFile.GetString('SAVE_AS', '');
    IDS_LOGS_FILE_DIALOG_FILTER:=LangFile.GetString('LOGS_FILE_DIALOG_FILTER', '');
    IDS_ADD_PAUSE_TO_FILE:=LangFile.GetString('ADD_PAUSE_TO_FILE', '');
  finally
    LangFile.Free;
  end;

  Application.Title:=Caption;

  for i:=1 to ParamCount do begin
    if ParamStr(i) = '-b' then
      CustomBackupFile:=ParamStr(i + 1);
    if ParamStr(i) = '-s' then
      SilentMode:=true;
  end;

  ExcludePaths:=TStringList.Create; // Создаём до загрузки путей для исключения

  if CustomBackupFile = '' then
    LoadBackupPaths(ExtractFilePath(ParamStr(0)) + BACKUP_PATHS_FILE_NAME)
  else
    LoadBackupPaths(ExtractFilePath(ParamStr(0)) + CustomBackupFile);

  //Actions:=TStringList.Create;
  FSActions:=TList<TFSAction>.Create;
  ExcludeRenameFiles:=TStringList.Create;

  if SilentMode then begin
    NotificationApp:=GetNotificationAppPath;
    RunBtn.Click;
    Halt(0);
  end;
end;

procedure TMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //Actions.Free;
  FSActions.Free;
  ExcludePaths.Free;
  ExcludeRenameFiles.Free;
end;

procedure TMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if SilentMode then Exit;
  StopRequest:=true;
  RequestCloseApp:=true;
  CanClose:=AllowAppClose;
end;

function OutFSActions: string;
var
  i: integer;
  LogLine: string;
begin
  Result:='';
  for i:=0 to FSActions.Count - 1 do
    if FSActions[i].ActionType <> ID_OPERATION_NONE then begin
      LogLine:=FSOperationStr[Integer(FSActions[i].ActionType)] + ' "' + FSActions[i].FirstPath + '"';


      if FSActions[i].SecondPath <> '' then begin
        if FSActions[i].ActionType = ID_OPERATION_RENAME then
          LogLine:=LogLine + ' "' + ExtractFileName(FSActions[i].SecondPath) + '"' // Совместимость с командной строкой
        else
          LogLine:=LogLine + ' "' + FSActions[i].SecondPath + '"';
      end;

      Result:=Result + LogLine + #13#10;
    end;
end;

procedure TMain.RunBtnClick(Sender: TObject);
var
  i: integer;
  Item: TListItem;
  BackupStatusTitle: string;

  SuccessOperationsText, FailOperationsText: string;
begin
  AllowAppClose:=false; // Запрещаем закрытие приложения
  StopRequest:=false;
  ProgressBar.Position:=0;
  RunBtn.Enabled:=false;
  CreateBtn.Enabled:=false;
  OpenBtn.Enabled:=false;
  OpenBtn2.Enabled:=false;
  AddBtn.Enabled:=false;
  AddBtn2.Enabled:=false;
  SettingsBtn.Enabled:=false;
  RemBtn.Enabled:=false;
  RemBtn2.Enabled:=false;
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
  //Actions.Clear;
  FSActions.Clear;
  ExcludeRenameFiles.Clear;

  for i:=0 to ListView.Items.Count - 1 do begin
    Item:=ListView.Items.Item[i];
    if Item.Checked then begin
      CheckFilesDiff(Item.SubItems[1], Item.SubItems[2]);
      CheckRemoteFilesToRemove(Item.SubItems[1], Item.SubItems[2]);
    end;
  end;
  CheckRemoteFilesToMove;

  // Количество операций
  ActionGoodCounter:=FSActions.Count;

  // Если есть операции
  if FSActions.Count > 0 then begin

    // Обычный режим
    if SilentMode = false then begin

      StatusText(IDS_PERFORM_OPERATIONS, IDS_PERFORM_OPERATIONS);

      // Подтверждение выполнения операций
      if CheckLogShow then begin

          // Показываем логи
          LogsForm.Show;

          //LogsForm.LogsMemo.Text:=Actions.Text;
          LogsForm.LogsMemo.Text:=OutFSActions();

          // Подтверждение операции
          case MessageBox(Handle, PChar(IDS_PERFORM_OPERATIONS), PChar(Caption), 35) of
            6: begin
                  // Если окно не закрыто, то закрываем его
                  if LogsForm.Showing then
                    LogsForm.Close;

                  ActionsRun;
               end;

          end;

      // Без подтверждения выполнения операций
      end else
        ActionsRun;

    // Тихий режим
    end else
      ActionsRun;
  end;

  if (BadCopyFilesCounter > 0) or (BadMoveFilesCounter > 0) or (BadDeleteFilesCounter > 0) or (BadMakeFoldersCounter > 0) or (BadRemoveFoldersCounter > 0) then begin
    ProgressBar.Position:=0;
    StatusText(IDS_COMPLETED_ERROR, IDS_COMPLETED_ERROR);
  end else begin
    StatusText(IDS_COMPLETED, IDS_COMPLETED);
    //Actions.Clear;
    FSActions.Clear;
  end;

  RunBtn.Enabled:=true;
  CreateBtn.Enabled:=true;
  OpenBtn.Enabled:=true;
  OpenBtn2.Enabled:=true;
  RunBtn.Enabled:=true;
  AddBtn.Enabled:=true;
  AddBtn2.Enabled:=true;
  SettingsBtn.Enabled:=true;
  RemBtn.Enabled:=true;
  RemBtn2.Enabled:=true;
  ExcludeBtn.Enabled:=true;
  StopBtn.Enabled:=false;
  ProgressBar2.Position:=0;
  AllowAppClose:=true; // Разрешаем закрытие приложения

  if (SilentMode = false) and (RequestCloseApp = false) then begin

    if (BadCopyFilesCounter = 0) and (BadMoveFilesCounter = 0) and (BadDeleteFilesCounter = 0) and (BadRenameFilesCounter = 0) and (BadRemoveFoldersCounter = 0) then
      BackupStatusTitle:=IDS_BACKUP_COMPLETED
    else
      BackupStatusTitle:=IDS_BACKUP_FAILED;

    SuccessOperationsText:='';
    if GoodCopyFilesCounter > 0 then SuccessOperationsText:=IDS_SUCCESS_COPY_FILES + ' ' + IntToStr(GoodCopyFilesCounter) + #13#10;
    if GoodMoveFilesCounter > 0 then SuccessOperationsText:=SuccessOperationsText + IDS_SUCCESS_MOVE_FILES + ' ' + IntToStr(GoodMoveFilesCounter) + #13#10;
    if GoodRenameFilesCounter > 0 then SuccessOperationsText:=SuccessOperationsText + IDS_SUCCESS_RENAME_FILES + ' ' + IntToStr(GoodRenameFilesCounter) + #13#10;
    if GoodDeleteFilesCounter > 0 then SuccessOperationsText:=SuccessOperationsText + IDS_SUCCESS_REMOVE_FILES + ' ' + IntToStr(GoodDeleteFilesCounter) + #13#10;
    if GoodMakeFoldersCounter > 0 then SuccessOperationsText:=SuccessOperationsText + IDS_SUCCESS_CREATE_FOLDERS + ' ' + IntToStr(GoodMakeFoldersCounter) + #13#10;
    if GoodRemoveFoldersCounter > 0 then SuccessOperationsText:=SuccessOperationsText + IDS_SUCCESS_REMOVE_FOLDERS + ' ' + IntToStr(GoodRemoveFoldersCounter);
    if SuccessOperationsText <> '' then SuccessOperationsText:=#13#10#13#10 + Trim(SuccessOperationsText);
    
    FailOperationsText:='';
    if BadCopyFilesCounter > 0 then FailOperationsText:=FailOperationsText + IDS_FAIL_COPY_FILES + ' ' + IntToStr(BadCopyFilesCounter) + #13#10;
    if BadMoveFilesCounter > 0 then FailOperationsText:=FailOperationsText + IDS_FAIL_MOVE_FILES + ' ' + IntToStr(BadMoveFilesCounter) + #13#10;
    if BadRenameFilesCounter > 0 then FailOperationsText:=FailOperationsText + IDS_FAIL_RENAME_FILES + ' ' + IntToStr(BadRenameFilesCounter) + #13#10;
    if BadDeleteFilesCounter > 0 then FailOperationsText:=FailOperationsText + IDS_FAIL_REMOVE_FILES + ' ' + IntToStr(BadDeleteFilesCounter) + #13#10;
    if BadMakeFoldersCounter > 0 then FailOperationsText:=FailOperationsText + IDS_FAIL_CREATE_FOLDERS + ' ' + IntToStr(BadMakeFoldersCounter) + #13#10;
    if BadRemoveFoldersCounter > 0 then FailOperationsText:=FailOperationsText + IDS_FAIL_REMOVE_FOLDERS + ' ' + IntToStr(BadRemoveFoldersCounter);
    if FailOperationsText <> '' then FailOperationsText:=#13#10#13#10 + Trim(FailOperationsText);
    
    Application.MessageBox(PChar(BackupStatusTitle + #13#10 + #13#10 +
                                 IDS_CHECK_FILES + ' ' + IntToStr(FilesCounter) + #13#10 + IDS_TOTAL_OPERATIONS + ' ' + IntToStr(ActionGoodCounter) +
                                 SuccessOperationsText + FailOperationsText ),
                            PChar(Caption), MB_ICONINFORMATION or MB_TOPMOST);
    
    {Application.MessageBox(PChar(BackupStatusTitle + #13#10 + #13#10 +
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
                            PChar(Caption), MB_ICONINFORMATION or MB_TOPMOST);}

    if FSActions.Count > 0 then begin // Выводим проблемные операции
      LogsForm.Show;
      //for i:=Actions.Count - 1 downto 0 do
        //if Actions.Strings[i] = '' then
          //Actions.Delete(i);
      //LogsForm.LogsMemo.Text:=Actions.Text;

      LogsForm.LogsMemo.Text:=OutFSActions();

    end;



  end else if Trim(NotificationApp) <> '' then begin

    if (BadCopyFilesCounter = 0) and (BadMoveFilesCounter = 0) and (BadDeleteFilesCounter = 0) and (BadRenameFilesCounter = 0) and (BadRemoveFoldersCounter = 0) then
      ShellExecute(0, 'open', PChar(NotificationApp), PChar('-t "' + Caption + '" -d "' + IDS_SUCCESS_NOTIFICATION_MESSAGE + '" -b EchoBackaper.png -c 1'), nil, SW_SHOWNORMAL)
    else
      ShellExecute(0, 'open', PChar(NotificationApp), PChar('-t "' + Caption + '" -d "' + IDS_FAIL_NOTIFICATION_MESSAGE + '" -b EchoBackaper.png -c 1'), nil, SW_SHOWNORMAL);
  end;

  if RequestCloseApp then Close;
end;

function TMain.BrowseFolderDialog(Title: PChar; Flags: Cardinal): string;
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
  BrowseInfo.ulFlags:=Flags; // BIF_RETURNONLYFSDIRS
  lpItemId:=shBrowseForFolder(BrowseInfo);
  if lpItemId <> nil then begin
    shGetPathFromIdList(lpItemId, TempPath);
    Result:=TempPath;
    GlobalFreePtr(lpItemId);
  end;
end;

procedure TMain.OpenBtn2Click(Sender: TObject);
begin
  OpenBtn.Click;
end;

procedure TMain.OpenBtnClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  if not OpenDialog.Execute then Exit;
  LoadBackupPaths(OpenDialog.FileName);
  Ini:=TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'Config.ini');
  Ini.WriteString('Main', 'BackupFilesFolder', ExtractFilePath(OpenDialog.FileName)); // Сохраняем последний выбранный каталог
  Ini.Free;
end;

procedure TMain.CreateBtnClick(Sender: TObject);
begin
   if SaveDialog.Execute then begin
    CurrentBackupFilePath:=SaveDialog.FileName;
    // Очищаем текущие пути
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
  // Очищаем текущие пути
  ListView.Clear;
  ExcludePaths.Clear;

  BackupPaths:=TStringList.Create;
  LoadExcludePaths:=false;

  if FileExists(FileName) then begin
    BackupPaths.LoadFromFile(FileName);

    // Сохраняем текущий путь для сохранения
    CurrentBackupFilePath:=FileName;
  end else
    // Если файл не найден, то читаем дефолтный файл
    CurrentBackupFilePath:=ExtractFilePath(ParamStr(0)) + BACKUP_PATHS_FILE_NAME;


  for i:=1 to BackupPaths.Count - 1 do begin // Первая строка зарезервирована под "PAIR FOLDERS:"
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

procedure TMain.EditBtn2Click(Sender: TObject);
begin
  EditBtn.Click;
end;

procedure TMain.EditBtnClick(Sender: TObject);
var
  Item: TListItem; NameFolders, LeftFolder, RightFolder: string;
begin
  if ListView.ItemIndex = -1 then Exit;
  Item:=ListView.Items.Item[ListView.ItemIndex];

  NameFolders:=InputBox(Caption, IDS_ENTER_NAME_PAIR_FOLDERS, Item.SubItems[0]);

  if Trim(NameFolders) <> '' then begin
    LeftFolder:=BrowseFolderDialog(PChar(IDS_CHOOSE_LEFT_FOLDER), BIF_RETURNONLYFSDIRS);

    if LeftFolder <> '' then
      Item.SubItems[1]:=LeftFolder;

    RightFolder:=BrowseFolderDialog(PChar(IDS_CHOOSE_RIGHT_FOLDER), BIF_RETURNONLYFSDIRS or BIF_USENEWUI);
    if RightFolder <> '' then
      Item.SubItems[2]:=RightFolder;

    Item.SubItems[0]:=NameFolders;
    SaveBackupPaths;
  end else
    Exit; // Выходим если название не введено
end;

procedure TMain.ExcludeBtnClick(Sender: TObject);
begin
  ExcludeFoldersForm.ShowModal;
end;

procedure TMain.ExitBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TMain.SaveBackupPaths;
var
  i: integer;
  Item: TListItem;
  BackupPaths: TStringList;
begin
  BackupPaths:=TStringList.Create;

  // Добавляем связанные папки
  BackupPaths.Add(PAIR_FOLDERS_FILE);
  for i:=0 to ListView.Items.Count - 1 do begin
    Item:=ListView.Items.Item[i];
    BackupPaths.Add(Item.SubItems[0]+ #9 + Item.SubItems[1] + #9 + Item.SubItems[2]);
  end;

  // Добавляем исключённые пути
  BackupPaths.Add(EXCLUDE_PATHS_FILE);
  BackupPaths.Add(Trim(ExcludePaths.Text));

  BackupPaths.SaveToFile(CurrentBackupFilePath); // Сохраняем в текущий открытый файл
  BackupPaths.Free;
end;

procedure TMain.SettingsBtnClick(Sender: TObject);
begin
  Settings.ShowModal;
end;

procedure TMain.AddBtn2Click(Sender: TObject);
begin
  AddBtn.Click;
end;

procedure TMain.AddBtnClick(Sender: TObject);
var
  Item: TListItem; NameFolders, LeftFolder, RightFolder: string;
begin
  NameFolders:='';
  LeftFolder:='';
  RightFolder:='';

  InputQuery(Caption, IDS_ENTER_NAME_PAIR_FOLDERS, NameFolders);

  if Trim(NameFolders) <> '' then begin
    LeftFolder:=BrowseFolderDialog(PChar(IDS_CHOOSE_LEFT_FOLDER), BIF_RETURNONLYFSDIRS);

    if LeftFolder <> '' then
      RightFolder:=BrowseFolderDialog(PChar(IDS_CHOOSE_RIGHT_FOLDER), BIF_RETURNONLYFSDIRS or BIF_USENEWUI);
  end else
    Exit; // Выходим если название не введено

  if (LeftFolder <> '') and (RightFolder <> '') then begin
    Item:=Main.ListView.Items.Add;
    Item.Caption:='';
    Item.SubItems.Add(NameFolders);
    Item.SubItems.Add(LeftFolder);
    Item.SubItems.Add(RightFolder);
    Item.Checked:=true;
    SaveBackupPaths;
  end else
    Application.MessageBox(PChar(IDS_CHOOSE_FOLDER_ERROR), PChar(Caption), MB_ICONWARNING);
end;

procedure TMain.RemBtn2Click(Sender: TObject);
begin
  RemBtn.Click;
end;

procedure TMain.RemBtnClick(Sender: TObject);
begin
  if ListView.ItemIndex <> -1 then begin
    ListView.DeleteSelected;
    SaveBackupPaths;
  end;
end;

procedure TMain.RemSelectionBtnClick(Sender: TObject);
var
  i: integer;
  Item: TListItem;
begin
  for i:=0 to ListView.Items.Count - 1 do begin
    Item:=ListView.Items.Item[i];
    Item.Checked:=false;
  end;
end;

procedure TMain.RightFolderBtnClick(Sender: TObject);
var
  Item: TListItem;
begin
  if ListView.ItemIndex = -1 then Exit;
  Item:=ListView.Items.Item[ListView.ItemIndex];
  ShellExecute(0, 'open', 'explorer', PChar('/select, "' + Item.SubItems[2] + '"'), nil, SW_SHOW);
end;

procedure TMain.LeftFolderBtnClick(Sender: TObject);
var
  Item: TListItem;
begin
  if ListView.ItemIndex = -1 then Exit;
  Item:=ListView.Items.Item[ListView.ItemIndex];
  ShellExecute(0, 'open', 'explorer', PChar('/select, "' + Item.SubItems[1] + '"'), nil, SW_SHOW);
end;

procedure TMain.ListViewDblClick(Sender: TObject);
var
  Item: TListItem;
begin
  if ListView.ItemIndex = -1 then Exit;
  Item:=ListView.Items.Item[ListView.ItemIndex];
  Application.MessageBox(PChar(ListView.Columns[2].Caption + ': ' + Item.SubItems[1] + #13#10 + ListView.Columns[3].Caption + ': ' + Item.SubItems[2]), PChar(Item.SubItems[0]), MB_ICONINFORMATION);
end;

procedure TMain.ListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then begin
    RemBtn.Click;
    SaveBackupPaths;
  end;
end;

procedure TMain.ListViewMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    ListViewPM.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TMain.StopBtnClick(Sender: TObject);
begin
  StopRequest:=true;
end;

procedure TMain.UpBtnClick(Sender: TObject);
var
  ItemDown, ItemUp: TListItem;
  ItemUpTitle, ItemUpPairFolders: string;
begin
  if ListView.ItemIndex > 0 then begin
    ItemUp:=ListView.Items.Item[ListView.ItemIndex - 1];
    ItemDown:=ListView.Items.Item[ListView.ItemIndex];

    ItemUpTitle:=ItemUp.Caption;
    ItemUpPairFolders:=ItemUp.SubItems.Text;

    ItemUp.Caption:=ItemDown.Caption;
    ItemUp.SubItems.Text:=ItemDown.SubItems.Text;

    ItemDown.Caption:=ItemUpTitle;
    ItemDown.SubItems.Text:=ItemUpPairFolders;

    ListView.ItemIndex:=ListView.ItemIndex - 1;

    SaveBackupPaths;
  end;
end;

procedure TMain.DownBtnClick(Sender: TObject);
var
  ItemDown, ItemUp: TListItem;
  ItemUpTitle, ItemUpPairFolders: string;
begin
  if (ListView.ItemIndex <> -1) and (ListView.ItemIndex < ListView.Items.Count - 1) then begin

    ItemUp:=ListView.Items.Item[ListView.ItemIndex];
    ItemDown:=ListView.Items.Item[ListView.ItemIndex + 1];

    ItemUpTitle:=ItemUp.Caption;
    ItemUpPairFolders:=ItemUp.SubItems.Text;

    ItemUp.Caption:=ItemDown.Caption;
    ItemUp.SubItems.Text:=ItemDown.SubItems.Text;

    ItemDown.Caption:=ItemUpTitle;
    ItemDown.SubItems.Text:=ItemUpPairFolders;

    ListView.ItemIndex:=ListView.ItemIndex + 1;

    SaveBackupPaths;
  end;
end;

procedure TMain.AboutBtnClick(Sender: TObject);
begin
  Application.MessageBox(PChar(Caption + ' 1.0.2' + #13#10 +
  IDS_LAST_UPDATE + ' 04.01.25' + #13#10 +
  'https://r57zone.github.io' + #13#10 +
  'r57zone@gmail.com'), PChar(IDS_ABOUT_TITLE), MB_ICONINFORMATION);
end;

end.
