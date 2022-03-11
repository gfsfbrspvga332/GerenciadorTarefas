unit unitGerenciaFichas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics, Dialogs,
  DBCtrls, DBGrids, Menus;

type

  { TfoGerenciaFichas }

  TfoGerenciaFichas = class(TForm)
    coFichasRegistro: TSQLite3Connection;
    edNomeFicha: TDBEdit;
    grPrincipal: TDBGrid;
    miExcluir: TMenuItem;
    nvPrincipal: TDBNavigator;
    dsFichasRegistro: TDataSource;
    ppMenuFichas: TPopupMenu;
    quFichasRegistro: TSQLQuery;
    quFichasRegistrocodigoficha: TAutoIncField;
    quFichasRegistronomeficha: TStringField;
    coGeral: TSQLite3Connection;
    quGeral: TSQLQuery;
    trGeral: TSQLTransaction;
    trFichasRegistro: TSQLTransaction;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure miExcluirClick(Sender: TObject);
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
  //CONFIGURA O BANCO RESPONSAVEL POR DELETAR TODAS AS TAREFAS E A FICHA
  coGeral.Connected:=False;
  coGeral.DatabaseName:=GetCurrentDir+'\base.db';

  //CONFIGURA A LISTA DE FICHAS
  coFichasRegistro.Connected:=False;
  coFichasRegistro.DatabaseName:=GetCurrentDir+'\base.db';
  quFichasRegistro.SQL.Text:='SELECT * FROM FICHA';
  quFichasRegistro.Open;
  //quFichasRegistro.Insert;
  edNomeFicha.SetFocus;
end;




//EXCLUI TODAS AS TAREFAS E A FICHA PELO CODIGO
procedure TfoGerenciaFichas.miExcluirClick(Sender: TObject);
var
  codigo: Integer;
begin
  //PEGA O CODIGO
  codigo := quFichasRegistrocodigoficha.Value;

  //FECHA AS CONEXOES
  coFichasRegistro.Connected:=False;

  //DELETA TODOS AS FICHAS LIGADAS A ESTE CODIGO
  coGeral.Connected:=False;
  quGeral.SQL.Clear;
  quGeral.SQL.Text:='DELETE FROM TAREFA WHERE codigoficha=:CODIGO';
  quGeral.Params.ParamByName('CODIGO').Value:=codigo;
  quGeral.ExecSQL;
  trGeral.CommitRetaining;
  coGeral.Connected:=False;

  //DELETA ESTA FICHA
  coGeral.Connected:=False;
  quGeral.SQL.Clear;
  quGeral.SQL.Text:='DELETE FROM FICHA WHERE codigoficha=:CODIGO';
  quGeral.Params.ParamByName('CODIGO').Value:=codigo;
  quGeral.ExecSQL;
  trGeral.CommitRetaining;
  coGeral.Connected:=False;

  //REABRE A CONEXAO
  quFichasRegistro.Open;
end;





//FECHA A CONEXAO ANTES DE SAIR DA TELA
procedure TfoGerenciaFichas.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  coFichasRegistro.Connected:=False;
  foPrincipal.quFichasLista.Open;
  foPrincipal.quFichasLista.First;
end;

//APLICA AS MUDANÇAS NO BANCO DE DADOS
procedure TfoGerenciaFichas.quFichasRegistroAfterPost(DataSet: TDataSet);
begin
  quFichasRegistro.ApplyUpdates;
  trFichasRegistro.CommitRetaining;
  quFichasRegistro.Refresh;

  //ao terminar o registro deixa pronto para realizer outro
  quFichasRegistro.Open;
  quFichasRegistro.Insert;
  edNomeFicha.SetFocus;
end;

end.

