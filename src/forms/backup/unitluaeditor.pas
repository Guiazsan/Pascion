unit UnitLuaEditor;

{$mode objfpc}{$H+}

interface

uses
  cmem, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, Grids, ExtCtrls, RichMemo, Types;

type

  { TLuaEditor }

  TLuaEditor = class(TForm)
    GridLinhas : TDrawGrid;
    RMEditor : TRichMemo;
    ScrollBox1 : TScrollBox;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender : TObject);
    procedure GridLinhasDblClick(Sender: TObject);
    procedure GridLinhasDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure RMEditorChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FCaminho : String;
    procedure ColorirPalavrasReservadas(palavra : String; cor : TColor);
    procedure ColorirNumeros(cor : TColor);
    procedure ColorirComentarios(cor : TColor);
    procedure ColorirStrings(cor : TColor);

  public
    procedure CarregarArquivo;
    procedure SalvarArquivo;
    procedure SetCaminho(caminho : String);
  end;

var
  LuaEditor: TLuaEditor;

implementation

uses
  RichMemoUtils, UnitVariaveisGlobais, UnitFuncoes, strutils, LCLType, Clipbrd, UnitDesktop;

{$R *.lfm}

{ TLuaEditor }

procedure TLuaEditor.Timer1Timer(Sender: TObject);
var
  i : Integer;
begin
  try
    RMEditor.SetRangeColor(0,Length(RMEditor.Text),TColor(clBlack));
    for i := 0 to VariaveisGlobais.getPalavrasReservadas.Count - 1 do
    begin
      ColorirPalavrasReservadas(VariaveisGlobais.getPalavrasReservadas[i],
        TColor($5F8FFF));
    end;
    ColorirNumeros(TColor($77a796));
    ColorirStrings(TColor($ce9178));
    ColorirComentarios(TColor($59954c));
  finally
    Timer1.Enabled := false;
    Application.ProcessMessages;
  end;
end;

procedure TLuaEditor.RMEditorChange(Sender: TObject);
begin
  Timer1.Enabled := False;
  Timer1.Enabled := True;
  Desktop.AlterarCodigo(nil);
  GridLinhas.RowCount := RMEditor.Lines.Count;
  RMEditor.Height := (RMEditor.Lines.Count + 1) * (RMEditor.Font.Size + 6);
end;

procedure TLuaEditor.FormCreate(Sender: TObject);
begin
  GridLinhas.DefaultRowHeight := RMEditor.Font.Size + 6;
end;

procedure TLuaEditor.FormResize(Sender : TObject);
begin
  RMEditor.Width := Self.Width - GridLinhas.Width;
  RMEditor.Left  := GridLinhas.Width;
end;

procedure TLuaEditor.GridLinhasDblClick(Sender: TObject);
begin
  //GridLinhas.Canvas.Draw();
end;

procedure TLuaEditor.GridLinhasDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var i : Integer;
begin
  GridLinhas.Canvas.Font.Size := 8;
  for i := 0 to Pred(GridLinhas.RowCount) do
  begin
                              //para deixar sempre alinhado os números
    GridLinhas.Canvas.TextOut(GridLinhas.CellRect(0,i).Left + 26 - (Length(IntToStr(i + 1)) * 6),
                              GridLinhas.CellRect(0,i).Top -1, IntToStr(i + 1));

  end;
end;

procedure TLuaEditor.ColorirPalavrasReservadas(palavra : String; cor : TColor);
var
  texto : String;
