import 'package:app/domain/procedure_record_immutable.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:app/domain/procedure_immutable.dart';
import 'package:app/domain/procedure_summary.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/domain/procedure.dart';
import 'package:app/errors/failure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:collection';
import 'dart:io';


class SQLiteDbProvider {
  SQLiteDbProvider._();

  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static Database _database;


  Future<Database> get database async{
    if (_database != null) {
      return _database;
    }

    return await initDB();
  }


  initDB() async{
    //Directory documentsDirectory = await getApplicationDocumentsDirectory();
    Directory documentsDirectory = await getExternalStorageDirectory();
    String path = join(documentsDirectory.path, "time_tracker.db");
    return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
        onConfigure: (db) async{
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (Database db, int version) async {
            await db.execute('''
              CREATE TABLE procedure (
                  id   INTEGER PRIMARY KEY AUTOINCREMENT
                               NOT NULL,
                  name TEXT    NOT NULL UNIQUE,
                  type INTEGER NOT NULL DEFAULT 1
              )
            ''');

            await db.execute('''
              CREATE TABLE procedure_record (
                  id            INTEGER PRIMARY KEY AUTOINCREMENT
                                        NOT NULL,
                  procedure     INTEGER NOT NULL,
                  year          INTEGER NOT NULL,
                  month         INTEGER NOT NULL,
                  day           INTEGER NOT NULL,
                  week          INTEGER NOT NULL,
                  quantity      INTEGER,
                  start         INTEGER NOT NULL,
                  finish        INTEGER,
                  time_spent    INTEGER,
                  FOREIGN KEY (procedure) REFERENCES procedure (id)
              )
            ''');

            await db.execute('''
              CREATE INDEX year_month_day ON procedure_record (year, month, day)
            ''');

            await db.execute('''
              CREATE INDEX year_week ON procedure_record (year, week)
            ''');

            await db.execute('''
              INSERT INTO procedure(name, type) VALUES ('Přestávka', 0)
            ''');

            await db.execute('''
              INSERT INTO procedure(name) VALUES
                ('Střih vláken, kabelů a tubingů'), ('Střih vláken v primární izolaci'),
                ('Střih kabelů s velkým průměrem'), ('Střih vláken a tubingů do 0,5m'),
                ('Protahování vláken do tubingů do 1,1m'), ('Protahování vláken do tubingů do 3,1m'),
                ('Protahování vláken do tubingů do 6,1m'), ('Rozdělení konců duplex'),
                ('Zakracování délky'), ('Příprava kabelů leoni'), ('Příprava vícevláknových kabelů'),
                ('Příprava konců vlákno'), ('Příprava konců kabel'), ('Příprava konců ribon'),
                ('Příprava konců kabel + ribonizace'), ('Lepení keramika vlákno'),
                ('Lepení keramika kabel'), ('Lepení kapilára'), ('Lepení diamond + 1. středění'),
                ('Lepení kov'), ('Lepení MT 12'), ('Lepení MT 24'), ('Lepení HP'), ('Krimpování diamond'),
                ('Řezání vlákna ruční'), ('Řezání vlákna automat'), ('Zabroušení před laděním'),
                ('Řezání diamond'), ('Řezání F3000'), ('Řezání MT'), ('Ladění tunex'), ('Montáž vlákno FC, SC, MU'),
                ('Montáž vlákno a kabel E2000'), ('Montáž kabel FC, SC, MU'), ('Montážvlákno a kabel LC, ST'),
                ('Montáž MTP vlákno'), ('Montáž MTP kabel'), ('Montáž splitrů do RX'), ('Montáž splitrů do LGX'),
                ('Montáž splitrů do LGX - 1/32'), ('Montáž splitrů do LGX - 1/64'), ('Výroba FO-BOX - 6'),
                ('Výroba FO-BOX - 12'), ('Výroba cylindr'), ('Výroba FO-board'), ('Rozribonování do 0,5m'),
                ('Rozribonování do 1m'), ('Rozribonování do 2m'), ('Rozribonování do 3m'), ('Lepení čárových kódů + načítání'),
                ('Navíjení krátkých cívek do 100m'), ('Navíjení PVL nad 100m'), ('Montáž kazety PVL'), ('Konečná montáž PVL'),
                ('2. Středění diamond'), ('2. středění diamond 0,1dB'), ('Měření numerické apertury HP'),
                ('Měření úhlu HP'), ('Zabrušování kermika PC'), ('Zabrušování keramika LC, E2000 APC'),
                ('Zabrušování SC, FC APC'), ('Broušení ferule FORJ schleifring'), ('Zabrušování kapilár'), ('Zabrušování MT'), ('Zabrušování KOV'),
                ('Broušení kapilár 0,5mm'), ('Broušení kapilár jednochodka'), ('Broušení kapilár excentr'),
                ('Broušení keramika KAR.'), ('Broušení diamond KAR.'), ('Broušení MT/APC KAR.'), ('Broušení MT/PC excentr'),
                ('Broušení ker. ručně'), ('Broušení KOV ručně'), ('Broušení SMA/APC/PC'), ('Optická kontrola MOK, KOK'),
                ('Optická kontrola MT'), ('Montáž diamond'), ('Měření GEO'), ('Měření GEO MT'), ('Měření GEO + report'),
                ('Měření standart'), ('Měření nestandart vln. délky'), ('Měření MAP'), ('Měření MAP MTP 12'), ('Měření MAP MTP 24'),
                ('Měření MAP SM 12'), ('Měření MAP SM 24'), ('Focení čela ker. ferule'), ('Focení čela ferule/MT'), ('Balení'),
                ('Balení UHV'), ('Balení splitr'), ('Balení coupler'), ('Balení ribon radiall + opt. kontrola'), ('Příprava a zakrácení couplerů'),
                ('Navlékání couplerů do metal tubingu'), ('Montáž FC na metal tubing'), ('Zakládání do boxů na nápar'), ('Vyndávání z boxů po náparu'),
                ('Měření a zakracování luna'), ('Broušení AFC 2 plochy'), ('Broušení AFC 4 plochy'), ('Měření GEO AFC'),
                ('Optická kontrola pro planární tech.'), ('Měření mechanické délky FORJ'), ('Čístění v IPA'), ('Měření optické délky'),
                ('Perforace tubingu'), ('Lepení ferule do těla konektoru')
            ''');
        }
    );
  }


