program Love2DIDE;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, UnitDesktop, UnitSplash, UnitStart, UnitLuaEditor,
  UnitVariaveisGlobais, UnitFuncoes;

{$R *.res}

begin
  Application.Title := 'Pasciön';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TSplashForm, SplashForm);
  Application.CreateForm(TDesktop, Desktop);
  Application.CreateForm(TStartForm, StartForm);
  Application.CreateForm(TLuaEditor, LuaEditor);

  Application.Run;
end.

