unit UnitLuaEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, Grids, ExtCtrls, RichMemo, Types;

type

  { TLuaEditor }

  TLuaEditor = class(TForm)
    GridLinhas: TDrawGrid;
    RMEditor: TRichMemo;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure GridLinhasDblClick(Sender: TObject);
    procedure GridLinhasDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure RMEditorChange(Sender: TObject);
    procedure RMEditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure RMEditorKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
  private
    KShift : Boolean;
    procedure ColorirPalavrasReservadas(palavra : String; cor : TColor);
    procedure ColorirNumeros(cor : TColor);
    procedure ColorirComentarios(cor : TColor);
    procedure ColorirStrings(cor : TColor);
    function ContarLinhas : Integer;

  public

  end;

var
  LuaEditor: TLuaEditor;

implementation

uses
  RichMemoUtils, UnitVariaveisGlobais, strutils, LCLType, Clipbrd;

{$R *.lfm}

{ TLuaEditor }

procedure TLuaEditor.Timer1Timer(Sender: TObject);
var
  i : Integer;
begin
  try
    for i := 0 to VariaveisGlobais.getPalavrasReservadas.Count - 1 do
    begin
      ColorirPalavrasReservadas(VariaveisGlobais.getPalavrasReservadas[i], TColor(clBlue));
    end;
    ColorirNumeros(TColor(clPurple));
    ColorirStrings(TColor(clYellow));
    ColorirComentarios(TColor(clGreen));
  finally
    Timer1.Enabled := false;
  end;
end;

procedure TLuaEditor.RMEditorChange(Sender: TObject);
begin
  Timer1.Enabled := True;
  GridLinhas.RowCount := ContarLinhas;
end;

procedure TLuaEditor.RMEditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_SHIFT then
    KShift := True;

  if key = VK_TAB then
  begin
    if not KShift then
      RMEditor.SelText := '  '+ ReplaceStr(RMEditor.SelText,sLineBreak,sLineBreak + '  ')
    else
      RMEditor.SelText := ReplaceStr(RMEditor.SelText,sLineBreak + ' ', sLineBreak);
    key := 0;
  end;
end;

procedure TLuaEditor.RMEditorKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_SHIFT then
    KShift := False;
end;

procedure TLuaEditor.FormCreate(Sender: TObject);
begin
  RMEditor.Text := '';
  GridLinhas.DefaultRowHeight := RMEditor.Font.Size + 6;
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
  GridLinhas.Canvas.TextOut(GridLinhas.CellRect(0,0).Left + 20,GridLinhas.CellRect(0,0).Top -1, IntToStr(1));
  for i := 1 to GridLinhas.RowCount do
  begin
     GridLinhas.Canvas.TextOut(GridLinhas.CellRect(0,i).Left + 26 - (Length(IntToStr(i + 1)) * 6),
                               GridLinhas.CellRect(0,i).Top -1, IntToStr(i + 1));
  end;
end;

procedure TLuaEditor.ColorirPalavrasReservadas(palavra : String; cor : TColor);
var
  texto : String;
begin
  texto := RMEditor.Text;
    while PosEx(palavra, texto) <> 0 do
    begin
      if ((texto[PosEx(palavra, texto) + palavra.Length] = ' ') or
          (texto[PosEx(palavra, texto) + palavra.Length] = '') or
          (texto[PosEx(palavra, texto) + palavra.Length] = LineEnding) or
          (texto[PosEx(palavra, texto) + palavra.Length] = sLineBreak) or
          (texto[PosEx(palavra, texto) + palavra.Length] = '(') or
          (texto[PosEx(palavra, texto) + palavra.Length] = ')') or
          (texto[PosEx(palavra, texto) + palavra.Length] = ',') or
          (texto[PosEx(palavra, texto) + palavra.Length] = '.')) and   //Depois da Palavra

         ((texto[PosEx(palavra, texto) - 1] = ' ') or
          (texto[PosEx(palavra, texto) - 1] = LineEnding) or
          (texto[PosEx(palavra, texto) - 1] = sLineBreak) or
          (PosEx(palavra, RMEditor.text) = 1))  //Antes da Palavra
      then
        RMEditor.SetRangeColor( (PosEx(palavra, texto) - 2) + (String(RMEditor.text).Length - texto.Length),
                                 palavra.Length + 1 , cor)
      else
        RMEditor.SetRangeColor( (PosEx(palavra, texto) - 2) + (String(RMEditor.text).Length - texto.Length),
                                 palavra.Length + 1 , TColor(clWhite));

      texto := texto.Substring(PosEx(palavra, texto) + palavra.Length);
    end;
end;

procedure TLuaEditor.ColorirNumeros(cor: TColor);
var
  texto : String;
  numeros : array[0..9] of Integer;
  i : Integer;
begin
  texto := RMEditor.Text;
  for i := 0 to Length(numeros) - 1 do
    while PosEx(IntToStr(numeros[i]), texto) <> 0 do
    begin
      if (not(texto[PosEx(IntToStr(numeros[i]), texto) + IntToStr(numeros[i]).Length] in ['a'..'z','A'..'Z'])
          and
          not(texto[PosEx(IntToStr(numeros[i]), texto) - 1] in ['a'..'z','A'..'Z']))
      then
        RMEditor.SetRangeColor( (PosEx(IntToStr(numeros[i]), texto) - 2) + (String(RMEditor.text).Length - texto.Length),
                                 IntToStr(numeros[i]).Length + 2 , cor)
      else
        RMEditor.SetRangeColor( (PosEx(IntToStr(numeros[i]), texto) - 2) + (String(RMEditor.text).Length - texto.Length),
                                 IntToStr(numeros[i]).Length + 2 , TColor(clWhite));

      texto := texto.Substring(PosEx(IntToStr(numeros[i]), texto) + IntToStr(numeros[i]).Length);
    end;
end;

procedure TLuaEditor.ColorirComentarios(cor: TColor);
var
  texto : String;
  final : String;
  indexFinal : integer;
begin
  texto := RMEditor.Text;
  while PosEx('--[[', texto) > 0 do
  begin
    texto := texto.Substring(PosEx('--[[',Texto));

    if PosEx(']]--', texto) = 0 then
      indexFinal := Length(texto) - 1
    else
      indexFinal := PosEx('--]]', texto);

    RMEditor.SetRangeColor((PosEx(texto, RMEditor.Text) - 2), indexFinal + 1, cor);
    texto := texto.Substring(PosEx('--]]',Texto) + 4);
  end;

  texto := RMEditor.Text;
  While (PosEx('--', texto) <> 0) do
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

      RMEditor.SetRangeColor( (PosEx(texto, RMEditor.Text) - 2),(indexFinal - PosEx('--', texto)), cor);


      texto := texto.Substring(PosEx(final,Texto));
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

function TLuaEditor.ContarLinhas : Integer;
var
  linha : array of String;
  i,n : Integer;
  texto : String;
begin
  texto := RMEditor.Text;
  n := 0;
  for i := 0 to Length(RMEditor.Text) -1 do
  begin
    if (RMEditor.Text[i] = LineEnding) or (RMEditor.Text[i] = sLineBreak) then
    begin
      SetLength(linha, Length(linha) + 1);
      linha[n] := Texto.Substring(n,i);
      n := n + 1;
    end;

  end;
  result := n + 1;

end;

end.