  Future<ResultObject<ProcedureImmutable>> insertProcedure(String name) async{
    ResultObject<ProcedureImmutable> result = ResultObject();
    try {
      final db = await database;

      Procedure procedure = Procedure(name);
      int id = await db.insert('procedure', procedure.toMap());
      procedure.id = id;
      result = ResultObject(procedure.toImmutable());

    } on DatabaseException catch(e) {
      if (e.isUniqueConstraintError()) {
        result.addErrorMessage('Akce již existuje');
      } else {
        result.addErrorMessage('Při ukládání došlo k chybě');
      }
    }

    return Future.value(result);
  }


  Future<ResultObject<void>> _saveProcedure(Procedure procedure, [Transaction tx]) async{
    ResultObject<void> result = ResultObject();
    try {
      final db = tx != null ? tx : await database;

      await db.update('procedure', procedure.toMap(), where: 'id = ?', whereArgs: [procedure.id]);

    } on DatabaseException catch(e) {
      if (e.isUniqueConstraintError()) {
        result.addErrorMessage('Akce již existuje');
      } else {
        result.addErrorMessage('Při ukládání záznamu došlo k chybě');
      }
    }

    return result;
  }


  Future<ResultObject<ProcedureImmutable>> updateProcedure(ProcedureImmutable procedure, String newName) async{
    ResultObject<ProcedureImmutable> result = ResultObject();
    try {
      final db = await database;

      var updatedProcedure = await db.transaction<ProcedureImmutable>((txn) async{
        var procedureSearch = await _getProcedureById(procedure.id, txn);
        if (procedureSearch.isFailure) {
          throw Failure(procedureSearch.lastMessage);
        }

        var procedureEntity = procedureSearch.result;
        procedureEntity.name = newName;

        var update = await _saveProcedure(procedureEntity, txn);
        if (update.isFailure) {
          throw Failure(update.lastMessage);
        }

        return procedureEntity.toImmutable();
      });
      result = ResultObject(updatedProcedure);

    } on Failure catch(e) {
      result.addErrorMessage(e.message);
    }

    return Future.value(result);
  }


