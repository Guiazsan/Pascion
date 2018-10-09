unit UnitFuncoes;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils;

type

  { Funcoes }

  Funcoes = class
  public

  end;

  function IIF(Condition: Boolean; TrueResult, FalseResult: variant): Variant;


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

