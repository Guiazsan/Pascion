unit unitLoveObjs;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics;

type
  TDrawMode = (dmFill, dmLine);

type

  { TLoveGraphic }

  TLoveGraphic = class(TObject)
  private
    FDrawMode : TDrawMode;
    FX : Integer;
    FY : Integer;
  public
    property DrawMode : TDrawMode read FDrawMode Write FDrawMode;
    property x : Integer read FX write FX;
    property y : Integer read FY write FY;
    procedure setColor(r,g,b : Integer);
  end;

type
  TLGArc = class(TLoveGraphic)
  private
  public
  end;

type
  TLGCircle = class(TLoveGraphic)
  private
  public
  end;


implementation

{ TLoveGraphic }

procedure TLoveGraphic.setColor(r, g, b : Integer);
begin

end;

end.

