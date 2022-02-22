unit unitGerenciaFichas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  DBCtrls, DBGrids;

type

  { TfoGerenciaFichas }

  TfoGerenciaFichas = class(TForm)
    coFichasRegistro: TSQLite3Connection;
    edNomeFicha: TDBEdit;
    grPrincipal: TDBGrid;
    nvPrincipal: TDBNavigator;
    dsFichasRegistro: TDataSource;
    quFichasRegistro: TSQLQuery;
    quFichasRegistrocodigoficha: TAutoIncField;
    quFichasRegistronomeficha: TStringField;
    trFichasRegistro: TSQLTransaction;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure quFichasRegistroAfterPost(DataSet: TDataSet);
  private

  public

  end;

var
  foGerenciaFichas: TfoGerenciaFichas;

implementation

{$R *.lfm}

{ TfoGerenciaFichas }

uses
  unitPrincipal;

//CONFIGURAÇÃO DE ABERTURA DO BANCO DE DADOS
procedure TfoGerenciaFichas.FormShow(Sender: TObject);
begin
  coFichasRegistro.Connected:=False;
  coFichasRegistro.DatabaseName:=GetCurrentDir+'\base.db';
  quFichasRegistro.SQL.Text:='SELECT * FROM FICHA';
  quFichasRegistro.Open;
  quFichasRegistro.Insert;
end;

//FECHA A CONEXAO ANTES DE SAIR DA TELA
procedure TfoGerenciaFichas.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  coFichasRegistro.Connected:=False;
  foPrincipal.quFichasLista.Open;
end;

//APLICA AS MUDANÇAS NO BANCO DE DADOS
procedure TfoGerenciaFichas.quFichasRegistroAfterPost(DataSet: TDataSet);
begin
  quFichasRegistro.ApplyUpdates;
  trFichasRegistro.CommitRetaining;
  quFichasRegistro.Refresh;
end;

end.