  Future<ResultObject<ProcedureRecord>> _insertProcedureRecord(ProcedureRecord newRecord, [Transaction tx]) async{
    _checkProcedureIdentity(newRecord.procedure);

    ResultObject<ProcedureRecord> result = ResultObject();
    try {
      final db = tx != null ? tx : await database;

      int newId = await db.insert('procedure_record', newRecord.toMap());
      newRecord.id = newId;
      result = ResultObject(newRecord);

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při ukládání záznamu došlo k chybě');
    }

    return Future.value(result);
  }


  Future<ResultObject<void>> _saveProcedureRecord(ProcedureRecord record, [Transaction tx]) async{
    ResultObject<void> result = ResultObject();
    try {
      final db = tx != null ? tx : await database;

      await db.update('procedure_record', record.toMap(), where: 'id = ?', whereArgs: [record.id]);

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při ukládání záznamu došlo k chybě');
    }
    return Future.value(result);
  }


  Future<ResultObject<ProcedureRecordImmutable>> updateProcedureRecord(
    ProcedureRecordImmutable recordToUpdate,
    ProcedureImmutable newProcedure,
    int newQuantity
  ) async{
    ResultObject<ProcedureRecordImmutable> result = ResultObject();
    try {
      final db = await database;

      var record = await db.transaction<ProcedureRecordImmutable>((txn) async {
        var procedureRecordSearch = await _getProcedureRecordById(recordToUpdate.id, txn);
        if (procedureRecordSearch.isFailure) {
          throw Failure(procedureRecordSearch.lastMessage);
        }

        var procedureSearch = await _getProcedureById(newProcedure.id, txn);
        if (procedureSearch.isFailure) {
          throw Failure(procedureSearch.lastMessage);
        }

        var procedureRecordEntity = procedureRecordSearch.result;
        var procedureEntity = procedureSearch.result;

        procedureRecordEntity.updateRecord(procedureEntity, newQuantity);

        var update = await _saveProcedureRecord(procedureRecordEntity, txn);
        if (update.isFailure) {
          throw Failure(update.lastMessage);
        }

        return procedureRecordEntity.toImmutable();
      });
      result = ResultObject(record);

    } on Failure catch (e) {
      result.addErrorMessage(e.message);

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při ukládání záznamu došlo k chybě.');
    }

    return Future.value(result);
  }


  Future<ResultObject<void>> deleteProcedureRecord(ProcedureRecordImmutable record, [Transaction tx]) async{
    ResultObject<void> result = ResultObject();
    try {
      final db = tx != null ? tx : await database;

      db.delete('procedure_record', where: 'id = ?', whereArgs: [record.id]);
    } on DatabaseException catch (e) {
      result.addErrorMessage('Při odstraňování záznamu došlo k chybě.');
    }
    return Future.value(result);
  }


  Future<ResultObject<ProcedureRecordImmutable>> openProcedureRecord(ProcedureRecordImmutable record) async{
    ResultObject<ProcedureRecordImmutable> result = ResultObject();
    try {
      final db = await database;

      var openedRecord = await db.transaction<ProcedureRecordImmutable>((txn) async{
        var procedureRecordSearch = await _getProcedureRecordById(record.id, txn);
        if (procedureRecordSearch.isFailure) {
          throw Failure(procedureRecordSearch.lastMessage);
        }

        var procedureRecordEntity = procedureRecordSearch.result;
        procedureRecordEntity.openRecord();

        var update = await _saveProcedureRecord(procedureRecordEntity, txn);
        if (update.isFailure) {
          throw Failure(update.lastMessage);
        }

        return procedureRecordEntity.toImmutable();
      });

      result = ResultObject(openedRecord);

    } on Failure catch (e) {
      result.addErrorMessage(e.message);

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při otevírání záznamu došlo k chybě');
    }

    return Future.value(result);
  }


  Future<ResultObject<ProcedureRecordImmutable>> closeProcedureRecord(ProcedureRecordImmutable record, DateTime finishTime, int quantity) async {
    ResultObject<ProcedureRecordImmutable> result = ResultObject();
    try {
      final db = await database;

      var closedRecord = await db.transaction<ProcedureRecordImmutable>((txn) async{
        var procedureRecordSearch = await _getProcedureRecordById(record.id, txn);
        if (procedureRecordSearch.isFailure) {
          throw Failure(procedureRecordSearch.lastMessage);
        }

        var procedureRecordEntity = procedureRecordSearch.result;
        procedureRecordEntity.closeRecord(finishTime, quantity);

        var update = await _saveProcedureRecord(procedureRecordEntity, txn);
        if (update.isFailure) {
          throw Failure(update.lastMessage);
        }

        return procedureRecordEntity.toImmutable();
      });

      result = ResultObject(closedRecord);

    } on Failure catch (e) {
      result.addErrorMessage(e.message);

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při uzavírání záznamu došlo k chybě');
    }

    return Future.value(result);
  }


