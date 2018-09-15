unit UnitDesktop;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ActnList, Menus, ExtCtrls, StdCtrls;

type

  { TDesktop }

  TDesktop = class(TForm)
    ActAbrir: TAction;
    ActParar: TAction;
    ActPlay: TAction;
    ActSalvarTudo: TAction;
    ActSalvar: TAction;
    ActSair: TAction;
    ActNovo: TAction;
    Actions: TActionList;
    GBProjeto: TGroupBox;
    GBComponentes: TGroupBox;
    GBPropriedades: TGroupBox;
    ImageList1: TImageList;
    LVComponentes: TListView;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    LCtrlPanel: TPanel;
    PageControl1: TPageControl;
    RCtrlPanel: TPanel;
    ToolBar1: TToolBar;
    BtnNovo: TToolButton;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    TVProject: TTreeView;
  private

  public

  end;

var
  Desktop: TDesktop;

implementation

{$R *.lfm}

end.

