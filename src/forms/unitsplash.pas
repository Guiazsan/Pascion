unit UnitSplash;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, IniFiles;

type

  { TSplashForm }

  TSplashForm = class(TForm)
    Image1: TImage;
    ProgressBar1: TProgressBar;
    procedure FormActivate(Sender: TObject);
  private
    INIPath : TINIFile;
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
begin
  if FileExists(GetCurrentDir + '\Config.ini') then
  begin
    Application.CreateForm(TDesktop,Desktop);
    try
      Desktop.ShowModal;
      SplashForm.Visible := false;
    finally
      FreeAndNil(Desktop);
      Close;
    end;
  end
  else
    begin
      Application.CreateForm(TStartForm,StartForm);
      try
        SplashForm.Visible := false;
        StartForm.ShowModal;
      finally
        FreeAndNil(StartForm);
      end;
  end
end;

end.

