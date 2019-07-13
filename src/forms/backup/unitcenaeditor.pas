unit UnitCenaEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  CustomDrawnControls, ComCtrls, UnitLuaEditor;

type

  { TCenaEditor }

  TCenaEditor = class(TForm)
    GroupBox1 : TGroupBox;
    PageControl1 : TPageControl;
    Panel1 : TPanel;
    ScrollBox1 : TScrollBox;
    TabSheet1 : TTabSheet;
    TabCodigo : TTabSheet;
  private
    FCaminho, FNome : String;

  public
    procedure AbrirEditor(Caminho, Nome : String);

  end;

var
  CenaEditor : TCenaEditor;

implementation

{$R *.lfm}

{ TCenaEditor }

procedure TCenaEditor.AbrirEditor(Caminho, Nome : String);
var LuaTela : TLuaEditor;
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
end;

end.