  Future<ResultObject<List<ProcedureImmutable>>> findAllProcedures() async{
    ResultObject<List<ProcedureImmutable>> result = ResultObject();
    List<ProcedureImmutable> procedures = List();
    try {
      final db = await database;

      var futureResults = db.rawQuery('''
        SELECT id as procedure_id, name as procedure_name, type as procedure_type
        FROM procedure
        ORDER BY name COLLATE LOCALIZED
      ''');
      var queryResults = await futureResults;
      queryResults.forEach((f) {
        procedures.add(Procedure.fromMap(f).toImmutable());
      });
      result = ResultObject(procedures);

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při získávání akcí došlo k chybě.');
    }

    return Future.value(result);
  }


  Future<ResultObject<Procedure>> _getProcedureById(int id, [Transaction tx]) async{
    ResultObject<Procedure> result = ResultObject();
    try {
      final db = tx != null ? tx : await database;

      var futureResult = db.rawQuery(
          '''SELECT p.id AS procedure_id, p.name AS procedure_name, p.type AS procedure_type
             FROM procedure p
             WHERE p.id = ?
       ''', [id]);
      var procedureResult = await futureResult;
      if (procedureResult.isNotEmpty) {
        result = ResultObject(Procedure.fromMap(procedureResult[0]));
      }

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při získávání záznamu došlo k chybě.');
    }

    return Future.value(result);
  }


  Future<ResultObject<List<ProcedureRecordImmutable>>> findAllProcedureRecords(int year, int month, int day) async{
    ResultObject<List<ProcedureRecordImmutable>> result = ResultObject();
    List<ProcedureRecordImmutable> procedureRecords = List<ProcedureRecordImmutable>();
    try {
      final db = await database;

      var futureResult = db.rawQuery(
          '''SELECT pr.*, p.id as procedure_id, p.name as procedure_name, p.type as procedure_type
           FROM procedure_record pr
           LEFT JOIN procedure p ON (p.id = pr.procedure)
           WHERE pr.year = ? AND pr.month = ? and pr.day = ?
           ORDER BY pr.id DESC''',
          [year, month, day]
      );
      var records = await futureResult;

      records.forEach((record) {
        procedureRecords.add(ProcedureRecord.fromMap(record).toImmutable());
      });
      result = ResultObject(procedureRecords);

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při získávání dat došlo k chybě.');
    }

    return Future.value(result);
  }


  Future<ResultObject<ProcedureRecord>> _getProcedureRecordById(int id, [Transaction tx]) async{
    ResultObject<ProcedureRecord> result = ResultObject();
    try {
      final db = tx != null ? tx : await database;

      var futureResult = db.rawQuery('''
        SELECT pr.*, p.id as procedure_id, p.name as procedure_name, p.type as procedure_type
        FROM procedure_record pr
        LEFT JOIN procedure p ON (p.id = pr.procedure)
        WHERE pr.id = ?
      ''', [id]);
      var prResult = await futureResult;
      if (prResult.isNotEmpty) {
        result = ResultObject(ProcedureRecord.fromMap(prResult[0]));
      }

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při získávání záznamů došlo k chybě');
    }

    return Future.value(result);
  }
  

