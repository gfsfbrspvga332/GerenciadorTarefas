program projectGerenciadorTarefas;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  unitPrincipal, unitGerenciaFichas { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TfoPrincipal, foPrincipal);
  Application.CreateForm(TfoGerenciaFichas, foGerenciaFichas);
  Application.Run;
end.
