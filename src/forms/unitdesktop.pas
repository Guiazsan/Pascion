unit UnitDesktop;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, process, strutils, FileUtil, Forms,
  Controls, Graphics, Dialogs, ComCtrls, ActnList, Menus, ExtCtrls, StdCtrls,
  UnitLuaEditor, UnitVariaveisGlobais, ResizeablePanel;

type

  { TDesktop }

  { TExecutarProjeto }

  TDesktop = class(TForm)
    ActAbrir: TAction;
    ActParar: TAction;
    ActPlay: TAction;
    ActSalvarTudo: TAction;
    ActSalvar: TAction;
    ActSair: TAction;
    ActNovo: TAction;
    Actions: TActionList;
    GBConsole: TGroupBox;
    GBProjeto: TGroupBox;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MemoConsole: TMemo;
    ItemArquivo: TMenuItem;
    ItemNovo: TMenuItem;
    ItemAbrir: TMenuItem;
    ItemSair: TMenuItem;
    AbrirProjeto: TOpenDialog;
    ItemEditar : TMenuItem;
    ItemSalvar : TMenuItem;
    ItemSalvarTodos : TMenuItem;
    ItemExecutar : TMenuItem;
    ItemPlay : TMenuItem;
    ItemStop : TMenuItem;
    PageControl1: TPageControl;
    CtrlLeftPanel: TResizeablePanel;
    ProjetoTree: TTreeView;
    PnBottom: TResizeablePanel;
    ToolBar1: TToolBar;
    BtnNovo: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure ActAbrirExecute(Sender: TObject);
    procedure ActPararExecute(Sender: TObject);
    procedure ActPlayExecute(Sender: TObject);
    procedure ActSairExecute(Sender: TObject);
    procedure ActSalvarExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ProjetoTreeDblClick(Sender: TObject);
    procedure AlterarCodigo(Sender : TObject);
  private
    ProjetoPath, LovePath, ProjetoNome : String;
    IniConfig : TIniFile;
    love : TProcess;
    procedure popularTreeProjeto;
    procedure LimparTela;
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
  IniConfig   := TIniFile.Create(GetCurrentDir + separadorPasta +'Config.ini');
  ProjetoPath := IniConfig.ReadString('Project','Path','');
  ProjetoNome := IniConfig.ReadString('Project','Name','');
  Self.Caption := ProjetoNome + ' - Pasciön IDE';
  LovePath := IniConfig.ReadString('Love2d','Path','');

  popularTreeProjeto;
end;

procedure TDesktop.ProjetoTreeDblClick(Sender: TObject);
var newTab: TTabSheet;
    LuaTela : TLuaEditor;
begin
  if PosEx('.lua',ProjetoTree.Selected.Text) > 0 then
  begin
    newTab                := PageControl1.AddTabSheet;
    newTab.Caption        := ProjetoTree.Selected.Text;

    LuaTela := TLuaEditor.Create(nil);
    LuaTela.SetCaminho(ProjetoPath + StringReplace(ProjetoTree.Selected.GetTextPath, ProjetoNome , '', []));
    LuaTela.CarregarArquivo;
    LuaTela.BorderStyle := bsNone;
    LuaTela.Parent      := newTab;
    LuaTela.Align       := alClient;
    LuaTela.Show;
  end;
end;

procedure TDesktop.popularTreeProjeto;
var
  arquivo : TSearchRec;
  raiz    : TTreeNode;
begin
  raiz := ProjetoTree.Items.AddFirst(nil,ProjetoNome);
  if FindFirst(ProjetoPath + separadorPasta +'*.*', faAnyFile, arquivo) = 0 then
    repeat
      if (arquivo.Name <> '.') and (arquivo.Name <> '..') then
        ProjetoTree.Items.AddChild(raiz, arquivo.Name);
    until FindNext(arquivo) <> 0;
      FindClose(arquivo);
end;

procedure TDesktop.LimparTela;
begin
  //
  //PageControl1.;
end;

procedure TDesktop.AlterarCodigo(Sender: TObject);
begin
  if PosEx('*',PageControl1.ActivePage.Caption) = 0 then
    PageControl1.ActivePage.Caption := '*'+ PageControl1.ActivePage.Caption;
  ActSalvar.Enabled := True;
end;

procedure TDesktop.ActSairExecute(Sender: TObject);
begin
  Close;
end;

procedure TDesktop.ActSalvarExecute(Sender: TObject);
var i : Integer;
begin
  for i := 0 to Pred(PageControl1.ActivePage.ControlCount) do
    if PageControl1.ActivePage.Controls[i].ClassType = TLuaEditor then
      TLuaEditor(PageControl1.ActivePage.Controls[i]).SalvarArquivo;
  ActSalvar.Enabled := false;
  PageControl1.ActivePage.Caption := StringReplace(PageControl1.ActivePage.Caption,'*','',[]);
end;

procedure TDesktop.ActPlayExecute(Sender: TObject);
begin
  MemoConsole.Lines.Add('Iniciando ' + ProjetoNome);
  love := TProcess.Create(nil);
  love.CommandLine := LovePath + ' "'+ProjetoPath+'"';
  love.Active := True;
  if love.Active then
  begin
    ActPlay.Enabled := False;
    ActParar.Enabled := True;
  end;

  //SysUtils.ExecuteProcess(Utf8ToAnsi(LovePath),Utf8ToAnsi('"'+ProjetoPath+'"'),[]);
end;

procedure TDesktop.ActPararExecute(Sender: TObject);
begin
  love.Active := False;
  if not(love.Active) then
  begin
    ActPlay.Enabled := True;
    ActParar.Enabled := False;
    FreeAndNil(love);
  end;
end;

procedure TDesktop.ActAbrirExecute(Sender: TObject);
var caminho : String;
begin
  if AbrirProjeto.Execute then
  begin
    caminho := AbrirProjeto.InitialDir.Substring(0, Length(AbrirProjeto.InitialDir) - 1);
    IniConfig.WriteString('Project', 'Path', caminho);
    IniConfig.WriteString('Project','Name', ReverseString(ReverseString(caminho).Substring(0, PosEx('\',ReverseString(caminho)) -1 )));
  end;
end;

end.

