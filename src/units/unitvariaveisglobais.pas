unit UnitVariaveisGlobais;

{$mode objfpc}{$H+}

interface

uses
  cmem, Classes, SysUtils;

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

var
  separadorPasta : String;

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
  VariaveisGlobais.addPalavrasPadroes(['and','break','do','else','elseif',
                                       'end','false','for','function','if',
                                       'in','local','nil','not','or','repeat',
                                       'return','then','true','until','while']);
  {$IFDEF UNIX}
    separadorPasta := '/';
  {$ELSE}
    {$IFDEF WINDOWS}
      separadorPasta := '\';
    {$ENDIF}
  {$ENDIF}

end;
end.

