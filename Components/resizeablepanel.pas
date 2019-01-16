unit ResizeablePanel;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, ExtCtrls, Controls;

type

  { TResizeablePanel }

  TResizeablePanel = class(TPanel)
  private
    LeftBar, RightBar, TopBar, BottomBar : TPanel;
    clicando, LSize, RSize, TopSize, BSize : boolean;
    procedure ResizeL(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
    procedure ResizeR(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
    procedure ResizeT(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
    procedure ResizeB(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
    procedure MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
    procedure MouseUP(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);


  protected

  public
    constructor Create(TheOwner: TComponent); override;
  published
    property LeftResize: Boolean read LSize write LSize;
    property RightResize: Boolean read RSize write RSize;
    property TopResize: Boolean read TopSize write TopSize;
    property BottomResize: Boolean read BSize write BSize;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard',[TResizeablePanel]);
end;

{ TResizeablePanel }

procedure TResizeablePanel.ResizeL(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if clicando then
  begin
    Self.Width := Self.Width - x;
    Self.Left := Self.Left + x;
  end;
end;

procedure TResizeablePanel.ResizeR(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if clicando then
    Self.Width := Self.Width + x;
end;

procedure TResizeablePanel.ResizeT(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if clicando then
  begin
    Self.Height := Self.Height - y;
    Self.Top := Self.Top + y;
  end;
end;

procedure TResizeablePanel.ResizeB(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if clicando then
    Self.Height := Self.Height + y;
end;

procedure TResizeablePanel.MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  clicando := True;
end;

procedure TResizeablePanel.MouseUP(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  clicando := False;
end;

constructor TResizeablePanel.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

    LeftBar := TPanel.Create(nil);
    with LeftBar do
    begin
      Parent := Self;
      Align  := alLeft;
      Width  := 2;
      Cursor := crSizeWE;
      OnMouseDown := @Self.MouseDown;
      OnMouseUp   := @self.MouseUp;
      OnMouseMove := @ResizeL;
    end;

    RightBar := TPanel.Create(nil);
    with RightBar do
    begin
      Parent := Self;
      Align  := alRight;
      Width  := 2;
      Cursor := crSizeWE;
      OnMouseDown := @Self.MouseDown;
      OnMouseUp   := @self.MouseUp;
      OnMouseMove := @ResizeR;
    end;

    TopBar := TPanel.Create(nil);
    with TopBar do
    begin
      Parent := Self;
      Align  := alTop;
      Height  := 2;
      Cursor := crSizeNS;
      OnMouseDown := @Self.MouseDown;
      OnMouseUp   := @self.MouseUp;
      OnMouseMove := @ResizeT;
    end;


    BottomBar := TPanel.Create(nil);
    with BottomBar do
    begin
      Parent := Self;
      Align  := alBottom;
      Height := 2;
      Cursor := crSizeNS;
      OnMouseDown := @Self.MouseDown;
      OnMouseUp   := @self.MouseUp;
      OnMouseMove := @ResizeB;
    end;
end;

end.
