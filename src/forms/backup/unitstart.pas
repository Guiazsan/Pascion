unit UnitStart;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, IniFiles, sysutils;

type

  { TStartForm }

  TStartForm = class(TForm)
    EdtCaminho: TEdit;
    EdtNome: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
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
    procedure Panel2Click(Sender: TObject);
    procedure Panel3Click(Sender: TObject);
    procedure PnCriarProjetoClick(Sender: TObject);
    procedure PnNewProjectClick(Sender: TObject);
    procedure PnOpenProjectClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    bNewFile  : Boolean;
    bBackPage : Boolean;
    PathFile  : TIniFile;
    PgpFile   : TIniFile;
  public
    procedure CriarProjeto();
  end;

var
  StartForm: TStartForm;

implementation

{$R *.lfm}

{ TStartForm }

procedure TStartForm.CriarProjeto();
begin
  if SelectDirectoryDialog1.Execute then
  begin
    PathFile := TIniFile.Create(GetCurrentDir + '\Config.ini');
    PathFile.WriteString('Project','Path', SelectDirectoryDialog1.FileName);
    PgpFile := TIniFile.Create(SelectDirectoryDialog1.FileName);
    {FileCreate(SaveDialog1.GetNamePath + '\conf\conf.lua');
    FileCreate(SaveDialog1.GetNamePath + '\src\main.lua');
    FileCreate(SaveDialog1.GetNamePath + '\src\class\');
    FileCreate(SaveDialog1.GetNamePath + '\src\scenes\');}
    PgpFile.WriteString('Properties','Name',InputBox('NovoProjeto','Dê um nome ao seu Projeto',''));
  end;
end;

procedure TStartForm.PnNewProjectClick(Sender: TObject);
begin
  bNewFile := true;
end;

procedure TStartForm.FormCreate(Sender: TObject);
begin
  StartForm.Width := 522;
  EdtCaminho.Text := GetUserDir + 'Pascion Projects\';
  EdtNome.Text := 'NewProject';
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

procedure TStartForm.PnCriarProjetoClick(Sender: TObject);
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

  PathFile := TIniFile.Create(GetCurrentDir + '\Config.ini');
  PathFile.WriteString('Project','Path', EdtCaminho.Text + '\' + EdtNome.Text);
  PgpFile := TIniFile.Create(EdtCaminho.Text + '\' + EdtNome.Text + '.pgp');
end;

procedure TStartForm.PnOpenProjectClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    PathFile := TIniFile.Create(GetCurrentDir + '\Config.ini');
    PathFile.WriteString('Project','Path', OpenDialog1.FileName);
    PgpFile := TIniFile.Create(OpenDialog1.FileName);
  end;
end;

procedure TStartForm.Timer1Timer(Sender: TObject);
begin
  if bNewFile then
  begin
    Panel1.Left := Panel1.Left - 15;
    if Panel1.Left <= -522 then
      bNewFile := false;
  end;
  if bBackPage then
  begin
    Panel1.Left := Panel1.Left + 15;
    if Panel1.Left >= -1 then
      bBackPage := false;
  end;
end;

end.

