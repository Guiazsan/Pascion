unit UnitDesktop;

{$mode objfpc}{$H+}

interface

uses
  cmem, Classes, SysUtils, IniFiles, process, strutils, FileUtil, Forms,
  Controls, Graphics, Dialogs, ComCtrls, ActnList, Menus, ExtCtrls, StdCtrls,
  CustomDrawn_Common, CustomDrawnControls, UnitLuaEditor, UnitVariaveisGlobais,
  ResizeablePanel, UnitPastasProjetos, UnitCenaEditor;

type

  { TDesktop }

  { TExecutarProjeto }

  TDesktop = class(TForm)
    ActAbrir: TAction;
    ActProjConfig : TAction;
    ActParar: TAction;
    ActPlay: TAction;
    ActSalvarTudo: TAction;
    ActSalvar: TAction;
    ActSair: TAction;
    ActNovo: TAction;
    Actions: TActionList;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
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
    Memo1 : TMemo;
    MemoMensagens: TMemo;
    MenuItem1 : TMenuItem;
    MenuItem2 : TMenuItem;
    PageControl1: TCDPageControl;
    CtrlLeftPanel: TResizeablePanel;
    PcSaidas: TCDPageControl;
    PnBottom: TResizeablePanel;
    TsMensagens: TCDTabSheet;
    TsConsole: TCDTabSheet;
    TmExecutor: TTimer;
    ToolBar1: TToolBar;
    BtnNovo: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure ActProjConfigExecute(Sender : TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ActAbrirExecute(Sender : TObject);
    procedure ActPararExecute(Sender : TObject);
    procedure ActPlayExecute(Sender : TObject);
    procedure ActSairExecute(Sender : TObject);
    procedure ActSalvarExecute(Sender : TObject);
    procedure TmExecutorTimer(Sender : TObject);
  private
    IniConfig : TIniFile;
    love : TProcess;
    MemSaida : TMemo;
    FramePastas : TPastasProjetos;

    procedure LimparTela;
  public
    ProjetoPath, LovePath, ProjetoNome : String;
    procedure AlterarCodigo(Sender : TObject);
    procedure AbrirCodigo(Caminho, Nome : String);
    procedure AbrirCena(Caminho, Nome : String);

  end;

var
  Desktop: TDesktop;

implementation

uses UnitProjConfig;

{$R *.lfm}

{ TDesktop }

procedure TDesktop.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Application.Terminate;
end;

procedure TDesktop.ActProjConfigExecute(Sender : TObject);
begin
  //
  Application.CreateForm(TProjConfig, ProjConfig);
  try
    ProjConfig.ShowModal;
  finally
    FreeAndNil(ProjConfig);
  end;
end;

procedure TDesktop.FormCreate(Sender: TObject);
begin
  IniConfig     := TIniFile.Create(GetCurrentDir + separadorPasta +'Config.ini');
  ProjetoPath   := IniConfig.ReadString('Project','Path','');
  ProjetoNome   := IniConfig.ReadString('Project','Name','');
  Self.Caption  := ProjetoNome + ' - Pasciön IDE';
  LovePath      := IniConfig.ReadString('Love2d','Path','');

  FramePastas         := TPastasProjetos.Create(nil);
  FramePastas.popularTreeProjeto(ProjetoPath, ProjetoNome);
  FramePastas.Parent  := CtrlLeftPanel;
  FramePastas.Align   := alClient;
  FramePastas.Show;

end;

procedure TDesktop.LimparTela;
begin
  //PageControl1.;
end;

procedure TDesktop.AlterarCodigo(Sender: TObject);
begin
  if PosEx('*',PageControl1.ActivePage.Caption) = 0 then
    PageControl1.ActivePage.Caption := '*'+ PageControl1.ActivePage.Caption;
  ActSalvar.Enabled := True;
end;

procedure TDesktop.AbrirCodigo(Caminho, Nome : String);
var newTab: TCDTabSheet;
    LuaTela : TLuaEditor;
begin
  if PosEx('.lua',Nome) > 0 then
  begin
    newTab                := PageControl1.AddPage(Nome);

    LuaTela := TLuaEditor.Create(nil);
    LuaTela.SetCaminho(ProjetoPath + StringReplace(Caminho, ProjetoNome , '', []));
    LuaTela.CarregarArquivo;
    //LuaTela.GridLinhas.RowCount := LuaTela.RMEditor.Lines.Count;
    LuaTela.BorderStyle := bsNone;
    LuaTela.Parent      := newTab;
    LuaTela.Align       := alClient;
    LuaTela.Show;
  end;
end;

procedure TDesktop.AbrirCena(Caminho, Nome : String);
var newTab: TCDTabSheet;
    CenaTela : TCenaEditor;
begin
  if PosEx('.lua',Nome) > 0 then
  begin
    newTab               := PageControl1.AddPage(Nome);
    CenaTela := TCenaEditor.Create(nil);
    CenaTela.AbrirEditor(Caminho, Nome);
    CenaTela.BorderStyle := bsNone;
    CenaTela.Parent      := newTab;
    CenaTela.Align       := alClient;
    CenaTela.Show;
  end;
end;

procedure TDesktop.TmExecutorTimer(Sender: TObject);
begin
  if Assigned(love) and love.Running then
  begin
    ActParar.Enabled := True;
    ActPlay.Enabled := False;
    Caption := 'Pasciön - Em Execução';
  end
  else
  begin
    ActParar.Enabled := False;
    ActPlay.Enabled := True;
    Caption := 'Pasciön';
    TmExecutor.Enabled := False;
    if Assigned(love) then
    begin
      Memo1.Lines.LoadFromStream(love.Output);
      FreeAndNil(love);
    end;

    {if Assigned(ExecutorSaida) then
      FreeAndNil(ExecutorSaida);}
  end;
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
  MemoMensagens.Lines.Add('Iniciando ' + ProjetoNome);
  love := TProcess.Create(nil);
  love.CommandLine :='"'+ LovePath + '" "'+ProjetoPath+'"';
  love.Options := love.Options + [poUsePipes, poStderrToOutPut];
  love.Active := True;

  TmExecutor.Enabled := True;

  //SysUtils.ExecuteProcess(Utf8ToAnsi(LovePath),Utf8ToAnsi('"'+ProjetoPath+'"'),[]);
end;

procedure TDesktop.ActPararExecute(Sender: TObject);
begin
  love.Terminate(0);

  ActPlay.Enabled := True;
  ActParar.Enabled := False;
  if Assigned(love) then
    FreeAndNil(love);
end;

procedure TDesktop.ActAbrirExecute(Sender: TObject);
var caminho : String;
    Processo : TProcess;
begin
  if AbrirProjeto.Execute then
  begin
    caminho := AbrirProjeto.InitialDir.Substring(0, Length(AbrirProjeto.InitialDir) - 1);
    IniConfig.WriteString('Project', 'Path', caminho);
    IniConfig.WriteString('Project','Name', ReverseString(ReverseString(caminho).Substring(0, PosEx('\',ReverseString(caminho)) -1 )));
    Processo := TProcess.Create(nil);
    try
      Processo.CommandLine := Application.ExeName;
      Processo.Execute;
    finally
      FreeAndNil(Processo);
      Application.Terminate;
    end;
  end;
end;
end.

