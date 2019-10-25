unit UnitCenaEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, strutils, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Buttons, ActnList, DBGrids, LCLType, db,
  BufDataset, UnitLuaEditor;

type

  { TCenaEditor }
  TObjetoCena = class(TObject)
    tipo, texto, caminho, linha : String;
    x, y, r, w, h : Integer;
    componente : TControl;
  end;

  TObjetosCena = specialize TFPGObjectList<TObjetoCena>;

  //TObjetosCena = specialize TFPGMap<TObjetoCena, TControl>;

  TCenaEditor = class(TForm)
    ActImagem: TAction;
    ActTexto: TAction;
    ActRetangulo: TAction;
    ActionList1: TActionList;
    BDSInspetorAtributo : TStringField;
    BDSInspetorValor : TStringField;
    BtnImage: TToggleBox;
    BtnMover : TToggleBox;
    BtnMouse : TToggleBox;
    BtnRect: TToggleBox;
    BtnText: TToggleBox;
    BDSInspetor : TBufDataset;
    DsInspetor : TDataSource;
    GridInspetor : TDBGrid;
    GroupBox1 : TGroupBox;
    lbObjeto : TLabel;
    PageControl1 : TPageControl;
    PnScreen : TPanel;
    PnTools: TPanel;
    ScrollBox1 : TScrollBox;
    TabSheet1 : TTabSheet;
    TabCodigo : TTabSheet;
    procedure BtnRectClick(Sender: TObject);
    procedure FormCreate(Sender : TObject);
    procedure FormKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState
      );
    procedure GridInspetorEditingDone(Sender : TObject);
    procedure PnScreenClick(Sender : TObject);
    procedure PnScreenMouseDown(Sender : TObject; Button : TMouseButton;
      Shift : TShiftState; X, Y : Integer);
    procedure MoverObjetos(Sender : TObject; Shift : TShiftState;
      X, Y : Integer);
    procedure SoltarObjeto(Sender : TObject; Button : TMouseButton; Shift : TShiftState;
      X, Y : Integer);
    procedure ReescreverObjeto(Objeto : TObjetoCena);
    procedure ClickObjeto(Sender : TObject);
    procedure InspecionarObjeto;
  private
    FCaminho, FNome : String;
    Objetos : TStringList;
    ObjetosCena : TObjetosCena;
    ObjetoSelecionado : TObjetoCena;
  public
    procedure AbrirEditor(Caminho, Nome : String);
    procedure LerObjetos;

  end;

var
  CenaEditor : TCenaEditor;

implementation

uses UnitDesktop, UnitVariaveisGlobais;

{$R *.lfm}

{ TCenaEditor }

procedure TCenaEditor.BtnRectClick(Sender: TObject);
var i : Integer;
begin
  if TToggleBox(Sender).Checked = True then
    for i := 0 to Pred(PnTools.ControlCount) do
      if (PnTools.Controls[i] is TToggleBox) and (PnTools.Controls[i] <> Sender) then
        TToggleBox(PnTools.Controls[i]).Checked := false;

  if TToggleBox(Sender) <> BtnMouse then
  begin
    ObjetoSelecionado := nil;
    InspecionarObjeto;
  end;
end;

procedure TCenaEditor.FormCreate(Sender : TObject);
begin
  Objetos          := TStringList.Create;
  ObjetosCena      := TObjetosCena.Create();
  lbObjeto.Caption := '';
end;