  Future<ResultObject<Map<String, ProcedureRecordImmutable>>> startProcedureRecord(
    ProcedureRecordImmutable lastRecord,
    int lastProcedureQuantity,
    ProcedureImmutable procedure,
    DateTime start
  ) async{
    ResultObject<Map<String, ProcedureRecordImmutable>> result = ResultObject();
    try {
      final db = await database;

      var resultMap = await db.transaction<Map<String, ProcedureRecordImmutable>>((txn) async {
        Map<String, ProcedureRecordImmutable> result = Map();
        result['lastRecord'] = null;
        if (lastRecord != null) {
          var lastRecordSearch = await _getProcedureRecordById(lastRecord.id, txn);
          if (lastRecordSearch.isFailure) {
            throw Failure('Záznam s ID#${lastRecord.id} nebyl nalezen.');
          }

          ProcedureRecord lastRecordEntity = lastRecordSearch.result;
          lastRecordEntity.closeRecord(start, lastProcedureQuantity);

          var procedureRecordUpdate = await _saveProcedureRecord(lastRecordEntity, txn);
          if (procedureRecordUpdate.isFailure) {
            throw Failure('Při úpravě záznamu došlo k chybě.');
          }
          result['lastRecord'] = lastRecordEntity.toImmutable();
        }

        var procedureSearch = await _getProcedureById(procedure.id, txn);
        if (procedureSearch.isFailure) {
          throw Failure('Akce s ID#${procedure.id} nebyla nalezena');
        }

        Procedure procedureEntity = procedureSearch.result;
        var newRecordInsertion = await _insertProcedureRecord(ProcedureRecord(procedureEntity, start), txn);
        if (newRecordInsertion.isFailure) {
          throw Failure('Při ukládání záznamu došlo k chybě');
        }

        result['newRecord'] = newRecordInsertion.result.toImmutable();
        return result;
      });
      result = ResultObject(resultMap);

    } on Failure catch (e) {
      result.addErrorMessage(e.message);
    }

    return Future.value(result);
  }


  Future<ResultObject<List<ProcedureSummary>>> getDaySummary(int year, int month, int day) async{
    ResultObject<List<ProcedureSummary>> result = ResultObject();
    try {
      final db = await database;

      var futureResult = db.rawQuery('''
        SELECT p.id, p.name, p.type, SUM(pr.quantity) AS quantity, SUM(pr.time_spent) AS time_spent
        FROM procedure_record pr
        LEFT JOIN procedure p ON (p.id = pr.procedure)
        WHERE pr.year = ? AND pr.month = ? AND pr.day = ?
        GROUP BY p.id
        ORDER BY p.id ASC
      ''', [year, month, day]);
      var rawSummaryList = await futureResult;

      List<ProcedureSummary> procedureSummaries = List();
      rawSummaryList.forEach((f) {
        if (f['time_spent'] == null) return;
        procedureSummaries.add(ProcedureSummary.fromMap(f));
      });
      result = ResultObject(procedureSummaries);

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při získávání záznamů došlo k chybě');
    }

    return result;
  }


  Future<ResultObject<List<ProcedureSummary>>> getWeekSummary(int year, int week) async{
    ResultObject<List<ProcedureSummary>> result = ResultObject();
    try {
      final db = await database;

      var futureResult = db.rawQuery('''
        SELECT p.id, p.name, p.type, SUM(pr.quantity) AS quantity, SUM(pr.time_spent) AS time_spent
        FROM procedure_record pr
        LEFT JOIN procedure p ON (p.id = pr.procedure)
        WHERE pr.year = ? AND pr.week = ?
        GROUP BY p.id
        ORDER BY p.id ASC
      ''', [year, week]);
      var rawSummaryList = await futureResult;

      List<ProcedureSummary> procedureSummaries = List();
      rawSummaryList.forEach((f) {
        if (f['time_spent'] == null) return;
        procedureSummaries.add(ProcedureSummary.fromMap(f));
      });
      result = ResultObject(procedureSummaries);

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při získávání záznamů došlo k chybě');
    }

    return result;
  }


  Future<ResultObject<UnmodifiableListView<DateTime>>> findHistoryData(int offset, [int limit = 15]) async{
    ResultObject<UnmodifiableListView<DateTime>> result = ResultObject();
    try {
      final db = await database;

      var futureResult = db.rawQuery('''
        SELECT DISTINCT pr.year, pr.month, pr.day
        FROM procedure_record pr
        ORDER BY pr.year DESC, pr.month DESC, pr.day DESC
        LIMIT ?
        OFFSET ?
      ''', [limit, offset]);
      var dates = await futureResult;
      List<DateTime> data = List();
      dates.forEach((row) {
        data.add(DateTime.utc(
            row['year'],
            row['month'],
            row['day'],
            0,
            0,
            0,
            0,
            0));
      });
      result = ResultObject(UnmodifiableListView(data));

    } on DatabaseException catch (e) {
      result.addErrorMessage('Při získávání záznamů došlo k chybě');
    }

    return Future.value(result);
  }


  // -----


  void _checkProcedureIdentity(Procedure procedure) {
    if (procedure.id == null) {
      throw ArgumentError('Procedure argument needs to have set an identifier');
    }
  }
}