unit UnitFuncoes;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils;

type

  { Funcoes }

  Funcoes = class
  public
    function IIF(Condition: Boolean; TrueResult, FalseResult: variant): Variant;
  end;



implementation

{ Funcoes }

function IIF(Condition: Boolean; TrueResult, FalseResult: variant): Variant;
begin
  if Condition then
    Result := TrueResult
  else
    Result := FalseResult;
end;

end.

