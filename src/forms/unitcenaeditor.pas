unit UnitCenaEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, strutils, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Buttons, ActnList, DBGrids, LCLType, DBCtrls,
  KDBGrids, db, BufDataset, UnitLuaEditor;

type

  { TCenaEditor }
  TObjetoCena = class(TObject)
    tipo, texto, caminho, linha : String;
    x, y, r, w, h : Integer;
    componente : TControl;
  end;

  TObjetosCena = specialize TFPGObjectList<TObjetoCena>;

  TCenaEditor = class(TForm)
    ActImagem: TAction;
    ActTexto: TAction;
    ActRetangulo: TAction;
    ActionList1: TActionList;
    BDSInspetorAtributo : TStringField;
    BDSInspetorTIpo : TStringField;
    BDSInspetorValor : TStringField;
    BtnImage: TToggleBox;
    BtnApagar : TToggleBox;
    BtnMover : TToggleBox;
    BtnMouse : TToggleBox;
    BtnWidth : TToggleBox;
    BtnRect: TToggleBox;
    BtnText: TToggleBox;
    BDSInspetor : TBufDataset;
    BtnHeigh : TToggleBox;
    DsInspetor : TDataSource;
    GridInspetor : TDBGrid;
    GBInspetor : TGroupBox;
    lbObjeto : TLabel;
    PageControl1 : TPageControl;
    PnScreen : TPanel;
    PnTools: TPanel;
    ScrollBox1 : TScrollBox;
    TabSheet1 : TTabSheet;
    TabCodigo : TTabSheet;
    procedure BDSInspetorAfterPost(DataSet : TDataSet);
    procedure BDSInspetorValorChange(Sender : TField);
    procedure BtnRectClick(Sender: TObject);
    procedure FormCreate(Sender : TObject);
    procedure FormKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState
      );
    procedure GridInspetorCellClick(Column : TColumn);
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
    procedure ExitCombo(Sender : TObject);
    procedure ChangeCombo(Sender : TObject);
  private
    FCaminho, FNome   : String;
    Objetos           : TStringList;
    ObjetosCena       : TObjetosCena;
    ObjetoSelecionado : TObjetoCena;
    MouseX, MouseY    : Integer;
    LuaTela           : TLuaEditor;
  public
    procedure AbrirEditor(Caminho, Nome : String);
    procedure LerObjetos;

  end;

var
  CenaEditor : TCenaEditor;

implementation

uses UnitDesktop, UnitVariaveisGlobais, UnitFuncoes;

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

procedure TCenaEditor.BDSInspetorValorChange(Sender : TField);
var i : Integer;
begin
  if (BDSInspetor.FieldByName('Tipo').AsString = 'Int') and
     not(TryStrToInt(Sender.AsString, i)) then
     Sender.AsString := '';

end;

procedure TCenaEditor.BDSInspetorAfterPost(DataSet : TDataSet);
var bm : TBookMark;
begin
  inherited;
  bm := BDSInspetor.GetBookmark;
  if BDSInspetor.Locate('Atributo', 'X', []) then
  begin
    ObjetoSelecionado.x := StrToIntDef(BDSInspetor.FieldByName('Valor').AsString, 0);
    ObjetoSelecionado.componente.Left := ObjetoSelecionado.x;
  end;

  if BDSInspetor.Locate('Atributo', 'Y', []) then
  begin
    ObjetoSelecionado.y := StrToIntDef(BDSInspetor.FieldByName('Valor').AsString, 0);
    ObjetoSelecionado.componente.Top := ObjetoSelecionado.y;
  end;

  if BDSInspetor.Locate('Atributo', 'Largura', []) then
  begin
    ObjetoSelecionado.w := StrToIntDef(BDSInspetor.FieldByName('Valor').AsString, 0);
    ObjetoSelecionado.componente.Width := ObjetoSelecionado.w;
  end;

  if BDSInspetor.Locate('Atributo', 'Altura', []) then
  begin
    ObjetoSelecionado.h := StrToIntDef(BDSInspetor.FieldByName('Valor').AsString, 0);
    ObjetoSelecionado.componente.Height := ObjetoSelecionado.h;
  end;

  if ObjetoSelecionado.tipo = 'text' then
  begin
    if BDSInspetor.Locate('Atributo', 'Texto', []) then
    begin
      ObjetoSelecionado.texto := BDSInspetor.FieldByName('Valor').AsString;
      TLabel(ObjetoSelecionado.componente).Caption := ObjetoSelecionado.texto;
    end;
  end;

  if AnsiMatchStr(ObjetoSelecionado.tipo, ['frect', 'lrect']) then
  begin
    if BDSInspetor.Locate('Atributo', 'Tipo', []) then
    begin
      ObjetoSelecionado.tipo := BDSInspetor.FieldByName('Valor').AsString;
      if ObjetoSelecionado.tipo = 'frect' then
      begin
        TShape(ObjetoSelecionado.componente).Pen.Style   := psClear;
        TShape(ObjetoSelecionado.componente).Brush.Style := bsSolid;
      end
      else if ObjetoSelecionado.tipo = 'lrect' then
      begin
        TShape(ObjetoSelecionado.componente).Pen.Style   := psSolid;
        TShape(ObjetoSelecionado.componente).Brush.Style := bsClear;
        TShape(ObjetoSelecionado.componente).Pen.Color   := clWhite;
      end;
    end;
  end;
  BDSInspetor.GotoBookmark(bm);
