unit unitPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  DBCtrls, ExtCtrls, Menus, unitGerenciaFichas, SQLite3Conn, SQLDB, DB;

type

  { TfoPrincipal }

  TfoPrincipal = class(TForm)
    btGerenciarFichas: TButton;
    cbOpcao: TComboBox;
    dsTarefaRegistro: TDataSource;
    edTarefa: TDBEdit;
    grListaTarefas: TDBGrid;
    nvTarefas: TDBNavigator;
    dsFichasLista: TDataSource;
    grFichasLista: TDBGrid;
    coFichasLista: TSQLite3Connection;
    quFichasLista: TSQLQuery;
    quFichasListacodigoficha: TAutoIncField;
    quFichasListanomeficha: TStringField;
    coTarefaRegistro: TSQLite3Connection;
    quTarefaRegistro: TSQLQuery;
    quTarefaRegistrocodigoficha: TLongintField;
    quTarefaRegistrocodigotarefa: TAutoIncField;
    quTarefaRegistronometarefa: TStringField;
    quTarefaRegistroopcaotarefa: TStringField;
    rgFiltro: TRadioGroup;
    trTarefaRegistro: TSQLTransaction;
    trFichasLista: TSQLTransaction;
    procedure btGerenciarFichasClick(Sender: TObject);
    procedure cbOpcaoChange(Sender: TObject);
    procedure dsFichasListaDataChange(Sender: TObject; Field: TField);
    procedure dsTarefaRegistroDataChange(Sender: TObject; Field: TField);
    procedure FormShow(Sender: TObject);
    procedure nvTarefasClick(Sender: TObject; Button: TDBNavButtonType);
    procedure quFichasListaAfterOpen(DataSet: TDataSet);
    procedure quTarefaRegistroAfterPost(DataSet: TDataSet);
    procedure quTarefaRegistroBeforePost(DataSet: TDataSet);
    procedure rgFiltroClick(Sender: TObject);
  private

  public

  end;

var
  foPrincipal: TfoPrincipal;

implementation

{$R *.lfm}

{ TfoPrincipal }

//ABRE O GERENCIADOR DE FICHAS
procedure TfoPrincipal.btGerenciarFichasClick(Sender: TObject);
begin
  //fecha a conexao de fichas na tela principal
  coFichasLista.Connected:=False;
  coTarefaRegistro.Connected:=False;

  //abre o gerenciador de fichas
  foGerenciaFichas.ShowModal;
end;

//ABRE A TABELA PARA ATUALIZACAO
procedure TfoPrincipal.cbOpcaoChange(Sender: TObject);
var
  opcao: Integer;
begin
  if cbOpcao.ItemIndex = 0 then
    opcao:=0
  else
    opcao:=1;

  quTarefaRegistro.Edit;
  cbOpcao.ItemIndex:=opcao;
end;

//MUDA A LISTA DE TAREFAS PARA CADA FICHA SELECIONADA
procedure TfoPrincipal.dsFichasListaDataChange(Sender: TObject; Field: TField);
begin
  if quFichasLista.RecordCount > 0 then
    begin
      if rgFiltro.ItemIndex = 0 then
        begin
          coTarefaRegistro.Connected:=False;
          quTarefaRegistro.SQL.Text:='SELECT * FROM TAREFA WHERE codigoficha='+IntToStr(quFichasListacodigoficha.Value);
          quTarefaRegistro.Open;
        end
      else if rgFiltro.ItemIndex = 1 then
        begin
          coTarefaRegistro.Connected:=False;
          quTarefaRegistro.SQL.Text:='SELECT * FROM TAREFA WHERE codigoficha='+IntToStr(quFichasListacodigoficha.Value)+
                                             ' AND opcaotarefa="Para fazer"';
          quTarefaRegistro.Open;
        end
      else
      begin
        coTarefaRegistro.Connected:=False;
        quTarefaRegistro.SQL.Text:='SELECT * FROM TAREFA WHERE codigoficha='+IntToStr(quFichasListacodigoficha.Value)+
                                             ' AND opcaotarefa="Feito"';
        quTarefaRegistro.Open;
      end;
    end
  else
    begin
      coTarefaRegistro.Connected:=False;
    end;

  //poe o focu no componente de inserção de tarefa
  edTarefa.SetFocus;
