unit UnitCenaEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  CustomDrawnControls, ComCtrls, Buttons, ActnList, UnitLuaEditor;

type

  { TCenaEditor }

  TCenaEditor = class(TForm)
    ActImagem: TAction;
    ActTexto: TAction;
    ActRetangulo: TAction;
    ActionList1: TActionList;
    BtnImage: TToggleBox;
    BtnRect: TToggleBox;
    BtnText: TToggleBox;
    GroupBox1 : TGroupBox;
    PageControl1 : TPageControl;
    PnScreen : TPanel;
    PnTools: TPanel;
    ScrollBox1 : TScrollBox;
    TabSheet1 : TTabSheet;
    TabCodigo : TTabSheet;
    procedure BtnRectClick(Sender: TObject);
    procedure PnScreenClick(Sender: TObject);
  private
    FCaminho, FNome, Objetos : String;

  public
    procedure AbrirEditor(Caminho, Nome : String);
    procedure LerObjetos;

  end;

var
  CenaEditor : TCenaEditor;

implementation

uses UnitDesktop, UnitVariaveisGlobais, strutils;

{$R *.lfm}

{ TCenaEditor }

procedure TCenaEditor.BtnRectClick(Sender: TObject);
var i : Integer;
begin
  if TToggleBox(Sender).Checked = True then
    for i := 0 to Pred(PnTools.ControlCount) do
      if (PnTools.Controls[i] is TToggleBox) and (PnTools.Controls[i] <> Sender) then
        TToggleBox(PnTools.Controls[i]).Checked := false;

  //TToggleBox(Sender).Checked := True;
end;

procedure TCenaEditor.PnScreenClick(Sender: TObject);
var TextPrint : TLabel;
begin
  //
  if BtnText.Checked then

end;

procedure TCenaEditor.AbrirEditor(Caminho, Nome : String);
var LuaTela : TLuaEditor;
    config : TStringList;
    i : Integer;
begin
  FCaminho                    := Caminho;
  FNome                       := Nome;
  LuaTela                     := TLuaEditor.Create(nil);
  LuaTela.SetCaminho(Caminho);
  LuaTela.CarregarArquivo;
  //LuaTela.GridLinhas.RowCount := LuaTela.RMEditor.Lines.Count;
  LuaTela.BorderStyle         := bsNone;
  LuaTela.Parent              := TabCodigo;
  LuaTela.Align               := alClient;
  LuaTela.Show;
  config := TStringList.Create;
  try
     config.LoadFromFile(Desktop.ProjetoPath + separadorPasta + 'conf.lua');
     config.Sorted := true;
     PnScreen.Width := 800;
     PnScreen.Height := 600;
     for I := 0 to Pred(config.Count) do
       if Pos('t.window.width', config.Strings[i]) <> 0 then
         PnScreen.Width :=  StrToInt(StringReplace(config.Strings[i].Substring(Pos('=', config.Strings[i]) + 1), ';', '', []));

     for I := 0 to Pred(config.Count) do
       if Pos('t.window.height', config.Strings[i]) <> 0 then
         PnScreen.Height :=  StrToInt(StringReplace(config.Strings[i].Substring(Pos('=', config.Strings[i]) + 1),';','', []));

   finally
     FreeAndNil(config);
   end;
   ScrollBox1.AutoScroll := True;
end;

procedure TCenaEditor.LerObjetos;
var codigo      : TStringList;
    qtde_objeto : Integer;
begin
  codigo := TStringList.Create(nil);
  try
    codigo.LoadFromFile(Caminho);
    Objetos := Copy(codigo.Text, Pos('objeto[', codigo.Text), Pos('function' ,codigo.Text) - Pos('objeto[', codigo.Text));
  finally
    FreeAndNil(codigo);
  end;

  if Objetos <> '' then
    qtde_objeto := StrToInt(Copy(Objetos, RPos('objeto[', Objetos)+ 7, 1));
end;

end.

