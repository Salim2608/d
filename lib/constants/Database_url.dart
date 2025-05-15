import 'dart:ffi';

import 'package:darlink/models/user_model.dart';
import 'package:darlink/modules/navigation/home_screen.dart';
import 'package:flutter/rendering.dart';
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



  static Future<String> collect_user_info() async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("user");
    var userDoc =
        collection.findOne(mongo.where.eq("Email", lg.usermail)).toString();

    return userDoc;
  }

  static Future<List<Map<String, dynamic>>> collect_info_properties() async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("Property");
    var propertydata =
        await collection.find(where.eq('Approve', true)).toList();
    return propertydata;
  }

  static dynamic collect_info_properties_admin() async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("Property");
    var propertydata = await collection.find().toList();
    return propertydata;
  }


  static Future<List<Map<String, dynamic>>>
      collect_info_properties_whishlist() async {
    var db = await mongo.Db.create(mg.mongo_url);
    try {
      await db.open();
      var collection = db.collection("Property");
      var userCollection = db.collection("user");

      // Find the user
      var specificUser = await userCollection
          .findOne(mongo.where.eq("Email", lg.usermail));

      // Get whishlist IDs
      var whishlistIds = specificUser?["whishlist"];

      var whishlist = await collection.find({
        "ID": {"\$in": whishlistIds}
      }).toList();

      print(whishlist.toString());
      print(
          "---------------------------------------------------------------------");

      return whishlist;
    } finally {
      await db.close();
    }
  }

  static Future<int> largest() async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("Property");
    var largest_id_table =
        await collection.findOne(where.sortBy("ID", descending: true));
    largest_id = largest_id_table?['ID'] as int? ?? 1;
    return largest_id;
  }
  static Future<String?> phone_nb_by_user(String username) async {
    var db = await mongo.Db.create(mg.mongo_url);
    await db.open();
    var collection = db.collection("user");
var user_data =await collection.findOne(mongo.where.eq("name", username));
var user_phonenb = user_data?['phone'].toString();
    return user_phonenb;
  }

}
