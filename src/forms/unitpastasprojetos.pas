unit UnitPastasProjetos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strutils, memds, db, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons, ActnList, DBGrids,
  CustomDrawnControls, CustomDrawnDrawers, CustomDrawn_Android, UnitVariaveisGlobais;

type

  { TPastasProjetos }

  TPastasProjetos = class(TForm)
    ActFolder : TAction;
    ActAddFile : TAction;
    ActNewScene : TAction;
    ActionList1 : TActionList;
    BtnNewScene : TSpeedButton;
    BtnAddFile : TSpeedButton;
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
    procedure ProjetoTreeDblClick(Sender : TObject);
  private


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

procedure TPastasProjetos.ActAddFileExecute(Sender : TObject);
var
  cenaNome : String;
  cena : TStringList;
begin
  nome := InputBox('Nome da Cena', 'Nome', '');
  cena := TStringList.Create;
  try
    cena.SaveToFile(Desktop.ProjetoPath + nome);
  finally
    FreeAndNil(cena);
  end;
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

