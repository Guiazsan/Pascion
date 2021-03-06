unit UnitStart;

{$mode objfpc}{$H+}

interface

uses
  cmem, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, UnitDesktop, UnitVariaveisGlobais, IniFiles, process,
  strutils, LCLIntf, LazUtils;

type

  { TStartForm }

  TStartForm = class(TForm)
    EdtCaminho: TEdit;
    EdtCaminhoLove: TEdit;
    EdtNome: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel4: TPanel;
    PnVolta: TPanel;
    PnCaminhoLove: TPanel;
    PnComecar: TPanel;
    PnProximo: TPanel;
    PnPastaLove: TPanel;
    PnCriarProjeto: TPanel;
    PnNome: TPanel;
    Panel3: TPanel;
    Pn2: TPanel;
    Pn1: TPanel;
    PnCaminho: TPanel;
    PnNewProject: TPanel;
    PnOpenProject: TPanel;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Label7Click(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure PnComecarClick(Sender: TObject);
    procedure PnCriarProjetoClick(Sender: TObject);
    procedure PnNewProjectClick(Sender: TObject);
    procedure PnOpenProjectClick(Sender: TObject);
    procedure PnProximoClick(Sender: TObject);
    procedure PnVoltaClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    bNewFile       : Boolean;
    bBackPage      : Boolean;
    PathFile       : TIniFile;
    PgpFile        : TIniFile;
    PainelAtivo    : TPanel;
    PainelAnterior : TPanel;
    procedure SetPainelAtual(Painel : TPanel; animacao : Boolean = False);
    procedure abrirIDE;
  public
    procedure CriarProjeto;
  end;

var
  StartForm: TStartForm;

implementation

{$R *.lfm}

{ TStartForm }

procedure TStartForm.CriarProjeto;
begin
  if SelectDirectoryDialog1.Execute then
  begin
    PathFile := TIniFile.Create(GetCurrentDir + separadorPasta +'Config.ini');
    PathFile.WriteString('Project','Path', SelectDirectoryDialog1.FileName);
    //PgpFile := TIniFile.Create(SelectDirectoryDialog1.FileName);
    FileCreate(SelectDirectoryDialog1.GetNamePath + '\conf\conf.lua');
    FileCreate(SelectDirectoryDialog1.GetNamePath + '\main.lua');
    FileCreate(SelectDirectoryDialog1.GetNamePath + '\src\classes\');
    FileCreate(SelectDirectoryDialog1.GetNamePath + '\src\cenas\');
    PgpFile.WriteString('Properties','Name',InputBox('NovoProjeto','Dê um nome ao seu Projeto',''));
  end;
end;

procedure TStartForm.PnNewProjectClick(Sender: TObject);
begin
  bNewFile := true;
  SetPainelAtual(Pn2, True);
end;

procedure TStartForm.FormCreate(Sender: TObject);
begin
  StartForm.Width := 522;
  EdtCaminho.Text := GetUserDir + 'Pascion Projects'+ separadorPasta;
  EdtNome.Text := 'NewProject';
  PathFile := TIniFile.Create(GetCurrentDir + separadorPasta + 'Config.ini');
end;

procedure TStartForm.FormShow(Sender: TObject);
begin
  SetPainelAtual(Panel2);
end;

procedure TStartForm.Label7Click(Sender: TObject);
begin
  //Shellexecute(handle, 'open', pchar('https://love2d.org/'), nil,nil, 1);
  OpenUrl('https://love2d.org/');
end;

procedure TStartForm.Panel2Click(Sender: TObject);
begin
  bBackPage := true;
end;

procedure TStartForm.Panel3Click(Sender: TObject);
begin
  if SelectDirectoryDialog1.Execute then
  begin
    EdtCaminho.Text := SelectDirectoryDialog1.FileName;
  end;
end;

procedure TStartForm.Panel4Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    {$IFDEF LINUX}
      OpenDialog1.DefaultExt := '.appimage';
      OpenDialog1.Filter := 'appimage';
    {$ELSE}
      {$IFDEF WINDOWS}
        OpenDialog1.DefaultExt := '.exe';
        OpenDialog1.Filter := 'exe';
      {$ENDIF}
    {$ENDIF}

    EdtCaminhoLove.Text := OpenDialog1.FileName;
  end;
end;

procedure TStartForm.PnComecarClick(Sender: TObject);
begin
  SetPainelAtual(PnPastaLove, true);
end;

procedure TStartForm.PnCriarProjetoClick(Sender: TObject);
var MainFile, ConfFile : TStringList;
begin
  if EdtNome.Text = '' then
  begin
    ShowMessage('Digite um nome para o projeto!');
    Exit;
  end;
  if EdtCaminho.Text = '' then
  begin
    ShowMessage('Digite o caminho do projeto');
    Exit;
  end;

  PathFile.WriteString('Project','Path', EdtCaminho.Text + separadorPasta + EdtNome.Text);
  PathFile.WriteString('Project','Name', EdtNome.Text);
  MainFile := TStringList.Create;
  try
    ForceDirectories(EdtCaminho.Text + separadorPasta + EdtNome.Text);
    MainFile.Add('objeto = {x, y, r = 0, w, h, tipo, caminho, imagem, quad, texto}');
    MainFile.Add('');
    MainFile.Add('require('+ QuotedStr('Lib/cena_render') +')');
    MainFile.SaveToFile(EdtCaminho.Text + separadorPasta +
        EdtNome.Text + separadorPasta +'main.lua');

    ConfFile := TStringList.Create;
    try
      ConfFile.Add('function love.conf(t)');
      ConfFile.Add('  t.title = "'+ EdtNome.Text +'"');
      ConfFile.Add('  t.window.width = 800;');
      ConfFile.Add('  t.window.height = 600;');
      ConfFile.Add('end');
      ConfFile.SaveToFile(EdtCaminho.Text + separadorPasta +
        EdtNome.Text + separadorPasta +'conf.lua');
    finally
      FreeAndNil(ConfFile);
    end;

    ForceDirectories(
      EdtCaminho.Text + separadorPasta +
      EdtNome.Text + separadorPasta + 'Cenas');

    ForceDirectories(
      EdtCaminho.Text + separadorPasta +
      EdtNome.Text + separadorPasta + 'Lib');

    CopyFile(
      GetCurrentDir + separadorPasta +
      'lua files' + separadorPasta +
      'cena_render.lua' ,EdtCaminho.Text + separadorPasta +
      EdtNome.Text + separadorPasta +
      'Lib' + separadorPasta + 'cena_render.lua')
  finally
    FreeAndNil(MainFile);
  end;

  abrirIDE;
end;

procedure TStartForm.PnOpenProjectClick(Sender: TObject);
var caminho : String;
begin
  if (OpenDialog1.Execute) and (OpenDialog1.FileName <> '') then
  begin
    caminho := OpenDialog1.InitialDir.Substring(0, Length(OpenDialog1.InitialDir) - 1);
    PathFile.WriteString('Project','Path', caminho);
    PathFile.WriteString('Project','Name', ReverseString(ReverseString(caminho).Substring(0, PosEx(separadorPasta,ReverseString(caminho)) -1 )));
    PgpFile := TIniFile.Create(OpenDialog1.FileName);
    abrirIDE;
  end;
end;

procedure TStartForm.PnProximoClick(Sender: TObject);
begin
  if EdtCaminhoLove.Text = '' then
  begin
    EdtCaminhoLove.Color := TColor($008080FF);
    Label5.Caption := 'Caminho vazío!';
    Exit;
  end;

  PathFile.WriteString('Love2d','Path', EdtCaminhoLove.Text);
  SetPainelAtual(Pn1, True);
end;

procedure TStartForm.PnVoltaClick(Sender: TObject);
begin
  SetPainelAtual(PainelAnterior);
end;

procedure TStartForm.Timer1Timer(Sender: TObject);
begin
  if PainelAtivo.Left > 0 then
  begin
    PainelAnterior.Left := PainelAnterior.Left - 30;
    PainelAtivo.Left    := PainelAtivo.Left - 30;
    Timer1.Interval     := Timer1.Interval + 1;
  end
  else
  begin
    if PainelAtivo.Left < 0 then
      PainelAtivo.Left := 0;
    Timer1.Enabled  := False;
    Timer1.Interval := 1;
  end;
end;

procedure TStartForm.SetPainelAtual(Painel: TPanel; animacao : Boolean = False);
var i : Integer;
begin
  PainelAnterior := PainelAtivo;
  PainelAtivo := Painel;
  for i := 0 to Pred(Panel1.ControlCount) do
  begin
    if Panel1.Controls[i] is TPanel then
      if Panel1.Controls[i] <> Painel then
      begin
        TPanel(Panel1.Controls[i]).Visible := False;
        TPanel(Panel1.Controls[i]).Align := alNone;
      end;
  end;

  if animacao then
  begin
    PainelAnterior.Visible := True;
    Painel.Left :=  StartForm.Width;
  end;

  Painel.Visible := True;
  Painel.Width := StartForm.Width;

  if animacao then
  begin
    Timer1.enabled := True;
    PnVolta.Visible := True
  end
  else
    Painel.Left := 0;
end;

procedure TStartForm.abrirIDE;
begin
  Application.CreateForm(TDesktop, Desktop);
  try
    StartForm.Visible := False;
    Desktop.ShowModal;
  finally
    FreeAndNil(Desktop);
    Close;
  end;
end;

end.

