import 'dart:ffi';

import 'package:darlink/modules/navigation/home_screen.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:mongo_dart/mongo_dart.dart' as mongo;

import '../modules/authentication/login_screen.dart' as lg;
import 'Database_url.dart' as mg;
import 'package:fixnum/fixnum.dart';

const mongo_url =
    ('mongodb+srv://salimshatila21:UfXFh4SuoVCusLO8@cluster0.p3mm2.mongodb.net/seniorDBtest1?retryWrites=true&w=majority&appName=Cluster0');
int test = 0;
int largest_id = 0;

class MongoDatabase {
  static connect() async {
    var db = await Db.create(mongo_url);
    await db.open();
  }
}

Future<String> collect_user_info() async {
  var db = await mongo.Db.create(mg.mongo_url);
  await db.open();
  var collection = db.collection("user");
  var userDoc =
      await collection.findOne(mongo.where.eq("Email", lg.usermail)).toString();

  return userDoc;
}

Future<List<Map<String, dynamic>>> collect_info_properties() async {
  var db = await mongo.Db.create(mg.mongo_url);
  await db.open();
  var collection = db.collection("Property");
  var propertydata = await collection.find().toList();

  return propertydata;
}

Future<int> largest() async {
  var db = await mongo.Db.create(mg.mongo_url);
  await db.open();
  var collection = db.collection("Property");
  var largest_id_table =
      await collection.findOne(where.sortBy("id", descending: true));
  largest_id = (largest_id_table?['id'] as Int64).toInt();
  largest_id -= test;
  test++;
  print(largest_id);
  return largest_id;
}