begin
  texto := RMEditor.Text;
  while AnsiContainsStr(texto, palavra) do
  begin
    if ((texto[PosEx(palavra, texto) + palavra.Length] in
        [' ', #10, '(', ')', '}', ',', '.', Char('')]) or //Depois da Palavra
        (PosEx(palavra, RMEditor.text) + Length(palavra) = Length(RMEditor.text))) and
        ((texto[PosEx(palavra, texto) - 1] in
        [' ', '(', ')', '{', ',', #10, Char('')]) or //Antes da Palavra
        (PosEx(palavra, RMEditor.text) - 1 = 0))
    then
      RMEditor.SetRangeParams((PosEx(palavra, texto)) + (String(RMEditor.text).Length - texto.Length) - 1,
       palavra.Length ,[tmm_Styles, tmm_Color], RMEditor.Font.Name, RMEditor.Font.Size, cor,
       [fsBold], []);

    texto := texto.Substring(PosEx(palavra, texto) + palavra.Length);
  end;
end;

procedure TLuaEditor.ColorirNumeros(cor: TColor);
var
  texto : String;
  i : Integer;
begin
  texto := RMEditor.Text;
  for i := 1 to Length(texto) do
  begin
    if (texto[i] in ['1','2','3','4','5','6','7','8','9','0']) and
     not(texto[i - 1] in ['a'..'z','A'..'Z']) //se antes não for letra
     and not(texto[i + 1] in ['a'..'z','A'..'Z']) //se depois não for letra
    then
      RMEditor.SetRangeColor(i - 1, 1, cor);

  end;
end;

procedure TLuaEditor.ColorirComentarios(cor: TColor);
var
  texto : String;
  final : String;
  indexFinal : integer;
  i : Integer;
begin
  texto := RMEditor.Text;

  //comentários de multiplas linhas
  while PosEx('--[[', texto) > 0 do
  begin
    texto := texto.Substring(PosEx('--[[',Texto));

    if PosEx(']]--', texto) = 0 then
      indexFinal := Length(texto) - 1
    else
      indexFinal := PosEx(']]', texto) + 3;

    RMEditor.SetRangeParams((PosEx(texto, RMEditor.Text) - 2), indexFinal + 1,
      [tmm_Styles, tmm_Color], RMEditor.Font.Name, RMEditor.Font.Size,
      cor, [fsItalic], [fsBold]);
    texto := texto.Substring(PosEx(']]',Texto));
  end;

  // comentários de linha única
  for i := 0 to RMEditor.Lines.Count -1 do
  begin
    texto := RMEditor.Lines[i];
    While (PosEx('--', texto) <> 0) and (texto[PosEx('--', texto) - 1] <> ']') do
    begin
      texto := texto.Substring(PosEx('--', texto));

      if PosEx(sLineBreak,texto) > PosEx(LineEnding,texto) then
        final := LineEnding
      else
        final := sLineBreak;

      if PosEx(sLineBreak, texto) = 0 then
        indexFinal := Length(texto)
      else
        indexFinal := PosEx(final, texto);

      RMEditor.SetRangeParams( (PosEx(texto, RMEditor.Text) -2 ),
      (indexFinal - PosEx('--', texto)) + 2, [tmm_Styles, tmm_Color],
       RMEditor.Font.Name, RMEditor.Font.Size, cor, [fsItalic], [fsBold]);


      texto := texto.Substring(PosEx(final,Texto));
    end;
  end;
end;

procedure TLuaEditor.ColorirStrings(cor: TColor);
var
  texto : String;
  indexFinal : Integer;
begin
  texto := RMEditor.Text;
  while PosEx('"', texto) > 0 do
  begin
    texto := texto.Substring(PosEx('"',Texto));

    if PosEx('"', texto) = 0 then
      indexFinal := Length(texto) - 1
    else
      indexFinal := PosEx('"', texto);

    RMEditor.SetRangeColor((PosEx(texto, RMEditor.Text) - 2), indexFinal + 1, cor);
    texto := texto.Substring(PosEx('"',Texto));
  end;
end;

procedure TLuaEditor.CarregarArquivo;
begin
  RMEditor.Clear;
  RMEditor.Lines.LoadFromFile(FCaminho);
  Timer1.Enabled := True;
  //RMEditor.Height := RMEditor.Lines.Count * (RMEditor.Font.Size + 6);
  ScrollBox1.AutoScroll := True;
end;

procedure TLuaEditor.SalvarArquivo;
begin
  RMEditor.Lines.SaveToFile(FCaminho);
end;

procedure TLuaEditor.SetCaminho(caminho: String);
begin
  FCaminho := IIF(separadorPasta = '/', caminho, ReplaceStr(caminho,'/','\'));
end;

end.

