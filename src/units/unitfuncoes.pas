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
  function multif(condicoes : array of boolean; resultados : array of variant): Variant;


implementation

{ Funcoes }

function IIF(Condition: Boolean; TrueResult, FalseResult: variant): Variant;
begin
  if Condition then
    Result := TrueResult
  else
    Result := FalseResult;
end;

function multif(condicoes : array of boolean; resultados : array of variant
  ) : Variant;
var i : Integer;
begin
  result := false;
  if Length(condicoes) <> Length(resultados) then
    raise Exception.Create('Número de condições não condiz com número de resultados');

  for i := 0 to Pred(Length(condicoes)) do
  begin
    if condicoes[i] then
      result := resultados[i];
  end;
end;

end.

