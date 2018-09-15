unit UnitVariaveisGlobais;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { VariaveisGlobais }

  VariaveisGlobais = class
  private
    class var slPalavrasReservadas : array of String;
    class procedure addPalavrasPadroes(palavras : array of String);

  public
    class function getPalavrasReservadas : TStringList;
    class procedure setPalavrasReservadas(palavra : String);

  end;

implementation

{ VariaveisGlobais }

class procedure VariaveisGlobais.addPalavrasPadroes(palavras : array of String);
var
  i : Integer;
begin
  SetLength(slPalavrasReservadas, Length(palavras));
  for i := 0 to Length(palavras) - 1 do
    slPalavrasReservadas[i] := palavras[i];
end;

class function VariaveisGlobais.getPalavrasReservadas: TStringList;
var
  i : Integer;
  saida : TStringList;
begin
  saida := TStringList.Create;
  for i := 0 to Length(slPalavrasReservadas) - 1 do
    saida.add(slPalavrasReservadas[i]);

  result := saida;
end;

class procedure VariaveisGlobais.setPalavrasReservadas(palavra: String);
begin
  SetLength(slPalavrasReservadas, Length(slPalavrasReservadas) + 1);
  slPalavrasReservadas[Length(slPalavrasReservadas) -1] := palavra;
end;

initialization
begin
  VariaveisGlobais.addPalavrasPadroes(['if','function','then','end']);

end;
end.