end;

//ATUALIZA A OPÇÃO QUANDO MUDA O ITEM DA LISTA
procedure TfoPrincipal.dsTarefaRegistroDataChange(Sender: TObject; Field: TField
  );
begin
  //muda o combobox de feito/nao feito de acordo com o valor selecionado na tarefa
  if quTarefaRegistroopcaotarefa.Value = 'Feito' then
    cbOpcao.ItemIndex:=1
  else
    cbOpcao.ItemIndex:=0;

  //poe o focu no componente de inserção de tarefa
  edTarefa.SetFocus;
end;

//CONFIGURA AS CONEXOES NA ABERTURA DO PROGRAMA
procedure TfoPrincipal.FormShow(Sender: TObject);
begin
  //configura as conexoes
  coFichasLista.Connected:=False;
  coTarefaRegistro.Connected:=False;
  coFichasLista.DatabaseName:=GetCurrentDir+'\base.db';
  coTarefaRegistro.DatabaseName:=GetCurrentDir+'\base.db';

  //abre as conexoes
  quFichasLista.SQL.Text:='SELECT * FROM FICHA ORDER BY CODIGOFICHA DESC';
  quFichasLista.Open;

  //seleciona a primeira ficha da lista
  quFichasLista.First;
end;

//ao escolher inserir nova tarefa seleciona o componente edit
procedure TfoPrincipal.nvTarefasClick(Sender: TObject; Button: TDBNavButtonType
  );
begin
  if Button = nbInsert then
    edTarefa.SetFocus;
end;

//AO ABRIR A PESQUISA AQUI POSICIONA O REGISTRO NO ULTIMO REGISTRO FEITO
procedure TfoPrincipal.quFichasListaAfterOpen(DataSet: TDataSet);
begin
  quFichasLista.First;
end;

//CONFIGURA TUDO DEPOIS DE FAZER O REGISTRO/ATUALIZACAO
procedure TfoPrincipal.quTarefaRegistroAfterPost(DataSet: TDataSet);
begin
  //fazer a atualização do banco de dados
  quTarefaRegistro.ApplyUpdates;
  trTarefaRegistro.CommitRetaining;

  //abre a lista de fichas
  quFichasLista.Open;
  quFichasLista.First;
end;

//CONFIGURA TUDO ANTES DE FAZER O REGISTRO/ATUALIZACAO
procedure TfoPrincipal.quTarefaRegistroBeforePost(DataSet: TDataSet);
begin
  //salva os dados
  quTarefaRegistroopcaotarefa.Value:=cbOpcao.Items[cbOpcao.ItemIndex];
  quTarefaRegistrocodigoficha.Value:=quFichasListacodigoficha.Value;

  //fecha a conexao que lista fichas
  coFichasLista.Connected:=False;
end;

//AO MUDAR O FILTRO MUDA OS VALORER DA LISTA
procedure TfoPrincipal.rgFiltroClick(Sender: TObject);
begin
  if quFichasLista.RecordCount > 0 then
    begin
      if rgFiltro.ItemIndex = 0 then //TODOS
        begin
          coTarefaRegistro.Connected:=False;
          quTarefaRegistro.SQL.Text:='SELECT * FROM TAREFA WHERE codigoficha='+IntToStr(quFichasListacodigoficha.Value);
          quTarefaRegistro.Open;
        end
      else if rgFiltro.ItemIndex = 1 then //PARA FAZER
        begin
          coTarefaRegistro.Connected:=False;
          quTarefaRegistro.SQL.Text:='SELECT * FROM TAREFA WHERE codigoficha='+IntToStr(quFichasListacodigoficha.Value)+
                                             ' AND opcaotarefa="Para fazer"';
          quTarefaRegistro.Open;
        end
      else
      begin  //FEITOS
        coTarefaRegistro.Connected:=False;
        quTarefaRegistro.SQL.Text:='SELECT * FROM TAREFA WHERE codigoficha='+IntToStr(quFichasListacodigoficha.Value)+
                                             ' AND opcaotarefa="Feito"';
        quTarefaRegistro.Open;
      end;
    end
  else
    begin
      coTarefaRegistro.Connected:=False;
    end;
end;

end.

