unit UnitVariaveisGlobais;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type

  { VariaveisGlobais }

  VariaveisGlobais = class()
  private
    asPalavrasReservadas : array['if','function','then', 'end', 'int', 'var'] of String;

  public
    class function getPalavrasReservadas : TStringArray;

  end;

implementation

{ VariaveisGlobais }

class function VariaveisGlobais.getPalavrasReservadas: TStringArray;
begin
  result := asPalavrasReservadas;
end;

end.

