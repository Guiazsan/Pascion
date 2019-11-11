unit UnitProjConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, memds, BufDataset, db, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, DBCtrls, UnitDesktop;

type

  { TProjConfig }

  TProjConfig = class(TForm)
    BDSConfig : TBufDataset;
    BDSConfigresH : TLongintField;
    BDSConfigresW : TLongintField;
    Button1 : TButton;
    Button2 : TButton;
    DBEdit2 : TDBEdit;
    DSConfig : TDataSource;
    DBEdit1 : TDBEdit;
    GroupBox1 : TGroupBox;
    Label1 : TLabel;
    Label2 : TLabel;
    Panel1 : TPanel;
    procedure BDSConfigAfterPost(DataSet : TDataSet);
    procedure Button1Click(Sender : TObject);
    procedure Button2Click(Sender : TObject);
    procedure FormActivate(Sender : TObject);
  private
    config : TStringList;
    procedure CarregarConfig;

  public

  end;

var
  ProjConfig : TProjConfig;

implementation

uses UnitFuncoes, UnitVariaveisGlobais;

{$R *.lfm}

{ TProjConfig }

procedure TProjConfig.FormActivate(Sender : TObject);
begin
  BDSConfig.CreateDataset;
  CarregarConfig;
end;

procedure TProjConfig.Button2Click(Sender : TObject);
begin
  BDSConfig.Close;
  Close;
end;

procedure TProjConfig.Button1Click(Sender : TObject);
begin
  BDSConfig.Post;
  BDSConfig.Close;
  Close;
end;

procedure TProjConfig.BDSConfigAfterPost(DataSet : TDataSet);
var I : Integer;
begin
  for I := 0 to Pred(config.Count) do
    if Pos('t.window.width', config.Strings[i]) <> 0 then
      config.Strings[i] := ReplaceBetween(config.Strings[i], IntToStr(BDSConfigresW.AsInteger), 't.window.width = ', ';');

  for I := 0 to Pred(config.Count) do
    if Pos('t.window.height', config.Strings[i]) <> 0 then
      config.Strings[i] := ReplaceBetween(config.Strings[i], IntToStr(BDSConfigresH.AsInteger), 't.window.height = ', ';');

  config.SaveToFile(Desktop.ProjetoPath + separadorPasta + 'conf.lua');
end;

procedure TProjConfig.CarregarConfig;
var I : Integer;
begin
  config := TStringList.Create;
  try
    config.LoadFromFile(Desktop.ProjetoPath + separadorPasta + 'conf.lua');
    config.Sorted := true;
    BDSConfig.Append;

    for I := 0 to Pred(config.Count) do
      if Pos('t.window.width', config.Strings[i]) <> 0 then
        BDSConfigresW.AsInteger := StrToInt(StringReplace(config.Strings[i].Substring(Pos('=', config.Strings[i]) + 1), ';', '', []));

    for I := 0 to Pred(config.Count) do
      if Pos('t.window.height', config.Strings[i]) <> 0 then
        BDSConfigresH.AsInteger :=  StrToInt(StringReplace(config.Strings[i].Substring(Pos('=', config.Strings[i]) + 1),';','', []));

  finally
    FreeAndNil(config);
  end;
end;

end.

