unit UnitLuaEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, Grids, ExtCtrls, RichMemo;

type

  { TLuaEditor }

  TLuaEditor = class(TForm)
    Edit1: TEdit;
    RMEditor: TRichMemo;
    GridLinhas: TStringGrid;
    Timer1: TTimer;
    procedure RMEditorChange(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    procedure ColorirPalavrasReservadas(palavra : String; cor : TColor);
    procedure ColorirNumeros(cor : TColor);
    procedure ColorirComentarios(cor : TColor);
    procedure ColorirStrings(cor : TColor);
    procedure ContarLinhas;

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
end;

procedure TLuaEditor.ColorirPalavrasReservadas(palavra : String; cor : TColor);
var
  texto : String;
begin
  texto := RMEditor.Text;
    while PosEx(palavra, texto) <> 0 do
    begin
      if ((texto[PosEx(palavra, texto) + palavra.Length] = ' ') or
          (texto[PosEx(palavra, texto) + palavra.Length] = LineEnding)) and   //Depois da Palavra

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

procedure TLuaEditor.ContarLinhas;
var
  linha : array of String;
  i,n : Integer;
  texto : String;
begin
  texto := RMEditor.Text;
  n := 0;
  for i := 0 to Length(RMEditor.Text) -1 do
  begin
    if RMEditor.Text[i] = LineEnding then
    begin
      SetLength(linha, Length(linha) + 1);
      linha[n] := Texto.Substring(n,i);
      n := n + 1;
    end;

  end;
  Edit1.Text := IntToStr(n + 1);

end;

end.