procedure TCenaEditor.FormKeyDown(Sender : TObject; var Key : Word;
  Shift : TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    ObjetoSelecionado := nil;
    InspecionarObjeto;
  end;
end;

procedure TCenaEditor.GridInspetorEditingDone(Sender : TObject);
var bm : TBookMark;
begin
  inherited;
  bm := BDSInspetor.GetBookmark;
  BDSInspetor.Locate('Atributo', 'X', []);
  ObjetoSelecionado.x := StrToIntDef(BDSInspetor.FieldByName('Valor').AsString, 0);
  ObjetoSelecionado.componente.Left := ObjetoSelecionado.x;
  BDSInspetor.Locate('Atributo', 'Y', []);
  ObjetoSelecionado.y := StrToIntDef(BDSInspetor.FieldByName('Valor').AsString, 0);
  ObjetoSelecionado.componente.Top := ObjetoSelecionado.y;
  if ObjetoSelecionado.tipo = 'text' then
  begin
    BDSInspetor.Locate('Atributo', 'Texto', []);
    ObjetoSelecionado.texto := BDSInspetor.FieldByName('Valor').AsString;
    TLabel(ObjetoSelecionado.componente).Caption := ObjetoSelecionado.texto;
  end;
  BDSInspetor.GotoBookmark(bm);
end;

procedure TCenaEditor.PnScreenClick(Sender : TObject);
begin
  ObjetoSelecionado := nil;
  InspecionarObjeto;
end;

procedure TCenaEditor.PnScreenMouseDown(Sender : TObject;
  Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
var objetoLinha, objetoTexto : String;
    objeto : TObjetoCena;
begin
  if BtnText.Checked then
  begin
    objetoTexto := InputBox('Texto', 'Texto', '');
    objetoLinha := 'objeto['+ IntToStr(Objetos.Count + 1) +'] = {};'+
      'objeto['+ IntToStr(Objetos.Count + 1) +'].tipo = '+ QuotedStr('text') + ';'+
      'objeto['+ IntToStr(Objetos.Count + 1) +'].x = ' + IntTostr(X) + ';'+
      'objeto['+ IntToStr(Objetos.Count + 1) +'].y = '+ IntToStr(Y) + ';'+
      'objeto['+ IntToStr(Objetos.Count + 1) +'].texto = '+ QuotedStr(objetoTexto) + ';';

    Objetos.Add( objetoLinha );

    Objeto            := TObjetoCena.Create;
    Objeto.x          := X;
    Objeto.y          := Y;
    Objeto.tipo       := 'text';
    Objeto.texto      := objetoTexto;
    Objeto.linha      := objetoLinha;
    Objeto.componente := TLabel.Create(nil);
    with Objeto.componente do
    begin
      Left        := X;
      Top         := Y;
      Caption     := objetoTexto;
      Parent      := PnScreen;
      Font.Color  := clWhite;
      OnMouseMove := @MoverObjetos;
      OnMouseUp   := @SoltarObjeto;
      OnClick     := @ClickObjeto;
    end;
    ObjetosCena.Add(Objeto);
    ObjetoSelecionado := Objeto;
    InspecionarObjeto;
  end;
  Objetos.SaveToFile(FCaminho);
  //LerObjetos;
end;

procedure TCenaEditor.MoverObjetos(Sender : TObject; Shift : TShiftState; X,
  Y : Integer);
begin
  if (BtnMover.Checked) then
  begin
    TControl(Sender).Cursor := crCross;
    if (ssLeft in Shift) then
    begin
      TControl(Sender).Left :=
        Mouse.CursorPos.x - PnScreen.ClientToScreen(Point(0,0)).x;

      TControl(Sender).Top  :=
        Mouse.CursorPos.y - PnScreen.ClientToScreen(Point(0,0)).y;
    end;
  end
  else
    TControl(Sender).Cursor := crDefault;
end;

procedure TCenaEditor.SoltarObjeto(Sender : TObject; Button : TMouseButton;
  Shift : TShiftState; X, Y : Integer);
var i : Integer;
begin
  for i := 0 to Pred(ObjetosCena.Count) do
    if ObjetosCena.Items[i].componente = Sender then
    begin
      with ObjetosCena.Items[i] do
      begin
        x := TControl(Sender).Left;
        y := TControl(Sender).Top;
      end;
      ReescreverObjeto(ObjetosCena.Items[i]);
    end;
end;

procedure TCenaEditor.ReescreverObjeto(Objeto : TObjetoCena);
var texto : String;
  function ReplaceBetween(Src, sub, inicio, fim : String) : String;
  var tempText : String;
  begin
    tempText := Src.Substring(Pos(inicio, Src) + Length(inicio));
    tempText := tempText.Substring(Pos(fim, tempText) - 1);
    Result   :=
      Src.Substring(0, Pos(inicio, Src) + Length(inicio)) + sub + tempText;
  end;
begin
  texto := Objeto.linha;
  texto := ReplaceBetween(texto, IntToStr(Objeto.x), '].x =', ';');
  texto := ReplaceBetween(texto, IntToStr(Objeto.y), '].y =', ';');
  if Objeto.tipo = 'text' then
    texto := ReplaceBetween(texto, QuotedStr(Objeto.texto), '].texto =', ';');

  Objetos.Strings[Objetos.IndexOf(Objeto.Linha)] := texto;
  Objeto.linha := texto;
  Objetos.SaveToFile(FCaminho);
end;

procedure TCenaEditor.ClickObjeto(Sender : TObject);
var i : Integer;
begin
  if BtnMouse.Checked then
  begin
    for i := 0 to Pred(ObjetosCena.Count) do
      if ObjetosCena.Items[i].componente = TControl(Sender) then
      begin
        ObjetoSelecionado := ObjetosCena.Items[i];
        InspecionarObjeto;
        Exit;
      end;

  end;
end;

procedure TCenaEditor.InspecionarObjeto;
begin
  BDSInspetor.Close;
  lbObjeto.Caption := '';

  if Assigned(ObjetoSelecionado) then
  begin
    BDSInspetor.CreateDataset;

    lbObjeto.Caption := ObjetoSelecionado.tipo;
    BDSInspetor.Append;
    BDSInspetor.FieldByName('Atributo').AsString := 'X';
    BDSInspetor.FieldByName('Valor').AsString := IntToStr(ObjetoSelecionado.x);

    BDSInspetor.Append;
    BDSInspetor.FieldByName('Atributo').AsString := 'Y';
    BDSInspetor.FieldByName('Valor').AsString := IntToStr(ObjetoSelecionado.y);

    if ObjetoSelecionado.tipo = 'text' then
    begin
      BDSInspetor.Append;
      BDSInspetor.FieldByName('Atributo').AsString := 'Texto';
      BDSInspetor.FieldByName('Valor').AsString := ObjetoSelecionado.texto;
    end;
  end;
end;

procedure TCenaEditor.AbrirEditor(Caminho, Nome : String);
var LuaTela : TLuaEditor;
    config  : TStringList;
    i       : Integer;
begin
  FCaminho                    := Caminho;
  FNome                       := Nome;
  LuaTela                     := TLuaEditor.Create(nil);
  LuaTela.SetCaminho(Caminho);
  LuaTela.CarregarArquivo;
  //LuaTela.GridLinhas.RowCount := LuaTela.RMEditor.Lines.Count;
  LuaTela.BorderStyle         := bsNone;
  LuaTela.Parent              := TabCodigo;
  LuaTela.Align               := alClient;
  LuaTela.Show;
  config := TStringList.Create;
  try
     config.LoadFromFile(Desktop.ProjetoPath + separadorPasta + 'conf.lua');
     config.Sorted := true;
     PnScreen.Width := 800;
     PnScreen.Height := 600;
     for I := 0 to Pred(config.Count) do
       if Pos('t.window.width', config.Strings[i]) <> 0 then
         PnScreen.Width :=  StrToInt(StringReplace(config.Strings[i].Substring(Pos('=', config.Strings[i]) + 1), ';', '', []));

     for I := 0 to Pred(config.Count) do
       if Pos('t.window.height', config.Strings[i]) <> 0 then
         PnScreen.Height :=  StrToInt(StringReplace(config.Strings[i].Substring(Pos('=', config.Strings[i]) + 1),';','', []));

   finally
     FreeAndNil(config);
   end;
   ScrollBox1.AutoScroll := True;
   LerObjetos;
end;

procedure TCenaEditor.LerObjetos;
var
  codigo : TStringList;
  i      : Integer;
  Objeto : TObjetoCena;
  lTexto : TLabel;
  texto : String;
  function nextPos(S : String; Sub : Char; posi : Integer) : Integer;
  var
    SubStr : String;
  begin
    SubStr := S.Substring(posi);
    result := Pos(Sub, SubStr);
  end;

begin
  for i := 0 to Pred(Objetos.Count) do
    if AnsiContainsStr(Objetos.Strings[i], 'objeto[') then
    begin
      Objeto := TObjetoCena.Create;

      Objeto.x := StrToIntDef(Trim(Copy(
        Objetos.Strings[i], Pos('.x =', Objetos.Strings[i])+ 4 ,
        nextPos(Objetos.Strings[i], ';', Pos('.x =', Objetos.Strings[i])+ 4))), 0);

      Objeto.y := StrToIntDef(Trim(Copy(
        Objetos.Strings[i], Pos('.y =', Objetos.Strings[i])+ 4 ,
        nextPos(Objetos.Strings[i], ';', Pos('.y =', Objetos.Strings[i])+ 4))), 0);

      Objeto.w := StrToIntDef(Trim(Copy(
        Objetos.Strings[i], Pos('.w =', Objetos.Strings[i])+ 4 ,
        nextPos(Objetos.Strings[i], ';', Pos('.w =', Objetos.Strings[i])+ 4))), 0);

      Objeto.h := StrToIntDef(Trim(Copy(
        Objetos.Strings[i], Pos('.h =', Objetos.Strings[i])+ 4 ,
        nextPos(Objetos.Strings[i], ';', Pos('.h =', Objetos.Strings[i])+ 4))), 0);

      Objeto.r := StrToIntDef(Trim(Copy(
        Objetos.Strings[i], Pos('.r =', Objetos.Strings[i])+ 4 ,
        nextPos(Objetos.Strings[i], ';', Pos('.r =', Objetos.Strings[i])+ 4))), 0);

      Objeto.tipo := ReplaceStr(Trim(Copy(
        Objetos.Strings[i], Pos('.tipo =', Objetos.Strings[i])+ 7 ,
        nextPos(Objetos.Strings[i], ';', Pos('.tipo =', Objetos.Strings[i])+ 7))), Char(39), '');

      texto := Objeto.tipo;

      if Objeto.tipo = 'text' then
      begin
        Objeto.texto := ReplaceStr(Trim(Copy(
        Objetos.Strings[i], Pos('.texto =', Objetos.Strings[i])+ 8 ,
        nextPos(Objetos.Strings[i], ';', Pos('.texto =', Objetos.Strings[i])+ 8))), Char(39), '');

        lTexto            := TLabel.Create(nil);
        lTexto.Parent     := PnScreen;
        lTexto.Left       := Objeto.x;
        lTexto.Top        := Objeto.y;
        lTexto.Width      := Objeto.w;
        lTexto.Height     := Objeto.h;
        lTexto.Font.Color := clWhite;
        lTexto.Caption    := Objeto.texto;
        ObjetosCena.Add(Objeto);
      end;
    end;
end;

end.