end;

procedure TCenaEditor.FormCreate(Sender : TObject);
begin
  Objetos          := TStringList.Create;
  ObjetosCena      := TObjetosCena.Create();
  lbObjeto.Caption := '';
  BtnMouse.Checked := True;
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

procedure TCenaEditor.GridInspetorCellClick(Column : TColumn);
var combo : TDBComboBox;
begin
  //
  if (BDSInspetor.FieldByName('Tipo').AsString = 'Cmb') then
  begin
    combo := TDBComboBox.Create(nil);
    combo.Parent := GBInspetor;
    combo.Left   := GridInspetor.Left + GridInspetor.Columns[0].Width;
    combo.Top    := GridInspetor.Top + (Pred(BDSInspetor.RecNo) * GridInspetor.DefaultRowHeight);
    combo.Height := GridInspetor.DefaultRowHeight;
    combo.Width  := Column.Width + 2;
    combo.OnExit := @ExitCombo;
    combo.OnChange := @ChangeCombo;
    combo.Font.Size := GridInspetor.Font.Size;

    if AnsiMatchStr(BDSInspetor.FieldByName('Valor').AsString, ['frect', 'lrect']) then
    begin
      combo.Items.Add('frect');
      combo.Items.Add('lrect');
    end;

    combo.SetFocus;
    combo.DataSource := DsInspetor;
    combo.DataField := 'Valor';
    //ActiveControl := combo;
  end;
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
  if BtnText.Checked or BtnRect.Checked or BtnImage.Checked then
  begin
    if BtnText.Checked then
      objetoTexto := InputBox('Texto', 'Texto', '');

    Objeto            := TObjetoCena.Create;
    Objeto.x          := X;
    Objeto.y          := Y;
    if BtnText.Checked then
    begin
      Objeto.tipo       := 'text';
      Objeto.texto      := objetoTexto;
      Objeto.componente := TLabel.Create(nil);
    end
    else if BtnRect.Checked then
    begin
      Objeto.tipo       := 'frect';
      Objeto.componente := TShape.Create(nil);
      Objeto.h          := Objeto.componente.Height;
      Objeto.w          := Objeto.componente.Width;
    end
    else if BtnImage.Checked then
    begin
      Objeto.tipo       := 'img';
      Objeto.componente := TImage.Create(nil);
    end;
    with Objeto.componente do
    begin
      Left        := X;
      Top         := Y;
      if BtnText.Checked then
      begin
        Caption     := objetoTexto;
        Font.Color  := clWhite;
      end;
      Parent      := PnScreen;
      OnMouseMove := @MoverObjetos;
      OnMouseUp   := @SoltarObjeto;
      OnClick     := @ClickObjeto;
    end;

    objetoLinha := 'objeto['+ IntToStr(Objetos.Count + 1) +'] = {};'+
      'objeto['+ IntToStr(Objetos.Count + 1) +'].tipo = '+ QuotedStr(multif([BtnText.Checked, BtnRect.Checked, BtnImage.Checked],['text', 'frect', 'img'])) + ';'+
      'objeto['+ IntToStr(Objetos.Count + 1) +'].x = ' + IntTostr(X) + ';'+
      'objeto['+ IntToStr(Objetos.Count + 1) +'].y = '+ IntToStr(Y) + ';'+
      IIF(BtnText.Checked, 'objeto['+ IntToStr(Objetos.Count + 1) +'].texto = '+ QuotedStr(objetoTexto) + ';', '')+
      IIF(BtnRect.Checked, 'objeto['+ IntToStr(Objetos.Count + 1) +'].h = '+ IntToStr(Objeto.h) + ';' , '')+
      IIF(BtnRect.Checked, 'objeto['+ IntToStr(Objetos.Count + 1) +'].w = '+ IntToStr(Objeto.w) + ';' , '');

    Objetos.Add(objetoLinha);
    Objeto.linha      := objetoLinha;
    ObjetosCena.Add(Objeto);
    ObjetoSelecionado := Objeto;
    InspecionarObjeto;
  end;
  Objetos.SaveToFile(FCaminho);
  LuaTela.CarregarArquivo;
