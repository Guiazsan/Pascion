program Love2DIDE;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  cmem, Interfaces, // this includes the LCL widgetset
  Forms, memdslaz, UnitDesktop, UnitSplash, UnitStart, UnitLuaEditor,
  UnitVariaveisGlobais, UnitFuncoes, UnitPastasProjetos, UnitCenaEditor,
  unitLoveObjs, UnitProjConfig;

{$R *.res}

begin
  Application.Title := 'Pasciön';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TSplashForm, SplashForm);
  Application.CreateForm(TCenaEditor, CenaEditor);
  Application.Run;
end.
