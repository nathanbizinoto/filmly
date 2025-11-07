import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Inicializa o databaseFactory para web
void initDatabaseForWeb() {
  // Define o databaseFactory para usar a implementação web
  // O sqflite_common_ffi_web já inicializa automaticamente
  databaseFactory = databaseFactoryFfiWeb;
}