end;

procedure TCenaEditor.MoverObjetos(Sender : TObject; Shift : TShiftState; X,
  Y : Integer);
begin
  if BtnMover.Checked then
  begin
    TControl(Sender).Cursor := crSizeAll;
    if (ssLeft in Shift) then
    begin
      TControl(Sender).Left :=
        Mouse.CursorPos.x - PnScreen.ClientToScreen(Point(0,0)).x - trunc(TControl(Sender).Width/2);

      TControl(Sender).Top  :=
        Mouse.CursorPos.y - PnScreen.ClientToScreen(Point(0,0)).y - trunc(TControl(Sender).Height/2);
    end;
  end
  else if BtnWidth.Checked then
  begin
    TControl(Sender).Cursor := crSizeWE;
    if (ssLeft in Shift) then
    begin
      TControl(Sender).Width := TControl(Sender).Width + (X - MouseX);
    end;
  end
  else if BtnHeigh.Checked then
    begin
      TControl(Sender).Cursor := crSizeNS;
      if (ssLeft in Shift) then
      begin
        TControl(Sender).Height := TControl(Sender).Height + (Y - MouseY);
      end;
    end
  else
    TControl(Sender).Cursor := crDefault;

  MouseX := X;
  MouseY := Y;
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
        w := TControl(Sender).Width;
        h := TControl(Sender).Height;
      end;
      ReescreverObjeto(ObjetosCena.Items[i]);
    end;
end;

procedure TCenaEditor.ReescreverObjeto(Objeto : TObjetoCena);
var texto : String;
begin
  texto := Objeto.linha;
  texto := ReplaceBetween(texto, IntToStr(Objeto.x), '].x =', ';');
  texto := ReplaceBetween(texto, IntToStr(Objeto.y), '].y =', ';');
  texto := ReplaceBetween(texto, IntToStr(Objeto.w), '].w =', ';');
  texto := ReplaceBetween(texto, IntToStr(Objeto.h), '].h =', ';');
  if Objeto.tipo = 'text' then
    texto := ReplaceBetween(texto, QuotedStr(Objeto.texto), '].texto =', ';');

  texto := ReplaceBetween(texto, QuotedStr(Objeto.tipo), '].tipo =', ';');

  Objetos.Strings[Objetos.IndexOf(Objeto.Linha)] := texto;
  Objeto.linha := texto;
  Objetos.SaveToFile(FCaminho);
end;

procedure TCenaEditor.ClickObjeto(Sender : TObject);
var i : Integer;
    obj : TObjetoCena;
begin
  if BtnMouse.Checked then
    for i := 0 to Pred(ObjetosCena.Count) do
      if ObjetosCena.Items[i].componente = TControl(Sender) then
      begin
        ObjetoSelecionado := ObjetosCena.Items[i];
        InspecionarObjeto;
        Exit;
      end;

  if BtnApagar.Checked then
    for i := 0 to Pred(ObjetosCena.Count) do
      if ObjetosCena.Items[i].componente = TControl(Sender) then
      begin
        obj := ObjetosCena.Items[i];
        Objetos.Delete(Objetos.IndexOf(ObjetosCena.Items[i].linha));
        ObjetosCena.Delete(i);
        FreeAndNil(obj);
        TControl(Sender).Visible := false;
        Exit;
      end;
end;

