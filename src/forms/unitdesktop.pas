unit UnitDesktop;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, FileUtil, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ActnList, Menus, ExtCtrls, StdCtrls, ShellCtrls;

type

  { TDesktop }

  TDesktop = class(TForm)
    ActAbrir: TAction;
    ActParar: TAction;
    ActPlay: TAction;
    ActSalvarTudo: TAction;
    ActSalvar: TAction;
    ActSair: TAction;
    ActNovo: TAction;
    Actions: TActionList;
    GBProjeto: TGroupBox;
    GBConsole: TGroupBox;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MemoConsole: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    LCtrlPanel: TPanel;
    PageControl1: TPageControl;
    PnBottom: TPanel;
    ToolBar1: TToolBar;
    BtnNovo: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ProjetoTree: TTreeView;
    procedure ActSairExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    ProjetoPath, LovePath : String;
    IniConfig : TIniFile;
    procedure popularTreeProjeto;
  public

  end;

var
  Desktop: TDesktop;

implementation

{$R *.lfm}

{ TDesktop }

procedure TDesktop.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Application.Terminate;
end;

procedure TDesktop.FormCreate(Sender: TObject);
begin
  IniConfig   := TIniFile.Create(GetCurrentDir + '\Config.ini');
  ProjetoPath := IniConfig.ReadString('Project','Path','');
  LovePath := IniConfig.ReadString('Love2d','Path','');

  popularTreeProjeto;
end;

procedure TDesktop.popularTreeProjeto;
var arquivo : TSearchRec;
begin
  FindFirst(ProjetoPath, faAnyFile, arquivo);
  ProjetoTree.Items.Add(nil, arquivo.Name);
  while FindNext(arquivo) <> 0 do
  begin
    ProjetoTree.Items.Add(nil, arquivo.Name);
  end;
end;

procedure TDesktop.ActSairExecute(Sender: TObject);
begin
  Close;
end;

end.

