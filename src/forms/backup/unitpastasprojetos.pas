unit UnitPastasProjetos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, strutils, memds, db, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Buttons, ActnList, Grids, DBGrids,
  UnitVariaveisGlobais;

type

  { TPastasProjetos }

  TPastasProjetos = class(TForm)
    ActFolder : TAction;
    ActAddFile : TAction;
    ActNewScene : TAction;
    ActionList1 : TActionList;
    BtnNewScene : TSpeedButton;
    BtnAddFile : TSpeedButton;
    DSCenas : TDataSource;
    DBGrid1 : TDBGrid;
    GBProjeto : TGroupBox;
    ImageList1 : TImageList;
    MDSCenas : TMemDataset;
    PageControl1 : TPageControl;
    Panel1 : TPanel;
    ProjetoTree : TTreeView;
    BtnNewFolder : TSpeedButton;
    TabPastas : TTabSheet;
    TabSheet1 : TTabSheet;
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

