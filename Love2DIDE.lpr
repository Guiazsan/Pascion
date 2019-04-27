program Love2DIDE;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cmem, cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, memdslaz, UnitDesktop, UnitSplash, UnitStart, UnitLuaEditor,
  UnitVariaveisGlobais, UnitFuncoes, UnitPastasProjetos, UnitCenaEditor, unitLoveObjs;

{$R *.res}

begin
  Application.Title := 'Pasciön';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TSplashForm, SplashForm);
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
