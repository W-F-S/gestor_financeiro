// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class user_screen extends StatefulWidget {
  const user_screen({Key? key}) : super(key: key);

  @override
  User_Screen createState() => User_Screen();
}

/// Aqui é o corpo da tela user.
class User_Screen extends State<user_screen> {
  _recuperarBancoDados() async {
    final caminhoBancoDados = await getDatabasesPath();
    final localBancoDados = join(caminhoBancoDados, "database.bd");
    var bd = await openDatabase(
        localBancoDados,
        version: 2,
        onCreate: (db, dbVersaoRecente){
          db.execute("CREATE TABLE IF NOT EXISTS userData (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, email VARCHAR, senha VARCHAR); ");
          db.execute("CREATE TABLE IF NOT EXISTS cadBancos (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR, userId INTEGER NOT NULL,  FOREIGN KEY(userId) REFERENCES userData(id)); ");
          db.execute("CREATE TABLE IF NOT EXISTS transacoes (id INTEGER PRIMARY KEY AUTOINCREMENT, value INTEGER NOT NULL, userId INTEGER NOT NULL, bancoId INTEGER NOT NULL, type VARCHAR, FOREIGN KEY(userId) REFERENCES userData(id), FOREIGN KEY(bancoId) REFERENCES cadBancos(id)); ");
          
        }
    );
    return bd;
    //print("aberto: " + bd.isOpen.toString() );
  }

  _salvarDadosUser(String name, String email, String senha) async {
    Database bd = await _recuperarBancoDados();
    Map<String, dynamic> dadosUsuario = {
      "name" : name,
      "email" : email,
      "senha": senha
    };
    bd.insert("userData", dadosUsuario);
  }

  _salvarDadosBanco(String name, int userId) async {
    Database bd = await _recuperarBancoDados();
    Map<String, dynamic> dadosBanco = {
      "name" : name,
      "userId" : userId,
    };
    bd.insert("cadBancos", dadosBanco);
  }

  _salvarDadosTransacao(int value, int userId, int bancoId, String type, bool despesa) async {
    Database bd = await _recuperarBancoDados();
    if(despesa) value *= -1;
    Map<String, dynamic> dadosTransacao = {
      "value" : value,
      "userId" : userId,
      "bancoId" : bancoId,
      "type": type
    };
    bd.insert("userData", dadosTransacao);
  }

  _listarUsuarios() async{
    Database bd = await _recuperarBancoDados();
    List userData = await bd.rawQuery("SELECT * FROM userData"); //conseguimos escrever a query que quisermos
    for(var usu in userData){
      print(" id: "+usu['id'].toString() +
          " name: "+usu['name']+
          " email: "+usu['email']+
          " senha: "+usu['senha']);
    }
  }

  _listarBancos() async{
    Database bd = await _recuperarBancoDados();
    List userData = await bd.rawQuery("SELECT * FROM cadBancos"); //conseguimos escrever a query que quisermos
    for(var usu in userData){
      print(" id: "+usu['id'].toString() +
          " name: "+usu['name']+
          " userId: "+usu['userId'].toString());
    }
  }


  _listarTransacoes() async{
    Database bd = await _recuperarBancoDados();
    List userData = await bd.rawQuery("SELECT * FROM transacoes"); //conseguimos escrever a query que quisermos
    for(var usu in userData){
      print(" id: "+usu['id'].toString() +
          " value: "+usu['value'].toString()+
          " userId: "+usu['userId'].toString()+
          " bancoId: "+usu['bancoId'].toString()+
          " type: "+usu['type']);
    }
  }

  Future<int> _receitaUsuarioBanco(int userId, int bancoId) async{

    Database bd = await _recuperarBancoDados();
    List receita = await bd.rawQuery("SELECT SUM(value) FROM transacoes WHERE type='0' AND userId="+userId.toString()+"AND bancoId="+bancoId.toString()+";");
    //não sei se o valor userId.toString transforma o 0 para um '0' ou "0", então caso der error tentar conserta ou checar essa possibilidade
  
    return receita[0]['SUM(value)'];
    //coloquei o valor SUM(value) porque na criação da lista ele é o parametro mais provavel, se não der certo tenta com '0'
    
  }

  Future<int> _receitaUsuario(int userId) async{

    Database bd = await _recuperarBancoDados();
    List receita = await bd.rawQuery("SELECT SUM(value) FROM transacoes WHERE type='0' AND userId="+userId.toString()+";");
    //não sei se o valor userId.toString transforma o 0 para um '0' ou "0", então caso der error tentar conserta ou checar essa possibilidade
  
    return receita[0]['SUM(value)'];
    //coloquei o valor SUM(value) porque na criação da lista ele é o parametro mais provavel, se não der certo tenta com '0'
    
  }

  Future<int> _despesaUsuarioBanco(int userId, int bancoId) async{

    Database bd = await _recuperarBancoDados();
    List receita = await bd.rawQuery("SELECT SUM(value) FROM transacoes WHERE type!='0' AND userId="+userId.toString()+"AND bancoId="+bancoId.toString()+";");
    //não sei se o valor userId.toString transforma o 0 para um '0' ou "0", então caso der error tentar conserta ou checar essa possibilidade
  
    return receita[0]['SUM(value)'];
    //coloquei o valor SUM(value) porque na criação da lista ele é o parametro mais provavel, se não der certo tenta com '0'
    
  }

  Future<int> _despesaUsuario(int userId) async{

    Database bd = await _recuperarBancoDados();
    List receita = await bd.rawQuery("SELECT SUM(value) FROM transacoes WHERE type!='0' AND userId="+userId.toString()+";");
    //não sei se o valor userId.toString transforma o 0 para um '0' ou "0", então caso der error tentar conserta ou checar essa possibilidade
  
    return receita[0]['SUM(value)'];
    //coloquei o valor SUM(value) porque na criação da lista ele é o parametro mais provavel, se não der certo tenta com '0'
    
  }


  Future<int> _login(String email, String senha) async{

    Database bd = await _recuperarBancoDados();

    List user = await bd.rawQuery("SELECT id FROM userData WHERE email="+email+" AND senha="+senha+";"); 
    
    if(user.isEmpty) return 0;

    return user[0]['id'];
    
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _controllernome = TextEditingController();
    TextEditingController _controlleremail = TextEditingController();
    TextEditingController _controllersenha = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banco de dados"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        child: Column(
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: "Digite o nome: ",
              ),
              controller: _controllernome,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: "Digite o email: ",
              ),
              controller: _controlleremail,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: "Digite a senha: ",
              ),
              controller: _controllersenha,
            ),
            const SizedBox(height: 20,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                    child: const Text("Salvar um usuário"),
                    onPressed: (){
                      _salvarDadosUser(_controllernome.text, _controlleremail.text, _controllersenha.text);
                    }
                ),
                ElevatedButton(
                    child: const Text("Listar todos usuários"),
                    onPressed: (){
                      _listarUsuarios();
                    }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
