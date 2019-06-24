unit UnitPastasProjetos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strutils, memds, db, BufDataset, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons, ActnList, DBGrids,
  CustomDrawnControls, CustomDrawnDrawers, CustomDrawn_Android,
  UnitVariaveisGlobais;

type

  { TPastasProjetos }

  TPastasProjetos = class(TForm)
    ActFolder : TAction;
    ActAddFile : TAction;
    ActNewScene : TAction;
    ActionList1 : TActionList;
    BDSCenasCaminho : TStringField;
    BDSCenasNome : TStringField;
    BtnNewScene : TSpeedButton;
    BtnAddFile : TSpeedButton;
    BDSCenas : TBufDataset;
    CDPageControl1 : TCDPageControl;
    CDTabSheet1 : TCDTabSheet;
    CDTabSheet2 : TCDTabSheet;
    DSCenas : TDataSource;
    DBGrid1 : TDBGrid;
    GBProjeto : TGroupBox;
    ImageList1 : TImageList;
    MDSCenas : TMemDataset;
    Panel1 : TPanel;
    ProjetoTree : TTreeView;
    BtnNewFolder : TSpeedButton;
    procedure ActAddFileExecute(Sender : TObject);
    procedure DBGrid1DblClick(Sender : TObject);
    procedure FormShow(Sender : TObject);
    procedure ProjetoTreeCustomDrawItem(Sender : TCustomTreeView;
      Node : TTreeNode; State : TCustomDrawState; var DefaultDraw : Boolean);
    procedure ProjetoTreeDblClick(Sender : TObject);
  private
    procedure CarregarCenas;
  public
    procedure popularTreeProjeto(ProjetoPath, ProjetoNome : String);
  end;

var
  PastasProjetos : TPastasProjetos;

implementation

uses UnitDesktop;

{$R *.lfm}

procedure TPastasProjetos.ProjetoTreeDblClick(Sender : TObject);
begin
  Desktop.AbrirCodigo(ProjetoTree.Selected.GetTextPath, ProjetoTree.Selected.Text);
  Desktop.PageControl1.PageIndex := CDPageControl1.PageCount;
end;

procedure TPastasProjetos.CarregarCenas;
var arquivo : TSearchRec;
    caminho : String;
begin
  BDSCenas.Close;

  if not BDSCenas.Active then
  begin
    BDSCenas.CreateDataset;
    BDSCenas.Open;
  end;

  caminho := Desktop.ProjetoPath + separadorPasta + 'Cenas' +
      separadorPasta +'*';

  if FindFirst(caminho, faAnyFile and faDirectory, arquivo) = 0 then
    repeat
      if (arquivo.Name <> '.') and (arquivo.Name <> '..') then
      begin
        if PosEx('.lcn', arquivo.Name) > 0 then
        begin
          BDSCenas.Append;
          BDSCenas.FieldByName('Nome').AsString := arquivo.Name;
          BDSCenas.FieldByName('Caminho').AsString := Desktop.ProjetoPath +
            separadorPasta + 'Cenas' + separadorPasta + arquivo.Name;
          BDSCenas.Post;
        end;
      end;
    until FindNext(arquivo) <> 0;
      FindClose(arquivo);
end;

procedure TPastasProjetos.ActAddFileExecute(Sender : TObject);
var
  cenaNome : String;
  cena : TStringList;
begin
  If not DirectoryExists(Desktop.ProjetoPath + separadorPasta + 'Cenas' ) then
    CreateDir(Desktop.ProjetoPath + separadorPasta + 'Cenas' );

  cenaNome := InputBox('Nome da Cena', 'Nome', '');
  cena := TStringList.Create;
  try
    cena.Add('function love.draw()');
    cena.Add('end');
    cena.SaveToFile(Desktop.ProjetoPath + separadorPasta + 'Cenas'
      + separadorPasta + cenaNome + '.lcn');
    CarregarCenas;
  finally
    FreeAndNil(cena);
  end;
end;

procedure TPastasProjetos.DBGrid1DblClick(Sender : TObject);
begin
  Desktop.AbrirCena(BDSCenasCaminho.AsString, BDSCenasNome.AsString);
end;

procedure TPastasProjetos.FormShow(Sender : TObject);
begin
  CarregarCenas;
end;

procedure TPastasProjetos.ProjetoTreeCustomDrawItem(Sender : TCustomTreeView;
  Node : TTreeNode; State : TCustomDrawState; var DefaultDraw : Boolean);
begin
  Canvas.Font.Color := clHighlight;
end;

procedure TPastasProjetos.popularTreeProjeto(ProjetoPath, ProjetoNome : String);
  procedure popularChilds(path : String; raiz : TTreeNode);
  var arquivo : TSearchRec;
      filho : TTreeNode;
  begin
    if FindFirst(path + separadorPasta +'*',faAnyFile and faDirectory, arquivo) = 0 then
      repeat
        if (arquivo.Name <> '.') and (arquivo.Name <> '..') then
        begin
          filho := ProjetoTree.Items.AddChild(raiz, arquivo.Name);
          filho.ImageIndex := 1;

          if (arquivo.Attr and faDirectory) = faDirectory then
          begin
            filho.ImageIndex := 0;
            popularChilds(path + separadorPasta + arquivo.Name, filho);
          end;

          if PosEx('.lua', arquivo.Name) > 0 then
            filho.ImageIndex := 2;

        end;
      until FindNext(arquivo) <> 0;
        FindClose(arquivo);
  end;
var
  raiz : TTreeNode;
begin
  raiz := ProjetoTree.Items.AddFirst(nil,ProjetoNome);
  popularChilds(ProjetoPath, raiz);
end;

end.

