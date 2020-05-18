import 'package:app/exceptions/entity_identity_exception.dart';
import 'package:app/extensions/datetime_extension.dart';
import 'package:app/domain/procedure_summary.dart';
import 'package:app/domain/procedure_record.dart';
import 'package:app/utils/result_object/result_object.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/domain/procedure.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "app.db");
    return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {
            await db.execute('PRAGMA foreign_keys = ON');

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
                ('Ladění tunex'), ('Řezání vlákna ruční'), ('Focení čela ker. ferule'),
                ('Lepení keramika vlákno'), ('Lepení keramika kabel'), ('Příprava konců kabel'),
                ('Protahování vláken do tubingů do 3,1m')
            ''');

            /*await db.execute('''
              INSERT INTO procedure(name) VALUES
                ('Příprava vláken'), ('Příprava kabelů'), ('Rezání vlákna ruční'),
                ('Řezání vlákna automat'), ('Zabrušování PC'), ('Zabrušování APC'),
                ('Lepení ker.'), ('Focení čela MT ferule'), ('Měření nestandart'),
                ('Měření standart'), ('Balení kabelů'), ('Balení couplerů')
            ''');*/

            /*var today = DateTime.now();
            var week = today.getWeek();
            await db.execute('''
              INSERT INTO procedure_record(procedure, year, month, day, week, quantity, start, finish, time_spent)
              VALUES
              (3, ${today.year}, ${today.month}, 15, $week, 10, ${DateTime(today.year, today.month, 15, 6, 0, 0).millisecondsSinceEpoch}, ${DateTime(today.year, today.month, 15, 7, 0, 0).millisecondsSinceEpoch}, 3600),
              (2, ${today.year}, ${today.month}, 15, $week, 10, ${DateTime(today.year, today.month, 15, 7, 0, 0).millisecondsSinceEpoch}, ${DateTime(today.year, today.month, 15, 8, 0, 0).millisecondsSinceEpoch}, 3600),
              (7, ${today.year}, ${today.month}, ${today.day}, $week, 10, ${DateTime(today.year, today.month, today.day, 8, 0, 0).millisecondsSinceEpoch}, ${DateTime(today.year, today.month, today.day, 9, 0, 0).millisecondsSinceEpoch}, 3600),
              (3, ${today.year}, ${today.month}, ${today.day}, $week, 10, ${DateTime(today.year, today.month, today.day, 9, 0, 0).millisecondsSinceEpoch}, ${DateTime(today.year, today.month, today.day, 10, 0, 0).millisecondsSinceEpoch}, 3600),
              (1, ${today.year}, ${today.month}, ${today.day}, $week, NULL, ${DateTime(today.year, today.month, today.day, 10, 00, 0).millisecondsSinceEpoch}, ${DateTime(today.year, today.month, today.day, 10, 30, 0).millisecondsSinceEpoch}, 1800),
              (5, ${today.year}, ${today.month}, ${today.day}, $week, 10, ${DateTime(today.year, today.month, today.day, 10, 30, 0).millisecondsSinceEpoch}, ${DateTime(today.year, today.month, today.day, 11, 30, 0).millisecondsSinceEpoch}, 3600),
              (6, ${today.year}, ${today.month}, ${today.day}, $week, 10, ${DateTime(today.year, today.month, today.day, 11, 30, 0).millisecondsSinceEpoch}, ${DateTime(today.year, today.month, today.day, 12, 30, 0).millisecondsSinceEpoch}, 3600),
              (7, ${today.year}, ${today.month}, ${today.day}, $week, 10, ${DateTime(today.year, today.month, today.day, 12, 30, 0).millisecondsSinceEpoch}, ${DateTime(today.year, today.month, today.day, 13, 30, 0).millisecondsSinceEpoch}, 3600),
              (8, ${today.year}, ${today.month}, ${today.day}, $week, NULL, ${DateTime(today.year, today.month, today.day, 13, 30, 0).millisecondsSinceEpoch}, NULL, NULL)
            ''');*/

        }
    );
  }


  Future<ResultObject<Procedure>> insertProcedure(Procedure procedure) async{
    if (procedure.id != null) throw ArgumentError('Argument must be newly created!');
    final db = await database;
    ResultObject<Procedure> result = ResultObject();
    try {
      int id = await db.insert('procedure', procedure.toMap());
      procedure.id = id;
      result = ResultObject(procedure);

    } on DatabaseException catch(e) {
      if (e.isUniqueConstraintError())
        result.addErrorMessage('Akce již existuje');
      else
        result.addErrorMessage('Při ukládání došlo k chybě');
    } catch (e) {
      result.addErrorMessage('Požadavek nelze dokončit');
    }

    return Future.value(result);
  }


  Future<ResultObject<Procedure>> updateProcedure(Procedure procedure) async{
    final db = await database;
    _checkProcedureIdentity(procedure);

    ResultObject<Procedure> result = ResultObject(procedure);
    try {
      await db.update('procedure', procedure.toMap(), where: 'id = ?', whereArgs: [procedure.id]);

    } on DatabaseException catch(e) {
      if (e.isUniqueConstraintError())
        result.addErrorMessage('Akce již existuje');
      else
        result.addErrorMessage('Při ukládání došlo k chybě');
    } catch (e) {
      result.addErrorMessage('Požadavek nelze dokončit');
    }

    return Future.value(result);
  }


  Future<ProcedureRecord> insertProcedureRecord(Procedure procedure, DateTime start, [Transaction tx]) async{
    final db = tx != null ? tx : await database;
    _checkProcedureIdentity(procedure);

    ProcedureRecord newRecord = ProcedureRecord(procedure, start);
    int newId = await db.insert('procedure_record', newRecord.toMap());
    newRecord.id = newId;
    return Future.value(newRecord);
  }


  void updateProcedureRecord(ProcedureRecord record, [Transaction tx]) async{
    final db = tx != null ? tx : await database;
    db.update('procedure_record', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }


  void deleteProcedureRecord(ProcedureRecord record, [Transaction tx]) async{
    final db = tx != null ? tx : await database;
    db.delete('procedure_record', where: 'id = ?', whereArgs: [record.id]);
  }


  Future<List<Procedure>> findAllProcedures() async{
    final db = await database;

    List<Procedure> procedures = List<Procedure>();
    var futureResults = db.rawQuery('''
      SELECT id as procedure_id, name as procedure_name, type as procedure_type 
      FROM procedure
      ORDER BY name
    ''');
    var results = await futureResults;
    results.forEach((f) {
      procedures.add(Procedure.fromMap(f));
    });

    return Future.value(procedures);
  }


  Future<List<ProcedureRecord>> findAllProcedureRecords(int year, int month, int day) async{
    final db = await database;

    List<ProcedureRecord> procedures = List<ProcedureRecord>();
    var futureResult = db.rawQuery(
        '''SELECT pr.*, p.id as procedure_id, p.name as procedure_name, p.type as procedure_type
           FROM procedure_record pr
           LEFT JOIN procedure p ON (p.id = pr.procedure)
           WHERE pr.year = ? AND pr.month = ? and pr.day = ?
           ORDER BY pr.id DESC''',
        [year, month, day]
    );
    var result = await futureResult;
    result.forEach((f) {
      procedures.add(ProcedureRecord.fromMap(f));
    });

    return procedures;
  }


  Future<ProcedureRecord> getProcedureRecordById(int id) async{
    final db = await database;

    var futureResult = db.rawQuery('''
      SELECT pr.*, p.id as procedure_id, p.name as procedure_name, p.type as procedure_type
      FROM procedure_record pr
      LEFT JOIN procedure p ON (p.id = pr.procedure)
      WHERE pr.id = ?
      LIMIT 1
    ''', [id]);
    var result = await futureResult;
    if (result.isEmpty) return Future.value(null);
    return Future.value(ProcedureRecord.fromMap(result[0]));
  }
  
  
  Future<ProcedureRecord> getLastProcedureRecord(int year, int month, int day, [Transaction tx]) async{
    final db = tx != null ? tx : await database;

    var futureResult = db.rawQuery(
        '''SELECT pr.*, p.id as procedure_id, p.name as procedure_name, p.type as procedure_type
            FROM procedure_record pr
            LEFT JOIN procedure p ON (p.id = pr.procedure)
            WHERE pr.year = ? AND pr.month = ? and pr.day = ?
            ORDER BY pr.id DESC
            LIMIT 1''',
      [year, month, day]
    );
    var result = await futureResult;
    if (result.isEmpty) return Future.value(null);

    return Future.value(ProcedureRecord.fromMap(result[0]));
  }


  void deleteLastProcedureRecord(int year, int month, int day) async{
    final db = await database;
    await db.transaction((txn) async{
      txn.rawQuery('''
        DELETE FROM procedure_record
        WHERE id = (
            SELECT id FROM procedure_record 
            WHERE year = ? AND month = ? AND day = ?
            ORDER BY id DESC
            LIMIT 1
        )
      ''', [year, month, day]);
      txn.rawQuery('''
        UPDATE procedure_record
        SET finish = NULL, time_spent = NULL, quantity = NULL
        WHERE id = id = (
            SELECT id FROM procedure_record 
            WHERE year = ? AND month = ? AND day = ?
            ORDER BY id DESC
            LIMIT 1
        ) 
      ''', [year, month, day]);
    });
  }


  Future<ProcedureRecord> startProcedureRecord(ProcedureRecord lastRecord, int lastProcedureQuantity, Procedure procedure, DateTime start) async{
    final db = await database;
    var newRecord = await db.transaction<ProcedureRecord>((txn) async{
      if (lastRecord != null) {
        lastRecord.closeRecord(start, lastProcedureQuantity);
        await updateProcedureRecord(lastRecord, txn);
      }

      ProcedureRecord newRecord = await insertProcedureRecord(procedure, start, txn);
      return Future.value(newRecord);
    });

    return Future.value(newRecord);
  }


  Future<List<ProcedureSummary>> getDaySummary(int year, int month, int day) async{
    final db = await database;
    var futureResult = db.rawQuery('''
      SELECT p.id, p.name, SUM(pr.quantity) AS quantity, SUM(pr.time_spent) AS time_spent
      FROM procedure_record pr
      LEFT JOIN procedure p ON (p.id = pr.procedure)
      WHERE pr.year = ? AND pr.month = ? AND pr.day = ?
      GROUP BY p.id
    ''', [year, month, day]);
    var result = await futureResult;

    List<ProcedureSummary> summary = List<ProcedureSummary>();
    result.forEach((f) {
      if (f['time_spent'] == null || f['quantity'] == null) return;
      summary.add(ProcedureSummary.fromMap(f));
    });

    return Future.value(summary);
  }


  Future<List<ProcedureSummary>> getWeekSummary(int year, int week) async{
    final db = await database;
    var futureResult = db.rawQuery('''
      SELECT p.id, p.name, SUM(pr.quantity) AS quantity, SUM(pr.time_spent) AS time_spent
      FROM procedure_record pr
      LEFT JOIN procedure p ON (p.id = pr.procedure)
      WHERE pr.year = ? AND pr.week = ?
      GROUP BY p.id
    ''', [year, week]);
    var result = await futureResult;

    List<ProcedureSummary> summary = List<ProcedureSummary>();
    result.forEach((f) {
      if (f['time_spent'] == null || f['quantity'] == null) return;
      summary.add(ProcedureSummary.fromMap(f));
    });

    return Future.value(summary);
  }


  // -----


  void _checkProcedureIdentity(Procedure procedure) {
    if (procedure.id == null) {
      throw ArgumentError('Procedure argument needs to have set an identifier');
    }
  }
}