procedure TCenaEditor.InspecionarObjeto;
begin
  BDSInspetor.Close;
  lbObjeto.Caption := '';
  BDSInspetor.DisableControls;
  BDSInspetor.CreateDataset;
  if Assigned(ObjetoSelecionado) then
  begin
    lbObjeto.Caption := ObjetoSelecionado.tipo;
    BDSInspetor.Append;
    BDSInspetor.FieldByName('Atributo').AsString := 'X';
    BDSInspetor.FieldByName('Valor').AsString := IntToStr(ObjetoSelecionado.x);
    BDSInspetor.FieldByName('Tipo').AsString := 'Int';

    BDSInspetor.Append;
    BDSInspetor.FieldByName('Atributo').AsString := 'Y';
    BDSInspetor.FieldByName('Valor').AsString := IntToStr(ObjetoSelecionado.y);
    BDSInspetor.FieldByName('Tipo').AsString := 'Int';

    BDSInspetor.Append;
    BDSInspetor.FieldByName('Atributo').AsString := 'Largura';
    BDSInspetor.FieldByName('Valor').AsString := IntToStr(ObjetoSelecionado.w);
    BDSInspetor.FieldByName('Tipo').AsString := 'Int';

    BDSInspetor.Append;
    BDSInspetor.FieldByName('Atributo').AsString := 'Altura';
    BDSInspetor.FieldByName('Valor').AsString := IntToStr(ObjetoSelecionado.h);
    BDSInspetor.FieldByName('Tipo').AsString := 'Int';

    if ObjetoSelecionado.tipo = 'text' then
    begin
      BDSInspetor.Append;
      BDSInspetor.FieldByName('Atributo').AsString := 'Texto';
      BDSInspetor.FieldByName('Valor').AsString := ObjetoSelecionado.texto;
      BDSInspetor.FieldByName('Tipo').AsString := 'Str';
    end;

    if AnsiMatchStr(ObjetoSelecionado.tipo, ['frect', 'lrect']) then
    begin
      BDSInspetor.Append;
      BDSInspetor.FieldByName('Atributo').AsString := 'Tipo';
      BDSInspetor.FieldByName('Valor').AsString := ObjetoSelecionado.tipo;
      BDSInspetor.FieldByName('Tipo').AsString := 'Cmb';
    end;
  end;
  BDSInspetor.First;
  BDSInspetor.EnableControls;
end;

procedure TCenaEditor.ExitCombo(Sender : TObject);
begin
  TControl(Sender).Visible := False;
  FreeAndNil(Sender);
end;

procedure TCenaEditor.ChangeCombo(Sender : TObject);
begin
  BDSInspetor.Post;
end;

procedure TCenaEditor.AbrirEditor(Caminho, Nome : String);
var
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
   Objetos.LoadFromFile(caminho);
   LerObjetos;
end;

procedure TCenaEditor.LerObjetos;
var
  codigo : TStringList;
  i      : Integer;
  Objeto : TObjetoCena;
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

      Objeto.linha := Objetos.Strings[i];

      texto := Objeto.tipo;

      if Objeto.tipo = 'text' then
      begin
        Objeto.texto := ReplaceStr(Trim(Copy(
        Objetos.Strings[i], Pos('.texto =', Objetos.Strings[i])+ 8 ,
        nextPos(Objetos.Strings[i], ';', Pos('.texto =', Objetos.Strings[i])+ 8))), Char(39), '');

        Objeto.componente            := TLabel.Create(nil);
        Objeto.componente.Font.Color := clWhite;
        Objeto.componente.Caption    := Objeto.texto;
      end;

      if Objeto.tipo = 'frect' then
      begin
        Objeto.componente := TShape.Create(nil);
        TShape(Objeto.componente).Pen.Style := psClear;
      end;

      if Objeto.tipo = 'lrect' then
      begin
        Objeto.componente := TShape.Create(nil);
        TShape(Objeto.componente).Pen.Style   := psSolid;
        TShape(Objeto.componente).Brush.Style := bsClear;
        TShape(Objeto.componente).Pen.Color   := clWhite;
      end;

      if Assigned(Objeto.componente) then
        with Objeto.componente do
        begin
          Parent      := PnScreen;
          Left        := Objeto.x;
          Top         := Objeto.y;
          Width       := Objeto.w;
          Height      := Objeto.h;
          OnMouseMove := @MoverObjetos;
          OnMouseUp   := @SoltarObjeto;
          OnClick     := @ClickObjeto;
          ObjetosCena.Add(Objeto);
        end;
    end;
end;

end.

