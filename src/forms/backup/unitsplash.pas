unit UnitSplash;

{$mode objfpc}{$H+}

interface

uses
  cmem, Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, CustomDrawnControls, CustomDrawnDrawers,
  UnitVariaveisGlobais, IniFiles;

type

  { TSplashForm }

  TSplashForm = class(TForm)
    Image1: TImage;
    LbStatus: TLabel;
    procedure FormActivate(Sender: TObject);
  private
    Paths   : TStringList;
  public

  end;

var
  SplashForm: TSplashForm;

implementation

uses
  UnitDesktop, UnitStart;

{$R *.lfm}

{ TSplashForm }

procedure TSplashForm.FormActivate(Sender: TObject);
var INIPath : TINIFile;
    Drawner : TCDDrawer;
begin
  Drawner := TCDDrawer.Create;
  Drawner.PaletteKind := palFallback;
  LbStatus.Caption := 'Carregando Config';

  if FileExists(GetCurrentDir + separadorPasta + 'Config.ini') then
  begin
    INIPath := TIniFile.Create(GetCurrentDir + separadorPasta + 'Config.ini');
    try
      if (INIPath.ReadString('Project','Path','') <> '') and
        (INIPath.ReadString('Love2d','Path','') <> '') and
        FileExists(INIPath.ReadString('Project', 'Path', '')) then
      begin
        Application.CreateForm(TDesktop,Desktop);
        try
          SplashForm.Visible := false;
          Desktop.ShowModal;
        finally
          FreeAndNil(Desktop);
          Close;
        end;
      end;
    finally
      FreeAndNil(INIPath);
    end;
  end;

  Application.CreateForm(TStartForm,StartForm);
  try
    SplashForm.Visible := false;
    StartForm.ShowModal;
  finally
    FreeAndNil(StartForm);
  end;
end;

end.

